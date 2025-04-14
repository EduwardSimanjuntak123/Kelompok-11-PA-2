package models

import "time"

type ChatRoom struct {
	ID         uint      `gorm:"primaryKey" json:"id"`
	CustomerID uint      `gorm:"not null" json:"customer_id"`
	VendorID   uint      `gorm:"not null" json:"vendor_id"`
	CreatedAt  time.Time `gorm:"autoCreateTime" json:"created_at"`
	UpdatedAt  time.Time `gorm:"autoUpdateTime" json:"updated_at"`
	Messages   []Message `gorm:"foreignKey:ChatRoomID" json:"messages"`

	Customer   User      `gorm:"foreignKey:CustomerID" json:"customer"`
	Vendor     User      `gorm:"foreignKey:VendorID" json:"vendor"`
}