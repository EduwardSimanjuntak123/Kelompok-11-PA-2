package controllers

import (
	"fmt"
	"log"
	"mime/multipart"
	"net/http"
	"os"
	"path/filepath"
	"rental-backend/config"
	"rental-backend/models"
	"time"

	"golang.org/x/crypto/bcrypt"

	"strings"

	"github.com/gin-gonic/gin"
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

// Get All Motors
func GetAllMotors(c *gin.Context) {
	var motors []models.Motor
	config.DB.Where("status = ?", "available").Find(&motors)
	c.JSON(http.StatusOK, motors)
}
// saveBookingImage menyimpan file gambar booking ke folder ./fileserver/booking
func saveBookingImage(c *gin.Context, file *multipart.FileHeader) (string, error) {
	timestamp := time.Now().Format("20060102_150405")
	filename := fmt.Sprintf("%s%s", timestamp, filepath.Ext(file.Filename))
	filePath := filepath.Join("./fileserver/booking", filename)

	if err := os.MkdirAll("./fileserver/booking", os.ModePerm); err != nil {
		return "", err
	}
	if err := c.SaveUploadedFile(file, filePath); err != nil {
		return "", err
	}
	return "/fileserver/booking/" + filename, nil
}


func CreateBooking(c *gin.Context) {
	var booking models.Booking

	// Bind request (dikirim sebagai multipart/form-data) ke struct booking
	if err := c.ShouldBind(&booking); err != nil {
		log.Printf("Error binding request: %v", err)
		c.JSON(http.StatusBadRequest, gin.H{"error": "Format request tidak valid"})
		return
	}

	log.Printf("Debug: Booking data received: %+v", booking)

	// Ambil user_id dari token
	userID, exists := c.Get("user_id")
	if !exists {
		log.Printf("User not authenticated")
		c.JSON(http.StatusUnauthorized, gin.H{"error": "User not authenticated"})
		return
	}

	// Karena CustomerID bertipe *uint, ambil pointer dari userID
	id := userID.(uint)
	booking.CustomerID = &id

	log.Printf("Debug: User ID dari token: %v", id)

	// Mulai transaksi database
	tx := config.DB.Begin()

	// Ambil data pelanggan (customer) berdasarkan user_id dari token
	var customer models.User
	if err := tx.Select("id, name").Where("id = ?", id).First(&customer).Error; err != nil {
		tx.Rollback()
		log.Printf("Error fetching customer: %v", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal mendapatkan data pelanggan"})
		return
	}

	log.Printf("Debug: Customer Data -> ID: %d, Name: %s", customer.ID, customer.Name)

	// Set CustomerName di booking dari nama customer yang diambil
	booking.CustomerName = customer.Name

	// Validasi MotorID
	if booking.MotorID == 0 {
		tx.Rollback()
		c.JSON(http.StatusBadRequest, gin.H{"error": "MotorID tidak boleh 0. Pastikan gunakan 'motor_id' dalam request."})
		return
	}

	// Cari Motor berdasarkan MotorID
	var motor models.Motor
	if err := tx.Select("id, name, brand, model, year, price, vendor_id").Where("id = ?", booking.MotorID).First(&motor).Error; err != nil {
		tx.Rollback()
		log.Printf("Error fetching motor: %v", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal mendapatkan data motor"})
		return
	}

	log.Printf("Debug: Motor Data -> ID: %d, Name: '%s', VendorID: %d", motor.ID, motor.Name, motor.VendorID)

	if motor.VendorID == 0 {
		tx.Rollback()
		log.Printf("Motor with ID %d does not have a valid VendorID", booking.MotorID)
		c.JSON(http.StatusBadRequest, gin.H{"error": "Motor does not have a valid VendorID"})
		return
	}

	booking.VendorID = motor.VendorID

	// Validasi rentang tanggal
	if booking.EndDate.Before(booking.StartDate) {
		tx.Rollback()
		c.JSON(http.StatusBadRequest, gin.H{"error": "Tanggal booking tidak valid: end_date tidak boleh lebih awal dari start_date"})
		return
	}

	// Hitung durasi booking dalam hari
	duration := int(booking.EndDate.Sub(booking.StartDate).Hours() / 24)
	if duration <= 0 {
		tx.Rollback()
		c.JSON(http.StatusBadRequest, gin.H{"error": "Durasi booking tidak valid"})
		return
	}
	totalPrice := float64(duration) * motor.Price

	// Set status default dan booking date
	booking.Status = "pending"
	booking.BookingDate = time.Now()

	// Tangani file gambar untuk PhotoID (jika ada)
	if file, err := c.FormFile("photo_id"); err == nil {
		photoPath, err := saveBookingImage(c, file)
		if err != nil {
			tx.Rollback()
			log.Printf("Error saving photo_id: %v", err)
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal menyimpan foto ID"})
			return
		}
		booking.PhotoID = photoPath
	}

	// Tangani file gambar untuk KtpID (jika ada)
	if file, err := c.FormFile("ktp_id"); err == nil {
		ktpPath, err := saveBookingImage(c, file)
		if err != nil {
			tx.Rollback()
			log.Printf("Error saving ktp_id: %v", err)
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal menyimpan foto KTP"})
			return
		}
		booking.KtpID = ktpPath
	}

	// Insert booking ke database
	if err := tx.Create(&booking).Error; err != nil {
		tx.Rollback()
		log.Printf("Error inserting booking: %v", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal menambahkan booking"})
		return
	}

	// Commit transaksi
	tx.Commit()

	// Siapkan respons
	response := gin.H{
		"message":         "Booking berhasil dibuat",
		"booking_id":      booking.ID,
		"customer_name":   customer.Name,
		"booking_date":    booking.BookingDate,
		"start_date":      booking.StartDate,
		"end_date":        booking.EndDate,
		"pickup_location": booking.PickupLocation,
		"status":          "pending",
		"motor": gin.H{
			"id":            motor.ID,
			"name":          motor.Name,
			"brand":         motor.Brand,
			"model":         motor.Model,
			"year":          motor.Year,
			"price_per_day": motor.Price,
			"total_price":   totalPrice,
		},
		"photo_id": booking.PhotoID,
		"ktp_id":   booking.KtpID,
	}

	log.Printf("Booking successfully created: %+v", response)
	c.JSON(http.StatusOK, response)
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
