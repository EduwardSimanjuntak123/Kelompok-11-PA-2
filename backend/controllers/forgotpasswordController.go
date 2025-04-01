package controllers

import (
	"fmt"
	"math/rand"
	"net/http"
	"net/smtp"
	"rental-backend/config"
	"rental-backend/models"
	"strconv"
	"strings"
	"time"

	"github.com/gin-gonic/gin"
	"golang.org/x/crypto/bcrypt"
)

// SendOTPEmail mengirim email yang berisi OTP
func SendOTPEmail(email string, otp string) error {
	from := "eduwardsimanjuntak02@gmail.com" // Ganti dengan alamat email pengirim
	pass := "nhto bysa efzx aoyw"  // Ganti dengan password email pengirim

	// Membuat pesan email
	subject := "Your OTP for Password Reset"
	body := fmt.Sprintf("Use this OTP to reset your password: %s", otp)

	// Setup email headers dan body
	msg := "From: " + from + "\n" +
		"To: " + email + "\n" +
		"Subject: " + subject + "\n\n" +
		body

	// Setup SMTP server
	smtpHost := "smtp.gmail.com"
	smtpPort := "587"

	// Kirim email
	auth := smtp.PlainAuth("", from, pass, smtpHost)
	return smtp.SendMail(smtpHost+":"+smtpPort, auth, from, []string{email}, []byte(msg))
}

// GenerateOTP menghasilkan OTP 6 digit acak
func generateOTP() string {
	rand.Seed(time.Now().UnixNano()) // Seed untuk memastikan angka acak berbeda setiap kali dijalankan
	otp := rand.Intn(900000) + 100000 // Hasilkan angka acak antara 100000 dan 999999
	return strconv.Itoa(otp)          // Ubah angka menjadi string
}

// SendOTPEmailHandler menangani permintaan pengiriman OTP
func SendOTPEmailHandler(c *gin.Context) {
	// Ambil email dari request body
	var input struct {
		Email string `json:"email" binding:"required,email"`
	}

	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": fmt.Sprintf("Gagal memproses input: %s", err.Error())})
		return
	}

	// Generate OTP
	otp := generateOTP() // Generate OTP acak

	// Simpan OTP di database
	otpRequest := models.OtpRequest{
		Email:    input.Email,
		OTP:      otp,
		ExpiresAt: time.Now().Add(10 * time.Minute), // OTP kadaluarsa dalam 10 menit
	}

	if err := config.DB.Create(&otpRequest).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": fmt.Sprintf("Gagal menyimpan OTP di database: %s", err.Error())})
		return
	}

	// Kirim OTP ke email
	err := SendOTPEmail(input.Email, otp)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": fmt.Sprintf("Gagal mengirim OTP ke email %s: %s", input.Email, err.Error())})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "OTP berhasil dikirim"})
}

// ChangePasswordWithOTP menangani perubahan password dengan OTP
func ChangePasswordWithOTP(c *gin.Context) {
	var input struct {
		Email       string `json:"email" binding:"required,email"`
		NewPassword string `json:"new_password" binding:"required,min=6"`
		OTP         string `json:"otp" binding:"required"`
	}

	// Bind input JSON ke struct
	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": fmt.Sprintf("Gagal memproses input: %s", err.Error())})
		return
	}

	// Validasi apakah email terdaftar
	var user models.User
	if err := config.DB.Where("email = ?", input.Email).First(&user).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": fmt.Sprintf("Email %s tidak ditemukan: %s", input.Email, err.Error())})
		return
	}

	// Cari OTP berdasarkan email
	var otpRequest models.OtpRequest
	if err := config.DB.Where("email = ? AND otp = ?", input.Email, input.OTP).First(&otpRequest).Error; err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": fmt.Sprintf("OTP %s untuk email %s tidak valid: %s", input.OTP, input.Email, err.Error())})
		return
	}

	// Periksa apakah OTP sudah expired
	if otpRequest.ExpiresAt.Before(time.Now()) {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "OTP telah kadaluarsa"})
		return
	}

	// Hash password baru
	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(strings.TrimSpace(input.NewPassword)), bcrypt.DefaultCost)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": fmt.Sprintf("Kesalahan dalam hashing password: %s", err.Error())})
		return
	}

	// Update password di database
	if err := config.DB.Model(&user).Update("password", string(hashedPassword)).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": fmt.Sprintf("Gagal mengubah password untuk email %s: %s", input.Email, err.Error())})
		return
	}

	// Hapus OTP setelah digunakan
	if err := config.DB.Delete(&otpRequest).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": fmt.Sprintf("Gagal menghapus OTP setelah digunakan: %s", err.Error())})
		return
	}

	// Kirim respons sukses
	c.JSON(http.StatusOK, gin.H{"message": "Password berhasil diubah"})
}
