package controllers

import (
	"encoding/json"
	"fmt"
	"log"
	"mime/multipart"
	"net/http"
	"os"
	"path/filepath"
	"rental-backend/config"
	"rental-backend/dto"
	"rental-backend/models"
	"rental-backend/websocket"
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

func getConfirmedBookings(motorID uint) ([]models.Booking, error) {
    var bookings []models.Booking

    // Ambil hanya booking dengan status "confirmed" dan motor_id sesuai
    if err := config.DB.Where("status = ? AND motor_id = ?", "confirmed", motorID).Find(&bookings).Error; err != nil {
        return nil, fmt.Errorf("error querying confirmed bookings: %v", err)
    }

    return bookings, nil
}

func checkBookingConflict(startDate, endDate time.Time, motorID uint) error {
    confirmedBookings, err := getConfirmedBookings(motorID)
    if err != nil {
        return fmt.Errorf("gagal mengambil booking yang terkonfirmasi: %v", err)
    }

    for _, booking := range confirmedBookings {
        if startDate.Before(booking.EndDate.Add(24 * time.Hour)) {
            return fmt.Errorf(
                "motor telah dibooking pada rentang tanggal %s hingga %s, hanya bisa booking setelah %s",
                booking.StartDate.Format("2006-01-02 15:04"),
                booking.EndDate.Format("2006-01-02 15:04"),
                booking.EndDate.Add(24*time.Hour).Format("2006-01-02 15:04"),
            )
        }
    }

    return nil
}

// Fix the incorrect vendor ID reference in the CreateBooking function

func CreateBooking(c *gin.Context) {
    log.Println("[INFO] CreateBooking function called")

    var bookingInput dto.BookingInput
    if err := c.ShouldBind(&bookingInput); err != nil {
        log.Printf("[ERROR] Error binding request: %v", err)
        c.JSON(http.StatusBadRequest, gin.H{
            "error":   "Format request tidak valid",
            "details": err.Error(),
        })
        return
    }

    // Ambil user_id dari context
    rawUserID, exists := c.Get("user_id")
    if !exists {
        log.Println("[DEBUG] User ID not found in context")
        c.JSON(http.StatusUnauthorized, gin.H{"error": "User tidak ditemukan"})
        return
    }
    userID := rawUserID.(uint)
    log.Printf("[DEBUG] Creating booking for user_id: %d", userID)

    // Hitung tanggal mulai & selesai
    startDateUTC := bookingInput.StartDate.UTC()
    endDateUTC := startDateUTC.Add(time.Duration(bookingInput.Duration*24) * time.Hour)

    // Cek konflik
    if err := checkBookingConflict(startDateUTC, endDateUTC, bookingInput.MotorID); err != nil {
        log.Printf("[DEBUG] Booking conflict detected: %v", err)
        c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
        return
    }

    // Mulai transaction
    tx := config.DB.Begin()
    if tx.Error != nil {
        log.Printf("[DEBUG] Failed to begin transaction: %v", tx.Error)
        c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal memulai transaksi database"})
        return
    }
    committed := false
    defer func() {
        if !committed {
            log.Println("[DEBUG] Rolling back transaction")
            tx.Rollback()
        }
    }()

    // Ambil data customer (user)
    var customer models.User
    if err := tx.Select("id, name").Where("id = ?", userID).First(&customer).Error; err != nil {
        log.Printf("[DEBUG] Failed to get customer data for user_id %d: %v", userID, err)
        c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal mendapatkan data pelanggan"})
        return
    }
    log.Printf("[DEBUG] Found customer: ID=%d, Name=%s", customer.ID, customer.Name)

    // Ambil data motor
    var motor models.Motor
    if err := tx.Where("id = ?", bookingInput.MotorID).First(&motor).Error; err != nil {
        log.Printf("[DEBUG] Failed to get motor data for motor_id %d: %v", bookingInput.MotorID, err)
        c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal mendapatkan data motor"})
        return
    }
    log.Printf("[DEBUG] Found motor: ID=%d, Name=%s, VendorID=%d", motor.ID, motor.Name, motor.VendorID)

    if motor.Status == "unavailable" {
        log.Printf("[DEBUG] Motor is unavailable: ID=%d", motor.ID)
        c.JSON(http.StatusBadRequest, gin.H{"error": "Tidak bisa booking, motor sedang perbaikan/rusak"})
        return
    }

    // Ambil data vendor supaya kita dapat user_id vendor
    var vendor models.Vendor
    if err := tx.Select("id, user_id").Where("id = ?", motor.VendorID).First(&vendor).Error; err != nil {
        log.Printf("[DEBUG] Failed to get vendor data for vendor_id %d: %v", motor.VendorID, err)
        c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal mendapatkan data vendor"})
        return
    }
    log.Printf("[DEBUG] Found vendor: ID=%d, UserID=%d", vendor.ID, vendor.UserID)

    // Validasi durasi
    duration := int(endDateUTC.Sub(startDateUTC).Hours() / 24)
    if duration <= 0 {
        log.Printf("[DEBUG] Invalid booking duration: %d days", duration)
        c.JSON(http.StatusBadRequest, gin.H{"error": "Durasi booking tidak valid"})
        return
    }

    // Siapkan objek booking
    booking := models.Booking{
        CustomerID:      &userID,
        CustomerName:    customer.Name,
        VendorID:        motor.VendorID,
        MotorID:         bookingInput.MotorID,
        BookingDate:     time.Now().UTC(),
        StartDate:       startDateUTC,
        EndDate:         endDateUTC,
        PickupLocation:  bookingInput.PickupLocation,
        DropoffLocation: bookingInput.DropoffLocation,
        Status:          "pending",
    }

    // Upload foto ID
    if file, err := c.FormFile("photo_id"); err == nil {
        if photoPath, err := saveBookingImage(c, file); err == nil {
            booking.PhotoID = photoPath
        } else {
            log.Printf("[DEBUG] Failed to upload photo: %v", err)
            c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal mengupload foto"})
            return
        }
    } else {
        log.Printf("[DEBUG] Photo ID not uploaded: %v", err)
        c.JSON(http.StatusBadRequest, gin.H{"error": "Foto ID wajib diunggah"})
        return
    }

    // Upload KTP
    if file, err := c.FormFile("ktp_id"); err == nil {
        if ktpPath, err := saveBookingImage(c, file); err == nil {
            booking.KtpID = ktpPath
        } else {
            log.Printf("[DEBUG] Failed to upload KTP: %v", err)
            c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal mengupload KTP"})
            return
        }
    } else {
        log.Printf("[DEBUG] KTP not uploaded: %v", err)
        c.JSON(http.StatusBadRequest, gin.H{"error": "KTP wajib diunggah"})
        return
    }

    // Simpan booking
    if err := tx.Create(&booking).Error; err != nil {
        log.Printf("[DEBUG] Failed to save booking: %v", err)
        c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal menyimpan data booking"})
        return
    }
    log.Printf("[DEBUG] Created booking: ID=%d", booking.ID)

    // Commit transaction
    if err := tx.Commit().Error; err != nil {
        log.Printf("[DEBUG] Failed to commit transaction: %v", err)
        c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal menyimpan data booking"})
        return
    }
    committed = true
    log.Println("[DEBUG] Transaction committed successfully")

    // Buat notifikasi ke vendor (pakai vendor.UserID, bukan vendor.ID)
    notifMsg := fmt.Sprintf(
        "Ada booking baru dari %s untuk motor %s pada tanggal %s",
        customer.Name,
        motor.Name,
        booking.StartDate.Format("02 Jan 2006"),
    )
    notification := models.Notification{
        UserID:    vendor.UserID,    // ← pakai ini
        Message:   notifMsg,
        Status:    "unread",
        BookingID: booking.ID,
        CreatedAt: time.Now(),
    }
    if err := config.DB.Create(&notification).Error; err != nil {
        log.Printf("[WARN] Gagal menyimpan notifikasi vendor: %v", err)
    } else {
        payload := map[string]interface{}{
            "message":    notifMsg,
            "booking_id": booking.ID,
        }
        if data, err := json.Marshal(payload); err == nil {
            websocket.SendNotificationToUser(vendor.UserID, string(data))
            log.Printf("[DEBUG] WS notification sent to vendor user_id=%d", vendor.UserID)
        } else {
            log.Printf("[WARN] Gagal marshal WS payload: %v", err)
        }
    }

    // Response sukses
    c.JSON(http.StatusOK, gin.H{
        "message": "Booking berhasil dibuat",
        "booking": booking,
    })
}




func UpdateBookingStatus() {
    now := time.Now()

    // Cari booking yang sudah melewati end_date dan statusnya masih "in use"
    var bookings []models.Booking
    if err := config.DB.Where("end_date <= ? AND status = ?", now, "in use").Find(&bookings).Error; err != nil {
        log.Printf("Error saat mengambil booking untuk update status: %v", err)
        return
    }

    for _, booking := range bookings {
        booking.Status = "awaiting return" // status menunggu pengembalian

        if err := config.DB.Save(&booking).Error; err != nil {
            log.Printf("Error saat memperbarui status booking ID %d: %v", booking.ID, err)
        } else {
            log.Printf("Booking ID %d status telah diperbarui ke 'awaiting return'", booking.ID)

            // Kirim notifikasi jika CustomerID tersedia
            if booking.CustomerID != nil {
                notification := models.Notification{
                    UserID:    *booking.CustomerID,
                    Message:   "Waktu sewa Anda telah selesai. Mohon kembalikan motor ke vendor.",
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
        }
    }
}
