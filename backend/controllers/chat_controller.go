package controllers

import (
	"encoding/json"
	"log"
	"net/http"
	"rental-backend/config"
	"rental-backend/models"
	"strconv"
	"sync"
	"time"

	"gorm.io/gorm"

	"github.com/gin-gonic/gin"
	"github.com/gorilla/websocket"
)

// Upgrader untuk WebSocket
var upgrader = websocket.Upgrader{
	CheckOrigin: func(r *http.Request) bool {
		return true
	},
}

// Global map untuk koneksi WebSocket per ChatRoom
var chatRoomConnections = make(map[uint][]*websocket.Conn)
var chatRoomMutex = &sync.Mutex{}

// ChatWebSocket meng-handle koneksi WebSocket chat
func ChatWebSocket(c *gin.Context) {
	// Ambil sender_id dari query parameter
	senderIDStr := c.Query("sender_id")
	senderIDInt, err := strconv.Atoi(senderIDStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "sender_id tidak valid"})
		return
	}
	senderID := uint(senderIDInt)

	// Ambil chat_room_id dari query
	chatRoomIDStr := c.Query("chat_room_id")
	chatRoomIDInt, err := strconv.Atoi(chatRoomIDStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "chat_room_id tidak valid"})
		return
	}
	chatRoomID := uint(chatRoomIDInt)

	// (Opsional) Validasi chat room ada
	var chatRoom models.ChatRoom
	if err := config.DB.First(&chatRoom, chatRoomID).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Chat room tidak ditemukan"})
		return
	}

	// Upgrade koneksi ke WebSocket
	conn, err := upgrader.Upgrade(c.Writer, c.Request, nil)
	if err != nil {
		log.Println("WebSocket upgrade error:", err)
		return
	}

	chatRoomMutex.Lock()
	chatRoomConnections[chatRoomID] = append(chatRoomConnections[chatRoomID], conn)
	chatRoomMutex.Unlock()
	log.Printf("Client (user %d) terhubung di ChatRoom %d", senderID, chatRoomID)

	defer func() {
		chatRoomMutex.Lock()
		conns := chatRoomConnections[chatRoomID]
		for i, c := range conns {
			if c == conn {
				chatRoomConnections[chatRoomID] = append(conns[:i], conns[i+1:]...)
				break
			}
		}
		chatRoomMutex.Unlock()
		conn.Close()
		log.Printf("Client (user %d) terputus dari ChatRoom %d", senderID, chatRoomID)
	}()

	for {
		_, messageBytes, err := conn.ReadMessage()
		if err != nil {
			log.Println("Error membaca pesan:", err)
			break
		}

		var msg models.Message
		if err := json.Unmarshal(messageBytes, &msg); err != nil {
			log.Println("Gagal decode JSON:", err)
			continue
		}

		msg.SenderID = senderID
		msg.ChatRoomID = chatRoomID
		msg.SentAt = time.Now()

		if err := config.DB.Create(&msg).Error; err != nil {
			log.Println("Gagal menyimpan pesan:", err)
			continue
		}

		encodedMsg, _ := json.Marshal(msg)
		broadcastMessage(chatRoomID, encodedMsg)
	}
}




// broadcastMessage mengirim ke semua koneksi di chatRoom
func broadcastMessage(chatRoomID uint, message []byte) {
	chatRoomMutex.Lock()
	defer chatRoomMutex.Unlock()

	for _, conn := range chatRoomConnections[chatRoomID] {
		if err := conn.WriteMessage(websocket.TextMessage, message); err != nil {
			log.Println("Gagal mengirim pesan ke client:", err)
		}
	}
}


// SendMessage melalui endpoint HTTP
func SendMessage(c *gin.Context) {
	var input struct {
		ChatRoomID uint   `json:"chat_room_id" binding:"required"`
		SenderID   uint   `json:"sender_id" binding:"required"`
		Content    string `json:"content" binding:"required"`
	}

	// Mengambil data dari body request
	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error":   "Data tidak valid",
			"details": err.Error(),
		})
		return
	}

	// Ambil data chat room berdasarkan ID
	var chatRoom models.ChatRoom
	if err := config.DB.First(&chatRoom, input.ChatRoomID).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Chat room tidak ditemukan"})
		return
	}

	// Validasi apakah sender adalah customer atau vendor dari chat room
	if input.SenderID != chatRoom.CustomerID && input.SenderID != chatRoom.VendorID {
		c.JSON(http.StatusForbidden, gin.H{"error": "Kamu tidak termasuk dalam chat room ini"})
		return
	}

	// Buat objek pesan
	message := models.Message{
		ChatRoomID: input.ChatRoomID,
		SenderID:   input.SenderID,
		Message:    input.Content,
		SentAt:     time.Now(),
	}

	// Simpan pesan ke database
	if err := config.DB.Create(&message).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal menyimpan pesan"})
		return
	}

	// Broadcast pesan ke semua koneksi WebSocket yang terhubung di chat room
	encodedMsg, _ := json.Marshal(message)
	broadcastMessage(input.ChatRoomID, encodedMsg)

	c.JSON(http.StatusOK, gin.H{
		"message": "Pesan berhasil dikirim",
		"data":    message,
	})
}




// GetChatMessages mengambil pesan berdasarkan chat_room_id
func GetChatMessages(c *gin.Context) {
	// Ambil chat_room_id dari query parameter
	chatRoomIDStr := c.Query("chat_room_id")
	chatRoomID, err := strconv.Atoi(chatRoomIDStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "chat_room_id tidak valid"})
		return
	}

	// Ambil user_id dari query parameter
	userIDStr := c.Query("user_id")
	if userIDStr == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "user_id tidak ditemukan"})
		return
	}
	userID, err := strconv.Atoi(userIDStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "user_id tidak valid"})
		return
	}

	// Validasi bahwa user_id adalah bagian dari chat room (bisa sebagai customer atau vendor)
	var chatRoom models.ChatRoom
	if err := config.DB.First(&chatRoom, chatRoomID).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Chat room tidak ditemukan"})
		return
	}
	if chatRoom.CustomerID != uint(userID) && chatRoom.VendorID != uint(userID) {
		c.JSON(http.StatusForbidden, gin.H{"error": "Anda bukan bagian dari chat room ini"})
		return
	}

	// Ambil pesan-pesan berdasarkan chat_room_id
	var messages []models.Message
	if err := config.DB.Preload("Sender").
		Where("chat_room_id = ?", chatRoomID).
		Order("sent_at ASC").
		Find(&messages).Error; err != nil {
		log.Println("Error fetching messages:", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal mengambil pesan"})
		return
	}

	// Tandai pesan yang belum dibaca dan bukan dikirim oleh user tersebut sebagai sudah dibaca
	if err := config.DB.Model(&models.Message{}).
		Where("chat_room_id = ? AND is_read = false AND sender_id != ?", chatRoomID, userID).
		Update("is_read", true).Error; err != nil {
		log.Println("Error updating messages:", err)
	}

	c.JSON(http.StatusOK, gin.H{
		"messages": messages,
	})
}


func MarkMessageAsRead(c *gin.Context) {
	messageID := c.Param("id")
	var msg models.Message
	if err := config.DB.First(&msg, messageID).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Pesan tidak ditemukan"})
		return
	}

	msg.IsRead = true
	if err := config.DB.Save(&msg).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal memperbarui pesan"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Pesan ditandai sebagai dibaca"})
}

// GetOrCreateChatRoom membuat atau ambil chat room
type ChatRoomRequest struct {
	CustomerID uint `json:"customer_id,omitempty"`
	VendorID   uint `json:"vendor_id,omitempty"`
}
func GetOrCreateChatRoom(c *gin.Context) {
	var req ChatRoomRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error":   "Data tidak valid",
			"details": err.Error(),
		})
		return
	}

	// Cek apakah vendor_id ada dalam tabel users
	var vendor models.User
	result := config.DB.Where("id = ?", req.VendorID).First(&vendor)
	if result.Error != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Vendor tidak ditemukan"})
		return
	}

	// Melanjutkan proses seperti biasa
	var room models.ChatRoom
	result = config.DB.Where("customer_id = ? AND vendor_id = ?", req.CustomerID, req.VendorID).First(&room)
	if result.Error == nil {
		c.JSON(http.StatusOK, gin.H{"message": "Chat room ditemukan", "chat_room": room})
		return
	}

	// Room belum ada, buat baru
	newRoom := models.ChatRoom{
		CustomerID: req.CustomerID,
		VendorID:   req.VendorID,
	}
	if err := config.DB.Create(&newRoom).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal membuat chat room"})
		return
	}

	c.JSON(http.StatusCreated, gin.H{"message": "Chat room berhasil dibuat", "chat_room": newRoom})
}



func GetUserChatRooms(c *gin.Context) {
	// Ambil user_id dari query parameter
	userIDStr := c.Query("user_id")
	userIDInt, err := strconv.Atoi(userIDStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "user_id tidak valid"})
		return
	}
	userID := uint(userIDInt)

	var chatRooms []models.ChatRoom
	if err := config.DB.
	Preload("Customer").
	Preload("Vendor").
	Preload("Messages", func(db *gorm.DB) *gorm.DB {
		return db.Order("sent_at desc").Limit(1)
	}).
	Preload("Messages.Sender"). // ⬅️ preload data Sender
	Preload("Messages.ChatRoom"). // ⬅️ preload data ChatRoom
	Where("customer_id = ? OR vendor_id = ?", userID, userID).
	Find(&chatRooms).Error; err != nil {
	c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal mengambil chat rooms"})
	return
}

	c.JSON(http.StatusOK, gin.H{
		"user_id":    userID,
		"chat_rooms": chatRooms,
	})
}




