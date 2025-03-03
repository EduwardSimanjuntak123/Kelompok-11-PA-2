package models

import "time"

type Notification struct {
	ID        uint      `gorm:"primaryKey"`
	UserID    uint      `gorm:"not null"`
	Message   string    `gorm:"not null"`
	Status    string    `gorm:"type:enum('unread', 'read');default:'unread'"`
	CreatedAt time.Time
	UpdatedAt time.Time
}
