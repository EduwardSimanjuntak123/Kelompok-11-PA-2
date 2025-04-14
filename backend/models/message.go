package models

import "time"

type Message struct {
	ID         uint      `gorm:"primaryKey"`
	ChatRoomID uint      `gorm:"not null"`            // ForeignKey ke ChatRoom
	SenderID   uint      `gorm:"not null"`            // ForeignKey ke User
	Message    string    `gorm:"not null"`
	SentAt     time.Time `json:"sent_at"`
	IsRead     bool      `gorm:"default:false" json:"is_read"` 
	ChatRoom   ChatRoom  `gorm:"foreignKey:ChatRoomID"`
	Sender     User      `gorm:"foreignKey:SenderID"`
}