package models

import "time"

type Message struct {
    ID         uint      `gorm:"primaryKey" json:"message_id"`
    ChatRoomID uint      `gorm:"not null" json:"chat_room_id"`
    SenderID   uint      `gorm:"not null" json:"sender_id"`
    Message    string    `gorm:"not null" json:"message"`
    SentAt     time.Time `json:"sent_at"`
    IsRead     bool      `gorm:"default:false" json:"is_read"`
    // Jika tidak ingin mengirim data ChatRoom dan Sender, gunakan tag "-" untuk mengabaikannya
    ChatRoom   ChatRoom  `gorm:"foreignKey:ChatRoomID"`
    Sender     User      `gorm:"foreignKey:SenderID" json:"sender"`
}