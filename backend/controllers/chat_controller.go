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

	"github.com/gin-gonic/gin"
	"github.com/gorilla/websocket"
	"gorm.io/gorm"
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

	// Validasi chat room ada
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
		msg.IsRead = false

		if err := config.DB.Create(&msg).Error; err != nil {
			log.Println("Gagal menyimpan pesan:", err)
			continue
		}

		// Preload sender untuk respons
		config.DB.Preload("Sender").First(&msg, msg.ID)

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
		Content    string `json:"message" binding:"required"`
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
		IsRead:     false,
	}

	// Simpan pesan ke database
	if err := config.DB.Create(&message).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal menyimpan pesan"})
		return
	}

	// Preload sender untuk respons
	config.DB.Preload("Sender").First(&message, message.ID)

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

// MarkMessageAsRead menandai pesan sebagai sudah dibaca
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

// MarkAllMessagesAsRead menandai semua pesan di chat room sebagai sudah dibaca
func MarkAllMessagesAsRead(c *gin.Context) {
	var req struct {
		ChatRoomID uint `json:"chat_room_id" binding:"required"`
		UserID     uint `json:"user_id" binding:"required"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error":   "Data tidak valid",
			"details": err.Error(),
		})
		return
	}

	// Tandai semua pesan yang dikirim oleh lawan bicara sebagai sudah dibaca
	if err := config.DB.Model(&models.Message{}).
		Where("chat_room_id = ? AND is_read = false AND sender_id != ?", req.ChatRoomID, req.UserID).
		Update("is_read", true).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal memperbarui pesan"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Semua pesan ditandai sebagai dibaca"})
}

// GetOrCreateChatRoom membuat atau ambil chat room
type ChatRoomRequest struct {
	CustomerID uint `json:"customer_id" binding:"required"`
	VendorID   uint `json:"vendor_id" binding:"required"`
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
	if err := config.DB.First(&vendor, req.VendorID).Error; err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Vendor tidak ditemukan"})
		return
	}

	// Cek apakah customer_id ada dalam tabel users
	var customer models.User
	if err := config.DB.First(&customer, req.CustomerID).Error; err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Customer tidak ditemukan"})
		return
	}

	// Cek apakah chat room sudah ada
	var room models.ChatRoom
	err := config.DB.
		Preload("Customer").
		Preload("Vendor").
		Preload("Messages", func(db *gorm.DB) *gorm.DB {
			return db.Order("sent_at ASC") // urutkan pesan lama ke baru
		}).
		Preload("Messages.Sender"). // preload sender info tiap message
		Where("customer_id = ? AND vendor_id = ?", req.CustomerID, req.VendorID).
		First(&room).Error

	if err == nil {
		// Hitung jumlah pesan yang belum dibaca untuk customer dan vendor
		var unreadForCustomer, unreadForVendor int64
		config.DB.Model(&models.Message{}).
			Where("chat_room_id = ? AND is_read = false AND sender_id != ?", room.ID, req.CustomerID).
			Count(&unreadForCustomer)
		
		config.DB.Model(&models.Message{}).
			Where("chat_room_id = ? AND is_read = false AND sender_id != ?", room.ID, req.VendorID).
			Count(&unreadForVendor)

		c.JSON(http.StatusOK, gin.H{
			"message": "Chat room ditemukan", 
			"chat_room": room,
			"unread_stats": gin.H{
				"unread_for_customer": unreadForCustomer,
				"unread_for_vendor": unreadForVendor,
			},
		})
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

	// Setelah buat baru, preload juga semua relasi
	if err := config.DB.
		Preload("Customer").
		Preload("Vendor").
		Preload("Messages", func(db *gorm.DB) *gorm.DB {
			return db.Order("sent_at ASC")
		}).
		Preload("Messages.Sender").
		First(&newRoom, newRoom.ID).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal memuat chat room setelah dibuat"})
		return
	}

	c.JSON(http.StatusCreated, gin.H{
		"message": "Chat room berhasil dibuat", 
		"chat_room": newRoom,
		"unread_stats": gin.H{
			"unread_for_customer": 0,
			"unread_for_vendor": 0,
		},
	})
}

// GetUserChatRooms mengambil semua chat room milik user
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
		Preload("Messages.Sender").
		Where("customer_id = ? OR vendor_id = ?", userID, userID).
		Order("updated_at DESC").
		Find(&chatRooms).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal mengambil chat rooms"})
		return
	}

	// Hitung jumlah pesan yang belum dibaca untuk setiap chat room
	type ChatRoomWithUnread struct {
		ChatRoom      models.ChatRoom `json:"chat_room"`
		UnreadCount   int64           `json:"unread_count"`
		LastMessage   *models.Message `json:"last_message,omitempty"`
		OtherUserInfo gin.H           `json:"other_user_info"`
	}

	var result []ChatRoomWithUnread

	for _, room := range chatRooms {
		var unreadCount int64
		config.DB.Model(&models.Message{}).
			Where("chat_room_id = ? AND is_read = false AND sender_id != ?", room.ID, userID).
			Count(&unreadCount)

		// Ambil pesan terakhir
		var lastMessage models.Message
		hasLastMessage := false
		if err := config.DB.
			Preload("Sender").
			Where("chat_room_id = ?", room.ID).
			Order("sent_at desc").
			First(&lastMessage).Error; err == nil {
			hasLastMessage = true
		}

		// Tentukan info lawan bicara
		var otherUserInfo gin.H
		if room.CustomerID == userID {
	otherUserInfo = gin.H{
		"id":            room.VendorID,
		"name":          room.Vendor.Name,
		"role":          room.Vendor.Role,
		"profile_image": room.Vendor.ProfileImage,
	}
	if room.Vendor.Vendor != nil {
		otherUserInfo["shop_name"] = room.Vendor.Vendor.ShopName
	}
} else {
	otherUserInfo = gin.H{
		"id":            room.CustomerID,
		"name":          room.Customer.Name,
		"role":          room.Customer.Role,
		"profile_image": room.Customer.ProfileImage,
	}
}


		roomWithUnread := ChatRoomWithUnread{
			ChatRoom:      room,
			UnreadCount:   unreadCount,
			OtherUserInfo: otherUserInfo,
		}

		if hasLastMessage {
			roomWithUnread.LastMessage = &lastMessage
		}

		result = append(result, roomWithUnread)
	}

	c.JSON(http.StatusOK, gin.H{
		"user_id":    userID,
		"chat_rooms": result,
	})
}

// GetUnreadMessageCount mendapatkan jumlah pesan yang belum dibaca
func GetUnreadMessageCount(c *gin.Context) {
	userIDStr := c.Query("user_id")
	userIDInt, err := strconv.Atoi(userIDStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "user_id tidak valid"})
		return
	}
	userID := uint(userIDInt)

	// Hitung total pesan yang belum dibaca di semua chat room
	var totalUnread int64
	if err := config.DB.Model(&models.Message{}).
		Joins("JOIN chat_rooms ON messages.chat_room_id = chat_rooms.id").
		Where("(chat_rooms.customer_id = ? OR chat_rooms.vendor_id = ?) AND messages.is_read = false AND messages.sender_id != ?", 
			userID, userID, userID).
		Count(&totalUnread).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal menghitung pesan yang belum dibaca"})
		return
	}

	// Hitung jumlah pesan yang belum dibaca per chat room
	type ChatRoomUnread struct {
		ChatRoomID  uint  `json:"chat_room_id"`
		UnreadCount int64 `json:"unread_count"`
	}

	var chatRoomUnreads []ChatRoomUnread
	rows, err := config.DB.Raw(`
		SELECT messages.chat_room_id, COUNT(*) as unread_count
		FROM messages
		JOIN chat_rooms ON messages.chat_room_id = chat_rooms.id
		WHERE (chat_rooms.customer_id = ? OR chat_rooms.vendor_id = ?) 
		AND messages.is_read = false 
		AND messages.sender_id != ?
		GROUP BY messages.chat_room_id
	`, userID, userID, userID).Rows()

	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal menghitung pesan yang belum dibaca per chat room"})
		return
	}
	defer rows.Close()

	for rows.Next() {
		var unread ChatRoomUnread
		if err := rows.Scan(&unread.ChatRoomID, &unread.UnreadCount); err != nil {
			continue
		}
		chatRoomUnreads = append(chatRoomUnreads, unread)
	}

	c.JSON(http.StatusOK, gin.H{
		"user_id":      userID,
		"total_unread": totalUnread,
		"chat_rooms":   chatRoomUnreads,
	})
}

// DeleteChatRoom menghapus chat room dan semua pesannya
func DeleteChatRoom(c *gin.Context) {
	chatRoomID := c.Param("id")
	
	// Validasi chat room ada
	var chatRoom models.ChatRoom
	if err := config.DB.First(&chatRoom, chatRoomID).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Chat room tidak ditemukan"})
		return
	}

	// Hapus semua pesan di chat room
	if err := config.DB.Where("chat_room_id = ?", chatRoomID).Delete(&models.Message{}).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal menghapus pesan"})
		return
	}

	// Hapus chat room
	if err := config.DB.Delete(&chatRoom).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal menghapus chat room"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Chat room berhasil dihapus"})
}

// SearchChatMessages mencari pesan berdasarkan kata kunci
func SearchChatMessages(c *gin.Context) {
	userIDStr := c.Query("user_id")
	userIDInt, err := strconv.Atoi(userIDStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "user_id tidak valid"})
		return
	}
	userID := uint(userIDInt)

	keyword := c.Query("keyword")
	if keyword == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Kata kunci pencarian tidak boleh kosong"})
		return
	}

	var messages []models.Message
	if err := config.DB.
		Preload("Sender").
		Preload("ChatRoom").
		Joins("JOIN chat_rooms ON messages.chat_room_id = chat_rooms.id").
		Where("(chat_rooms.customer_id = ? OR chat_rooms.vendor_id = ?) AND messages.message LIKE ?", 
			userID, userID, "%"+keyword+"%").
		Order("messages.sent_at DESC").
		Find(&messages).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal mencari pesan"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"keyword":  keyword,
		"messages": messages,
	})
}