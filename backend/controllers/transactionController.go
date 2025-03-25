package controllers

import (
	"net/http"
	"rental-backend/config"
	"rental-backend/models"
	"time"

	"github.com/gin-gonic/gin"
)

// Fungsi untuk menambahkan transaksi manual dan menghitung harga berdasarkan motor dan durasi
func AddManualTransaction(c *gin.Context) {
	// Inisialisasi variabel transaksi
	var transaction models.Transaction

	// Bind JSON dari body request ke dalam struktur transaksi
	if err := c.ShouldBindJSON(&transaction); err != nil {
		// Jika terjadi error saat parsing JSON, kembalikan error
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Mengabaikan bagian waktu (jam, menit, detik) untuk perbandingan
	startDate := transaction.StartDate
	endDate := transaction.EndDate

	// Set waktu menjadi 00:00:00 agar hanya membandingkan tanggal
	startDate = time.Date(startDate.Year(), startDate.Month(), startDate.Day(), 0, 0, 0, 0, startDate.Location())
	endDate = time.Date(endDate.Year(), endDate.Month(), endDate.Day(), 0, 0, 0, 0, endDate.Location())

	// Cek apakah sudah ada transaksi dengan motor_id dan durasi yang sama
	var existingTransaction models.Transaction
	if err := config.DB.Where("motor_id = ? AND DATE(start_date) = ? AND DATE(end_date) = ?",
		transaction.MotorID, startDate, endDate).First(&existingTransaction).Error; err == nil {
		// Jika transaksi sudah ada, kembalikan error bahwa transaksi duplikat
		c.JSON(http.StatusConflict, gin.H{"error": "Transaksi dengan motor, tanggal mulai, dan tanggal selesai yang sama sudah ada"})
		return
	}

	// Ambil harga motor berdasarkan motorID
	var motor models.Motor
	if err := config.DB.Where("id = ?", transaction.MotorID).First(&motor).Error; err != nil {
		// Jika motor tidak ditemukan, kembalikan error
		c.JSON(http.StatusNotFound, gin.H{"error": "Motor tidak ditemukan"})
		return
	}

	// Hitung durasi rental dalam hari
	duration := endDate.Sub(startDate).Hours() / 24

	// Hitung total harga berdasarkan harga motor dan durasi rental
	totalPrice := duration * float64(motor.Price)

	// Set tipe transaksi manual
	transaction.Type = models.ManualType

	// Set status transaksi menjadi 'completed' (karena transaksi manual langsung selesai)
	transaction.Status = models.Completed

	// Set CustomerID menjadi null jika transaksi manual tidak terkait dengan user
	transaction.CustomerID = nil

	// Set total price yang telah dihitung
	transaction.TotalPrice = totalPrice

	// Simpan transaksi ke dalam database
	if err := config.DB.Create(&transaction).Error; err != nil {
		// Jika gagal menyimpan transaksi, kembalikan error
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal menambahkan transaksi manual"})
		return
	}

	// Jika berhasil, kirimkan response sukses
	c.JSON(http.StatusOK, gin.H{"message": "Transaksi manual berhasil ditambahkan", "transaction": transaction})
}


func GetVendorTransactions(c *gin.Context) {
    // Ambil user_id dari token JWT
    userID, exists := c.Get("user_id")
    if !exists {
        c.JSON(http.StatusUnauthorized, gin.H{"error": "Vendor tidak terautentikasi"})
        return
    }

    // Cari vendor berdasarkan user_id
    var vendor models.Vendor
    if err := config.DB.Where("user_id = ?", userID).First(&vendor).Error; err != nil {
        c.JSON(http.StatusUnauthorized, gin.H{"error": "Vendor tidak ditemukan"})
        return
    }

    // Query transaksi berdasarkan vendor_id
    var transactions []models.Transaction
    if err := config.DB.Where("vendor_id = ?", vendor.ID).Find(&transactions).Error; err != nil {
        c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal mendapatkan data transaksi"})
        return
    }

    // Kembalikan data transaksi sebagai JSON
    c.JSON(http.StatusOK, transactions)
}
