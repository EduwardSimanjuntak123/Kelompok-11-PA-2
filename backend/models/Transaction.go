package models

import "time"

type Transaction struct {
	ID             uint      `gorm:"primaryKey"`
	BookingID      *uint
	VendorID       uint      `gorm:"not null"`
	CustomerID     *uint
	MotorID        uint      `gorm:"not null"`
	Type           string    `gorm:"type:enum('online', 'manual');not null"`
	TotalPrice     float64   `gorm:"not null"`
	StartDate      time.Time `gorm:"not null"`
	EndDate        time.Time `gorm:"not null"`
	PickupLocation string    `gorm:"not null"`
	Status         string    `gorm:"type:enum('completed', 'disputed');default:'completed'"`
	CreatedAt      time.Time
	UpdatedAt      time.Time
}
