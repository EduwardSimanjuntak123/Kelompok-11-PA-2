package controllers

import (
	"log"
	"net/http"
	"rental-backend/config"
	"rental-backend/models"
	"strconv"
	"strings"
	"time"

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

	var bookings []models.Booking

	// Query bookings berdasarkan vendor_id dan preload relasi Motor
	query := config.DB.Where("vendor_id = ?", vendor.ID).
		Preload("Motor")

	if err := query.Find(&bookings).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal mendapatkan booking"})
		return
	}

	// Base URL untuk gambar
	baseURL := "http://localhost:8080"

	// Format respons
	var response []map[string]interface{}
	for _, booking := range bookings {
		// Ambil langsung dari kolom customer_name di tabel bookings
		customerName := booking.CustomerName

		// Data motor
		motorData := map[string]interface{}{
			"id":            nil, // Default jika motor tidak ada
			"name":          "Tidak tersedia",
			"brand":         "Tidak tersedia",
			"model":         "Tidak tersedia",
			"year":          0,
			"price_per_day": 0,
			"total_price":   0,
			"image":         "https://via.placeholder.com/150",
		}

		if booking.Motor != nil {
			motorData = map[string]interface{}{
				"id":            booking.Motor.ID,
				"name":          booking.Motor.Name,
				"brand":         booking.Motor.Brand,
				"model":         booking.Motor.Model,
				"year":          booking.Motor.Year,
				"price_per_day": booking.Motor.Price,
				"total_price":   booking.Motor.Price * float64(booking.GetDurationDays()),
				"image": func() string {
					if booking.Motor.Image != "" {
						if strings.HasPrefix(booking.Motor.Image, "http") {
							return booking.Motor.Image
						}
						return baseURL + booking.Motor.Image
					}
					return "https://via.placeholder.com/150"
				}(),
			}
		}

		bookingData := map[string]interface{}{
			"id":              booking.ID,
			"customer_name":   customerName,
			"booking_date":    booking.BookingDate,
			"start_date":      booking.StartDate,
			"end_date":        booking.EndDate,
			"status":          booking.Status,
			"message":         "Booking berhasil diambil",
			"pickup_location": booking.PickupLocation,
			"motor":           motorData,
		}

		response = append(response, bookingData)
	}

	c.JSON(http.StatusOK, response)
}


func GetCustomerBookings(c *gin.Context) {
	// Ambil user_id dari token JWT
	userID, exists := c.Get("user_id")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Customer tidak terautentikasi"})
		return
	}

	var bookings []models.Booking
	// Query booking berdasarkan customer_id dan preload data Motor
	if err := config.DB.
		Where("customer_id = ?", userID).
		Preload("Motor", "id IS NOT NULL AND name IS NOT NULL").
		Find(&bookings).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal mendapatkan data booking"})
		return
	}

	// Base URL untuk gambar
	baseURL := "http://localhost:8080"

	// Format respons
	var response []map[string]interface{}
	for _, booking := range bookings {
		motorData := map[string]interface{}{}
		if booking.Motor != nil {
			motorData = map[string]interface{}{
				"id":            booking.Motor.ID,
				"name":          booking.Motor.Name,
				"brand":         booking.Motor.Brand,
				"model":         booking.Motor.Model,
				"year":          booking.Motor.Year,
				"price_per_day": booking.Motor.Price,
				"total_price":   booking.Motor.Price * float64(booking.GetDurationDays()),
				"image": func() string {
					if booking.Motor.Image != "" {
						if strings.HasPrefix(booking.Motor.Image, "http") {
							return booking.Motor.Image
						}
						return baseURL + booking.Motor.Image
					}
					return "https://via.placeholder.com/150"
				}(),
			}
		}

		bookingData := map[string]interface{}{
			"id":              booking.ID,
			"booking_date":    booking.BookingDate,
			"start_date":      booking.StartDate,
			"end_date":        booking.EndDate,
			"status":          booking.Status,
			"pickup_location": booking.PickupLocation,
			"motor":           motorData,
		}

		response = append(response, bookingData)
	}

	c.JSON(http.StatusOK, response)
}


func CreateManualBooking(c *gin.Context) {
	// Ambil data teks dari form-data
	motorIDStr := c.PostForm("motor_id")
	customerName := c.PostForm("customer_name")
	startDateStr := c.PostForm("start_date")
	endDateStr := c.PostForm("end_date")
	pickupLocation := c.PostForm("pickup_location")

	// Konversi motor_id dari string ke uint64
	motorID, err := strconv.ParseUint(motorIDStr, 10, 64)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "motor_id tidak valid"})
		return
	}

	// Parse waktu start_date dan end_date dengan format ISO8601
	// Expected format from the form: "2025-04-01T00:00:00Z" (adjust layout if needed)
	layout := "2006-01-02T15:04:05Z07:00"
	startDate, err := time.Parse(layout, startDateStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "start_date tidak valid"})
		return
	}
	endDate, err := time.Parse(layout, endDateStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "end_date tidak valid"})
		return
	}

	log.Printf("Debug: Manual Booking Data => motor_id: %d, customer_name: %s, start_date: %v, end_date: %v, pickup_location: %s",
		motorID, customerName, startDate, endDate, pickupLocation)

	// Ambil user_id dari token (ID vendor)
	userID, exists := c.Get("user_id")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Vendor tidak terautentikasi"})
		return
	}
	vendorUserID := userID.(uint)

	// Pastikan user role = vendor
	var user models.User
	if err := config.DB.First(&user, vendorUserID).Error; err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "User tidak ditemukan"})
		return
	}
	if user.Role != "vendor" {
		c.JSON(http.StatusForbidden, gin.H{"error": "Hanya vendor yang dapat membuat booking manual"})
		return
	}

	// Ambil data vendor berdasarkan user_id
	var vendor models.Vendor
	if err := config.DB.Where("user_id = ?", vendorUserID).First(&vendor).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Data vendor tidak ditemukan"})
		return
	}

	// Mulai transaksi
	tx := config.DB.Begin()

	// Validasi customer_name untuk booking manual tanpa akun
	finalCustomerName := strings.TrimSpace(customerName)
	if finalCustomerName == "" {
		tx.Rollback()
		c.JSON(http.StatusBadRequest, gin.H{"error": "Nama customer harus diisi jika tidak memiliki akun"})
		return
	}

	// Ambil motor
	var motor models.Motor
	if err := tx.Where("id = ?", motorID).First(&motor).Error; err != nil {
		tx.Rollback()
		c.JSON(http.StatusNotFound, gin.H{"error": "Motor tidak ditemukan"})
		return
	}

	// Pastikan motor dimiliki oleh vendor yang sedang login
	if motor.VendorID != vendor.ID {
		tx.Rollback()
		c.JSON(http.StatusForbidden, gin.H{"error": "Anda tidak memiliki izin untuk menyewakan motor ini"})
		return
	}

	// Validasi rentang tanggal
	if endDate.Before(startDate) {
		tx.Rollback()
		c.JSON(http.StatusBadRequest, gin.H{"error": "Tanggal booking tidak valid: end_date harus setelah start_date"})
		return
	}
	duration := int(endDate.Sub(startDate).Hours() / 24)
	if duration <= 0 {
		tx.Rollback()
		c.JSON(http.StatusBadRequest, gin.H{"error": "Durasi booking tidak valid"})
		return
	}
	totalPrice := float64(duration) * motor.Price

	// Validasi overlap: cek apakah motor sudah dibooking (status "confirmed") pada periode ini
	var overlappingCount int64
	if err := tx.Model(&models.Booking{}).
		Where("motor_id = ? AND status = 'confirmed'", motor.ID).
		Where("(start_date <= ? AND end_date >= ?)", endDate, startDate).
		Count(&overlappingCount).Error; err != nil {
		tx.Rollback()
		log.Printf("Error checking motor availability: %v", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal memeriksa ketersediaan motor"})
		return
	}
	if overlappingCount > 0 {
		tx.Rollback()
		c.JSON(http.StatusBadRequest, gin.H{"error": "Motor sudah dibooking pada rentang tanggal tersebut"})
		return
	}

	// Buat objek booking dengan status otomatis "confirmed"
	booking := models.Booking{
		CustomerID:     nil, // Booking manual tanpa akun customer
		CustomerName:   finalCustomerName,
		VendorID:       vendor.ID,
		MotorID:        uint(motorID),
		BookingDate:    time.Now(),
		StartDate:      startDate,
		EndDate:        endDate,
		PickupLocation: pickupLocation,
		Status:         "confirmed",
	}

	// Tangani file gambar untuk PhotoID (jika ada)
	if file, err := c.FormFile("photo_id"); err == nil {
		photoPath, err := saveBookingImage(c, file)
		if err != nil {
			tx.Rollback()
			log.Printf("Error saving photo_id: %v", err)
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal menyimpan foto ID"})
			return
		}
		booking.PhotoID = photoPath
	}

	// Tangani file gambar untuk KtpID (jika ada)
	if file, err := c.FormFile("ktp_id"); err == nil {
		ktpPath, err := saveBookingImage(c, file)
		if err != nil {
			tx.Rollback()
			log.Printf("Error saving ktp_id: %v", err)
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal menyimpan foto KTP"})
			return
		}
		booking.KtpID = ktpPath
	}

	// Simpan booking ke database
	if err := tx.Create(&booking).Error; err != nil {
		tx.Rollback()
		log.Printf("Error inserting manual booking: %v", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal menambahkan booking manual"})
		return
	}
	tx.Commit()

	// Siapkan respons
	response := gin.H{
		"message":         "Booking manual berhasil dibuat",
		"booking_id":      booking.ID,
		"customer_name":   booking.CustomerName,
		"booking_date":    booking.BookingDate,
		"start_date":      booking.StartDate,
		"end_date":        booking.EndDate,
		"pickup_location": booking.PickupLocation,
		"status":          booking.Status,
		"motor": gin.H{
			"id":            motor.ID,
			"name":          motor.Name,
			"brand":         motor.Brand,
			"model":         motor.Model,
			"year":          motor.Year,
			"price_per_day": motor.Price,
			"total_price":   totalPrice,
		},
		"photo_id": booking.PhotoID,
		"ktp_id":   booking.KtpID,
	}

	log.Printf("Manual booking successfully created: %+v", response)
	c.JSON(http.StatusOK, response)
}
