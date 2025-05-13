package models

import (
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
    BookingID      *uint     `gorm:"foreignKey:BookingID" json:"booking_id"`
    VendorID       uint      `gorm:"not null" json:"vendor_id"`
    CustomerID     *uint     `gorm:"foreignKey:CustomerID" json:"customer_id"`
    MotorID        uint      `gorm:"not null" json:"motor_id"`
    Type           string    `gorm:"type:varchar(255);not null" json:"type"`
    TotalPrice     float64   `gorm:"not null" json:"total_price"`
    StartDate      time.Time `gorm:"not null" json:"start_date"`
    EndDate        time.Time `gorm:"not null" json:"end_date"`
    PickupLocation string    `gorm:"not null" json:"pickup_location"`
    Status         string    `gorm:"type:varchar(255);default:'completed'" json:"status"`
    CreatedAt      time.Time `json:"created_at"`
    UpdatedAt      time.Time `json:"updated_at"`
}


// Fungsi untuk menghitung total harga berdasarkan motor dan durasi

