package websocketupdatemotor

import (
	"net/http"
	"rental-backend/config"
	"rental-backend/models"
	ws "rental-backend/websocket"
	"strconv"

	"github.com/gin-gonic/gin"
	"github.com/gorilla/websocket"
)

// Upgrader khusus notifikasi
var upgraderNotif = websocket.Upgrader{
	CheckOrigin: func(r *http.Request) bool {
		// Izinkan semua origin (bisa dibatasi kalau perlu)
		return true
	},
}

// WebSocket handler untuk notifikasi
func WebSocketNotifikasiHandler(c *gin.Context) {
	userIDStr := c.Query("user_id")
	userID, err := strconv.Atoi(userIDStr)
	if err != nil || userID == 0 {
		c.JSON(http.StatusBadRequest, gin.H{"error": "user_id tidak valid"})
		return
	}

	conn, err := upgraderNotif.Upgrade(c.Writer, c.Request, nil)
	if err != nil {
		return
	}

	// Registrasi client ke peta notifikasi
	ws.RegisterClient(uint(userID), conn)

	// Dengarkan pesan sampai koneksi ditutup
	for {
		_, _, err := conn.ReadMessage()
		if err != nil {
			ws.UnregisterClient(uint(userID))
			conn.Close()
			break
		}
	}
}

// Fungsi untuk mengubah status notifikasi
func UpdateNotificationStatus(c *gin.Context) {
	// Ambil notification_id dari parameter URL
	notificationIDStr := c.Param("notification_id")
	status := c.DefaultQuery("status", "") // Status harus di query parameter

	// Validasi status, hanya "read" atau "unread"
	if status != "read" && status != "unread" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "status tidak valid, hanya 'read' atau 'unread'"})
		return
	}

	// Convert notification_id menjadi integer
	notificationID, err := strconv.Atoi(notificationIDStr)
	if err != nil || notificationID <= 0 {
		c.JSON(http.StatusBadRequest, gin.H{"error": "notification_id tidak valid"})
		return
	}

	// Cari notifikasi berdasarkan ID
	var notification models.Notification
	if err := config.DB.First(&notification, notificationID).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Notifikasi tidak ditemukan"})
		return
	}

	// Perbarui status menjadi nilai yang baru
	notification.Status = status
	if err := config.DB.Save(&notification).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal memperbarui status notifikasi"})
		return
	}

	// Kirim respon sukses
	c.JSON(http.StatusOK, gin.H{"message": "Status notifikasi berhasil diperbarui"})
}

