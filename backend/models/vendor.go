package models

import "time"

type Vendor struct {
	ID              uint      `gorm:"primaryKey;autoIncrement;not null"`
	UserID          uint      `gorm:"unique;not null"` // foreign key untuk users
	IDKecamatan     *uint     `gorm:"index"`           // foreign key untuk kecamatan
	ShopName        string    `gorm:"size:100;not null"`
	ShopAddress     string    `gorm:"not null"`
	ShopDescription string    `gorm:"type:text"`
	Status          string    `gorm:"type:enum('active', 'inactive');default:'active'"`
	Rating          float32   `gorm:"default:0"`
	CreatedAt       time.Time `gorm:"autoCreateTime"`
	UpdatedAt       time.Time `gorm:"autoUpdateTime"`
	Motors          []Motor   `gorm:"foreignKey:VendorID"` // Relasi ke Motor
}

func (Vendor) TableName() string {
	return "vendors" // Harus sesuai dengan nama tabel di MySQL
}
