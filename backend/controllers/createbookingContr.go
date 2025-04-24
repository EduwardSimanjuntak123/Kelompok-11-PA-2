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
		c.JSON(http.StatusBadRequest, gin.H{"error": "Format request tidak valid", "details": err.Error()})
		return
	}

	userID, exists := c.Get("user_id")
	if !exists {
		log.Printf("[DEBUG] User ID not found in context")
		c.JSON(http.StatusUnauthorized, gin.H{"error": "User tidak ditemukan"})
		return
	}
	
	log.Printf("[DEBUG] Creating booking for user_id: %v", userID)

	startDateUTC := bookingInput.StartDate.UTC()
	endDateUTC := startDateUTC.Add(time.Duration(bookingInput.Duration*24) * time.Hour)

	if err := checkBookingConflict(startDateUTC, endDateUTC, bookingInput.MotorID); err != nil {
		log.Printf("[DEBUG] Booking conflict detected: %v", err)
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Start a new transaction
	tx := config.DB.Begin()
	if tx.Error != nil {
		log.Printf("[DEBUG] Failed to begin transaction: %v", tx.Error)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal memulai transaksi database"})
		return
	}
	
	// Use a variable to track if we should rollback
	var txCommitted bool = false
	defer func() {
		// Only rollback if not committed
		if !txCommitted {
			log.Printf("[DEBUG] Rolling back transaction")
			tx.Rollback()
		}
	}()

	var customer models.User
	if err := tx.Select("id, name").Where("id = ?", userID).First(&customer).Error; err != nil {
		log.Printf("[DEBUG] Failed to get customer data for user_id %v: %v", userID, err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal mendapatkan data pelanggan"})
		return
	}
	log.Printf("[DEBUG] Found customer: ID=%v, Name=%s", customer.ID, customer.Name)

	var motor models.Motor
	if err := tx.Where("id = ?", bookingInput.MotorID).First(&motor).Error; err != nil {
		log.Printf("[DEBUG] Failed to get motor data for motor_id %v: %v", bookingInput.MotorID, err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal mendapatkan data motor"})
		return
	}
	log.Printf("[DEBUG] Found motor: ID=%v, Name=%s, VendorID=%v", motor.ID, motor.Name, motor.VendorID)

	if motor.Status == "unavailable" {
		log.Printf("[DEBUG] Motor is unavailable: ID=%v", motor.ID)
		c.JSON(http.StatusBadRequest, gin.H{"error": "Tidak bisa booking, motor sedang perbaikan/rusak"})
		return
	}

	duration := int(endDateUTC.Sub(startDateUTC).Hours() / 24)
	if duration <= 0 {
		log.Printf("[DEBUG] Invalid booking duration: %v days", duration)
		c.JSON(http.StatusBadRequest, gin.H{"error": "Durasi booking tidak valid"})
		return
	}

	booking := models.Booking{
		CustomerID:      new(uint),
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
	*booking.CustomerID = userID.(uint)

	// Process photo uploads...
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

	// Create the booking record
	if err := tx.Create(&booking).Error; err != nil {
		log.Printf("[DEBUG] Failed to save booking: %v", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal menyimpan data booking"})
		return
	}
	log.Printf("[DEBUG] Created booking: ID=%v, CustomerID=%v, VendorID=%v, MotorID=%v", 
		booking.ID, *booking.CustomerID, booking.VendorID, booking.MotorID)

	// Commit the transaction and mark as committed
	if err := tx.Commit().Error; err != nil {
		log.Printf("[DEBUG] Failed to commit transaction: %v", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal menyimpan data booking"})
		return
	}
	txCommitted = true
	log.Printf("[DEBUG] Transaction committed successfully")

	// Create notification using a separate database connection (not in transaction)
	notification := models.Notification{
		UserID:    motor.VendorID,
		Message:   fmt.Sprintf("Ada booking baru dari %s untuk motor %s pada tanggal %s", customer.Name, motor.Name, booking.StartDate.Format("02 Jan 2006")),
		Status:    "unread",
		BookingID: booking.ID,
		CreatedAt: time.Now(),
	}

	log.Printf("[DEBUG] Creating notification for vendor_id: %v from user_id: %v", motor.VendorID, *booking.CustomerID)
	if err := config.DB.Create(&notification).Error; err != nil {
		log.Printf("❗ [DEBUG] Gagal menyimpan notifikasi vendor: %v", err)
	} else {
		log.Printf("[DEBUG] Created notification: ID=%v, UserID=%v, BookingID=%v", 
			notification.ID, notification.UserID, notification.BookingID)
		
		notifPayload := map[string]interface{}{
			"message":    notification.Message,
			"booking_id": notification.BookingID,
		}

		notifJSON, err := json.Marshal(notifPayload)
		if err != nil {
			log.Printf("❗ [DEBUG] Gagal encode notifikasi ke JSON (vendor): %v", err)
		} else {
			log.Printf("[DEBUG] Sending WebSocket notification to vendor_id: %v", motor.VendorID)
			websocket.SendNotificationToVendor(motor.VendorID, string(notifJSON))
			log.Printf("[DEBUG] WebSocket notification sent to vendor_id: %v", motor.VendorID)
		}
	}

	c.JSON(http.StatusOK, gin.H{"message": "Booking berhasil dibuat", "booking": booking})
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
