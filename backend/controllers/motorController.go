package controllers

import (
	"fmt"
	"log"
	"net/http"
	"rental-backend/config"
	"rental-backend/models"
	"time"

	"github.com/gin-gonic/gin"
)

// Fungsi untuk menambah motor baru
func CreateMotor(c *gin.Context) {
	var motor models.Motor

	// Validasi input JSON
	if err := c.ShouldBindJSON(&motor); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Ambil user_id dari JWT token yang sudah diproses di middleware
	userIDInt, exists := c.Get("user_id")
	fmt.Printf("Debug: User ID dari token -> %#v\n", userIDInt)
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "User ID tidak ditemukan dalam token"})
		return
	}
	fmt.Print(c.Get("user_id"))

	// Cek apakah user memiliki vendor terkait
	var vendor models.Vendor
	if err := config.DB.Where("user_id = ?", userIDInt).First(&vendor).Error; err != nil {
		fmt.Println("❌ Vendor tidak ditemukan untuk user_id:", userIDInt)
		c.JSON(http.StatusUnauthorized, gin.H{"error": "User bukan vendor atau vendor tidak ditemukan"})
		return
	}
	fmt.Printf("Debug: User ID dari token %d", vendor.ID)

	// Set VendorID pada motor dan pastikan tidak nol
	motor.VendorID = vendor.ID
	if motor.VendorID == 0 {
		fmt.Println("❌ Vendor ID tidak valid (0) untuk user_id:", userIDInt)
		c.JSON(http.StatusBadRequest, gin.H{"error": "Vendor ID tidak valid"})
		return
	}

	// Debugging sebelum menyimpan motor
	fmt.Println("📌 Menyimpan motor untuk vendor ID:", motor.VendorID)

	// Simpan data motor ke database
	if err := config.DB.Debug().Create(&motor).Error; err != nil {
		fmt.Println("❌ Gagal menyimpan motor ke database:", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal menambahkan motor"})
		return
	}

	fmt.Println("✅ Motor berhasil ditambahkan oleh vendor:", vendor.ID)
	c.JSON(http.StatusOK, gin.H{"message": "Motor berhasil ditambahkan", "data": motor})
}

// Fungsi untuk mendapatkan semua motor dari vendor yang login
func GetAllMotor(c *gin.Context) {
	var motors []models.Motor
	if err := config.DB.Find(&motors).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal mengambil data motor"})
		return
	}

	c.JSON(http.StatusOK, motors)
}

// Fungsi untuk mendapatkan motor berdasarkan ID
func GetMotorByID(c *gin.Context) {
	id := c.Param("id")
	var motor models.Motor

	if err := config.DB.First(&motor, id).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Motor tidak ditemukan"})
		return
	}

	c.JSON(http.StatusOK, motor)
}

// Fungsi untuk memperbarui motor
func UpdateMotor(c *gin.Context) {
	id := c.Param("id")
	var vendor models.Vendor
	userID, exists := c.Get("user_id")
	fmt.Printf("Debug: User ID dari token -> %#v\n", userID)
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "User ID tidak ditemukan dalam token"})
		return
	}

	if err := config.DB.
		Where("user_id = ?", userID).
		Order("id").
		First(&vendor).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "vendor tidak ditemukan"})
		return
	}

	var motor models.Motor

	if err := config.DB.First(&motor, id).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Motor tidak ditemukan"})
		return
	}
	fmt.Print(motor.VendorID)

	// Ambil vendor_id dari token
	// vendorID, exists := c.Get("vendor_id")
	fmt.Print(vendor.ID)

	if !exists || motor.VendorID != vendor.ID {
		c.JSON(http.StatusForbidden, gin.H{"error": "Anda tidak memiliki izin untuk mengubah motor ini"})
		return
	}

	if err := c.ShouldBindJSON(&motor); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	config.DB.Save(&motor)
	c.JSON(http.StatusOK, gin.H{"message": "Motor berhasil diperbarui", "data": motor})
}

// Fungsi untuk menghapus motor
func DeleteMotor(c *gin.Context) {
	id := c.Param("id")
	var motor models.Motor
	var vendor models.Vendor

	userID, exists := c.Get("user_id")
	fmt.Printf("Debug: User ID dari token -> %#v\n", userID)
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "User ID tidak ditemukan dalam token"})
		return
	}

	if err := config.DB.
		Where("user_id = ?", userID).
		Order("id").
		First(&vendor).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "vendor tidak ditemukan"})
		return
	}

	if err := config.DB.First(&motor, id).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Motor tidak ditemukan"})
		return
	}

	// Ambil vendor_id dari token
	fmt.Print(vendor.ID)

	if !exists || motor.VendorID != vendor.ID {
		c.JSON(http.StatusForbidden, gin.H{"error": "Anda tidak memiliki izin untuk mengubah motor ini"})
		return
	}

	config.DB.Delete(&motor)
	c.JSON(http.StatusOK, gin.H{"message": "Motor berhasil dihapus"})
}

// Fungsi untuk memperbarui status motor berdasarkan status booking
func AutoUpdateMotorStatus() {
	// Log untuk memastikan fungsi dimulai
	log.Println("🔄 Memulai update status motor otomatis...")

	// Ambil tanggal hari ini tanpa waktu (00:00:00)
	today := time.Date(time.Now().Year(), time.Now().Month(), time.Now().Day(), 0, 0, 0, 0, time.Local)

	// Ambil semua booking yang sedang berlangsung
	var bookings []models.Booking
	if err := config.DB.Where("start_date <= ? AND end_date >= ?", today, today).Find(&bookings).Error; err != nil {
		log.Printf("Error fetching bookings: %v", err)
		return
	}

	// Proses setiap booking yang ditemukan
	for _, booking := range bookings {
		// Log untuk setiap booking yang diproses
		log.Printf("📅 Memproses booking ID %d dengan motor ID %d", booking.ID, booking.MotorID)

		// Ambil motor terkait
		var motor models.Motor
		if err := config.DB.Where("id = ?", booking.MotorID).First(&motor).Error; err != nil {
			log.Printf("Motor dengan ID %d tidak ditemukan: %v", booking.MotorID, err)
			continue
		}

		// Cek apakah booking statusnya "confirmed"
		if booking.Status == "confirmed" {
			// Jika motor sedang dalam masa booking (di antara start_date dan end_date)
			if booking.StartDate.Before(today) && booking.EndDate.After(today) {
				// Motor sedang dalam masa booking
				if motor.Status != "booked" {
					motor.Status = "booked"
					if err := config.DB.Save(&motor).Error; err != nil {
						log.Printf("Gagal memperbarui status motor: %v", err)
					} else {
						log.Printf("Motor %d status diubah menjadi 'booked'", motor.ID)
					}
				}
			}
		} else {
			// Jika status booking bukan "confirmed", ubah status motor menjadi "available"
			if motor.Status != "available" {
				motor.Status = "available"
				if err := config.DB.Save(&motor).Error; err != nil {
					log.Printf("Gagal memperbarui status motor: %v", err)
				} else {
					log.Printf("Motor %d status diubah menjadi 'available' karena status booking bukan 'confirmed'", motor.ID)
				}
			}
		}

		// Cek jika booking sudah selesai
		if booking.EndDate.Before(today) {
			// Motor sudah selesai disewa, ubah status menjadi available
			if motor.Status != "available" {
				motor.Status = "available"
				if err := config.DB.Save(&motor).Error; err != nil {
					log.Printf("Gagal memperbarui status motor: %v", err)
				} else {
					log.Printf("Motor %d status diubah menjadi 'available' setelah booking selesai", motor.ID)
				}
			}
		}
	}

	// Log untuk memastikan fungsi selesai
	log.Println("✅ Update status motor selesai.")
}

// Fungsi untuk menjalankan pengecekan otomatis secara periodik setiap 5 menit
func StartAutoUpdateMotorStatus() {
	log.Println("🕒 Memulai auto update status motor secara periodik...")

	// Setiap 5 menit sekali
	ticker := time.NewTicker(30 * time.Minute) // Setiap 5 menit sekali
	defer ticker.Stop()

	// Perulangan untuk menjalankan AutoUpdateMotorStatus setiap 5 menit
	for range ticker.C {
		AutoUpdateMotorStatus() // Panggil fungsi untuk memperbarui status motor
	}
}
