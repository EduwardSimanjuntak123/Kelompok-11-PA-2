package controllers

import (
	"net/http"
	"rental-backend/config"
	"rental-backend/models"
	"strconv"
	"time"

	"github.com/dgrijalva/jwt-go"
	"github.com/gin-gonic/gin"
	"golang.org/x/crypto/bcrypt"
)

// Admin Login
func AdminLogin(c *gin.Context) {
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

	if err := config.DB.Debug().Select("id, name, email, password, role, phone, address, status").Where("email = ? AND role = 'admin'", input.Email).First(&user).Error; err != nil {
		// fmt.Println("❌ User tidak ditemukan di database:", input.Email)
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
		"message": "Login berhasil sebagai admin",
		"token":   tokenString,
	})
}

// Get All Transactions
func GetAllTransactions(c *gin.Context) {
	var transactions []models.Transaction

	if err := config.DB.Find(&transactions).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal mengambil data transaksi"})
		return
	}

	c.JSON(http.StatusOK, transactions)
}

// Get All Users
func GetAllUsers(c *gin.Context) {
	var users []models.User

	if err := config.DB.Find(&users).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal mengambil data pengguna"})
		return
	}

	c.JSON(http.StatusOK, users)
}

// Deactivate Vendor
func DeactivateVendor(c *gin.Context) {
	var user models.User
	id := c.Param("id")

	// Validasi apakah ID adalah angka
	vendorID, err := strconv.Atoi(id)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "ID tidak valid"})
		return
	}

	// Cari user berdasarkan ID
	if err := config.DB.Where("id = ?", vendorID).First(&user).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Pengguna (vendor) tidak ditemukan"})
		return
	}

	// Pastikan user adalah vendor
	if user.Role != "vendor" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Pengguna bukan vendor"})
		return
	}

	// Update hanya kolom yang diperlukan
	if err := config.DB.Model(&user).Updates(map[string]interface{}{
		"status":     "inactive",
		"updated_at": time.Now(),
	}).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal menonaktifkan vendor"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Akun vendor berhasil dinonaktifkan"})
}
