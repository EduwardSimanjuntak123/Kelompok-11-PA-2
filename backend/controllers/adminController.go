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
	"strconv"
	"time"

	"github.com/gin-gonic/gin"
)

func GetAllCustomersAndVendors(c *gin.Context) {
	var users []models.User

	// Ambil user dengan role "customer" atau "vendor"
	if err := config.DB.Where("role IN ?", []string{"customer", "vendor"}).Find(&users).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal mengambil data pengguna"})
		return
	}

	// Siapkan base URL untuk gambar

	// Format respons
	var result []gin.H
	for _, user := range users {
		profileImage := user.ProfileImage
		if profileImage == "" {
			profileImage = "https://via.placeholder.com/150"
		} else {
			profileImage = profileImage
		}

		result = append(result, gin.H{
			"id":            user.ID,
			"name":          user.Name,
			"email":         user.Email,
			"phone":         user.Phone,
			"address":       user.Address,
			"profile_image": profileImage,
			"status":        user.Status,
			"role":          user.Role,
			"created_at":    user.CreatedAt,
			"updated_at":    user.UpdatedAt,
		})
	}

	c.JSON(http.StatusOK, result)
}

func GetDataAdmin(c *gin.Context) {
	// Ambil user_id dari token JWT
	userID, exists := c.Get("user_id")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Admin tidak terautentikasi"})
		return
	}

	var user models.User

	// Ambil data user (admin) dengan semua atribut yang relevan
	if err := config.DB.
		Select("id, name, email, phone, address, profile_image, status, role, created_at, updated_at").
		Where("id = ? AND role = ?", userID, "admin").
		First(&user).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Admin tidak ditemukan"})
		return
	}

	// Siapkan base URL untuk membangun URL gambar lengkap

	// Buat URL gambar lengkap untuk profile_image
	var profileImageURL string
	if user.ProfileImage != "" {
		profileImageURL = user.ProfileImage
	} else {
		profileImageURL = "https://via.placeholder.com/150"
	}

	// Kembalikan respons JSON dengan semua atribut
	c.JSON(http.StatusOK, gin.H{
		"id":            user.ID,
		"name":          user.Name,
		"email":         user.Email,
		"phone":         user.Phone,
		"address":       user.Address,
		"profile_image": profileImageURL,
		"status":        user.Status,
		"role":          user.Role,
		"created_at":    user.CreatedAt,
		"updated_at":    user.UpdatedAt,
	})
}

func saveImageAdmin(c *gin.Context, file *multipart.FileHeader) (string, error) {
	timestamp := time.Now().Format("20060102_150405")
	filename := fmt.Sprintf("%s%s", timestamp, filepath.Ext(file.Filename))
	filePath := filepath.Join("./fileserver/admin", filename)

	if err := os.MkdirAll("./fileserver/admin", os.ModePerm); err != nil {
		return "", err
	}

	if err := c.SaveUploadedFile(file, filePath); err != nil {
		return "", err
	}

	// Kembalikan URL relatif, misalnya "/fileserver/admin/filename.jpg"
	return "/fileserver/admin/" + filename, nil
}

// saveImageKtp menyimpan file KTP image ke folder ./fileserver/admin
func saveImageKtp(c *gin.Context, file *multipart.FileHeader) (string, error) {
	timestamp := time.Now().Format("20060102_150405")
	filename := fmt.Sprintf("ktp_%s%s", timestamp, filepath.Ext(file.Filename))
	filePath := filepath.Join("./fileserver/admin", filename)

	if err := os.MkdirAll("./fileserver/admin", os.ModePerm); err != nil {
		return "", err
	}

	if err := c.SaveUploadedFile(file, filePath); err != nil {
		return "", err
	}

	return "/fileserver/admin/" + filename, nil
}

// EditDataAdmin mengupdate data admin berdasarkan input form-data.
// Bila ada file gambar baru, file gambar lama akan dihapus dari folder.
func EditDataAdmin(c *gin.Context) {
	// Ambil user_id dari context (diperoleh dari token)
	userID, exists := c.Get("user_id")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Admin tidak terautentikasi"})
		return
	}

	// Cari data admin berdasarkan user_id dan pastikan role adalah 'admin'
	var admin models.User
	if err := config.DB.Where("id = ? AND role = ?", userID, "admin").First(&admin).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Data admin tidak ditemukan"})
		return
	}

	// Gunakan map untuk update parsial
	input := make(map[string]interface{})

	// Update atribut jika ada input baru dari form-data
	if name := c.PostForm("name"); name != "" {
		input["name"] = name
	}
	if email := c.PostForm("email"); email != "" {
		input["email"] = email
	}
	if password := c.PostForm("password"); password != "" {
		// Pastikan untuk meng-hash password sebelum disimpan. (HashPassword harus diimplementasikan)
		hashedPassword := password // Gantikan ini dengan fungsi hashing password Anda
		input["password"] = hashedPassword
	}
	if phone := c.PostForm("phone"); phone != "" {
		input["phone"] = phone
	}
	if address := c.PostForm("address"); address != "" {
		input["address"] = address
	}
	if status := c.PostForm("status"); status != "" {
		input["status"] = status
	}
	if role := c.PostForm("role"); role != "" {
		input["role"] = role
	}

	// Tangani file profile_image jika ada
	if file, err := c.FormFile("profile_image"); err == nil {
		// Hapus file lama jika ada
		if admin.ProfileImage != "" {
			// Ubah URL relatif menjadi path file di sistem dengan menambahkan titik (.)
			oldPath := "." + admin.ProfileImage
			if err := os.Remove(oldPath); err != nil {
				log.Printf("Gagal menghapus file profile_image lama: %v", err)
			}
		}
		imagePath, err := saveImageAdmin(c, file)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal menyimpan profile image"})
			return
		}
		input["profile_image"] = imagePath
	}

	// Update waktu perubahan
	input["updated_at"] = time.Now()

	// Lakukan update data admin secara partial
	if err := config.DB.Model(&admin).Updates(input).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal memperbarui data admin", "details": err.Error()})
		return
	}

	// Refresh data admin agar respons mengembalikan data terbaru
	if err := config.DB.First(&admin, admin.ID).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal mengambil data admin setelah update"})
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

func GetAllVendors(c *gin.Context) {
	// Ambil semua vendor yang user-nya memiliki role 'vendor'
	var vendors []models.Vendor
	if err := config.DB.
		Joins("JOIN users ON users.id = vendors.user_id").
		Where("users.role = ?", "vendor").
		Find(&vendors).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal mengambil data vendor"})
		return
	}

	var result []gin.H

	for _, vendor := range vendors {
		var user models.User
		if err := config.DB.First(&user, vendor.UserID).Error; err != nil {
			log.Printf("Gagal mengambil user: %v\n", err)
			continue
		}

		// Hitung jumlah transaksi vendor
		var transactionCount int64
		if err := config.DB.Model(&models.Transaction{}).Where("vendor_id = ?", vendor.ID).Count(&transactionCount).Error; err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal menghitung transaksi"})
			return
		}

		// Susun data response
		result = append(result, gin.H{
			"id":                user.ID,
			"name":              user.Name,
			"email":             user.Email,
			"phone":             user.Phone,
			"address":           user.Address,
			"profile_image":     user.ProfileImage,
			"role":              user.Role,
			"status":            user.Status,
			"created_at":        user.CreatedAt,
			"updated_at":        user.UpdatedAt,
			"transaction_count": transactionCount,
		})
	}

	c.JSON(http.StatusOK, result)
}

func ActivateVendor(c *gin.Context) {
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

	// Update status menjadi aktif kembali
	if err := config.DB.Model(&user).Updates(map[string]interface{}{
		"status":     "active",
		"updated_at": time.Now(),
	}).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal mengaktifkan vendor"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Akun vendor berhasil diaktifkan"})
}

func GetVendorDetailByAdmin(c *gin.Context) {
	vendorID := c.Param("id")
	var vendor models.Vendor

	// Ambil data vendor dan motor terkait
	if err := config.DB.Preload("Motors").First(&vendor, vendorID).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Vendor tidak ditemukan"})
		return
	}

	// Hitung jumlah pelanggan per bulan (distinct user_id yang booking motor milik vendor)
	type MonthlyStats struct {
		Month         string
		CustomerCount int
		IncomeTotal   float64
	}

	var stats []MonthlyStats
	query := `
		SELECT
    DATE_FORMAT(b.created_at, '%Y-%m') AS month,
    COUNT(DISTINCT b.customer_id) AS customer_count,
    SUM(DATEDIFF(b.end_date, b.start_date) * m.price) AS income_total
FROM bookings b
JOIN motor m ON b.motor_id = m.id
WHERE m.vendor_id = ? AND b.status != 'canceled'
GROUP BY month
ORDER BY month DESC;
	`
	if err := config.DB.Raw(query, vendorID).Scan(&stats).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal mengambil statistik bulanan"})
		return
	}

	// Hitung jumlah motor tersedia
	var availableCount int64
	config.DB.Model(&models.Motor{}).Where("vendor_id = ? AND status = ?", vendorID, "available").Count(&availableCount)

	// Hitung jumlah motor dibooking hari ini
	var bookedTodayCount int64
	today := time.Now().Format("2006-01-02")
	config.DB.Raw(`
		SELECT COUNT(DISTINCT b.motor_id) 
		FROM bookings b
		JOIN motor m ON b.motor_id = m.id
		WHERE m.vendor_id = ? AND DATE(b.created_at) = ?
	`, vendorID, today).Scan(&bookedTodayCount)

	c.JSON(http.StatusOK, gin.H{
		"vendor":             vendor,
		"motors":             vendor.Motors,
		"monthly_statistics": stats,
		"motor_available":    availableCount,
		"motor_booked_today": bookedTodayCount,
	})
}
