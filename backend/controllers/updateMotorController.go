package controllers

import (
	"log"
	"time"

	"rental-backend/config"
	"rental-backend/models"
)

// Fungsi untuk memperbarui status motor secara real-time
func AutoUpdateMotorStatus() {
	for {
		// log.Println("🔄 Memulai update status motor otomatis...")

		// Gunakan UTC untuk konsistensi
		now := time.Now().UTC()
		// log.Printf("⏳ Waktu sekarang (UTC): %v\n", now)

		// Ambil semua booking yang masih aktif
		var bookings []models.Booking
		if err := config.DB.Where("status IN ('confirmed', 'in transit', 'in use', 'awaiting return')").Find(&bookings).Error; err != nil {
			log.Printf("❌ Error fetching bookings: %v", err)
			time.Sleep(500 * time.Millisecond) // Jika error, beri delay agar tidak overload
			continue
		}

		// Gunakan map untuk menyimpan ID motor yang sedang "booked"
		bookedMotors := make(map[uint]bool)

		// Proses setiap booking
		for _, booking := range bookings {
			log.Printf("📅 Memproses Booking ID %d | Motor ID %d", booking.ID, booking.MotorID)

			// Ambil motor terkait
			var motor models.Motor
			if err := config.DB.Where("id = ?", booking.MotorID).First(&motor).Error; err != nil {
				log.Printf("❌ Motor ID %d tidak ditemukan: %v", booking.MotorID, err)
				continue
			}

			// Konversi waktu booking ke UTC
			startDateUTC := booking.StartDate.UTC()
			endDateUTC := booking.EndDate.UTC()
			log.Printf("📌 Start Date (UTC): %v | End Date (UTC): %v", startDateUTC, endDateUTC)

			// Jika booking masih aktif, motor harus menjadi "booked"
			if now.Before(endDateUTC) {
				bookedMotors[motor.ID] = true
			}
		}

		// Ambil semua motor yang ada di database
		var allMotors []models.Motor
		if err := config.DB.Find(&allMotors).Error; err != nil {
			log.Printf("❌ Error fetching motors: %v", err)
			time.Sleep(2 * time.Minute) // Jika error, beri delay agar tidak overload
			continue
		}

		// Perbarui status motor berdasarkan booking yang ada
		for _, motor := range allMotors {
			oldStatus := motor.Status

			if motor.Status == "unavailable" {
				// log.Printf("⏸️ Motor ID %d tetap 'unavailable', tidak diubah", motor.ID)
				continue
			}

			if bookedMotors[motor.ID] {
				motor.Status = "booked"
			} else {
				motor.Status = "available"
			}

			// Simpan hanya jika status berubah
			if oldStatus != motor.Status {
				log.Printf("🔄 Motor ID %d -> Status berubah dari '%s' ke '%s'", motor.ID, oldStatus, motor.Status)
				if err := config.DB.Save(&motor).Error; err != nil {
					log.Printf("❌ Gagal memperbarui status motor ID %d: %v", motor.ID, err)
				}
			}
		}

		time.Sleep(500 * time.Millisecond) // Beri sedikit delay agar CPU tidak 100%
	}
}

// **Fungsi untuk menjalankan auto update secara real-time**
func StartAutoUpdateMotorStatus() {
	log.Println("🕒 Memulai auto update status motor secara real-time...")

	// Jalankan dalam Goroutine agar berjalan terus-menerus tanpa blocking
	go AutoUpdateMotorStatus()
}
