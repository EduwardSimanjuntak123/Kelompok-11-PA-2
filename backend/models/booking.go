package models

import "time"

type Booking struct {
	ID             uint      `gorm:"primaryKey"`
	CustomerID     uint      `gorm:"not null"`
	VendorID       uint      `gorm:"not null"`
	MotorID        uint      `gorm:"not null"`
	BookingDate    time.Time `gorm:"default:CURRENT_TIMESTAMP"`
	StartDate      time.Time `gorm:"not null"`
	EndDate        time.Time `gorm:"not null"`
	PickupLocation string    `gorm:"not null"`
	Status         string    `gorm:"type:enum('pending', 'confirmed','rejected', 'canceled', 'completed');default:'pending'"`
	PhotoID        string    `gorm:"not null"`
	KtpID          string    `gorm:"not null"`
	CreatedAt      time.Time
	UpdatedAt      time.Time
	Vendor         Vendor    `gorm:"foreignKey:VendorID"`
}

