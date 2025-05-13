package config

import (
	"log"
	"rental-backend/models"

	"golang.org/x/crypto/bcrypt"
	"gorm.io/gorm"
)

func SeedAdminUser(db *gorm.DB) {
	// Cek apakah admin sudah ada
	var admin models.User
	result := db.Where("email = ?", "admin@gmail.com").First(&admin)
	if result.Error == nil {
		log.Println("✅ Admin sudah tersedia")
		return
	}

	// Hash password
	hashedPassword, err := bcrypt.GenerateFromPassword([]byte("admin123"), bcrypt.DefaultCost)
	if err != nil {
		log.Println("❌ Gagal hash password:", err)
		return
	}

	// Buat admin baru
	admin = models.User{
		Name:     "Admin",
		Email:    "admin@gmail.com",
		Password: string(hashedPassword),
		Role:     "admin",
		Phone:    "081234567890",
		Address:  "Jl. Admin Center",
		Status:   "active",
	}

	if err := db.Create(&admin).Error; err != nil {
		log.Println("❌ Gagal membuat akun admin:", err)
		return
	}

	log.Println("✅ Admin berhasil dibuat dengan email admin@gmail.com dan password admin123")
}
