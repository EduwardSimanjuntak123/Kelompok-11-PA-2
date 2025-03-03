package models

import "gorm.io/gorm"

type Ulasan struct {
	gorm.Model
	UserID   uint    `json:"user_id"`
	BookingID uint   `json:"booking_id"`
	MotorID  uint    `json:"motor_id"`
	Rating   float64 `json:"rating" gorm:"check:rating >= 0 AND rating <= 5"`
	Komentar string  `json:"komentar"`
}
