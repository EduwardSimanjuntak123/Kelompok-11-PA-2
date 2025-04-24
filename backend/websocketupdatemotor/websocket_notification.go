package websocketupdatemotor

import (
	"log"
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

// WebSocket handler untuk notifikasi user
func WebSocketNotifikasiHandler(c *gin.Context) {
	userIDStr := c.Query("user_id")
	userID, err := strconv.Atoi(userIDStr)
	if err != nil || userID == 0 {
		log.Printf("[DEBUG] Invalid user_id in WebSocketNotifikasiHandler: %s", userIDStr)
		c.JSON(http.StatusBadRequest, gin.H{"error": "user_id tidak valid"})
		return
	}

	log.Printf("[DEBUG] Attempting to establish WebSocket connection for user_id: %d", userID)
	conn, err := upgraderNotif.Upgrade(c.Writer, c.Request, nil)
	if err != nil {
		log.Printf("[DEBUG] Failed to upgrade WebSocket connection for user_id %d: %v", userID, err)
		return
	}

	// Registrasi koneksi user
	ws.RegisterUser(uint(userID), conn)
	log.Printf("[DEBUG] Successfully registered WebSocket connection for user_id: %d", userID)

	// Unregister dan close saat koneksi ditutup
	defer func() {
		log.Printf("[DEBUG] Closing WebSocket connection for user_id: %d", userID)
		ws.UnregisterUser(uint(userID))
		conn.Close()
	}()

	// Tunggu pesan (jaga koneksi tetap terbuka)
	for {
		_, _, err := conn.ReadMessage()
		if err != nil {
			log.Printf("[DEBUG] WebSocket connection error for user_id %d: %v", userID, err)
			break
		}
	}
}

// WebSocket handler untuk notifikasi vendor
func WebSocketVendorNotifikasiHandler(c *gin.Context) {
	vendorIDStr := c.Query("vendor_id")
	vendorID, err := strconv.Atoi(vendorIDStr)
	if err != nil || vendorID == 0 {
		log.Printf("[DEBUG] Invalid vendor_id in WebSocketVendorNotifikasiHandler: %s", vendorIDStr)
		c.JSON(http.StatusBadRequest, gin.H{"error": "vendor_id tidak valid"})
		return
	}

	log.Printf("[DEBUG] Attempting to establish WebSocket connection for vendor_id: %d", vendorID)
	conn, err := upgraderNotif.Upgrade(c.Writer, c.Request, nil)
	if err != nil {
		log.Printf("[DEBUG] Failed to upgrade WebSocket connection for vendor_id %d: %v", vendorID, err)
		return
	}

	// Registrasi koneksi vendor
	ws.RegisterVendor(uint(vendorID), conn)
	log.Printf("[DEBUG] Successfully registered WebSocket connection for vendor_id: %d", vendorID)

	// Unregister dan close saat koneksi ditutup
	defer func() {
		log.Printf("[DEBUG] Closing WebSocket connection for vendor_id: %d", vendorID)
		ws.UnregisterVendor(uint(vendorID))
		conn.Close()
	}()

	// Tunggu pesan (jaga koneksi tetap terbuka)
	for {
		_, _, err := conn.ReadMessage()
		if err != nil {
			log.Printf("[DEBUG] WebSocket connection error for vendor_id %d: %v", vendorID, err)
			break
		}
	}
}

// Fungsi untuk mengambil notifikasi berdasarkan user_id
func GetNotificationByUserID(c *gin.Context) {
	userIDStr := c.Query("user_id")
	userID, err := strconv.Atoi(userIDStr)
	if err != nil || userID == 0 {
		log.Printf("[DEBUG] Invalid user_id in GetNotificationByUserID: %s", userIDStr)
		c.JSON(http.StatusBadRequest, gin.H{"error": "user_id tidak valid"})
		return
	}

	log.Printf("[DEBUG] Fetching notifications for user_id: %d", userID)
	var notifications []models.Notification
	if err := config.DB.Where("user_id = ?", userID).Find(&notifications).Error; err != nil {
		log.Printf("[DEBUG] Error fetching notifications for user_id %d: %v", userID, err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal mengambil notifikasi"})
		return
	}

	if len(notifications) == 0 {
		log.Printf("[DEBUG] No notifications found for user_id: %d", userID)
		c.JSON(http.StatusNotFound, gin.H{"message": "Tidak ada notifikasi untuk user ini"})
		return
	}

	log.Printf("[DEBUG] Found %d notifications for user_id: %d", len(notifications), userID)
	c.JSON(http.StatusOK, gin.H{"notifications": notifications})
}

// Fungsi untuk mengambil notifikasi berdasarkan vendor_id
func GetNotificationByVendorID(c *gin.Context) {
	vendorIDStr := c.Query("vendor_id")
	vendorID, err := strconv.Atoi(vendorIDStr)
	if err != nil || vendorID == 0 {
		log.Printf("[DEBUG] Invalid vendor_id in GetNotificationByVendorID: %s", vendorIDStr)
		c.JSON(http.StatusBadRequest, gin.H{"error": "vendor_id tidak valid"})
		return
	}

	log.Printf("[DEBUG] Fetching notifications for vendor_id: %d", vendorID)
	var notifications []models.Notification
	if err := config.DB.Where("user_id = ?", vendorID).Find(&notifications).Error; err != nil {
		log.Printf("[DEBUG] Error fetching notifications for vendor_id %d: %v", vendorID, err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal mengambil notifikasi"})
		return
	}

	if len(notifications) == 0 {
		log.Printf("[DEBUG] No notifications found for vendor_id: %d", vendorID)
		c.JSON(http.StatusNotFound, gin.H{"message": "Tidak ada notifikasi untuk vendor ini"})
		return
	}

	log.Printf("[DEBUG] Found %d notifications for vendor_id: %d", len(notifications), vendorID)
	c.JSON(http.StatusOK, gin.H{"notifications": notifications})
}

// Fungsi untuk mengubah status notifikasi
func UpdateNotificationStatus(c *gin.Context) {
	notificationIDStr := c.Param("notification_id")
	status := c.DefaultQuery("status", "")

	if status != "read" && status != "unread" {
		log.Printf("[DEBUG] Invalid status in UpdateNotificationStatus: %s", status)
		c.JSON(http.StatusBadRequest, gin.H{"error": "status tidak valid, hanya 'read' atau 'unread'"})
		return
	}

	notificationID, err := strconv.Atoi(notificationIDStr)
	if err != nil || notificationID <= 0 {
		log.Printf("[DEBUG] Invalid notification_id in UpdateNotificationStatus: %s", notificationIDStr)
		c.JSON(http.StatusBadRequest, gin.H{"error": "notification_id tidak valid"})
		return
	}

	log.Printf("[DEBUG] Updating notification status for notification_id: %d to %s", notificationID, status)
	var notification models.Notification
	if err := config.DB.First(&notification, notificationID).Error; err != nil {
		log.Printf("[DEBUG] Notification not found for notification_id: %d", notificationID)
		c.JSON(http.StatusNotFound, gin.H{"error": "Notifikasi tidak ditemukan"})
		return
	}

	notification.Status = status
	if err := config.DB.Save(&notification).Error; err != nil {
		log.Printf("[DEBUG] Error updating notification status for notification_id %d: %v", notificationID, err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal memperbarui status notifikasi"})
		return
	}

	log.Printf("[DEBUG] Successfully updated notification status for notification_id: %d", notificationID)
	c.JSON(http.StatusOK, gin.H{"message": "Status notifikasi berhasil diperbarui"})
}

// Fungsi untuk menghapus notifikasi
func DeleteNotificationByID(c *gin.Context) {
	notificationIDStr := c.Param("notification_id")
	notificationID, err := strconv.Atoi(notificationIDStr)
	if err != nil || notificationID <= 0 {
		log.Printf("[DEBUG] Invalid notification_id in DeleteNotificationByID: %s", notificationIDStr)
		c.JSON(http.StatusBadRequest, gin.H{"error": "notification_id tidak valid"})
		return
	}

	log.Printf("[DEBUG] Deleting notification for notification_id: %d", notificationID)
	var notification models.Notification
	if err := config.DB.First(&notification, notificationID).Error; err != nil {
		log.Printf("[DEBUG] Notification not found for notification_id: %d", notificationID)
		c.JSON(http.StatusNotFound, gin.H{"error": "Notifikasi tidak ditemukan"})
		return
	}

	if err := config.DB.Delete(&notification).Error; err != nil {
		log.Printf("[DEBUG] Error deleting notification for notification_id %d: %v", notificationID, err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal menghapus notifikasi"})
		return
	}

	log.Printf("[DEBUG] Successfully deleted notification for notification_id: %d", notificationID)
	c.JSON(http.StatusOK, gin.H{"message": "Notifikasi berhasil dihapus"})
}

// Fungsi untuk debugging koneksi WebSocket aktif
func DebugWebSocketConnections(c *gin.Context) {
	userConnections, vendorConnections := ws.GetActiveConnections()
	
	log.Printf("[DEBUG] Active WebSocket connections - Users: %d, Vendors: %d", 
		len(userConnections), len(vendorConnections))
	
	c.JSON(http.StatusOK, gin.H{
		"active_users": userConnections,
		"active_vendors": vendorConnections,
	})
}
