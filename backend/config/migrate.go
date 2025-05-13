package config

import (
	"log"
	"rental-backend/models"

	"gorm.io/gorm"
)

func MigrateDatabase(db *gorm.DB) {
	err := db.AutoMigrate(
		

		&models.User{},
		&models.Kecamatan{},
		&models.Vendor{},
		&models.Motor{},
		&models.Booking{},
		&models.BookingExtension{},
		&models.Notification{},
		&models.Review{},
		&models.ChatRoom{},
		&models.Message{},
		&models.OtpRequest{},
		&models.Transaction{},
		&models.LocationRecommendation{},
	)
	if err != nil {
		log.Fatal("❌ Migrasi database gagal:", err)
	}

	log.Println("✅ Migrasi database berhasil.")
}
