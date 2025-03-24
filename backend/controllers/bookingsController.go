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
	status := c.DefaultQuery("status", "")

	// Validasi status
	validStatuses := []string{"pending", "confirmed", "rejected", "canceled", "completed"}
	isValidStatus := false
	for _, s := range validStatuses {
		if status == s {
			isValidStatus = true
			break
		}
	}

	if status != "" && !isValidStatus {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Status tidak valid"})
		return
	}

	var bookings []models.Booking

	// Query bookings berdasarkan vendor_id dan status
	query := config.DB.Where("vendor_id = ?", vendor.ID).
		Preload("Customer", "id IS NOT NULL AND name IS NOT NULL"). // Pastikan nama customer valid
		Preload("Motor", "id IS NOT NULL AND name IS NOT NULL")     // Pastikan nama motor valid

	if status != "" {
		query = query.Where("status = ?", status)
	}

	if err := query.Find(&bookings).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal mendapatkan booking"})
		return
	}

	// Format response
	var response []map[string]interface{}

	for _, booking := range bookings {
		customerName := ""
		motorName := ""

		// Cek apakah data Customer ada
		if booking.Customer != nil && booking.Customer.Name != "" {
			customerName = booking.Customer.Name
		} else {
			// Query ulang jika data customer kosong
			var customer models.User
			if err := config.DB.Select("name").Where("id = ?", booking.CustomerID).First(&customer).Error; err == nil {
				customerName = customer.Name
			}
		}

		// Cek apakah data Motor ada
		if booking.Motor != nil && booking.Motor.Name != "" {
			motorName = booking.Motor.Name
		} else {
			// Query ulang jika data motor kosong
			var motor models.Motor
			if err := config.DB.Select("name").Where("id = ?", booking.MotorID).First(&motor).Error; err == nil {
				motorName = motor.Name
			}
		}

		// Hitung total harga
		totalPrice := booking.Motor.Price * float64(booking.GetDurationDays())

		bookingData := map[string]interface{}{
			"id":              booking.ID,
			"customer_name":   customerName, // Dipastikan tidak kosong
			"booking_date":    booking.BookingDate.Format("2006-01-02"),
			"start_date":      booking.StartDate.Format("2006-01-02"),
			"end_date":        booking.EndDate.Format("2006-01-02"),
			"status":          booking.Status,
			"message":         "Booking berhasil diambil",
			"pickup_location": booking.PickupLocation,
			"motor": map[string]interface{}{
				"id":            booking.Motor.ID,
				"name":          motorName, // Dipastikan tidak kosong
				"brand":         booking.Motor.Brand,
				"model":         booking.Motor.Model,
				"year":          booking.Motor.Year,
				"price_per_day": booking.Motor.Price,
				"total_price":   totalPrice,
			},
		}

		response = append(response, bookingData)
	}

	c.JSON(http.StatusOK, response)
}
