package models

import (
	"time"

	"gorm.io/gorm"
)

type OtpRequest struct {
    ID        uint      `gorm:"primaryKey"`
    Email     string    `gorm:"type:varchar(100);not null"`
    OTP       string    `gorm:"type:varchar(6);not null"`
    ExpiresAt time.Time `gorm:"not null"`
    CreatedAt time.Time `gorm:"autoCreateTime"`
    UpdatedAt time.Time `gorm:"autoUpdateTime"`
    DeletedAt gorm.DeletedAt
}
