package models

import (
	"time"
)

type BookingExtension struct {
    ID                uint       `gorm:"primaryKey" json:"id"`
    BookingID         uint       `json:"booking_id"`
    Booking           Booking    `gorm:"foreignKey:BookingID" json:"-"`
    RequestedEndDate  time.Time  `json:"requested_end_date"`
    Status            string     `gorm:"type:enum('pending','approved','rejected');default:'pending'" json:"status"`
    RequestedAt       time.Time  `gorm:"autoCreateTime" json:"requested_at"`
    ApprovedAt        *time.Time `json:"approved_at,omitempty"`
}
