package controllers

import (
	"net/http"
	"rental-backend/config"
	"rental-backend/models"
	"github.com/gin-gonic/gin"
	"strconv"
)

// Fungsi untuk membuat chat room antara vendor dan customer
func CreateChatRoom(c *gin.Context) {
	var chatRoom models.ChatRoom
	if err := c.ShouldBindJSON(&chatRoom); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Pastikan chat room dengan vendor dan customer tersebut belum ada
	var existingChatRoom models.ChatRoom
	if err := config.DB.Where("vendor_id = ? AND customer_id = ?", chatRoom.VendorID, chatRoom.CustomerID).First(&existingChatRoom).Error; err == nil {
		c.JSON(http.StatusConflict, gin.H{"error": "Chat room sudah ada"})
		return
	}

	// Simpan chat room ke database
	if err := config.DB.Create(&chatRoom).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal membuat chat room"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Chat room berhasil dibuat", "chat_room_id": chatRoom.ID})
}

// Fungsi untuk mengirim pesan ke chat room
func SendMessage(c *gin.Context) {
	chatRoomIDStr := c.Param("chat_room_id")

	// Convert chatRoomID from string to uint
	chatRoomID, err := strconv.ParseUint(chatRoomIDStr, 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid chat room ID"})
		return
	}

	var message models.Message

	// Bind the message payload
	if err := c.ShouldBindJSON(&message); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Set chat_room_id and sender_id
	message.ChatRoomID = uint(chatRoomID)

	// Simpan pesan ke database
	if err := config.DB.Create(&message).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to send message"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Message sent successfully"})
}

// Fungsi untuk mengambil semua pesan dalam chat room
func GetMessages(c *gin.Context) {
	chatRoomIDStr := c.Param("chat_room_id")

	// Convert chatRoomID from string to uint
	chatRoomID, err := strconv.ParseUint(chatRoomIDStr, 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid chat room ID"})
		return
	}

	var messages []models.Message

	// Ambil semua pesan yang terkait dengan chat_room_id
	if err := config.DB.Where("chat_room_id = ?", chatRoomID).Find(&messages).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to retrieve messages"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"messages": messages})
}

