package models

import "time"

type Vendor struct {
    ID              uint      `gorm:"primaryKey;autoIncrement;not null" json:"id"`
    UserID          uint      `gorm:"unique;not null" json:"user_id"` // foreign key untuk users
    IDKecamatan     *uint     `gorm:"index" json:"id_kecamatan"`       // foreign key untuk kecamatan
    ShopName        string    `gorm:"size:100;not null" json:"shop_name"`
    ShopAddress     string    `gorm:"not null" json:"shop_address"`
    ShopDescription string    `gorm:"type:text" json:"shop_description"`
    Status          string    `gorm:"type:enum('active', 'inactive');default:'active'" json:"status"`
    Rating          float32   `gorm:"default:0" json:"rating"`
    CreatedAt       time.Time `gorm:"autoCreateTime" json:"created_at"`
    UpdatedAt       time.Time `gorm:"autoUpdateTime" json:"updated_at"`
    Motors []Motor `gorm:"foreignKey:VendorID" json:"motors" binding:"-"`
    User   User    `gorm:"foreignKey:UserID" json:"user" binding:"-"`
}


func (Vendor) TableName() string {
	return "vendors" // Harus sesuai dengan nama tabel di MySQL
}
