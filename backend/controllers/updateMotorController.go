package controllers

import (
	"fmt"
	"log"
	"time"

	"rental-backend/config"
	"rental-backend/models"
	"rental-backend/websocketupdatemotor"
)

// Fungsi untuk memperbarui status motor secara real-time
func AutoUpdateMotorStatus() {
	for {
		now := time.Now().UTC()

		var bookings []models.Booking
		if err := config.DB.
			Where("status IN ('confirmed', 'in transit', 'in use', 'awaiting return')").
			Find(&bookings).Error; err != nil {
			log.Printf("❌ Error fetching bookings: %v", err)
			time.Sleep(500 * time.Millisecond)
			continue
		}

		bookedMotors := make(map[uint]bool)

		for _, booking := range bookings {
			var motor models.Motor
			if err := config.DB.First(&motor, booking.MotorID).Error; err != nil {
				log.Printf("❌ Motor ID %d tidak ditemukan: %v", booking.MotorID, err)
				continue
			}

			endDateUTC := booking.EndDate.UTC()

			if now.Before(endDateUTC) {
				bookedMotors[motor.ID] = true
			}
		}

		var allMotors []models.Motor
		if err := config.DB.Find(&allMotors).Error; err != nil {
			log.Printf("❌ Error fetching motors: %v", err)
			time.Sleep(2 * time.Minute)
			continue
		}

		for _, motor := range allMotors {
			oldStatus := motor.Status

			if motor.Status == "unavailable" {
				continue
			}

			if bookedMotors[motor.ID] {
				motor.Status = "booked"
			} else {
				motor.Status = "available"
			}

			if oldStatus != motor.Status {
				log.Printf("🔄 Motor ID %d -> Status berubah dari '%s' ke '%s'", motor.ID, oldStatus, motor.Status)
			
				if err := config.DB.Save(&motor).Error; err != nil {
					log.Printf("❌ Gagal memperbarui status motor ID %d: %v", motor.ID, err)
				} else {
					// ✅ Kirim update ke client via WebSocket setelah berhasil simpan
					websocketupdatemotor.BroadcastMotorStatus(
						`{"motor_id": ` +
							fmt.Sprintf("%d", motor.ID) +
							`, "new_status": "` +
							motor.Status + `"}`,
					)
				}
			}
		}

		time.Sleep(5 * time.Minute)
	}
}

func StartAutoUpdateMotorStatus() {
	log.Println("🕒 Memulai auto update status motor secara real-time...")
	go AutoUpdateMotorStatus()
}
