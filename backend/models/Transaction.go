package models

import (
	"log"
	"rental-backend/config"
	"time"
)

// Definisikan enum values sebagai konstanta untuk 'Type' dan 'Status'
const (
	BookingType = "booking" // Tipe transaksi untuk booking aplikasi
	ManualType  = "manual"  // Tipe transaksi untuk transaksi manual
	Completed   = "completed"
	Disputed    = "disputed"
)

type Transaction struct {
	ID             uint      `gorm:"primaryKey" json:"id"`
	BookingID      *uint     `gorm:"foreignKey:BookingID" json:"booking_id"` // Pointer karena nullable
	VendorID       uint      `gorm:"not null" json:"vendor_id"`
	CustomerID     *uint     `gorm:"foreignKey:CustomerID" json:"customer_id"` // Pointer karena nullable
	MotorID        uint      `gorm:"not null" json:"motor_id"`
	Type           string    `gorm:"type:varchar(255);not null" json:"type"` // 'transaction' or 'manual'
	TotalPrice     float64   `gorm:"not null" json:"total_price"`
	StartDate      time.Time `gorm:"not null" json:"start_date"`
	EndDate        time.Time `gorm:"not null" json:"end_date"`
	PickupLocation string    `gorm:"not null" json:"pickup_location"`
	Status         string    `gorm:"type:varchar(255);default:'completed'" json:"status"` // 'completed' or 'disputed'
	CreatedAt      time.Time `json:"created_at"`
	UpdatedAt      time.Time `json:"updated_at"`
}

// Fungsi untuk menghitung total harga berdasarkan motor dan durasi
func CalculateTotalPrice(motorID uint, startDate, endDate time.Time) float64 {
	// Contoh perhitungan harga, ini bisa disesuaikan dengan aturan harga motor
	var motor Motor // Merujuk ke struct Motor dalam paket yang sama
	if err := config.DB.Where("id = ?", motorID).First(&motor).Error; err != nil {
		log.Printf("Motor tidak ditemukan: %v", err)
		return 0
	}

	// Hitung durasi rental dalam hari
	duration := endDate.Sub(startDate).Hours() / 24
	totalPrice := duration * float64(motor.Price)
	return totalPrice
}
