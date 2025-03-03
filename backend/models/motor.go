package models

import "time"

type Motor struct {
	ID        uint      `gorm:"primaryKey" json:"id"`
	VendorID  uint      `gorm:"not null" json:"vendor_id"`
	Vendor    Vendor    `gorm:"foreignKey:VendorID"` 
	Name      string    `gorm:"size:100;not null" json:"name"`
	Brand     string    `gorm:"size:50;not null" json:"brand"`
	Model     string    `gorm:"size:50;not null" json:"model"`
	Year      uint      `gorm:"not null" json:"year"`
	Price     float64   `gorm:"type:decimal(10,2);not null" json:"price"`
	Color     string    `gorm:"size:50" json:"color"`
	Status    string    `gorm:"type:enum('available','booked','unavailable');default:'available'" json:"status"`
	Image     string    `gorm:"size:255" json:"image"`
	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`
}
func (Motor) TableName() string {
	return "motor" // Sesuaikan dengan nama tabel yang ada di DB
}


