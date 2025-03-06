package models

import (
	"time"
)

type ChatRoom struct {
	ID         uint       `gorm:"primaryKey"`
	VendorID   uint       `gorm:"not null"`
	CustomerID uint       `gorm:"not null"`
	CreatedAt  time.Time  `json:"created_at"`
	UpdatedAt  time.Time  `json:"updated_at"`
	Messages   []Message  `gorm:"foreignKey:ChatRoomID"` // Relasi ke messages
	Vendor     User       `gorm:"foreignKey:VendorID"`    // Relasi ke vendor
	Customer   User       `gorm:"foreignKey:CustomerID"`  // Relasi ke customer
}
