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
	motor.Color = c.PostForm("color")
	motor.Status = c.PostForm("status")
	motor.PlatMotor = c.PostForm("platmotor")

	motor.Type = c.PostForm("type")               // Tambahan kolom Type
	motor.Description = c.PostForm("description") // Tambahan kolom Description

	// Konversi nilai numerik
	year, _ := strconv.Atoi(c.PostForm("year"))
	price, _ := strconv.ParseFloat(c.PostForm("price"), 64)

	motor.Year = uint(year)
	motor.Price = price

	// Simpan motor terlebih dahulu
	if err := config.DB.Create(&motor).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal menambahkan motor"})
		return
	}

	// Ambil file gambar jika ada dan simpan
	if file, err := c.FormFile("image"); err == nil {
		if imagePath, err := saveImage(c, file); err == nil {
			motor.Image = imagePath
			config.DB.Save(&motor)
		} else {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal menyimpan gambar"})
			return
		}
	}

	c.JSON(http.StatusOK, gin.H{"message": "Motor berhasil ditambahkan", "data": motor})
}

// Fungsi untuk memperbarui motor
func UpdateMotor(c *gin.Context) {
	id := c.Param("id")
	var motor models.Motor
	var vendor models.Vendor
	input := make(map[string]interface{}) // Gunakan map untuk partial update

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

	// Update hanya jika ada input baru dari form-data
	if name := c.PostForm("name"); name != "" {
		input["name"] = name
	}
	if brand := c.PostForm("brand"); brand != "" {
		input["brand"] = brand
	}
	if PlatMotor := c.PostForm("platmotor"); PlatMotor != "" {
		input["platmotor"] = PlatMotor
	}

	if color := c.PostForm("color"); color != "" {
		input["color"] = color
	}
	if status := c.PostForm("status"); status != "" {
		input["status"] = status
	}
	if motorType := c.PostForm("type"); motorType != "" { // Tambahan kolom Type
		input["type"] = motorType
	}
	if description := c.PostForm("description"); description != "" { // Tambahan kolom Description
		input["description"] = description
	}

	// Update Year jika valid (jangan set 0)
	if yearStr := c.PostForm("year"); yearStr != "" {
		year, err := strconv.Atoi(yearStr)
		if err == nil && year > 0 {
			input["year"] = year
		}
	}

	// Update Price jika valid
	if priceStr := c.PostForm("price"); priceStr != "" {
		price, err := strconv.ParseFloat(priceStr, 64)
		if err == nil {
			input["price"] = price
		}
	}

	// Tangani file gambar jika ada
	if file, err := c.FormFile("image"); err == nil {
		// Hapus gambar lama jika ada
		if motor.Image != "" {
			// Ubah URL relatif menjadi path file sistem, misal: "/fileserver/motor/filename.jpg" -> "./fileserver/motor/filename.jpg"
			oldPath := "." + motor.Image
			if err := os.Remove(oldPath); err != nil {
				log.Printf("Gagal menghapus file gambar lama: %v", err)
			}
		}
		// Simpan gambar baru
		imagePath, err := saveImage(c, file)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal menyimpan gambar"})
			return
		}
		input["image"] = imagePath
	}

	// Gunakan GORM Updates agar hanya field yang diubah yang tersimpan
	if err := config.DB.Model(&motor).Updates(input).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal memperbarui motor"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Motor berhasil diperbarui", "data": motor})
}
func GetAllMotorByVendorID(c *gin.Context) {
	vendorID := c.Param("vendor_id")
	var motors []models.Motor

	// Ambil semua motor berdasarkan VendorID dengan informasi vendor terkait
	if err := config.DB.
		Where("vendor_id = ?", vendorID).
		Select("id, vendor_id, name, brand,  year, rating, price, platmotor,color,description,type, status, image, created_at, updated_at").
		Find(&motors).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal mengambil data motor"})
		return
	}

	// Periksa apakah ada motor yang tersedia untuk vendor tertentu
	if len(motors) == 0 {
		c.JSON(http.StatusNotFound, gin.H{"message": "Tidak ada motor yang tersedia untuk vendor ini"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "Berhasil mengambil data motor berdasarkan vendor",
		"data":    motors,
	})
}

// Fungsi untuk mendapatkan semua motor dari vendor yang login
// Fungsi untuk mendapatkan semua motor beserta informasi vendor
func GetAllMotor(c *gin.Context) {
	var motors []models.Motor

	// Ambil semua data motor dengan vendor terkait
	if err := config.DB.
		Preload("Vendor").
		Preload("Vendor.Kecamatan").
		Preload("Vendor.User").
		Find(&motors).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal mengambil data motor"})
		return
	}

	// Periksa apakah data motor ditemukan
	if len(motors) == 0 {
		c.JSON(http.StatusNotFound, gin.H{"message": "Tidak ada motor yang tersedia"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "Berhasil mengambil data motor",
		"data":    motors,
	})
}

// Fungsi untuk mendapatkan motor berdasarkan ID
func GetMotorByID(c *gin.Context) {
	id := c.Param("id")
	var motor models.Motor

	if err := config.DB.First(&motor, id).Error; err != nil {
		fmt.Println("Error:", err) // Menampilkan error lebih detail
		c.JSON(http.StatusNotFound, gin.H{"error": "Motor tidak ditemukan"})
		return
	}
	fmt.Printf("%+v\n", motor)
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
		Select("id, vendor_id, name, brand, year, price,platmotor, color,rating, description,type, status, image, created_at, updated_at").
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
func GetMotorByIDolehvendor(c *gin.Context) {
	var motor models.Motor

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

	// Ambil ID motor dari parameter URL
	motorID := c.Param("id")

	// Cari motor berdasarkan vendor_id dan motor_id
	if err := config.DB.
		Where("vendor_id = ? AND id = ?", vendor.ID, motorID).
		First(&motor).Error; err != nil {
		// Jika motor tidak ditemukan
		if err.Error() == "record not found" {
			c.JSON(http.StatusNotFound, gin.H{"error": "Motor tidak ditemukan"})
			return
		}
		// Jika ada error lainnya
		fmt.Printf("❌ Gagal mengambil data motor: %v\n", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal mengambil data motor"})
		return
	}

	// Kembalikan data motor
	c.JSON(http.StatusOK, gin.H{
		"message": "Berhasil mengambil data motor",
		"data":    motor,
	})
}

// Fungsi untuk menghapus motor
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

	// Periksa apakah ada booking aktif yang terkait dengan motor ini
	var activeBookings []models.Booking
	if err := config.DB.Where("motor_id = ? AND status IN ('pending', 'confirmed', 'in transit', 'in use')", motor.ID).Find(&activeBookings).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal memeriksa booking aktif"})
		return
	}

	// Jika ada booking aktif, motor tidak dapat dihapus
	if len(activeBookings) > 0 {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Motor tidak dapat dihapus karena masih ada booking aktif"})
		return
	}

	// Hapus motor dari database
	if err := config.DB.Delete(&motor).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal menghapus motor"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Motor berhasil dihapus"})
}
