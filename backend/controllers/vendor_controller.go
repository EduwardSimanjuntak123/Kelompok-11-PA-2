package controllers

import (
	"fmt"
	"net/http"
	"rental-backend/config"
	"rental-backend/models"
	"strings"

	"github.com/gin-gonic/gin"
	"golang.org/x/crypto/bcrypt"
	"gorm.io/gorm"
)

func RegisterVendor(c *gin.Context) {
	var input struct {
		Name            string `json:"name" binding:"required"`
		Email           string `json:"email" binding:"required,email"`
		Password        string `json:"password" binding:"required,min=6"`
		Phone           string `json:"phone" binding:"required"`
		ShopName        string `json:"shop_name" binding:"required"`
		ShopAddress     string `json:"shop_address" binding:"required"`
		ShopDescription string `json:"shop_description"`
		IDKecamatan     *uint  `json:"id_kecamatan"` // Menambahkan ID Kecamatan
	}

	// Validasi input JSON
	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Cek apakah email sudah digunakan oleh user atau vendor
	var existingUser models.User
	if err := config.DB.Where("email = ?", input.Email).First(&existingUser).Error; err == nil {
		// Cek jika user yang ditemukan memiliki role selain vendor
		if existingUser.Role == "vendor" {
			c.JSON(http.StatusConflict, gin.H{"error": "Email sudah digunakan oleh vendor"})
			return
		}
		if existingUser.Role == "customer" {
			c.JSON(http.StatusConflict, gin.H{"error": "Email sudah digunakan oleh pelanggan"})
			return
		}
	}

	// **Hash password sebelum menyimpan**
	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(strings.TrimSpace(input.Password)), bcrypt.DefaultCost)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Terjadi kesalahan dalam hashing password"})
		return
	}

	// Debugging
	fmt.Println("✅ Password hash berhasil dibuat:", string(hashedPassword))

	// Buat user baru
	user := models.User{
		Name:     input.Name,
		Email:    input.Email,
		Password: string(hashedPassword),
		Role:     "vendor", // Set role sebagai 'vendor'
		Phone:    input.Phone,
		Address:  input.ShopAddress, // Gunakan alamat toko untuk address user
		Status:   "active",          // Status default aktif
	}

	// **Simpan ke database**
	if err := config.DB.Create(&user).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal menyimpan data vendor"})
		return
	}

	// Setelah user berhasil dibuat, buat vendor terkait
	vendor := models.Vendor{
		UserID:          user.ID,        // Menghubungkan vendor dengan user
		ShopName:        input.ShopName, // Menyimpan nama toko
		ShopAddress:     input.ShopAddress,
		ShopDescription: input.ShopDescription,
		Status:          "active",          // Status vendor aktif
		IDKecamatan:     input.IDKecamatan, // Menyertakan ID kecamatan
	}

	// Simpan vendor ke database
	if err := config.DB.Create(&vendor).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal menyimpan data vendor"})
		return
	}

	// Debugging
	fmt.Println("✅ Vendor berhasil terdaftar dengan user ID:", user.ID)

	// Pastikan response yang benar
	c.JSON(http.StatusOK, gin.H{"message": "Pendaftaran vendor berhasil"})
}

func CompleteBooking(c *gin.Context) {
	id := c.Param("id")

	// Cek apakah booking yang dimaksud ada
	var booking models.Booking
	if err := config.DB.Where("id = ?", id).First(&booking).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Booking tidak ditemukan"})
		return
	}

	// Ubah status booking menjadi "completed"
	if err := config.DB.Model(&models.Booking{}).Where("id = ?", id).Update("status", "completed").Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal mengubah status booking"})
		return
	}

	// Setelah status booking menjadi "completed", buat transaksi otomatis
	CreateTransaction(booking) // Panggil CreateTransaction dengan data booking yang telah selesai

	c.JSON(http.StatusOK, gin.H{"message": "Booking selesai, transaksi dibuat otomatis"})
}

func GetVendorProfile(c *gin.Context) {
	userID, exists := c.Get("user_id")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "User tidak ditemukan, harap login ulang"})
		return
	}

	var user models.User
	// Ambil data user beserta vendor
	if err := config.DB.
		Select("id, name, email, role, phone, address, profile_image, ktp_image, status, created_at, updated_at").
		Preload("Vendor", func(db *gorm.DB) *gorm.DB {
			return db.Select("id, user_id, id_kecamatan, shop_name, shop_address, shop_description, status, created_at, updated_at")
		}).
		Where("id = ? AND name IS NOT NULL AND email IS NOT NULL", userID).
		First(&user).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "User tidak ditemukan atau bukan vendor"})
		return
	}

	// Pastikan user memiliki vendor
	if user.Role != "vendor" || user.Vendor.ID == 0 {
		c.JSON(http.StatusNotFound, gin.H{"error": "Vendor tidak ditemukan"})
		return
	}

	// Mengembalikan JSON tanpa duplikasi
	c.JSON(http.StatusOK, gin.H{"user": user})
}
