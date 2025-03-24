package controllers

import (
	"fmt"
	"log"
	"mime/multipart"
	"net/http"
	"os"
	"path/filepath"
	"rental-backend/config"
	"rental-backend/models"
	"strconv"
	"time"

	"github.com/gin-gonic/gin"
)

func saveImage(c *gin.Context, file *multipart.FileHeader) (string, error) {
	timestamp := time.Now().Format("20060102_150405")
	filename := fmt.Sprintf("%s%s", timestamp, filepath.Ext(file.Filename))
	filePath := filepath.Join("./fileserver/motor", filename)

	if err := os.MkdirAll("./fileserver/motor", os.ModePerm); err != nil {
		return "", err
	}

	if err := c.SaveUploadedFile(file, filePath); err != nil {
		return "", err
	}

	return "/fileserver/motor/" + filename, nil
}

// Fungsi untuk menambah motor baru
func CreateMotor(c *gin.Context) {
	var motor models.Motor

	// Ambil user ID dari token
	userIDInt, exists := c.Get("user_id")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "User ID tidak ditemukan dalam token"})
		return
	}

	// Cek apakah user adalah vendor
	var vendor models.Vendor
	if err := config.DB.Where("user_id = ?", userIDInt).First(&vendor).Error; err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "User bukan vendor atau vendor tidak ditemukan"})
		return
	}

	// Ambil data dari form-data
	motor.VendorID = vendor.ID
	motor.Name = c.PostForm("name")
	motor.Brand = c.PostForm("brand")
	motor.Model = c.PostForm("model")
	motor.Color = c.PostForm("color")
	motor.Status = c.PostForm("status")

	// Konversi nilai numerik
	year, _ := strconv.Atoi(c.PostForm("year"))
	price, _ := strconv.Atoi(c.PostForm("price"))

	motor.Year = uint(year)
	motor.Price = float64(price)

	// Simpan motor terlebih dahulu
	if err := config.DB.Create(&motor).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal menambahkan motor"})
		return
	}

	// Ambil file gambar jika ada
	file, err := c.FormFile("image")
	if err == nil {
		imagePath, err := saveImage(c, file)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal menyimpan gambar"})
			return
		}
		motor.Image = imagePath
		config.DB.Save(&motor)
	}

	c.JSON(http.StatusOK, gin.H{"message": "Motor berhasil ditambahkan", "data": motor})
}

// Fungsi untuk memperbarui motor
func UpdateMotor(c *gin.Context) {
	id := c.Param("id")
	var motor models.Motor
	var vendor models.Vendor
	var input = make(map[string]interface{}) // Gunakan map untuk partial update

	// Ambil user ID dari token
	userID, exists := c.Get("user_id")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "User ID tidak ditemukan dalam token"})
		return
	}

	// Cek apakah user adalah vendor
	if err := config.DB.Where("user_id = ?", userID).First(&vendor).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Vendor tidak ditemukan"})
		return
	}

	// Cek apakah motor ada di database
	if err := config.DB.First(&motor, id).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Motor tidak ditemukan"})
		return
	}

	// Cek apakah motor milik vendor yang sedang login
	if motor.VendorID != vendor.ID {
		c.JSON(http.StatusForbidden, gin.H{"error": "Anda tidak memiliki izin untuk mengupdate motor ini"})
		return
	}

	// Update hanya jika ada input baru
	if name := c.PostForm("name"); name != "" {
		input["name"] = name
	}
	if brand := c.PostForm("brand"); brand != "" {
		input["brand"] = brand
	}
	if model := c.PostForm("model"); model != "" {
		input["model"] = model
	}
	if color := c.PostForm("color"); color != "" {
		input["color"] = color
	}
	if status := c.PostForm("status"); status != "" {
		input["status"] = status
	}

	// **Perbaikan Year** -> Jangan set `0` ke database
	if yearStr := c.PostForm("year"); yearStr != "" {
		year, err := strconv.Atoi(yearStr)
		if err == nil && year > 0 { // Hanya update jika lebih dari 0
			input["year"] = year
		}
	}

	// **Perbaikan Price** -> Hanya update jika ada input valid
	if priceStr := c.PostForm("price"); priceStr != "" {
		price, err := strconv.ParseFloat(priceStr, 64)
		if err == nil {
			input["price"] = price
		}
	}

	// Ambil file gambar jika ada
	file, err := c.FormFile("image")
	if err == nil {
		// Hapus gambar lama jika ada
		if motor.Image != "" {
			os.Remove(motor.Image)
		}

		// Simpan gambar baru
		imagePath, err := saveImage(c, file)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal menyimpan gambar"})
			return
		}
		input["image"] = imagePath
	}

	// **Gunakan GORM Updates agar hanya yang diubah yang tersimpan**
	if err := config.DB.Model(&motor).Updates(input).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal memperbarui motor"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Motor berhasil diperbarui", "data": motor})
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

// Fungsi untuk mendapatkan semua motor berdasarkan vendor yang login
func GetAllMotorbyVendor(c *gin.Context) {
	var motors []models.Motor

	// Ambil user_id dari token
	userID, exists := c.Get("user_id")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "User tidak ditemukan dalam token"})
		return
	}

	// Cek apakah user memiliki vendor terkait
	var vendor models.Vendor
	if err := config.DB.Where("user_id = ?", userID).First(&vendor).Error; err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Vendor tidak ditemukan"})
		return
	}

	// Ambil motor berdasarkan vendor_id dengan Preload Vendor
	if err := config.DB.
		Select("id, vendor_id, name, brand, model, year, price, color, status, image, created_at, updated_at").
		Where("vendor_id = ?", vendor.ID).
		Find(&motors).Error; err != nil {
		fmt.Printf("❌ Gagal mengambil data motor: %v\n", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal mengambil data motor"})
		return
	}

	// Cek apakah ada data motor yang ditemukan
	if len(motors) == 0 {
		c.JSON(http.StatusNotFound, gin.H{"message": "Tidak ada motor yang tersedia"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "Berhasil mengambil data motor",
		"data":    motors,
	})
}

// Fungsi untuk menghapus motor
func DeleteMotor(c *gin.Context) {
	id := c.Param("id")
	var motor models.Motor
	var vendor models.Vendor

	// Pastikan user_id tersedia di middleware
	userID, exists := c.Get("user_id")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "User ID tidak ditemukan dalam token"})
		return
	}

	// Cari vendor yang terkait dengan user
	if err := config.DB.Where("user_id = ?", userID).First(&vendor).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Vendor tidak ditemukan"})
		return
	}

	// Cari motor berdasarkan ID
	if err := config.DB.First(&motor, id).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Motor tidak ditemukan"})
		return
	}

	// Validasi apakah motor milik vendor yang sesuai
	if motor.VendorID != vendor.ID {
		c.JSON(http.StatusForbidden, gin.H{"error": "Anda tidak memiliki izin untuk menghapus motor ini"})
		return
	}

	// Hapus motor dari database
	if err := config.DB.Delete(&motor).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal menghapus motor"})
		return
	}

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
