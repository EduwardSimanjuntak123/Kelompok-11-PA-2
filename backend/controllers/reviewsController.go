package controllers

import (
	"net/http"
	"rental-backend/config"
	"rental-backend/models"
	"time"

	"github.com/gin-gonic/gin"
)

func CreateReview(c *gin.Context) {
	var input struct {
		BookingID uint   `json:"booking_id" binding:"required"`
		Rating    int    `json:"rating" binding:"required,min=1,max=5"`
		Review    string `json:"review"`
	}

	// Validasi input JSON
	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Ambil user_id dari token
	userID, exists := c.Get("user_id")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "User not authenticated"})
		return
	}

	// Cek apakah booking milik customer yang sedang login
	var booking models.Booking
	if err := config.DB.Where("id = ? AND customer_id = ?", input.BookingID, userID).First(&booking).Error; err != nil {
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
	if err := config.DB.Where("booking_id = ?", input.BookingID).First(&existingReview).Error; err == nil {
		c.JSON(http.StatusConflict, gin.H{"error": "Anda sudah memberikan ulasan untuk booking ini"})
		return
	}

	// Buat review baru
	review := models.Review{
		BookingID:  input.BookingID,
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

	// 🔽 **Update rata-rata rating vendor**
	var avgRating float32
	config.DB.Table("reviews").Select("COALESCE(AVG(rating), 0)").Where("vendor_id = ?", booking.VendorID).Scan(&avgRating)

	// Simpan perubahan rating vendor ke database
	config.DB.Model(&models.Vendor{}).Where("id = ?", booking.VendorID).Update("rating", avgRating)

	c.JSON(http.StatusOK, gin.H{"message": "Review berhasil ditambahkan", "new_vendor_rating": avgRating})
}
