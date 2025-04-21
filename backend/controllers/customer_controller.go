package controllers

import (
	"net/http"
	"os"
	"rental-backend/config"
	"rental-backend/dto"
	"rental-backend/models"
	"strings"

	"github.com/gin-gonic/gin"
	"golang.org/x/crypto/bcrypt"
)

func GetCustomerProfile(c *gin.Context) {
	userID, exists := c.Get("user_id")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "User tidak ditemukan, harap login ulang"})
		return
	}

	var user models.User
	if err := config.DB.Select("id, name, email, role, birth_date, phone, address, profile_image, status, created_at, updated_at").
		Where("id = ? AND role = ?", userID, "customer").
		First(&user).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Customer tidak ditemukan"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"user": user})
}

// Get All Motors
func GetAllMotors(c *gin.Context) {
	var motors []models.Motor
	if err := config.DB.Where("status = ?", "available").Find(&motors).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal mengambil data motor"})
		return
	}
	c.JSON(http.StatusOK, motors)
}

// saveBookingImage menyimpan file gambar booking ke folder ./fileserver/booking

// Cancel Booking
func CancelBooking(c *gin.Context) {
	id := c.Param("id")
	var booking models.Booking

	if err := config.DB.Where("id = ?", id).First(&booking).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Booking tidak ditemukan"})
		return
	}

	if booking.Status != "pending" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Hanya booking dengan status 'pending' yang dapat dibatalkan"})
		return
	}

	if err := config.DB.Model(&booking).Update("status", "canceled").Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal membatalkan booking"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Booking berhasil dibatalkan"})
}

// Get Customer Transactions
func GetCustomerTransactions(c *gin.Context) {
	var transactions []models.Transaction
	if err := config.DB.Where("customer_id = ?", c.MustGet("user_id")).Find(&transactions).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal mengambil transaksi"})
		return
	}
	c.JSON(http.StatusOK, transactions)
}

// Update Profile
func EditProfile(c *gin.Context) {
	userID := c.MustGet("user_id").(uint)

	var input dto.EditProfileRequest
	if err := c.ShouldBind(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	var user models.User
	if err := config.DB.First(&user, userID).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "User tidak ditemukan"})
		return
	}

	updates := map[string]interface{}{}

	// Upload foto profil menggunakan helper
	newImagePath, err := saveUserImage(c, "profile_image")
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal mengunggah gambar"})
		return
	}
	if newImagePath != "" {
		// Hapus gambar lama jika ada
		if user.ProfileImage != "" {
			_ = os.Remove("." + user.ProfileImage) // tambahkan "." karena user.ProfileImage = "/fileserver/..."
		}
		updates["profile_image"] = newImagePath
	}

	// Update data profil jika ada perubahan
	if input.Name != "" {
		updates["name"] = input.Name
	}
	if input.Email != "" {
		updates["email"] = input.Email
	}
	if input.Phone != "" {
		updates["phone"] = input.Phone
	}
	if input.Address != "" {
		updates["address"] = input.Address
	}

	if err := config.DB.Model(&user).Updates(updates).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal memperbarui profil"})
		return
	}

	response := dto.UserResponse{
		Name:         user.Name,
		Email:        user.Email,
		Phone:        user.Phone,
		Address:      user.Address,
		ProfileImage: user.ProfileImage,
	}

	c.JSON(http.StatusOK, gin.H{"message": "Profil berhasil diperbarui", "user": response})
}

type ChangePasswordInput struct {
	OldPassword string `json:"old_password" binding:"required,min=6"`
	NewPassword string `json:"new_password" binding:"required,min=6"`
}

// ChangePassword handles a user's request to update their password.
func ChangePassword(c *gin.Context) {
	var input ChangePasswordInput

	// Bind JSON body to input struct
	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid request data: " + err.Error()})
		return
	}

	// Retrieve user ID from context (set by authentication middleware)
	userID, exists := c.Get("user_id")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized"})
		return
	}

	// Fetch only the password field to ensure GORM loads it
	var user models.User
	if err := config.DB.Select("password").First(&user, userID).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "User not found"})
		return
	}

	// Compare provided old password with stored hash
	trimmedOld := strings.TrimSpace(input.OldPassword)
	if err := bcrypt.CompareHashAndPassword([]byte(user.Password), []byte(trimmedOld)); err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Incorrect old password"})
		return
	}

	// Hash the new password
	trimmedNew := strings.TrimSpace(input.NewPassword)
	hashedNew, err := bcrypt.GenerateFromPassword([]byte(trimmedNew), bcrypt.DefaultCost)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to encrypt new password"})
		return
	}

	// Update the password in database
	if err := config.DB.Model(&models.User{}).
		Where("id = ?", userID).
		Update("password", string(hashedNew)).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to update password"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Password successfully updated"})
}
