package models

import "time"

// Booking adalah model pemesanan motor
// Contoh model Booking (penyesuaian)
type Booking struct {
	ID             uint      `gorm:"primaryKey" json:"id"`
	CustomerID     *uint     `json:"customer_id"` // Boleh NULL jika customer tidak memiliki akun
	CustomerName   string    `gorm:"size:100;not null" json:"customer_name"`
	VendorID       uint      `gorm:"not null" json:"vendor_id"`
	MotorID        uint      `gorm:"not null" json:"motor_id" form:"motor_id"`
	BookingDate    time.Time `gorm:"default:CURRENT_TIMESTAMP" json:"booking_date"`
	StartDate      time.Time `gorm:"not null" json:"start_date" form:"start_date"`
	EndDate        time.Time `gorm:"not null" json:"end_date" form:"end_date"`
	PickupLocation string    `gorm:"not null" json:"pickup_location" form:"pickup_location"`
	Status         string    `gorm:"type:varchar(20);not null;default:'pending'" json:"status"`
	PhotoID        string    `gorm:"not null" json:"photo_id"`
	KtpID          string    `gorm:"not null" json:"ktp_id"`
	CreatedAt      time.Time `json:"created_at"`
	UpdatedAt      time.Time `json:"updated_at"`
	DropoffLocation string   `json:"dropoff_location" form:"dropoff_location"`
	// Field relasi; tidak di-bind dari input
	Vendor   *Vendor `gorm:"foreignKey:VendorID" json:"vendor" binding:"-"`
	Customer *User   `gorm:"foreignKey:CustomerID" json:"customer" binding:"-"`
	Motor    *Motor  `gorm:"foreignKey:MotorID" json:"motor" binding:"-"`
}



func (Booking) TableName() string {
	return "bookings" // Harus sesuai dengan nama tabel di MySQL (huruf besar kecil harus cocok)
}

func (b *Booking) GetDurationDays() int {
	duration := b.EndDate.Sub(b.StartDate).Hours() / 24
	return int(duration)
}
