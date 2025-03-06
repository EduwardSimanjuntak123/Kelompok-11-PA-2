package controllers

import (
	"log"
	"net/http"
	"rental-backend/config"
	"rental-backend/models"
	"github.com/gin-gonic/gin"
)

// Fungsi untuk mengonfirmasi booking oleh vendor
func ConfirmBooking(c *gin.Context) {
	id := c.Param("id")

	// Ambil user_id dari token JWT yang merupakan ID vendor
	userID, exists := c.Get("user_id")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Vendor tidak terautentikasi"})
		return
	}

	var booking models.Booking

	// Cari booking berdasarkan ID dan pastikan statusnya "pending"
	if err := config.DB.Where("id = ?", id).First(&booking).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Booking tidak ditemukan"})
		return
	}

	// Pastikan hanya booking dengan status "pending" yang dapat dikonfirmasi
	if booking.Status != "pending" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Hanya booking dengan status 'pending' yang dapat dikonfirmasi"})
		return
	}

	// Log untuk memastikan ID yang dibandingkan
	log.Printf("Booking VendorID: %d", booking.VendorID)
	log.Printf("Authenticated UserID: %d", userID)

	// Cari vendor yang terkait dengan user_id (vendor_id)
	var vendor models.Vendor
	if err := config.DB.Where("user_id = ?", userID).First(&vendor).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Vendor tidak ditemukan"})
		return
	}

	// Pastikan vendor yang mengonfirmasi adalah pemilik motor yang sesuai
	if booking.VendorID != vendor.ID {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Anda tidak memiliki izin untuk mengonfirmasi booking ini"})
		return
	}

	// Ubah status booking menjadi "confirmed"
	if err := config.DB.Model(&models.Booking{}).Where("id = ?", id).Update("status", "confirmed").Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal mengonfirmasi booking"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Booking berhasil dikonfirmasi"})
}



// Reject Booking
func RejectBooking(c *gin.Context) {
	id := c.Param("id")

	// Ambil user_id dari token JWT yang merupakan ID vendor
	userID, exists := c.Get("user_id")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Vendor tidak terautentikasi"})
		return
	}

	var booking models.Booking

	// Cari booking berdasarkan ID dan pastikan statusnya "pending"
	if err := config.DB.Where("id = ?", id).First(&booking).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Booking tidak ditemukan"})
		return
	}

	// Pastikan hanya booking dengan status "pending" yang dapat dikonfirmasi
	if booking.Status != "pending" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Hanya booking dengan status 'pending' yang dapat ditolak"})
		return
	}

	// Log untuk memastikan ID yang dibandingkan
	log.Printf("Booking VendorID: %d", booking.VendorID)
	log.Printf("Authenticated UserID: %d", userID)

	// Cari vendor yang terkait dengan user_id (vendor_id)
	var vendor models.Vendor
	if err := config.DB.Where("user_id = ?", userID).First(&vendor).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Vendor tidak ditemukan"})
		return
	}

	// Pastikan vendor yang mengonfirmasi adalah pemilik motor yang sesuai
	if booking.VendorID != vendor.ID {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Anda tidak memiliki izin untuk menolak booking ini"})
		return
	}

	// Ubah status booking menjadi "confirmed"
	if err := config.DB.Model(&models.Booking{}).Where("id = ?", id).Update("status", "rejected").Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal mmenolak booking"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Booking berhasil ditolak"})
}

func GetVendorBookings(c *gin.Context) {
	// Ambil user_id dari token JWT
	userID, exists := c.Get("user_id")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Vendor tidak terautentikasi"})
		return
	}

	// Cari vendor berdasarkan user_id
	var vendor models.Vendor
	if err := config.DB.Where("user_id = ?", userID).First(&vendor).Error; err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Vendor tidak ditemukan"})
		return
	}

	// Ambil status dari query parameter
	status := c.DefaultQuery("status", "") // Jika tidak ada status, set ke string kosong

	// Validasi status (optional: Anda bisa memvalidasi apakah status yang diterima valid)
	validStatuses := []string{"pending", "confirmed", "canceled", "completed", "rejected"}
	isValidStatus := false
	for _, s := range validStatuses {
		if status == s {
			isValidStatus = true
			break
		}
	}

	// Jika status tidak valid
	if status != "" && !isValidStatus {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Status tidak valid"})
		return
	}

	var bookings []models.Booking

	// Cari booking berdasarkan status dan vendor_id yang terautentikasi
	if status == "" {
		// Jika status tidak diberikan, ambil semua booking untuk vendor tersebut
		if err := config.DB.Where("vendor_id = ?", vendor.ID).Find(&bookings).Error; err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal mendapatkan booking"})
			return
		}
	} else {
		// Jika status diberikan, cari booking berdasarkan status dan vendor_id
		if err := config.DB.Where("vendor_id = ? AND status = ?", vendor.ID, status).Find(&bookings).Error; err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal mendapatkan booking"})
			return
		}
	}

	c.JSON(http.StatusOK, bookings)
}
