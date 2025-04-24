package models

import "time"
	
type Notification struct {
	ID        int       `json:"id"`
	UserID    uint      `json:"user_id"` 
	Message   string    `json:"message"`
	Status    string    `json:"status"` // 0 atau 1
	BookingID uint      `json:"booking_id"` 
	CreatedAt time.Time `json:"created_at"`
}
