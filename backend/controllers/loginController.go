package controllers

import (
	"fmt"
	"net/http"
	"time"

	"github.com/dgrijalva/jwt-go"
	"github.com/gin-gonic/gin"
	"golang.org/x/crypto/bcrypt"

	"rental-backend/config"
	"rental-backend/models"
)

var jwtKey = []byte("secret123") // Gantilah dengan key yang lebih aman

func LoginUser(c *gin.Context) {
	var input struct {
		Email    string `json:"email" binding:"required,email"`
		Password string `json:"password" binding:"required,min=6"`
	}

	// Validasi input JSON
	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	var user models.User

	// Cari user berdasarkan email
	if err := config.DB.Debug().Select("id, name, email, password, role, phone, address, status").Where("email = ?", input.Email).First(&user).Error; err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Email tidak ditemukan"})
		return
	}

	// Verifikasi password dengan bcrypt
	if err := bcrypt.CompareHashAndPassword([]byte(user.Password), []byte(input.Password)); err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Password salah"})
		return
	}

	// Cek role dan status akun
	if user.Role == "vendor" && user.Status == "inactive" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Akun anda telah dinonaktifkan"})
		return
	}

	// Buat token JWT baru setiap kali login
	claims := jwt.MapClaims{
		"user_id": user.ID,
		"role":    user.Role,
		"exp":     time.Now().Add(24 * time.Hour).Unix(),
	}
	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	tokenString, err := token.SignedString(jwtKey)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal membuat token"})
		return
	}

	// Simpan token baru di cookie
	c.SetCookie("token", tokenString, 86400, "/", "localhost", false, true)

	// Data user yang dikembalikan
	responseData := gin.H{
		"id":      user.ID,
		"name":    user.Name,
		"email":   user.Email,
		"role":    user.Role,
		"phone":   user.Phone,
		"address": user.Address,
		"status":  user.Status,
	}

	// Jika role adalah vendor, ambil data vendor
	if user.Role == "vendor" {
		var vendor models.Vendor
		if err := config.DB.Debug().Where("user_id = ?", user.ID).First(&vendor).Error; err == nil {
			responseData["vendor"] = gin.H{
				"id":            vendor.ID,
				"business_name": vendor.ShopName,
				"address":       vendor.ShopAddress,
				"status":        vendor.Status,
			}
		}
	}

	// Kirim response sukses login dengan token baru
	c.JSON(http.StatusOK, gin.H{
		"message": fmt.Sprintf("Login berhasil sebagai %s", user.Role),
		"token":   tokenString,
		"user":    responseData,
	})
}
