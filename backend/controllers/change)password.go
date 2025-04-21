package controllers

import (
	"net/http"
	"rental-backend/config"
	"rental-backend/models"

	"time"

	"github.com/gin-gonic/gin"
)

func VerifyResetPasswordOTP(c *gin.Context) {
	var input struct {
		Email string `json:"email" binding:"required,email"`
		OTP   string `json:"otp" binding:"required"`
	}
	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Validasi OTP
	var otpRequest models.OtpRequest
	if err := config.DB.Where("email = ? AND otp = ?", input.Email, input.OTP).First(&otpRequest).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "OTP tidak valid"})
		return
	}
	if time.Now().After(otpRequest.ExpiresAt) {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "OTP telah kadaluarsa"})
		return
	}

	// Tandai verifikasi sukses (kita gak langsung ganti password di sini)
	// Bisa simpan flag di cache/session jika perlu

	// Hapus OTP agar tidak bisa digunakan ulang
	config.DB.Delete(&otpRequest)

	c.JSON(http.StatusOK, gin.H{"message": "OTP valid, lanjutkan ubah password"})
}

func RequestResetPasswordOTP(c *gin.Context) {
	// Ambil email dari body
	var input struct {
		Email string `json:"email" binding:"required,email"`
	}
	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Ambil ID user dari token (misalnya dari middleware)
	userIDFromToken := c.MustGet("user_id").(uint)

	// Ambil user dari DB
	var user models.User
	if err := config.DB.First(&user, userIDFromToken).Error; err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "User tidak ditemukan"})
		return
	}

	// Cocokkan email input dengan email user dari token
	if user.Email != input.Email {
		c.JSON(http.StatusForbidden, gin.H{"error": "Email tidak cocok dengan akun aktif"})
		return
	}

	// Generate OTP
	otp := generateOTP()
	otpRequest := models.OtpRequest{
		Email:     input.Email,
		OTP:       otp,
		ExpiresAt: time.Now().Add(10 * time.Minute),
	}
	if err := config.DB.Create(&otpRequest).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal menyimpan OTP"})
		return
	}

	// Kirim OTP ke email
	if err := SendOTPEmail(input.Email, otp); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal mengirim OTP"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "OTP berhasil dikirim ke email"})
}
