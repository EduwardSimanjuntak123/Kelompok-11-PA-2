package controllers

import (
	"encoding/json"
	"fmt"
	"log"
	"math"
	"mime/multipart"
	"net/http"
	"os"
	"path/filepath"
	"rental-backend/config"
	"rental-backend/models"
	"rental-backend/websocket"
	"strconv"
	"strings"
	"time"

	"github.com/gin-gonic/gin"
	"golang.org/x/crypto/bcrypt"
	"gorm.io/gorm"
)

func GetVendorByID(c *gin.Context) {
	// Ambil ID vendor dari parameter URL
	vendorID := c.Param("id")
	// Struct untuk menyimpan data vendor
	var vendor models.Vendor

	// Query database untuk mengambil vendor berdasarkan ID dengan user & motors terkait
	if err := config.DB.
		Preload("User").
		Preload("Motors").
		Where("id = ?", vendorID).
		First(&vendor).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Vendor tidak ditemukan"})
		return
	}

	// Kirim data vendor sebagai respons
	c.JSON(http.StatusOK, gin.H{
		"message": "Berhasil mengambil data vendor",
		"data":    vendor,
	})
}

type cancelInput struct {
	Email string `json:"email" binding:"required,email"`
}

// CancelRegistration menghapus OTP + akun inactive untuk customer/vendor
func CancelRegistration(c *gin.Context) {
	var in cancelInput
	if err := c.ShouldBindJSON(&in); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"status": "error", "message": err.Error()})
		return
	}

	// Hapus OTP
	if err := config.DB.
		Where("email = ?", in.Email).
		Delete(&models.OtpRequest{}).
		Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"status": "error", "message": "Gagal menghapus OTP"})
		return
	}

	// Cari tahu apakah ini request di group /vendor atau /customer
	path := c.FullPath() // misal "/vendor/cancel-registration"
	var res *gorm.DB
	if strings.HasPrefix(path, "/vendor") {
		res = config.DB.
			Where("email = ? AND status = ?", in.Email, "inactive").
			Delete(&models.Vendor{})
	} else {
		res = config.DB.
			Where("email = ? AND status = ?", in.Email, "inactive").
			Delete(&models.User{})
	}

	if res.Error != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"status": "error", "message": "Gagal menghapus akun"})
		return
	}
	if res.RowsAffected == 0 {
		c.JSON(http.StatusNotFound, gin.H{"status": "error", "message": "Akun tidak ditemukan atau sudah aktif"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"status": "success", "message": "Pendaftaran dibatalkan, data dihapus"})
}

// RegisterVendor mendaftarkan vendor baru
func RegisterVendor(c *gin.Context) {
	var input struct {
		Name            string     `form:"name" binding:"required"`
		Email           string     `form:"email" binding:"required,email"`
		Password        string     `form:"password" binding:"required,min=6"`
		Phone           string     `form:"phone" binding:"required"`
		ShopName        string     `form:"shop_name" binding:"required"`
		ShopAddress     string     `form:"shop_address" binding:"required"`
		ShopDescription string     `form:"shop_description"`
		IDKecamatan     *uint      `form:"id_kecamatan"`
		BirthDate       *time.Time `form:"birth_date" time_format:"2006-01-02"`
	}

	// Ambil form-data
	if err := c.ShouldBind(&input); err != nil {
		log.Println("[ERROR] Failed to bind input:", err)
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}
	log.Println("[INFO] Input berhasil dibaca:", input)

	// Cek email
	var existingUser models.User
	if err := config.DB.Where("email = ?", input.Email).First(&existingUser).Error; err == nil {
		log.Println("[ERROR] Email sudah digunakan:", input.Email)
		c.JSON(http.StatusConflict, gin.H{"error": "Email sudah digunakan"})
		return
	}

	// Cek nomor telepon
	var existingPhone models.User
	if err := config.DB.Where("phone = ?", input.Phone).First(&existingPhone).Error; err == nil {
		log.Println("[ERROR] Nomor telepon sudah digunakan:", input.Phone)
		c.JSON(http.StatusConflict, gin.H{"error": "Nomor telepon sudah digunakan"})
		return
	}

	// Hash password
	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(strings.TrimSpace(input.Password)), bcrypt.DefaultCost)
	if err != nil {
		log.Println("[ERROR] Gagal hashing password:", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Kesalahan dalam hashing password"})
		return
	}
	log.Println("[INFO] Password berhasil di-hash")

	// Simpan gambar profil
	profileImage, err := saveUserImage(c, "profile_image")
	if err != nil {
		log.Println("[ERROR] Gagal menyimpan gambar profil:", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal menyimpan gambar profil"})
		return
	}
	log.Println("[INFO] Gambar profil berhasil disimpan:", profileImage)

	// Generate dan simpan OTP
	otp := generateOTP()
	otpRequest := models.OtpRequest{
		Email:     input.Email,
		OTP:       otp,
		ExpiresAt: time.Now().Add(10 * time.Minute),
	}
	if err := config.DB.Create(&otpRequest).Error; err != nil {
		log.Println("[ERROR] Gagal menyimpan data OTP:", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal menyimpan data OTP"})
		return
	}
	log.Println("[INFO] OTP berhasil disimpan:", otp)

	// Kirim OTP ke email
	if err := SendOTPEmail(input.Email, otp); err != nil {
		log.Println("[ERROR] Gagal mengirim OTP ke email:", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal mengirim OTP ke email"})
		return
	}
	log.Println("[INFO] OTP berhasil dikirim ke:", input.Email)

	// Simpan user
	user := models.User{
		Name:         input.Name,
		Email:        input.Email,
		Password:     string(hashedPassword),
		Role:         "vendor",
		Phone:        input.Phone,
		Address:      input.ShopAddress,
		Status:       "inactive",
		ProfileImage: profileImage,
		BirthDate:    input.BirthDate,
	}

	if err := config.DB.Create(&user).Error; err != nil {
		log.Println("[ERROR] Gagal menyimpan data user:", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal menyimpan data user"})
		return
	}
	log.Println("[INFO] User berhasil disimpan dengan ID:", user.ID)

	// Simpan vendor
	vendor := models.Vendor{
		UserID:          user.ID,
		ShopName:        input.ShopName,
		ShopAddress:     input.ShopAddress,
		ShopDescription: input.ShopDescription,
		IDKecamatan:     input.IDKecamatan,
		Status:          "active",
	}

	if err := config.DB.Create(&vendor).Error; err != nil {
		log.Println("[ERROR] Gagal menyimpan data vendor:", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal menyimpan data vendor"})
		return
	}
	log.Println("[INFO] Vendor berhasil disimpan untuk user ID:", user.ID)

	// Berhasil
	c.JSON(http.StatusOK, gin.H{
		"message":       "OTP telah dikirim ke email, harap verifikasi",
		"profile_image": profileImage,
	})
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
	if booking.Status != "awaiting return" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Booking hanya dapat diselesaikan jika statusnya 'awaiting return'"})
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

	// Kirim notifikasi ke customer jika ada
	if booking.CustomerID != nil {
		notification := models.Notification{
			UserID:    *booking.CustomerID,
			Message:   "Booking Anda telah selesai. Terima kasih telah menggunakan layanan kami!",
			Status:    "unread",
			BookingID: booking.ID,
			CreatedAt: time.Now(),
		}

		if err := config.DB.Create(&notification).Error; err != nil {
			log.Println("❗ Gagal menyimpan notifikasi:", err)
		} else {
			notifPayload := map[string]interface{}{
				"message":    notification.Message,
				"booking_id": notification.BookingID,
			}

			notifJSON, err := json.Marshal(notifPayload)
			if err != nil {
				log.Println("❗ Gagal encode notifikasi ke JSON:", err)
			} else {
				websocket.SendNotificationToUser(*booking.CustomerID, string(notifJSON))
			}
		}
	}

	c.JSON(http.StatusOK, gin.H{"message": "Booking selesai, transaksi dibuat otomatis"})
}

func CreateTransaction(booking models.Booking) error {
	// Hitung total harga menggunakan fungsi terpisah
	totalPrice := CalculateTotalPrice(booking.MotorID, booking.StartDate, booking.EndDate)
	if totalPrice == 0 {
		return fmt.Errorf("gagal menghitung total harga, mungkin data motor tidak ditemukan")
	}

	// Tentukan tipe transaksi berdasarkan apakah booking memiliki CustomerID
	transactionType := "online"
	if booking.CustomerID == nil || *booking.CustomerID == 0 {
		transactionType = "manual"
	}

	// Buat objek transaksi
	transaction := models.Transaction{
		BookingID:      &booking.ID,
		VendorID:       booking.VendorID,
		MotorID:        booking.MotorID,
		Type:           transactionType,
		TotalPrice:     totalPrice,
		StartDate:      booking.StartDate,
		EndDate:        booking.EndDate,
		PickupLocation: booking.PickupLocation,
		Status:         "completed",
		CreatedAt:      time.Now(),
		UpdatedAt:      time.Now(),
	}

	// Sertakan CustomerID jika ada
	if booking.CustomerID != nil && *booking.CustomerID != 0 {
		transaction.CustomerID = booking.CustomerID
	}

	// Simpan transaksi ke database
	if err := config.DB.Create(&transaction).Error; err != nil {
		return fmt.Errorf("error creating transaction: %w", err)
	}
	return nil
}

func CalculateTotalPrice(motorID uint, startDate, endDate time.Time) float64 {
	var motor models.Motor
	if err := config.DB.First(&motor, motorID).Error; err != nil {
		log.Printf("❗ Motor tidak ditemukan (ID: %d): %v", motorID, err)
		return 0
	}

	// Hitung durasi dan bulatkan ke atas
	duration := math.Ceil(endDate.Sub(startDate).Hours() / 24)
	if duration < 1 {
		duration = 1
	}

	total := duration * motor.Price

	log.Printf("🧮 Harga: %.2f x Durasi: %.0f = Total: %.2f", motor.Price, duration, total)
	return total
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
		Select("id, name, email, role, phone, address, profile_image, status, created_at, updated_at").
		Preload("Vendor", func(db *gorm.DB) *gorm.DB {
			return db.Select("id, user_id, id_kecamatan,rating, shop_name, shop_address, shop_description, status, created_at, updated_at").
				Preload("Kecamatan", func(db *gorm.DB) *gorm.DB {
					return db.Select("id_kecamatan, nama_kecamatan") // Preload kecamatan data
				})
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

	// Struct input untuk balasan vendor
	var input struct {
		Reply string `json:"reply" binding:"required"`
	}
	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Ambil user_id dari token (ini adalah ID user)
	userID, exists := c.Get("user_id")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Vendor tidak terautentikasi"})
		return
	}

	// Cari record vendor berdasarkan user_id dari token
	var vendor models.Vendor
	if err := config.DB.Where("user_id = ?", userID).First(&vendor).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Vendor tidak ditemukan"})
		return
	}
	// Gunakan vendor.ID sebagai vendor yang sebenarnya
	log.Printf("Vendor ID dari token (dari record vendor): %d", vendor.ID)

	// Cari review berdasarkan review ID
	var review models.Review
	if err := config.DB.Where("id = ?", reviewID).First(&review).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Review tidak ditemukan"})
		return
	}
	// Log vendor id dari review
	log.Printf("Review VendorID: %d", review.VendorID)

	// Pastikan vendor yang membalas adalah vendor yang terkait dengan review
	if review.VendorID != vendor.ID {
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

// Fungsi untuk mendapatkan semua vendor
func GetAllVendor(c *gin.Context) {
	var vendors []models.Vendor

	// Ambil semua vendor dengan informasi user dan motor terkait
	if err := config.DB.Preload("User").Preload("Motors").Preload("Kecamatan").Find(&vendors).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal mengambil data vendor"})
		return
	}

	// Periksa apakah ada data vendor
	if len(vendors) == 0 {
		c.JSON(http.StatusNotFound, gin.H{"message": "Tidak ada vendor yang tersedia"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "Berhasil mengambil data vendor",
		"data":    vendors,
	})
}
