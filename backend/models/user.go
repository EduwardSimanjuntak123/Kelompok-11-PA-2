package models

import "time"

// models/user.go
type User struct {
    ID           uint      `gorm:"primaryKey" json:"id"`
    Name         string    `gorm:"size:100;not null" json:"name"`
    Email        string    `gorm:"size:100;unique;not null" json:"email"`
    Password     string    `gorm:"size:255;not null" json:"password"`
    Role         string    `gorm:"type:enum('admin', 'vendor', 'customer');default:'customer'" json:"role"`
    Phone        string    `gorm:"size:20;unique;not null" json:"phone"`
    Address      string    `json:"address"`
    BirthDate *time.Time `form:"birth_date" time_format:"2006-01-02"`
    ProfileImage string    `json:"profile_image"`
    Status       string    `gorm:"type:enum('active', 'inactive');default:'active'" json:"status"`
    CreatedAt    time.Time `json:"created_at"`
    UpdatedAt    time.Time `json:"updated_at"`
    // Relasi ke Vendor jika role adalah 'vendor'
    Vendor   *Vendor    `gorm:"foreignKey:UserID" json:"vendor"`
    Bookings []Booking `gorm:"foreignKey:CustomerID" json:"bookings" binding:"-"`
}


// Pastikan nama tabel sesuai dengan MySQL
func (User) TableName() string {
	return "users" // Harus sesuai dengan nama tabel di MySQL (huruf besar kecil harus cocok)
}
