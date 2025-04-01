package controllers

import (
	"net/http"
	"rental-backend/config"
	"rental-backend/models"
	"strings"
	"time"

	"github.com/gin-gonic/gin"
	"golang.org/x/crypto/bcrypt"
)

// RegisterCustomer menangani proses registrasi pelanggan.
// Pada fungsi ini, data pengguna disimpan dengan status "pending" dan OTP dikirim ke email.
// OTP disimpan di tabel terpisah (OtpRequest).
func RegisterCustomer(c *gin.Context) {
	var input struct {
		Name     string `form:"name" binding:"required"`
		Email    string `form:"email" binding:"required,email"`
		Password string `form:"password" binding:"required,min=6"`
		Phone    string `form:"phone" binding:"required"`
		Address  string `form:"address"`
	}

	if err := c.ShouldBind(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Jika diperlukan, Anda dapat memeriksa apakah email sudah terdaftar.
	// Namun, jika ingin memverifikasi bahwa email benar-benar ada melalui OTP,
	// Anda bisa menghilangkan pengecekan ini.
	var existingUser models.User
	if err := config.DB.Where("email = ?", input.Email).First(&existingUser).Error; err == nil {
		c.JSON(http.StatusConflict, gin.H{"error": "Email sudah digunakan"})
		return
	}

	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(strings.TrimSpace(input.Password)), bcrypt.DefaultCost)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Kesalahan dalam hashing password"})
		return
	}

	// Generate OTP dan simpan ke tabel otp_requests
	otp := generateOTP()
	otpRequest := models.OtpRequest{
		Email:     input.Email,
		OTP:       otp,
		ExpiresAt: time.Now().Add(10 * time.Minute),
	}
	if err := config.DB.Create(&otpRequest).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal menyimpan data OTP"})
		return
	}

	// Kirim OTP ke email
	if err := SendOTPEmail(input.Email, otp); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal mengirim OTP ke email"})
		return
	}

	// Simpan data user dengan status "pending" (belum aktif) tanpa field OTP
	user := models.User{
		Name:     input.Name,
		Email:    input.Email,
		Password: string(hashedPassword),
		Role:     "customer",
		Phone:    input.Phone,
		Address:  input.Address,
		Status:   "pending",
	}
	if err := config.DB.Create(&user).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal menyimpan data pelanggan"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "OTP telah dikirim ke email, harap verifikasi"})
}

// VerifyOTP menangani verifikasi OTP yang telah dikirim ke email pengguna.
// Jika OTP valid dan belum kadaluarsa, status pengguna akan diupdate menjadi "active" dan record OTP dihapus.
func VerifyOTP(c *gin.Context) {
	var input struct {
		Email string `json:"email" binding:"required,email"`
		OTP   string `json:"otp" binding:"required"`
	}
	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Cari record OTP di tabel otp_requests
	var otpRequest models.OtpRequest
	if err := config.DB.Where("email = ? AND otp = ?", input.Email, input.OTP).First(&otpRequest).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "OTP tidak ditemukan atau tidak valid"})
		return
	}

	if time.Now().After(otpRequest.ExpiresAt) {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "OTP telah kadaluarsa"})
		return
	}

	// Update status user menjadi "active"
	var user models.User
	if err := config.DB.Where("email = ?", input.Email).First(&user).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "User tidak ditemukan"})
		return
	}
	config.DB.Model(&user).Update("status", "active")

	// Hapus record OTP yang sudah digunakan
	config.DB.Delete(&otpRequest)

	c.JSON(http.StatusOK, gin.H{"message": "Verifikasi berhasil, akun telah diaktifkan"})
}
