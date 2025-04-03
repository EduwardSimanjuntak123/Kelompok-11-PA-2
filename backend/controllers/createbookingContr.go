package controllers

import (
	"fmt"
	"log"
	"mime/multipart"
	"net/http"
	"os"
	"path/filepath"
	"rental-backend/config"
	"rental-backend/dto"
	"rental-backend/models"
	"time"

	"github.com/gin-gonic/gin"
)


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
func getConfirmedBookings() ([]models.Booking, error) {
    var bookings []models.Booking

    // Menggunakan GORM untuk mengambil data booking dengan status "confirmed"
    if err := config.DB.Where("status = ?", "confirmed").Find(&bookings).Error; err != nil {
        return nil, fmt.Errorf("error querying confirmed bookings: %v", err)
    }

    return bookings, nil
}

func checkBookingConflict(startDate, endDate time.Time) error {
    // Ambil daftar booking yang statusnya "confirmed"
    confirmedBookings, err := getConfirmedBookings()
    if err != nil {
        return fmt.Errorf("gagal mengambil booking yang terkonfirmasi: %v", err)
    }

    // Periksa apakah tanggal booking yang ada tumpang tindih dengan rentang tanggal baru
    for _, booking := range confirmedBookings {
        // Pastikan booking baru dimulai setidaknya 1 hari setelah end_date booking yang sudah ada
        if startDate.Before(booking.EndDate.Add(24 * time.Hour)) {
            return fmt.Errorf("motor pada rentang tanggal %s sampai %s telah dibooking, hanya bisa booking setelah %s", 
                startDate.Format("2006-01-02"), endDate.Format("2006-01-02"), booking.EndDate.Add(24*time.Hour).Format("2006-01-02"))
        }
    }

    return nil
}


func CreateBooking(c *gin.Context) {
    log.Println("[INFO] CreateBooking function called")

    // Gunakan DTO untuk binding data dari form
    var bookingInput dto.BookingInput
    if err := c.ShouldBind(&bookingInput); err != nil {
        log.Printf("[ERROR] Error binding request: %v", err)
        c.JSON(http.StatusBadRequest, gin.H{"error": "Format request tidak valid", "details": err.Error()})
        return
    }

    userID, exists := c.Get("user_id")
    if !exists {
        c.JSON(http.StatusUnauthorized, gin.H{"error": "User tidak ditemukan"})
        return
    }

    // Validasi conflict sebelum melanjutkan
    if err := checkBookingConflict(bookingInput.StartDate, bookingInput.EndDate); err != nil {
        c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
        return
    }

    tx := config.DB.Begin()
    defer tx.Rollback()

    // Ambil data user berdasarkan userID
    var customer models.User
    if err := tx.Select("id, name").Where("id = ?", userID).First(&customer).Error; err != nil {
        c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal mendapatkan data pelanggan"})
        return
    }

    // Ambil data motor berdasarkan ID
    var motor models.Motor
    if err := tx.Where("id = ?", bookingInput.MotorID).First(&motor).Error; err != nil {
        c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal mendapatkan data motor"})
        return
    }

    // Validasi tanggal
    if bookingInput.EndDate.Before(bookingInput.StartDate) {
        c.JSON(http.StatusBadRequest, gin.H{"error": "Tanggal booking tidak valid"})
        return
    }

    duration := int(bookingInput.EndDate.Sub(bookingInput.StartDate).Hours() / 24)
    if duration <= 0 {
        c.JSON(http.StatusBadRequest, gin.H{"error": "Durasi booking tidak valid"})
        return
    }

    // Buat data booking baru
    booking := models.Booking{
        CustomerID:     new(uint),
        CustomerName:   customer.Name,
        VendorID:       motor.VendorID,
        MotorID:        bookingInput.MotorID,
        BookingDate:    time.Now(),
        StartDate:      bookingInput.StartDate,
        EndDate:        bookingInput.EndDate,
        PickupLocation: bookingInput.PickupLocation,
        Status:         "pending",
    }
    *booking.CustomerID = userID.(uint)

    // Proses upload file jika ada
    if file, err := c.FormFile("photo_id"); err == nil {
        if photoPath, err := saveBookingImage(c, file); err == nil {
            booking.PhotoID = photoPath
        } else {
            c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal mengupload foto"})
            return
        }
    } else {
        c.JSON(http.StatusBadRequest, gin.H{"error": "Foto ID wajib diunggah"})
        return
    }

    if file, err := c.FormFile("ktp_id"); err == nil {
        if ktpPath, err := saveBookingImage(c, file); err == nil {
            booking.KtpID = ktpPath
        } else {
            c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal mengupload KTP"})
            return
        }
    } else {
        c.JSON(http.StatusBadRequest, gin.H{"error": "KTP wajib diunggah"})
        return
    }

    // Simpan booking ke database
    if err := tx.Create(&booking).Error; err != nil {
        c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal menyimpan data booking"})
        return
    }

    tx.Commit()
    c.JSON(http.StatusOK, gin.H{"message": "Booking berhasil dibuat", "booking": booking})
}
