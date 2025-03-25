package controllers

import (
	"fmt"
	"log"
	"mime/multipart"
	"net/http"
	"os"
	"path/filepath"
	"strconv"
	"time" 
"strings"
	"rental-backend/config"
	"rental-backend/models"

	"github.com/gin-gonic/gin"
	"golang.org/x/crypto/bcrypt"
	"gorm.io/gorm"
)

func RegisterVendor(c *gin.Context) {
	var input struct {
		Name            string `json:"name" binding:"required"`
		Email           string `json:"email" binding:"required,email"`
		Password        string `json:"password" binding:"required,min=6"`
		Phone           string `json:"phone" binding:"required"`
		ShopName        string `json:"shop_name" binding:"required"`
		ShopAddress     string `json:"shop_address" binding:"required"`
		ShopDescription string `json:"shop_description"`
		IDKecamatan     *uint  `json:"id_kecamatan"` // Menambahkan ID Kecamatan
	}

	// Validasi input JSON
	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Cek apakah email sudah digunakan oleh user atau vendor
	var existingUser models.User
	if err := config.DB.Where("email = ?", input.Email).First(&existingUser).Error; err == nil {
		// Cek jika user yang ditemukan memiliki role selain vendor
		if existingUser.Role == "vendor" {
			c.JSON(http.StatusConflict, gin.H{"error": "Email sudah digunakan oleh vendor"})
			return
		}
		if existingUser.Role == "customer" {
			c.JSON(http.StatusConflict, gin.H{"error": "Email sudah digunakan oleh pelanggan"})
			return
		}
	}

	// **Hash password sebelum menyimpan**
	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(strings.TrimSpace(input.Password)), bcrypt.DefaultCost)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Terjadi kesalahan dalam hashing password"})
		return
	}

	// Debugging
	fmt.Println("✅ Password hash berhasil dibuat:", string(hashedPassword))

	// Buat user baru
	user := models.User{
		Name:     input.Name,
		Email:    input.Email,
		Password: string(hashedPassword),
		Role:     "vendor", // Set role sebagai 'vendor'
		Phone:    input.Phone,
		Address:  input.ShopAddress, // Gunakan alamat toko untuk address user
		Status:   "active",          // Status default aktif
	}

	// **Simpan ke database**
	if err := config.DB.Create(&user).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal menyimpan data vendor"})
		return
	}

	// Setelah user berhasil dibuat, buat vendor terkait
	vendor := models.Vendor{
		UserID:          user.ID,        // Menghubungkan vendor dengan user
		ShopName:        input.ShopName, // Menyimpan nama toko
		ShopAddress:     input.ShopAddress,
		ShopDescription: input.ShopDescription,
		Status:          "active",          // Status vendor aktif
		IDKecamatan:     input.IDKecamatan, // Menyertakan ID kecamatan
	}

	// Simpan vendor ke database
	if err := config.DB.Create(&vendor).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal menyimpan data vendor"})
		return
	}

	// Debugging
	fmt.Println("✅ Vendor berhasil terdaftar dengan user ID:", user.ID)

	// Pastikan response yang benar
	c.JSON(http.StatusOK, gin.H{"message": "Pendaftaran vendor berhasil"})
}

func CompleteBooking(c *gin.Context) {
    id := c.Param("id")

    // Ambil data booking beserta relasi Motor
    var booking models.Booking
    if err := config.DB.Preload("Motor").Where("id = ?", id).First(&booking).Error; err != nil {
        c.JSON(http.StatusNotFound, gin.H{"error": "Booking tidak ditemukan"})
        return
    }

    // Ubah status booking menjadi "completed"
    if err := config.DB.Model(&booking).Update("status", "completed").Error; err != nil {
        c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal mengubah status booking"})
        return
    }

    // Buat transaksi otomatis berdasarkan data booking yang sudah selesai
    if err := CreateTransaction(booking); err != nil {
        c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal membuat transaksi otomatis", "details": err.Error()})
        return
    }

    c.JSON(http.StatusOK, gin.H{"message": "Booking selesai, transaksi dibuat otomatis"})
}

// CreateTransaction membuat baris baru di tabel transaksi berdasarkan data booking.
func CreateTransaction(booking models.Booking) error {
    // Pastikan relasi Motor sudah terisi
    if booking.Motor == nil {
        return fmt.Errorf("data motor tidak tersedia pada booking")
    }
    
    // Hitung durasi booking (dalam hari) dengan memanggil method GetDurationDays()
    duration := booking.GetDurationDays()
    totalPrice := booking.Motor.Price * float64(duration)

    // Buat objek transaksi dengan data yang sesuai
    transaction := models.Transaction{
        BookingID:      &booking.ID,        // BookingID sebagai pointer
        VendorID:       booking.VendorID,
        MotorID:        booking.MotorID,
        Type:           "online",
        TotalPrice:     totalPrice,
        StartDate:      booking.StartDate,
        EndDate:        booking.EndDate,
        PickupLocation: booking.PickupLocation,
        Status:         "completed",        // Nilai default untuk transaksi
        CreatedAt:      time.Now(),
        UpdatedAt:      time.Now(),
    }

    // Jika CustomerID valid, masukkan juga (sebagai pointer)
    if booking.CustomerID != 0 {
        transaction.CustomerID = &booking.CustomerID
    }

    // Simpan transaksi ke database
    if err := config.DB.Create(&transaction).Error; err != nil {
        return fmt.Errorf("error creating transaction: %w", err)
    }
    return nil
}


func GetVendorProfile(c *gin.Context) {
	userID, exists := c.Get("user_id")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "User tidak ditemukan, harap login ulang"})
		return
	}

	var user models.User
	// Ambil data user beserta vendor
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

	// Pastikan user memiliki vendor
	if user.Role != "vendor" || user.Vendor.ID == 0 {
		c.JSON(http.StatusNotFound, gin.H{"error": "Vendor tidak ditemukan"})
		return
	}

	// Mengembalikan JSON tanpa duplikasi
	c.JSON(http.StatusOK, gin.H{"user": user})
}

func EditProfileVendor(c *gin.Context) {
	// Ambil user_id dari context (diperoleh dari token)
	userID, exists := c.Get("user_id")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "User tidak terautentikasi"})
		return
	}

	// Cari data user dengan role 'vendor' dan preload data vendor terkait
	var user models.User
	if err := config.DB.Preload("Vendor").Where("id = ? AND role = ?", userID, "vendor").First(&user).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Data vendor tidak ditemukan"})
		return
	}

	// Map untuk update data User dan Vendor
	userInput := make(map[string]interface{})
	vendorInput := make(map[string]interface{})

	// Update atribut dari User (misal: name, email, phone, address, password)
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
		// Hash password sebelum update
		hashedPassword, err := bcrypt.GenerateFromPassword([]byte(password), bcrypt.DefaultCost)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal meng-hash password"})
			return
		}
		userInput["password"] = string(hashedPassword)
	}

	// Update atribut Vendor (misal: shop_name, shop_address, shop_description, id_kecamatan)
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

	// Tangani file profile_image jika ada pada User
	if file, err := c.FormFile("profile_image"); err == nil {
		// Hapus file lama jika ada; karena disimpan sebagai URL relatif, ubah menjadi path file sistem
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

	// Tangani file ktp_image jika ada pada User
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

	// Update waktu perubahan untuk User dan Vendor
	userInput["updated_at"] = time.Now()
	vendorInput["updated_at"] = time.Now()

	// Lakukan update data User
	if err := config.DB.Model(&user).Updates(userInput).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal memperbarui data user", "details": err.Error()})
		return
	}

	// Lakukan update data Vendor
	if len(vendorInput) > 0 {
		if err := config.DB.Model(&user.Vendor).Updates(vendorInput).Error; err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal memperbarui data vendor", "details": err.Error()})
			return
		}
	}

	// Refresh data user dengan preload vendor agar respons mengembalikan data terbaru
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