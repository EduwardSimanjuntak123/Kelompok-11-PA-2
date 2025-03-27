package controllers

import (
	"net/http"
	"rental-backend/config"
	"rental-backend/models"
	"strconv"
	"time"

	"github.com/gin-gonic/gin"
)

func CreateReview(c *gin.Context) {
	// Ambil booking_id dari parameter URL
	bookingIDStr := c.Param("id")
	bookingID, err := strconv.ParseUint(bookingIDStr, 10, 64)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Booking ID tidak valid"})
		return
	}

	// Struct input hanya untuk rating dan review
	var input struct {
		Rating int    `json:"rating" binding:"required,min=1,max=5"`
		Review string `json:"review"`
	}

	// Validasi input JSON
	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Ambil user_id dari token (customer)
	userID, exists := c.Get("user_id")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "User tidak terautentikasi"})
		return
	}

	// Cek apakah booking tersebut milik customer yang sedang login
	var booking models.Booking
	if err := config.DB.Where("id = ? AND customer_id = ?", bookingID, userID).First(&booking).Error; err != nil {
		c.JSON(http.StatusForbidden, gin.H{"error": "Booking tidak ditemukan atau bukan milik Anda"})
		return
	}

	// Pastikan status booking adalah "completed"
	if booking.Status != "completed" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Anda hanya bisa memberikan ulasan untuk booking yang sudah selesai"})
		return
	}

	// Pastikan customer belum memberikan review untuk booking ini
	var existingReview models.Review
	if err := config.DB.Where("booking_id = ?", bookingID).First(&existingReview).Error; err == nil {
		c.JSON(http.StatusConflict, gin.H{"error": "Anda sudah memberikan ulasan untuk booking ini"})
		return
	}

	// Buat review baru
	review := models.Review{
		BookingID:  uint(bookingID),
		CustomerID: userID.(uint),
		MotorID:    booking.MotorID,
		VendorID:   booking.VendorID,
		Rating:     float32(input.Rating),
		Review:     input.Review,
		CreatedAt:  time.Now(),
	}

	// Simpan review ke database
	if err := config.DB.Create(&review).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal menyimpan review"})
		return
	}

	// Update rata-rata rating vendor berdasarkan review-review yang ada
	var avgVendorRating float32
	config.DB.Table("reviews").
		Select("COALESCE(AVG(rating), 0)").
		Where("vendor_id = ?", booking.VendorID).
		Scan(&avgVendorRating)
	config.DB.Model(&models.Vendor{}).Where("id = ?", booking.VendorID).Update("rating", avgVendorRating)

	// Update rata-rata rating motor berdasarkan review-review yang ada
	var avgMotorRating float32
	config.DB.Table("reviews").
		Select("COALESCE(AVG(rating), 0)").
		Where("motor_id = ?", booking.MotorID).
		Scan(&avgMotorRating)
	config.DB.Model(&models.Motor{}).Where("id = ?", booking.MotorID).Update("rating", avgMotorRating)

	c.JSON(http.StatusOK, gin.H{
		"message":            "Review berhasil ditambahkan",
		"new_vendor_rating":  avgVendorRating,
		"new_motor_rating":   avgMotorRating,
	})
}

func GetVendorReviews(c *gin.Context) {
	// Ambil user_id dari token JWT
	userID, exists := c.Get("user_id")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Vendor tidak terautentikasi"})
		return
	}

	// Cari record vendor berdasarkan user_id
	var vendor models.Vendor
	if err := config.DB.Where("user_id = ?", userID).First(&vendor).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Vendor tidak ditemukan"})
		return
	}

	// Ambil semua ulasan (reviews) yang memiliki VendorID sesuai vendor
	var reviews []models.Review
	if err := config.DB.
		Preload("Customer"). // Memuat data customer (jika ada)
		Preload("Motor").    // Memuat data motor yang diulas
		Where("vendor_id = ?", vendor.ID).
		Find(&reviews).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal mengambil data ulasan", "details": err.Error()})
		return
	}

	c.JSON(http.StatusOK, reviews)
}


