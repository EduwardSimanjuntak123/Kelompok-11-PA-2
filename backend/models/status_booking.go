package models

import "gorm.io/gorm"

type StatusBooking struct {
	gorm.Model
	Keterangan string `json:"keterangan"`
}