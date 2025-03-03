package controllers

import (
	"fmt"
	"github.com/gin-gonic/gin"
	"golang.org/x/crypto/bcrypt"
	"net/http"
	"rental-backend/config"
	"rental-backend/models"
	"strings"
	"github.com/dgrijalva/jwt-go"
	"time"
)
func VendorLogin(c *gin.Context) {
	var input struct {
		Email    string `json:"email" binding:"required"`
		Password string `json:"password" binding:"required"`
	}

	// Validasi input JSON
	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	var user models.User

	if err := config.DB.Debug().Select("id, name, email, password, role, phone, address, status").Where("email = ? AND role = 'vendor'", input.Email).First(&user).Error; err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Email tidak ditemukan atau bukan pelanggan"})
		return
	}

	// Verifikasi password
	if err := bcrypt.CompareHashAndPassword([]byte(user.Password), []byte(input.Password)); err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Password salah"})
		return
	}

	// Generate JWT token jika login berhasil
	token := jwt.NewWithClaims(jwt.SigningMethodHS256, jwt.MapClaims{
		"user_id": user.ID,
		"role":    user.Role,
		"exp":     time.Now().Add(24 * time.Hour).Unix(),
	})
	tokenString, _ := token.SignedString([]byte("secret123"))

	// Kirim response sukses login
	c.JSON(http.StatusOK, gin.H{
		"message": "Login berhasil sebagai vendoor",
		"token":   tokenString,
	})
}
func RegisterVendor(c *gin.Context) {
	var input struct {
		Name          string `json:"name" binding:"required"`
		Email         string `json:"email" binding:"required,email"`
		Password      string `json:"password" binding:"required,min=6"`
		Phone         string `json:"phone" binding:"required"`
		ShopName      string `json:"shop_name" binding:"required"`
		ShopAddress   string `json:"shop_address" binding:"required"`
		ShopDescription string `json:"shop_description"`
		IDKecamatan   *uint  `json:"id_kecamatan"` // Menambahkan ID Kecamatan
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
		Status:   "active",         // Status default aktif
	}

	// **Simpan ke database**
	if err := config.DB.Create(&user).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal menyimpan data vendor"})
		return
	}

	// Setelah user berhasil dibuat, buat vendor terkait
	vendor := models.Vendor{
		UserID:       user.ID,           // Menghubungkan vendor dengan user
		ShopName:     input.ShopName,    // Menyimpan nama toko
		ShopAddress:  input.ShopAddress,
		ShopDescription: input.ShopDescription,
		Status:       "active",          // Status vendor aktif
		IDKecamatan:  input.IDKecamatan, // Menyertakan ID kecamatan
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


// Confirm Booking
func ConfirmBooking(c *gin.Context) {
	id := c.Param("id")
	config.DB.Model(&models.Booking{}).Where("id = ?", id).Update("status", "confirmed")
	c.JSON(http.StatusOK, gin.H{"message": "Booking diterima"})
}

// Reject Booking
func RejectBooking(c *gin.Context) {
	id := c.Param("id")
	config.DB.Model(&models.Booking{}).Where("id = ?", id).Update("status", "canceled")
	c.JSON(http.StatusOK, gin.H{"message": "Booking ditolak"})
}

// Upload Manual Transaction
func AddManualTransaction(c *gin.Context) {
	var transaction models.Transaction
	if err := c.ShouldBindJSON(&transaction); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	transaction.Type = "manual"
	transaction.Status = "completed"
	config.DB.Create(&transaction)

	c.JSON(http.StatusOK, gin.H{"message": "Transaksi manual berhasil ditambahkan"})
}

// Get Vendor Transactions
func GetVendorTransactions(c *gin.Context) {
	var transactions []models.Transaction
	config.DB.Find(&transactions)
	c.JSON(http.StatusOK, transactions)
}
