package controllers

import (
	"encoding/json"
	"log"
	"net/http"
	"rental-backend/config"
	"rental-backend/models"
	"rental-backend/websocket"
	"strconv"
	"strings"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/go-co-op/gocron"
)

// Fungsi untuk mengonfirmasi booking oleh vendor
func ConfirmBooking(c *gin.Context) {
	id := c.Param("id")

	userID, exists := c.Get("user_id")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Vendor tidak terautentikasi"})
		return
	}

	var booking models.Booking
	if err := config.DB.Where("id = ?", id).First(&booking).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Booking tidak ditemukan"})
		return
	}

	if booking.Status != "pending" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Hanya booking dengan status 'pending' yang dapat dikonfirmasi"})
		return
	}

	var vendor models.Vendor
	if err := config.DB.Where("user_id = ?", userID).First(&vendor).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Vendor tidak ditemukan"})
		return
	}

	if booking.VendorID != vendor.ID {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Anda tidak memiliki izin untuk mengonfirmasi booking ini"})
		return
	}

	if err := config.DB.Model(&models.Booking{}).Where("id = ?", id).Update("status", "confirmed").Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal mengonfirmasi booking"})
		return
	}

	if booking.CustomerID != nil {
		notification := models.Notification{
			UserID:    *booking.CustomerID,
			Message:   "Booking Anda telah dikonfirmasi dan motor sedang disiapkan.",
			Status:    "unread",
			BookingID: booking.ID,
			CreatedAt: time.Now(),
		}

		if err := config.DB.Create(&notification).Error; err != nil {
			log.Println("❗ Gagal menyimpan notifikasi:", err)
		} else {
			// Kirim notifikasi real-time ke Flutter via WebSocket
			notifPayload := map[string]interface{}{
				"message":    notification.Message,
				"booking_id": notification.BookingID,
			}

			notifJSON, err := json.Marshal(notifPayload)
			if err != nil {
				log.Println("❗ Gagal encode notifikasi ke JSON:", err)
			} else {
				websocket.SendNotificationToUser(*booking.CustomerID, string(notifJSON))
			}
		}
	}

	c.JSON(http.StatusOK, gin.H{"message": "Booking berhasil dikonfirmasi"})
}

// SetBookingToTransit mengubah status booking menjadi "in transit"
func SetBookingToTransit(c *gin.Context) {
	id := c.Param("id")

	// Ambil user_id dari token JWT
	userID, exists := c.Get("user_id")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Vendor tidak terautentikasi"})
		return
	}

	var booking models.Booking

	// Cari booking berdasarkan ID
	if err := config.DB.Where("id = ?", id).First(&booking).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Booking tidak ditemukan"})
		return
	}

	// Hanya booking dengan status "confirmed" yang dapat diubah menjadi "in transit"
	if booking.Status != "confirmed" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Status booking harus 'confirmed' untuk mengubah ke 'in transit'"})
		return
	}

	// Pastikan vendor yang mengakses adalah pemilik booking
	var vendor models.Vendor
	if err := config.DB.Where("user_id = ?", userID).First(&vendor).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Vendor tidak ditemukan"})
		return
	}

	if booking.VendorID != vendor.ID {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Anda tidak memiliki izin untuk mengubah status booking ini"})
		return
	}

	// Ubah status menjadi "in transit"
	if err := config.DB.Model(&models.Booking{}).Where("id = ?", id).Update("status", "in transit").Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal mengubah status booking"})
		return
	}

	// Kirim notifikasi ke customer jika ada
	if booking.CustomerID != nil {
		notification := models.Notification{
			UserID:    *booking.CustomerID,
			Message:   "Motor Anda sedang dalam perjalanan ke lokasi penjemputan.",
			Status:    "unread",
			BookingID: booking.ID,
			CreatedAt: time.Now(),
		}

		if err := config.DB.Create(&notification).Error; err != nil {
			log.Println("❗ Gagal menyimpan notifikasi:", err)
		} else {
			notifPayload := map[string]interface{}{
				"message":    notification.Message,
				"booking_id": notification.BookingID,
			}

			notifJSON, err := json.Marshal(notifPayload)
			if err != nil {
				log.Println("❗ Gagal encode notifikasi ke JSON:", err)
			} else {
				websocket.SendNotificationToUser(*booking.CustomerID, string(notifJSON))
			}
		}
	}

	c.JSON(http.StatusOK, gin.H{"message": "Status booking berhasil diubah ke 'in transit'"})
}

// SetBookingToInUse mengubah status booking menjadi "in use"
func SetBookingToInUse(c *gin.Context) {
	id := c.Param("id")

	// Ambil user_id dari token JWT
	userID, exists := c.Get("user_id")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Vendor tidak terautentikasi"})
		return
	}

	var booking models.Booking

	// Cari booking berdasarkan ID
	if err := config.DB.Where("id = ?", id).First(&booking).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Booking tidak ditemukan"})
		return
	}

	// Hanya booking dengan status "in transit" yang bisa diubah ke "in use"
	if booking.Status != "in transit" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Status booking harus 'in transit' untuk mengubah ke 'in use'"})
		return
	}

	// Pastikan vendor yang mengakses adalah pemilik booking
	var vendor models.Vendor
	if err := config.DB.Where("user_id = ?", userID).First(&vendor).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Vendor tidak ditemukan"})
		return
	}

	if booking.VendorID != vendor.ID {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Anda tidak memiliki izin untuk mengubah status booking ini"})
		return
	}

	// Update status menjadi "in use"
	if err := config.DB.Model(&models.Booking{}).Where("id = ?", id).Update("status", "in use").Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal mengubah status booking"})
		return
	}

	// Kirim notifikasi ke customer
	if booking.CustomerID != nil {
		notification := models.Notification{
			UserID:    *booking.CustomerID,
			Message:   "Motor Anda telah tiba dan siap digunakan. Selamat berkendara!",
			Status:    "unread",
			BookingID: booking.ID,
			CreatedAt: time.Now(),
		}

		if err := config.DB.Create(&notification).Error; err != nil {
			log.Println("❗ Gagal menyimpan notifikasi:", err)
		} else {
			notifPayload := map[string]interface{}{
				"message":    notification.Message,
				"booking_id": notification.BookingID,
			}

			notifJSON, err := json.Marshal(notifPayload)
			if err != nil {
				log.Println("❗ Gagal encode notifikasi ke JSON:", err)
			} else {
				websocket.SendNotificationToUser(*booking.CustomerID, string(notifJSON))
			}
		}
	}

	c.JSON(http.StatusOK, gin.H{"message": "Status booking berhasil diubah ke 'in use'"})
}
func StartAutoAwaitingReturnScheduler() {
	log.Println("📆 Memulai scheduler untuk pengecekan pengembalian booking...")
	s := gocron.NewScheduler(time.Local)

	s.Every(1).Second().Do(AutoSetAwaitingReturn)

	s.StartAsync()
}

// AutoSetAwaitingReturn memproses semua booking yang seharusnya masuk status "awaiting return"
func AutoSetAwaitingReturn() {

	var bookings []models.Booking

	// Ambil semua booking yang masih "in use"
	if err := config.DB.Where("status = ?", "in use").Find(&bookings).Error; err != nil {
		log.Println("❗ Gagal mengambil booking:", err)
		return
	}

	now := time.Now()

	for _, booking := range bookings {
		// log.Printf("⏰ Booking ID %d - EndDate: %v | Now: %v\n", booking.ID, booking.EndDate, now)

		if now.After(booking.EndDate) {
			// Ubah status menjadi "awaiting return"
			if err := config.DB.Model(&models.Booking{}).Where("id = ?", booking.ID).Update("status", "awaiting return").Error; err != nil {
				log.Printf("❗ Gagal update status booking ID %d: %v\n", booking.ID, err)
				continue
			}

			// Kirim notifikasi ke customer
			if booking.CustomerID != nil {
				notification := models.Notification{
					UserID:    *booking.CustomerID,
					Message:   "Waktu peminjaman Anda telah berakhir. Mohon segera kembalikan motor.",
					Status:    "unread",
					BookingID: booking.ID,
					CreatedAt: time.Now(),
				}

				if err := config.DB.Create(&notification).Error; err != nil {
					log.Println("❗ Gagal menyimpan notifikasi:", err)
				} else {
					notifPayload := map[string]interface{}{
						"message":    notification.Message,
						"booking_id": notification.BookingID,
					}

					notifJSON, err := json.Marshal(notifPayload)
					if err != nil {
						log.Println("❗ Gagal encode notifikasi ke JSON:", err)
					} else {
						websocket.SendNotificationToUser(*booking.CustomerID, string(notifJSON))
					}
				}
			}

			log.Printf("✅ Booking ID %d status diubah ke 'awaiting return'\n", booking.ID)
		}
	}
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

	// Pastikan hanya booking dengan status "pending" yang dapat ditolak
	if booking.Status != "pending" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Hanya booking dengan status 'pending' yang dapat ditolak"})
		return
	}

	// Cari vendor yang terkait dengan user_id
	var vendor models.Vendor
	if err := config.DB.Where("user_id = ?", userID).First(&vendor).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Vendor tidak ditemukan"})
		return
	}

	// Pastikan vendor yang menolak adalah pemilik booking
	if booking.VendorID != vendor.ID {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Anda tidak memiliki izin untuk menolak booking ini"})
		return
	}

	// Ubah status booking menjadi "rejected"
	if err := config.DB.Model(&models.Booking{}).Where("id = ?", id).Update("status", "rejected").Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal menolak booking"})
		return
	}

	// Kirim notifikasi jika customer ID tersedia
	if booking.CustomerID != nil {
		notification := models.Notification{
			UserID:    *booking.CustomerID,
			Message:   "Maaf, booking Anda ditolak oleh vendor.",
			Status:    "unread",
			BookingID: booking.ID,
			CreatedAt: time.Now(),
		}

		if err := config.DB.Create(&notification).Error; err != nil {
			log.Println("❗ Gagal menyimpan notifikasi:", err)
		} else {
			// Kirim notifikasi real-time ke Flutter via WebSocket
			notifPayload := map[string]interface{}{
				"message":    notification.Message,
				"booking_id": notification.BookingID,
			}

			notifJSON, err := json.Marshal(notifPayload)
			if err != nil {
				log.Println("❗ Gagal encode notifikasi ke JSON:", err)
			} else {
				websocket.SendNotificationToUser(*booking.CustomerID, string(notifJSON))
			}
		}
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
			"year":          0,
			"price_per_day": 0,
			"total_price":   0,
			"image":         "https://via.placeholder.com/150",
		}

		if booking.Motor != nil {
			motorData = map[string]interface{}{
				"id":         booking.Motor.ID,
				"name":       booking.Motor.Name,
				"brand":      booking.Motor.Brand,
				"color":      booking.Motor.Color,
				"year":       booking.Motor.Year,
				"plat_motor": booking.Motor.PlatMotor,

				"price_per_day": booking.Motor.Price,
				"total_price":   booking.Motor.Price * float64(booking.GetDurationDays()),
				"image": func() string {
					if booking.Motor.Image != "" {
						if strings.HasPrefix(booking.Motor.Image, "http") {
							return booking.Motor.Image
						}
						return booking.Motor.Image
					}
					return "https://via.placeholder.com/150"
				}(),
			}
		}

		bookingData := map[string]interface{}{
			"id":              booking.ID,
			"customer_name":   customerName,
			"customer_id":     booking.CustomerID,
			"booking_date":    booking.BookingDate,
			"start_date":      booking.StartDate,
			"end_date":        booking.EndDate,
			"booking_purpose": booking.BookingPurpose,
			"status":          booking.Status,
			"message":         "Booking berhasil diambil",
			"pickup_location": booking.PickupLocation,
			"motor":           motorData,
			"ktpid":           booking.KtpID,
			"potoid":          booking.PhotoID,
		}

		response = append(response, bookingData)
	}

	c.JSON(http.StatusOK, response)
}

// GetBookingByIDForVendor mengambil detail booking berdasarkan ID oleh vendor
func GetBookingByIDForVendor(c *gin.Context) {
	id := c.Param("id")

	// Ambil user_id dari JWT token
	userID, exists := c.Get("user_id")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Vendor tidak terautentikasi"})
		return
	}

	// Cari vendor berdasarkan user_id
	var vendor models.Vendor
	if err := config.DB.Where("user_id = ?", userID).First(&vendor).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Vendor tidak ditemukan"})
		return
	}

	// Ambil booking berdasarkan ID
	var booking models.Booking
	if err := config.DB.Preload("Motor").Preload("Customer").Preload("Vendor").Where("id = ?", id).First(&booking).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Booking tidak ditemukan"})
		return
	}

	// Pastikan booking milik vendor yang sedang login
	if booking.VendorID != vendor.ID {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Anda tidak memiliki izin untuk melihat booking ini"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"booking": booking,
	})
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
		Preload("Vendor").
		Find(&bookings).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal mendapatkan data booking"})
		return
	}

	// Format respons
	var response []map[string]interface{}
	for _, booking := range bookings {
		motorData := map[string]interface{}{}
		if booking.Motor != nil {
			motorData = map[string]interface{}{
				"id":         booking.Motor.ID,
				"name":       booking.Motor.Name,
				"brand":      booking.Motor.Brand,
				"year":       booking.Motor.Year,
				"plat_motor": booking.Motor.PlatMotor,

				"price_per_day": booking.Motor.Price,
				"total_price":   booking.Motor.Price * float64(booking.GetDurationDays()),
				"image": func() string {
					if booking.Motor.Image != "" {
						if strings.HasPrefix(booking.Motor.Image, "http") {
							return booking.Motor.Image
						}
						return booking.Motor.Image
					}
					return "https://via.placeholder.com/150"
				}(),
			}
		}

		bookingData := map[string]interface{}{
			"id":               booking.ID,
			"vendor_Id":        booking.Vendor.UserID,
			"booking_date":     booking.BookingDate,
			"purpose_booking":  booking.BookingPurpose,
			"start_date":       booking.StartDate,
			"end_date":         booking.EndDate,
			"status":           booking.Status,
			"dropoff_location": booking.DropoffLocation,
			"pickup_location":  booking.PickupLocation,
			"motor":            motorData,
			"shop_name": func() string {
				if booking.Vendor != nil {
					return booking.Vendor.ShopName
				}
				return "Unknown Vendor" // fallback value
			}(),
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
	durationStr := c.PostForm("duration")
	pickupLocation := c.PostForm("pickup_location")
	dropoffLocation := c.PostForm("dropoff_location")

	// Konversi motor_id ke uint64
	motorID, err := strconv.ParseUint(motorIDStr, 10, 64)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "motor_id tidak valid"})
		return
	}

	// Parse durasi
	duration, err := strconv.Atoi(durationStr)
	if err != nil || duration <= 0 {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Durasi tidak valid"})
		return
	}

	// Parse waktu start_date
	layout := "2006-01-02T15:04:05Z07:00"
	startDate, err := time.Parse(layout, startDateStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "start_date tidak valid"})
		return
	}

	// Hitung endDate
	endDate := startDate.Add(time.Hour * 24 * time.Duration(duration))

	// Debug log
	log.Printf("Debug: Manual Booking => motor_id: %d, customer_name: %s, start_date: %v, duration: %d, end_date: %v, pickup_location: %s",
		motorID, customerName, startDate, duration, endDate, pickupLocation)

	// Ambil user_id dari token (vendor)
	userID, exists := c.Get("user_id")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Vendor tidak terautentikasi"})
		return
	}
	vendorUserID := userID.(uint)

	// Validasi user
	var user models.User
	if err := config.DB.First(&user, vendorUserID).Error; err != nil || user.Role != "vendor" {
		c.JSON(http.StatusForbidden, gin.H{"error": "Hanya vendor yang dapat membuat booking manual"})
		return
	}

	// Ambil data vendor
	var vendor models.Vendor
	if err := config.DB.Where("user_id = ?", vendorUserID).First(&vendor).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Data vendor tidak ditemukan"})
		return
	}

	tx := config.DB.Begin()

	// Validasi nama customer
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

	// Pastikan motor milik vendor ini
	if motor.VendorID != vendor.ID {
		tx.Rollback()
		c.JSON(http.StatusForbidden, gin.H{"error": "Anda tidak memiliki izin menyewakan motor ini"})
		return
	}

	// Cek konflik booking
	if err := checkBookingConflict(startDate, endDate, uint(motorID)); err != nil {
		tx.Rollback()
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Hitung total harga
	totalPrice := float64(duration) * motor.Price

	// Buat booking
	booking := models.Booking{
		CustomerID:      nil,
		CustomerName:    finalCustomerName,
		VendorID:        vendor.ID,
		MotorID:         uint(motorID),
		BookingDate:     time.Now(),
		StartDate:       startDate,
		EndDate:         endDate,
		PickupLocation:  pickupLocation,
		DropoffLocation: dropoffLocation,
		Status:          "confirmed",
	}

	// Upload photo_id
	if file, err := c.FormFile("photo_id"); err == nil {
		if path, err := saveBookingImage(c, file); err == nil {
			booking.PhotoID = path
		} else {
			tx.Rollback()
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal menyimpan photo ID"})
			return
		}
	}

	// Upload ktp_id
	if file, err := c.FormFile("ktp_id"); err == nil {
		if path, err := saveBookingImage(c, file); err == nil {
			booking.KtpID = path
		} else {
			tx.Rollback()
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal menyimpan KTP"})
			return
		}
	}

	// Simpan booking
	if err := tx.Create(&booking).Error; err != nil {
		tx.Rollback()
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal menyimpan booking"})
		return
	}
	tx.Commit()

	// Response
	c.JSON(http.StatusOK, gin.H{
		"message":          "Booking manual berhasil dibuat",
		"booking_id":       booking.ID,
		"customer_name":    booking.CustomerName,
		"booking_date":     booking.BookingDate,
		"start_date":       booking.StartDate,
		"end_date":         booking.EndDate,
		"pickup_location":  booking.PickupLocation,
		"dropoff_location": booking.DropoffLocation,
		"status":           booking.Status,
		"motor": gin.H{
			"id":            motor.ID,
			"name":          motor.Name,
			"brand":         motor.Brand,
			"year":          motor.Year,
			"price_per_day": motor.Price,
			"plat_motor":    motor.PlatMotor,

			"total_price": totalPrice,
		},
		"photo_id": booking.PhotoID,
		"ktp_id":   booking.KtpID,
	})
}
