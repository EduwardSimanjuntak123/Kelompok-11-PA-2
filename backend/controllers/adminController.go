package controllers

import (
	"net/http"
	"rental-backend/config"
	"rental-backend/models"
	"strconv"
	"time"

	"github.com/gin-gonic/gin"
)

func GetDataAdmin(c *gin.Context) {
	// Ambil user_id dari token JWT
	userID, exists := c.Get("user_id")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Admin tidak terautentikasi"})
		return
	}

	var user models.User

	// Ambil data user yang sedang login tanpa preload Vendor atau Booking
	if err := config.DB.Select("id, name, email, phone, address, profile_image, status, created_at, updated_at").
		Where("id = ? AND role = ?", userID, "admin").
		First(&user).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Admin tidak ditemukan"})
		return
	}

	// Format response hanya dengan data yang relevan
	response := gin.H{
		"id":            user.ID,
		"name":          user.Name,
		"email":         user.Email,
		"phone":         user.Phone,
		"address":       user.Address,
		"profile_image": user.ProfileImage,
		"status":        user.Status,
		"created_at":    user.CreatedAt,
		"updated_at":    user.UpdatedAt,
	}

	c.JSON(http.StatusOK, response)
}

func EditDataAdmin(c *gin.Context) {
	userID, exists := c.Get("user_id")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Admin tidak terautentikasi"})
		return
	}

	var admin models.User
	if err := config.DB.Where("id = ? AND role = ?", userID, "admin").First(&admin).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Data admin tidak ditemukan"})
		return
	}

	var input map[string]interface{}
	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Format data tidak valid"})
		return
	}

	// Perbarui data admin dengan data yang diberikan
	input["updated_at"] = time.Now()
	if err := config.DB.Model(&admin).Updates(input).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal memperbarui data admin"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Data admin berhasil diperbarui", "admin": admin})
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
