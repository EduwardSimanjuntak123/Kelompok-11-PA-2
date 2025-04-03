package controllers

import (
	"fmt"
	"net/http"
	"os"
	"path/filepath"
	"rental-backend/config"
	"rental-backend/models"
	"strings"
	"time"

	"github.com/gin-gonic/gin"
	"golang.org/x/crypto/bcrypt"
)

func saveUserImage(c *gin.Context, field string) (string, error) {
    file, err := c.FormFile(field)
    if err != nil {
        return "", nil
    }

    filename := fmt.Sprintf("%d_%s", time.Now().Unix(), file.Filename)
    filePath := filepath.Join("./fileserver/users", filename)

    if err := os.MkdirAll("./fileserver/users", os.ModePerm); err != nil {
        return "", err
    }

    if err := c.SaveUploadedFile(file, filePath); err != nil {
        return "", err
    }

    return "/fileserver/users/" + filename, nil
}
func RegisterCustomer(c *gin.Context) {
	var input struct {
		Name     string `form:"name" binding:"required"`
		Email    string `form:"email" binding:"required,email"`
		Password string `form:"password" binding:"required,min=6"`
		Phone    string `form:"phone" binding:"required"`
		Address  string `form:"address"`
	}

	// Bind input data dari form
	if err := c.ShouldBind(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Cek apakah email sudah terdaftar
	var existingUser models.User
	if err := config.DB.Where("email = ?", input.Email).First(&existingUser).Error; err == nil {
		c.JSON(http.StatusConflict, gin.H{"error": "Email sudah digunakan"})
		return
	}

	// Hash password
	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(strings.TrimSpace(input.Password)), bcrypt.DefaultCost)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Kesalahan dalam hashing password"})
		return
	}

	// Simpan gambar profil jika diunggah
	profileImage, err := saveUserImage(c, "profile_image")
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal menyimpan gambar profil"})
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
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal menyimpan data OTP"})
		return
	}

	// Kirim OTP ke email
	if err := SendOTPEmail(input.Email, otp); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal mengirim OTP ke email"})
		return
	}

	// Simpan data user dengan status "pending"
	user := models.User{
		Name:         input.Name,
		Email:        input.Email,
		Password:     string(hashedPassword),
		Role:         "customer",
		Phone:        input.Phone,
		Address:      input.Address,
		ProfileImage: profileImage, // Simpan gambar jika ada
		Status:       "pending",
	}
	if err := config.DB.Create(&user).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal menyimpan data pelanggan"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "OTP telah dikirim ke email, harap verifikasi", "profile_image": profileImage})
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
