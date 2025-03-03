package models

import (
	"time"

	"gorm.io/gorm"
)

type OTP struct {
	gorm.Model
	UserID    uint      `json:"user_id"`    // ID user yang didaftarkan
	Code      string    `json:"code"`       // Kode OTP
	ExpiresAt time.Time `json:"expires_at"` // Waktu kedaluwarsa OTP
}

func (OTP) TableName() string {
	return "otp"
}

