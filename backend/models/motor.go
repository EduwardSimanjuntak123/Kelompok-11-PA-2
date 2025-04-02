package models

import "time"

// models/motor.go
type Motor struct {
	ID          uint      `gorm:"primaryKey" json:"id"`
	VendorID    uint      `gorm:"not null" json:"vendor_id"`
	Vendor      Vendor    `gorm:"foreignKey:VendorID" json:"vendor"` // Perbaiki penamaan
	Name        string    `gorm:"size:100;not null" json:"name" form:"name"`
	Brand       string    `gorm:"size:50;not null" json:"brand" form:"brand"`
	Model       string    `gorm:"size:50;not null" json:"model" form:"model"`
	Year        uint      `gorm:"not null" json:"year" form:"year"`
	Rating      float64   `gorm:"not null;default:0" json:"rating" form:"rating"`
	Price       float64   `gorm:"type:decimal(10,2);not null" json:"price" form:"price"`
	Color       string    `gorm:"size:50" json:"color" form:"color"`
	Status      string    `gorm:"size:20;default:'available'" json:"status" form:"status"`
	Type        string    `gorm:"type:enum('automatic', 'manual', 'clutch', 'vespa');not null" json:"type" form:"type"`
	Description string    `gorm:"type:text" json:"description" form:"description"`
	Image       string    `gorm:"size:255" json:"image"`
	CreatedAt   time.Time `json:"created_at"`
	UpdatedAt   time.Time `json:"updated_at"`
}

func (Motor) TableName() string {
	return "motor" // Sesuaikan dengan nama tabel yang ada di DB
}
