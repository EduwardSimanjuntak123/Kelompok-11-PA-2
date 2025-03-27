package controllers

import (
	"fmt"
	"log"
	"mime/multipart"
	"net/http"
	"os"
	"path/filepath"
	"strconv"
	"strings"
	"time"

	"rental-backend/config"
	"rental-backend/models"

	"github.com/gin-gonic/gin"
	"golang.org/x/crypto/bcrypt"
	"gorm.io/gorm"
)

// RegisterVendor mendaftarkan vendor baru
func RegisterVendor(c *gin.Context) {
	var input struct {
		Name            string `json:"name" binding:"required"`
		Email           string `json:"email" binding:"required,email"`
		Password        string `json:"password" binding:"required,min=6"`
		Phone           string `json:"phone" binding:"required"`
		ShopName        string `json:"shop_name" binding:"required"`
		ShopAddress     string `json:"shop_address" binding:"required"`
		ShopDescription string `json:"shop_description"`
		IDKecamatan     *uint  `json:"id_kecamatan"`
	}

	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	var existingUser models.User
	if err := config.DB.Where("email = ?", input.Email).First(&existingUser).Error; err == nil {
		if existingUser.Role == "vendor" {
			c.JSON(http.StatusConflict, gin.H{"error": "Email sudah digunakan oleh vendor"})
			return
		}
		if existingUser.Role == "customer" {
			c.JSON(http.StatusConflict, gin.H{"error": "Email sudah digunakan oleh pelanggan"})
			return
		}
	}

	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(strings.TrimSpace(input.Password)), bcrypt.DefaultCost)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Terjadi kesalahan dalam hashing password"})
		return
	}

	fmt.Println("✅ Password hash berhasil dibuat:", string(hashedPassword))

	user := models.User{
		Name:     input.Name,
		Email:    input.Email,
		Password: string(hashedPassword),
		Role:     "vendor",
		Phone:    input.Phone,
		Address:  input.ShopAddress,
		Status:   "active",
	}

	if err := config.DB.Create(&user).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal menyimpan data vendor"})
		return
	}

	vendor := models.Vendor{
		UserID:          user.ID,
		ShopName:        input.ShopName,
		ShopAddress:     input.ShopAddress,
		ShopDescription: input.ShopDescription,
		Status:          "active",
		IDKecamatan:     input.IDKecamatan,
	}

	if err := config.DB.Create(&vendor).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal menyimpan data vendor"})
		return
	}

	fmt.Println("✅ Vendor berhasil terdaftar dengan user ID:", user.ID)
	c.JSON(http.StatusOK, gin.H{"message": "Pendaftaran vendor berhasil"})
}

// CompleteBooking menyelesaikan booking dan membuat transaksi otomatis
func CompleteBooking(c *gin.Context) {
	id := c.Param("id")

	// Ambil data booking beserta relasi Motor
	var booking models.Booking
	if err := config.DB.Preload("Motor").Where("id = ?", id).First(&booking).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Booking tidak ditemukan"})
		return
	}

	// Pastikan status booking adalah "confirmed"
	if booking.Status != "confirmed" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Booking hanya dapat diselesaikan jika statusnya 'confirmed'"})
		return
	}

	// Ubah status booking menjadi "completed"
	if err := config.DB.Model(&booking).Update("status", "completed").Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal mengubah status booking"})
		return
	}

	// Reload data booking agar field ID dan relasi terisi dengan benar (jika perlu)
	if err := config.DB.Preload("Motor").First(&booking, booking.ID).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal mengambil data booking terbaru"})
		return
	}

	// Buat transaksi otomatis berdasarkan data booking yang sudah selesai
	if err := CreateTransaction(booking); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal membuat transaksi otomatis", "details": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Booking selesai, transaksi dibuat otomatis"})
}


func CreateTransaction(booking models.Booking) error {
	// Pastikan relasi Motor sudah terisi
	if booking.Motor == nil {
		return fmt.Errorf("data motor tidak tersedia pada booking")
	}

	// Hitung durasi booking (dalam hari) dengan memanggil method GetDurationDays()
	duration := booking.GetDurationDays()
	totalPrice := booking.Motor.Price * float64(duration)

	// Tentukan tipe transaksi berdasarkan apakah booking memiliki CustomerID
	transactionType := "online"
	if booking.CustomerID == nil || *booking.CustomerID == 0 {
		transactionType = "manual"
	}

	// Buat objek transaksi dengan data yang sesuai
	transaction := models.Transaction{
		BookingID:      &booking.ID,
		VendorID:       booking.VendorID,
		MotorID:        booking.MotorID,
		Type:           transactionType,
		TotalPrice:     totalPrice,
		StartDate:      booking.StartDate,
		EndDate:        booking.EndDate,
		PickupLocation: booking.PickupLocation,
		Status:         "completed", // atau status sesuai kebutuhan
		CreatedAt:      time.Now(),
		UpdatedAt:      time.Now(),
	}

	// Jika CustomerID valid (non-nil dan tidak 0), masukkan juga
	if booking.CustomerID != nil && *booking.CustomerID != 0 {
		transaction.CustomerID = booking.CustomerID
	}

	// Simpan transaksi ke database
	if err := config.DB.Create(&transaction).Error; err != nil {
		return fmt.Errorf("error creating transaction: %w", err)
	}
	return nil
}


// GetVendorProfile mengambil data vendor beserta data user
func GetVendorProfile(c *gin.Context) {
	userID, exists := c.Get("user_id")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "User tidak ditemukan, harap login ulang"})
		return
	}

	var user models.User
	if err := config.DB.
		Select("id, name, email, role, phone, address, profile_image, ktp_image, status, created_at, updated_at").
		Preload("Vendor", func(db *gorm.DB) *gorm.DB {
			return db.Select("id, user_id, id_kecamatan, shop_name, shop_address, shop_description, status, created_at, updated_at")
		}).
		Where("id = ? AND name IS NOT NULL AND email IS NOT NULL", userID).
		First(&user).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "User tidak ditemukan atau bukan vendor"})
		return
	}

	if user.Role != "vendor" || user.Vendor == nil || user.Vendor.ID == 0 {
		c.JSON(http.StatusNotFound, gin.H{"error": "Vendor tidak ditemukan"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"user": user})
}

// EditProfileVendor mengupdate data profil vendor
func EditProfileVendor(c *gin.Context) {
	userID, exists := c.Get("user_id")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "User tidak terautentikasi"})
		return
	}

	var user models.User
	if err := config.DB.Preload("Vendor").Where("id = ? AND role = ?", userID, "vendor").First(&user).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Data vendor tidak ditemukan"})
		return
	}

	userInput := make(map[string]interface{})
	vendorInput := make(map[string]interface{})

	if name := c.PostForm("name"); name != "" {
		userInput["name"] = name
	}
	if email := c.PostForm("email"); email != "" {
		userInput["email"] = email
	}
	if phone := c.PostForm("phone"); phone != "" {
		userInput["phone"] = phone
	}
	if address := c.PostForm("address"); address != "" {
		userInput["address"] = address
	}
	if password := c.PostForm("password"); password != "" {
		hashedPassword, err := bcrypt.GenerateFromPassword([]byte(password), bcrypt.DefaultCost)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal meng-hash password"})
			return
		}
		userInput["password"] = string(hashedPassword)
	}

	if shopName := c.PostForm("shop_name"); shopName != "" {
		vendorInput["shop_name"] = shopName
	}
	if shopAddress := c.PostForm("shop_address"); shopAddress != "" {
		vendorInput["shop_address"] = shopAddress
	}
	if shopDesc := c.PostForm("shop_description"); shopDesc != "" {
		vendorInput["shop_description"] = shopDesc
	}
	if idKecamatanStr := c.PostForm("id_kecamatan"); idKecamatanStr != "" {
		if idKecamatan, err := strconv.Atoi(idKecamatanStr); err == nil {
			vendorInput["id_kecamatan"] = uint(idKecamatan)
		}
	}

	if file, err := c.FormFile("profile_image"); err == nil {
		if user.ProfileImage != "" {
			oldPath := "." + user.ProfileImage
			if err := os.Remove(oldPath); err != nil {
				log.Printf("Gagal menghapus file profile_image lama: %v", err)
			}
		}
		imagePath, err := saveImageVendor(c, file)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal menyimpan profile image"})
			return
		}
		userInput["profile_image"] = imagePath
	}

	if file, err := c.FormFile("ktp_image"); err == nil {
		if user.KtpImage != "" {
			oldPath := "." + user.KtpImage
			if err := os.Remove(oldPath); err != nil {
				log.Printf("Gagal menghapus file ktp_image lama: %v", err)
			}
		}
		ktpPath, err := saveImageVendor(c, file)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal menyimpan KTP image"})
			return
		}
		userInput["ktp_image"] = ktpPath
	}

	userInput["updated_at"] = time.Now()
	vendorInput["updated_at"] = time.Now()

	if err := config.DB.Model(&user).Updates(userInput).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal memperbarui data user", "details": err.Error()})
		return
	}

	if len(vendorInput) > 0 {
		if err := config.DB.Model(&user.Vendor).Updates(vendorInput).Error; err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal memperbarui data vendor", "details": err.Error()})
			return
		}
	}

	if err := config.DB.Preload("Vendor").First(&user, user.ID).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal mengambil data vendor setelah update"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Profil vendor berhasil diperbarui", "user": user})
}

func saveImageVendor(c *gin.Context, file *multipart.FileHeader) (string, error) {
	timestamp := time.Now().Format("20060102_150405")
	filename := fmt.Sprintf("%s%s", timestamp, filepath.Ext(file.Filename))
	filePath := filepath.Join("./fileserver/vendor", filename)

	if err := os.MkdirAll("./fileserver/vendor", os.ModePerm); err != nil {
		return "", err
	}

	if err := c.SaveUploadedFile(file, filePath); err != nil {
		return "", err
	}

	return "/fileserver/vendor/" + filename, nil
}

func ReplyReview(c *gin.Context) {
	// Ambil review ID dari parameter URL
	reviewIDStr := c.Param("id")
	reviewID, err := strconv.ParseUint(reviewIDStr, 10, 64)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Review ID tidak valid"})
		return
	}

	// Ambil input JSON untuk balasan
	var input struct {
		Reply string `json:"reply" binding:"required"`
	}
	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Ambil user_id dari token (vendor)
	userID, exists := c.Get("user_id")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Vendor tidak terautentikasi"})
		return
	}
	vendorID := userID.(uint)

	// Cari review berdasarkan ID
	var review models.Review
	if err := config.DB.Where("id = ?", reviewID).First(&review).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Review tidak ditemukan"})
		return
	}

	// Pastikan vendor yang membalas adalah pemilik ulasan (berdasarkan VendorID)
	if review.VendorID != vendorID {
		c.JSON(http.StatusForbidden, gin.H{"error": "Anda tidak memiliki izin untuk membalas ulasan ini"})
		return
	}

	// Update review dengan balasan vendor
	if err := config.DB.Model(&review).Update("vendor_reply", input.Reply).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal menyimpan balasan ulasan", "details": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "Balasan ulasan berhasil dikirim",
		"review":  review,
	})
}