package controllers

import (
	"fmt"
	"log"
	"net/http"
	"rental-backend/config"
	"rental-backend/models"
	"strings"
	"time"

	"github.com/dgrijalva/jwt-go"
	"github.com/gin-gonic/gin"
	"golang.org/x/crypto/bcrypt"
)

func RegisterCustomer(c *gin.Context) {
	var input struct {
		Name     string `json:"name" binding:"required"`
		Email    string `json:"email" binding:"required,email"`
		Password string `json:"password" binding:"required,min=6"`
		Phone    string `json:"phone" binding:"required"`
		Address  string `json:"address"`
	}

	// Validasi input JSON
	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Cek apakah email sudah digunakan
	var existingUser models.User
	if err := config.DB.Where("email = ?", input.Email).First(&existingUser).Error; err == nil {
		c.JSON(http.StatusConflict, gin.H{"error": "Email sudah digunakan"})
		return
	}

	// **Hash password sebelum menyimpan**
	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(strings.TrimSpace(input.Password)), bcrypt.DefaultCost)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Terjadi kesalahan dalam hashing password"})
		return
	}

	fmt.Println("✅ Password hash berhasil dibuat:", string(hashedPassword)) // Debugging

	// Buat user baru
	user := models.User{
		Name:     input.Name,
		Email:    input.Email,
		Password: string(hashedPassword), // Simpan hash password
		Role:     "customer",
		Phone:    input.Phone,
		Address:  input.Address,
		Status:   "active",
	}

	// **Simpan ke database**
	if err := config.DB.Create(&user).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal menyimpan data pelanggan"})
		return
	}

	fmt.Println("✅ User berhasil terdaftar dengan password hash:", user.Password) // Debugging

	c.JSON(http.StatusOK, gin.H{"message": "Pendaftaran pelanggan berhasil"})
}
func LoginCustomer(c *gin.Context) {
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
	fmt.Println("🔍 Mencari user dengan email:", input.Email)

	// Cari user berdasarkan email
	if err := config.DB.Debug().Select("id, name, email, password, role, phone, address, status").Where("email = ?", input.Email).First(&user).Error; err != nil {
		fmt.Println("❌ User tidak ditemukan di database:", input.Email)
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Email tidak ditemukan"})
		return
	}

	// Pastikan user adalah customer
	if user.Role != "customer" {
		fmt.Println("❌ Akses ditolak. User bukan customer:", user.Email)
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Akses ditolak"})
		return
	}

	// Verifikasi password dengan bcrypt
	err := bcrypt.CompareHashAndPassword([]byte(user.Password), []byte(input.Password))
	if err != nil {
		fmt.Println("❌ Password salah")
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Password salah"})
		return
	}

	// **Buat token JWT**
	claims := jwt.MapClaims{
		"user_id": user.ID,
		"role":    user.Role,
		"exp":     time.Now().Add(24 * time.Hour).Unix(),
	}

	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	tokenString, err := token.SignedString([]byte("secret123"))
	if err != nil {
		fmt.Println("❌ Gagal membuat token:", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal membuat token"})
		return
	}

	fmt.Println("✅ Login berhasil untuk:", user.Email)

	c.JSON(http.StatusOK, gin.H{
		"message": "Login berhasil untuk pelanggan",
		"token":   tokenString,
	})
}

// Get All Motors
func GetAllMotors(c *gin.Context) {
	var motors []models.Motor
	config.DB.Where("status = ?", "available").Find(&motors)
	c.JSON(http.StatusOK, motors)
}

// Create Booking
func CreateBooking(c *gin.Context) {
	var booking models.Booking

	// Bind the JSON payload to the 'booking' struct
	if err := c.ShouldBindJSON(&booking); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}
	// Mengambil user dari token
	userID, exists := c.Get("user_id")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "User not authenticated"})
		return
	}
	booking.CustomerID = userID.(uint)

	// Cek apakah sudah ada booking dengan rentang tanggal yang sama untuk vendor dan motor yang sama
	var existingBooking models.Booking
	err := config.DB.Debug().Where("vendor_id = ? AND motor_id = ? AND ((start_date <= ? AND end_date >= ?) OR (start_date <= ? AND end_date >= ?))",
		booking.VendorID, booking.MotorID, booking.EndDate, booking.StartDate, booking.StartDate, booking.EndDate).
		First(&existingBooking).Error

	if err == nil {
		// Debug: Tampilkan status booking yang ditemukan
		log.Printf("Existing Booking Status: %s", existingBooking.Status)

		// Jika ada booking yang tumpang tindih, cek status booking yang sudah ada
		if existingBooking.Status != "canceled" && existingBooking.Status != "rejected" {
			// Jika status bukan "completed" atau "canceled", blokir booking baru
			c.JSON(http.StatusBadRequest, gin.H{"error": "Motor tidak dapat dibooking karena status booking sebelumnya bukan 'rejected' atau 'canceled'"})
			return
		}
	}
	if err == nil {
		log.Printf("Existing Booking: %+v", existingBooking) // Menampilkan seluruh data existingBooking
	} else {
		log.Printf("Error fetching existing booking: %v", err)
	}
	

	// Enable GORM Debug to log the SQL queries
	if err := config.DB.Debug().Create(&booking).Error; err != nil {
		// Log the error (optional)
		log.Printf("Error inserting booking: %v", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal menambahkan booking"})
		return
	}

	// Respond with success and the newly created booking data
	c.JSON(http.StatusOK, gin.H{"message": "Booking berhasil dibuat", "data": booking})
}

// Cancel Booking
func CancelBooking(c *gin.Context) {
	id := c.Param("id")
	var booking models.Booking

	// Cari booking berdasarkan ID
	if err := config.DB.Where("id = ?", id).First(&booking).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Booking tidak ditemukan"})
		return
	}

	// Pastikan hanya booking dengan status 'pending' yang dapat dibatalkan
	if booking.Status != "pending" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Hanya booking dengan status 'pending' yang dapat dibatalkan"})
		return
	}

	// Update status menjadi 'canceled'
	if err := config.DB.Model(&models.Booking{}).Where("id = ?", id).Update("status", "canceled").Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal membatalkan booking"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Booking berhasil dibatalkan"})
}


// Get Customer Transactions
func GetCustomerTransactions(c *gin.Context) {
	var transactions []models.Transaction
	config.DB.Where("customer_id = ?", c.MustGet("user_id")).Find(&transactions)
	c.JSON(http.StatusOK, transactions)
}

// Update Profile
func UpdateProfile(c *gin.Context) {
	var user models.User
	id := c.MustGet("user_id").(uint)

	if err := c.ShouldBindJSON(&user); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	config.DB.Model(&user).Where("id = ?", id).Updates(user)
	c.JSON(http.StatusOK, gin.H{"message": "Profil berhasil diperbarui"})
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

	hashedPassword, _ := bcrypt.GenerateFromPassword([]byte(input.NewPassword), bcrypt.DefaultCost)
	config.DB.Model(&user).Update("password", hashedPassword)

	c.JSON(http.StatusOK, gin.H{"message": "Password berhasil diubah"})
}
