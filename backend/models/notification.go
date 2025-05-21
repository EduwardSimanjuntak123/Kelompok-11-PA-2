package models

import "time"

type Notification struct {
	ID        int       `json:"id"`
	UserID    uint      `json:"user_id"`
	Message   string    `json:"message"`
	Status    string    `gorm:"type:enum('unread','read');default:'unread';not null" json:"status"`
	BookingID uint      `json:"booking_id"`
	CreatedAt time.Time `json:"created_at"`
}
