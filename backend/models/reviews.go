package models

import "time"

// Review adalah model untuk ulasan
type Review struct {
	ID         uint      `gorm:"primaryKey" json:"id"`
	CustomerID uint      `gorm:"not null" json:"customer_id"`
	BookingID  uint      `gorm:"not null;unique" json:"booking_id"`
	VendorID   uint      `gorm:"not null" json:"vendor_id"`
	MotorID    uint      `gorm:"not null" json:"motor_id"`
	Rating     float32   `gorm:"not null" json:"rating"`
	Review     string    `gorm:"type:text" json:"review"`
	CreatedAt  time.Time `json:"created_at"`

	Booking  *Booking `gorm:"foreignKey:BookingID" json:"booking"`
	Customer *User    `gorm:"foreignKey:CustomerID" json:"customer"`
	Motor    *Motor   `gorm:"foreignKey:MotorID" json:"motor"`
	Vendor   *Vendor  `gorm:"foreignKey:UserID" json:"vendor"`
}

func (Review) TableName() string {
	return "reviews"
}
