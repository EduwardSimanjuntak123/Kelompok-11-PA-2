package controllers

import (
	"net/http"
	"os"
	"rental-backend/config"
	"rental-backend/dto"
	"rental-backend/models"

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




// Change Password
func ChangePassword(c *gin.Context) {
    var input struct {
        OldPassword string `json:"old_password" binding:"required"`
        NewPassword string `json:"new_password" binding:"required"`
    }

    id := c.MustGet("user_id").(uint)
    var user models.User
    config.DB.First(&user, id)

    if bcrypt.CompareHashAndPassword([]byte(user.Password), []byte(input.OldPassword)) != nil {
        c.JSON(http.StatusUnauthorized, gin.H{"error": "Password lama salah"})
        return
    }

    hashedPassword, err := bcrypt.GenerateFromPassword([]byte(input.NewPassword), bcrypt.DefaultCost)
    if err != nil {
        c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal mengenkripsi password"})
        return
    }

    config.DB.Model(&user).Update("password", hashedPassword)
    c.JSON(http.StatusOK, gin.H{"message": "Password berhasil diubah"})
}

