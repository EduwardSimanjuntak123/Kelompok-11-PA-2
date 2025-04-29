package controllers

import (
	"net/http"
	"rental-backend/config"
	"rental-backend/models"
	"strconv"

	"time"

	"github.com/gin-gonic/gin"
)

func RequestBookingExtension(c *gin.Context) {
    bookingID := c.Param("id")
    userID, exists := c.Get("user_id")
    if !exists {
        c.JSON(http.StatusUnauthorized, gin.H{"error": "Customer tidak terautentikasi"})
        return
    }

    // Ambil booking
    var booking models.Booking
    if err := config.DB.First(&booking, bookingID).Error; err != nil {
        c.JSON(http.StatusNotFound, gin.H{"error": "Booking tidak ditemukan"})
        return
    }

    // Validasi booking
    if booking.CustomerID == nil || *booking.CustomerID != userID.(uint) {
        c.JSON(http.StatusUnauthorized, gin.H{"error": "Anda tidak memiliki akses ke booking ini"})
        return
    }
    if booking.Status != "in use" {
        c.JSON(http.StatusBadRequest, gin.H{"error": "Perpanjangan hanya bisa dilakukan saat status booking 'in use'"})
        return
    }

    // Ambil durasi tambahan dari request body
    var req struct {
        AdditionalDays int `json:"additional_days"`
    }
    if err := c.ShouldBindJSON(&req); err != nil || req.AdditionalDays <= 0 {
        c.JSON(http.StatusBadRequest, gin.H{"error": "Durasi tambahan harus berupa angka lebih dari 0"})
        return
    }

    // Hitung end date baru
    newEndDate := booking.EndDate.AddDate(0, 0, req.AdditionalDays)

    // Cek overlapping booking yang bentrok
    var conflict int64
    if err := config.DB.
        Model(&models.Booking{}).
        Where("motor_id = ?", booking.MotorID).
        Where("status IN ?", []string{"confirmed", "in transit", "in use"}).
        // overlapping: start < newEndDate AND end > current end date
        Where("start_date < ? AND end_date > ?", newEndDate, booking.EndDate).
        Where("id != ?", booking.ID).
        Count(&conflict).Error; err != nil {
        c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal memeriksa konflik booking"})
        return
    }
    if conflict > 0 {
        c.JSON(http.StatusBadRequest, gin.H{"error": "Tidak bisa perpanjang, sudah ada booking lain di periode tersebut"})
        return
    }

    // Ambil harga per hari motor
    var motor models.Motor
    if err := config.DB.First(&motor, booking.MotorID).Error; err != nil {
        c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal mengambil data motor"})
        return
    }
    additionalPrice := float64(req.AdditionalDays) * motor.Price

    // Simpan request perpanjangan termasuk harga tambahan
    extension := models.BookingExtension{
        BookingID:        booking.ID,
        RequestedEndDate: newEndDate,
        AdditionalPrice:  additionalPrice,
        Status:           "pending",
    }
    if err := config.DB.Create(&extension).Error; err != nil {
        c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal menyimpan permintaan perpanjangan"})
        return
    }

    c.JSON(http.StatusOK, gin.H{
        "message": "Permintaan perpanjangan berhasil diajukan",
        "data":    extension,
    })
}



func ApproveBookingExtension(c *gin.Context) {
	extensionID := c.Param("id")
	userID, exists := c.Get("user_id")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Vendor tidak terautentikasi"})
		return
	}

	// Ambil data extension
	var extension models.BookingExtension
	if err := config.DB.First(&extension, extensionID).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Permintaan perpanjangan tidak ditemukan"})
		return
	}

	// Ambil booking terkait
	var booking models.Booking
	if err := config.DB.First(&booking, extension.BookingID).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Booking tidak ditemukan"})
		return
	}

	// Validasi vendor pemilik booking
	var vendor models.Vendor
	if err := config.DB.Where("user_id = ?", userID).First(&vendor).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Vendor tidak ditemukan"})
		return
	}
	if booking.VendorID != vendor.ID {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Anda tidak memiliki izin untuk menyetujui perpanjangan ini"})
		return
	}

	// Validasi status masih pending
	if extension.Status != "pending" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Permintaan perpanjangan sudah diproses"})
		return
	}

	// Update end_date di booking
	if err := config.DB.Model(&booking).Update("end_date", extension.RequestedEndDate).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal memperbarui end date booking"})
		return
	}

	// Update status extension
	now := time.Now()
	if err := config.DB.Model(&extension).Updates(map[string]interface{}{
		"status":      "approved",
		"approved_at": now,
	}).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal memperbarui status perpanjangan"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Perpanjangan booking disetujui"})
}

func RejectBookingExtension(c *gin.Context) {
	extensionID := c.Param("id")
	userID, exists := c.Get("user_id")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Vendor tidak terautentikasi"})
		return
	}

	var extension models.BookingExtension
	if err := config.DB.First(&extension, extensionID).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Permintaan perpanjangan tidak ditemukan"})
		return
	}

	var booking models.Booking
	if err := config.DB.First(&booking, extension.BookingID).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Booking tidak ditemukan"})
		return
	}

	var vendor models.Vendor
	if err := config.DB.Where("user_id = ?", userID).First(&vendor).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Vendor tidak ditemukan"})
		return
	}
	if booking.VendorID != vendor.ID {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Anda tidak memiliki izin untuk menolak perpanjangan ini"})
		return
	}

	if extension.Status != "pending" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Permintaan perpanjangan sudah diproses"})
		return
	}

	if err := config.DB.Model(&extension).Update("status", "rejected").Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal menolak perpanjangan"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Perpanjangan booking ditolak"})
}


func GetPendingBookingExtensions(c *gin.Context) {
	userID, exists := c.Get("user_id")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Vendor tidak terautentikasi"})
		return
	}

	// Ambil vendor berdasarkan user_id
	var vendor models.Vendor
	if err := config.DB.Where("user_id = ?", userID).First(&vendor).Error; err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Vendor tidak ditemukan"})
		return
	}

	var extensions []models.BookingExtension

	// Ambil permintaan perpanjangan yang booking-nya dimiliki vendor ini
	if err := config.DB.
		Preload("Booking").
		Where("status = ?", "pending").
		Find(&extensions).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal mengambil data perpanjangan"})
		return
	}

	var result []map[string]interface{}
	for _, ext := range extensions {
		var booking models.Booking
		if err := config.DB.First(&booking, ext.BookingID).Error; err != nil {
			continue
		}
		if booking.VendorID != vendor.ID {
			continue
		}

		result = append(result, map[string]interface{}{
			"id":                 ext.ID,
			"booking_id":         ext.BookingID,
			"customer_name":      booking.CustomerName,
			"requested_end_date": ext.RequestedEndDate,
			"status":             ext.Status,
			"requested_at":       ext.RequestedAt,
			"additional_price": ext.AdditionalPrice,

		})
	}

	c.JSON(http.StatusOK, result)
}


func GetCustomerBookingExtensions(c *gin.Context) {
	userID, exists := c.Get("user_id")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Customer tidak terautentikasi"})
		return
	}

	var extensions []models.BookingExtension

	// Join booking dan filter berdasarkan customer_id
	if err := config.DB.
		Joins("JOIN bookings ON bookings.id = booking_extensions.booking_id").
		Where("bookings.customer_id = ?", userID).
		Preload("Booking").
		Order("booking_extensions.requested_at DESC").
		Find(&extensions).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal mengambil data perpanjangan"})
		return
	}

	var result []map[string]interface{}
	for _, ext := range extensions {
		result = append(result, map[string]interface{}{
			"id":                 ext.ID,
			"booking_id":         ext.BookingID,
			"motor_id":           ext.Booking.MotorID,
			"vendor_id":          ext.Booking.VendorID,
			"requested_end_date": ext.RequestedEndDate,
			"status":             ext.Status,
			"requested_at":       ext.RequestedAt,
			"approved_at":        ext.ApprovedAt,
			"additional_price": ext.AdditionalPrice,
		})
	}

	c.JSON(http.StatusOK, result)
}


// GetBookingsByMotorID menampilkan daftar booking berdasarkan motor ID
func GetBookingsByMotorID(c *gin.Context) {
	idMotorStr := c.Param("idmotor")

	idMotor, err := strconv.ParseUint(idMotorStr, 10, 64)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "ID motor tidak valid"})
		return
	}

	var bookings []models.Booking

	// Ambil semua booking untuk motor ini, hanya status tertentu
	if err := config.DB.
		Where("motor_id = ? AND status IN ?", idMotor, []string{"confirmed", "in transit", "in use", "awaiting return"}).
		Find(&bookings).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal mengambil data booking"})
		return
	}

	c.JSON(http.StatusOK, bookings)
}


func GetBookingExtensionsByBookingID(c *gin.Context) {
    // pastikan customer terautentikasi
    userID, exists := c.Get("user_id")
    if !exists {
        c.JSON(http.StatusUnauthorized, gin.H{"error": "Customer tidak terautentikasi"})
        return
    }

    // parse booking ID dari path
    bookingIDParam := c.Param("booking_id")
    bookingID, err := strconv.ParseUint(bookingIDParam, 10, 64)
    if err != nil {
        c.JSON(http.StatusBadRequest, gin.H{"error": "ID booking tidak valid"})
        return
    }

    // pastikan booking milik customer
    var booking models.Booking
    if err := config.DB.First(&booking, bookingID).Error; err != nil {
        c.JSON(http.StatusNotFound, gin.H{"error": "Booking tidak ditemukan"})
        return
    }
    if booking.CustomerID == nil || *booking.CustomerID != userID.(uint) {
        c.JSON(http.StatusUnauthorized, gin.H{"error": "Anda tidak memiliki akses ke booking ini"})
        return
    }

    // ambil extension untuk booking tersebut
    var extensions []models.BookingExtension
    if err := config.DB.
        Where("booking_id = ?", bookingID).
        Order("requested_at DESC").
        Find(&extensions).Error; err != nil {
        c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal mengambil data perpanjangan"})
        return
    }

    // bentuk response
    var resp []map[string]interface{}
    for _, ext := range extensions {
        resp = append(resp, map[string]interface{}{
            "id":                ext.ID,
            "booking_id":        ext.BookingID,
            "requested_end_date": ext.RequestedEndDate,
            "additional_price":  ext.AdditionalPrice,
            "status":            ext.Status,
            "requested_at":      ext.RequestedAt,
            "approved_at":       ext.ApprovedAt,
        })
    }

    c.JSON(http.StatusOK, gin.H{"extensions": resp})
}

