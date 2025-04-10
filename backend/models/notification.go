package models

import "time"
	
type Notification struct {
	ID        int       `json:"id"`
	UserID    uint      `json:"user_id"` // ubah dari int ke uint
	Message   string    `json:"message"`
	Status    string    `json:"status"` // 'unread' atau 'read'
	BookingID uint      `json:"booking_id"` 
	CreatedAt time.Time `json:"created_at"`
}
