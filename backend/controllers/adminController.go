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
	baseURL := "http://localhost:8080"

	// Buat URL gambar lengkap untuk profile_image
	var profileImageURL string
	if user.ProfileImage != "" {
		profileImageURL = baseURL + user.ProfileImage
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
	// Ambil semua vendor dengan preload relasi Motors
	var vendors []models.Vendor
	// Preload Motors agar kita dapat menghitung jumlah motor
	if err := config.DB.Preload("Motors").Find(&vendors).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal mengambil data vendor"})
		return
	}

	// Hasil akhir untuk dikembalikan
	var result []gin.H

	// Iterasi setiap vendor untuk menggabungkan data dari tabel users
	for _, vendor := range vendors {
		// Hitung jumlah motor yang dimiliki vendor (dari preload)
		motorCount := len(vendor.Motors)

		// Hitung jumlah transaksi vendor
		var transactionCount int64
		if err := config.DB.Model(&models.Transaction{}).Where("vendor_id = ?", vendor.ID).Count(&transactionCount).Error; err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal menghitung transaksi"})
			return
		}

		// Ambil data user terkait vendor berdasarkan vendor.UserID
		var user models.User
		if err := config.DB.Where("id = ?", vendor.UserID).First(&user).Error; err != nil {
			// Jika gagal mengambil data user, lewati vendor ini
			log.Printf("Gagal mengambil user: %v\n", err)
			continue
		}

		// Siapkan URL lengkap untuk gambar (misal: tambahkan base URL)
		baseURL := "http://localhost:8080"
		profileImage := user.ProfileImage
		if profileImage == "" {
			profileImage = "https://via.placeholder.com/150"
		} else {
			profileImage = baseURL + profileImage
		}

		// Gabungkan data yang lengkap ke dalam response
		result = append(result, gin.H{
			"id":                user.ID,
			"name":              user.Name,
			"email":             user.Email,
			"phone":             user.Phone,
			"address":           user.Address,
			"profile_image":     profileImage,
			"role":              user.Role,
			"status":            user.Status,
			"created_at":        user.CreatedAt,
			"updated_at":        user.UpdatedAt,
			"motor_count":       motorCount,
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

