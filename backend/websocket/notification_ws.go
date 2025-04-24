package websocket

import (
	"log"
	"sync"

	"github.com/gorilla/websocket"
)

type clientMap struct {
	UserClients   map[uint]*websocket.Conn // user_id -> websocket.Conn
	VendorClients map[uint]*websocket.Conn // vendor_id -> websocket.Conn
	sync.Mutex
}

var clients = &clientMap{
	UserClients:   make(map[uint]*websocket.Conn),
	VendorClients: make(map[uint]*websocket.Conn),
}

// Untuk user biasa
func RegisterUser(userID uint, conn *websocket.Conn) {
	clients.Lock()
	defer clients.Unlock()
	clients.UserClients[userID] = conn
	log.Printf("✅ [DEBUG] User %d terhubung ke WebSocket", userID)
}

func UnregisterUser(userID uint) {
	clients.Lock()
	defer clients.Unlock()
	delete(clients.UserClients, userID)
	log.Printf("❌ [DEBUG] User %d terputus dari WebSocket", userID)
}

func SendNotificationToUser(userID uint, message string) {
	clients.Lock()
	defer clients.Unlock()

	log.Printf("[DEBUG] Attempting to send notification to user_id: %d", userID)
	if conn, ok := clients.UserClients[userID]; ok {
		log.Printf("[DEBUG] Found active WebSocket connection for user_id: %d", userID)
		notification := map[string]string{"message": message}
		if err := conn.WriteJSON(notification); err != nil {
			log.Printf("❗ [DEBUG] Gagal mengirim notifikasi ke user %d: %v", userID, err)
			conn.Close()
			delete(clients.UserClients, userID)
		} else {
			log.Printf("[DEBUG] Successfully sent notification to user_id: %d", userID)
		}
	} else {
		log.Printf("[DEBUG] No active WebSocket connection found for user_id: %d", userID)
	}
}

// Untuk vendor
func RegisterVendor(vendorID uint, conn *websocket.Conn) {
	clients.Lock()
	defer clients.Unlock()
	clients.VendorClients[vendorID] = conn
	log.Printf("✅ [DEBUG] Vendor %d terhubung ke WebSocket", vendorID)
}

func UnregisterVendor(vendorID uint) {
	clients.Lock()
	defer clients.Unlock()
	delete(clients.VendorClients, vendorID)
	log.Printf("❌ [DEBUG] Vendor %d terputus dari WebSocket", vendorID)
}

func SendNotificationToVendor(vendorID uint, message string) {
	clients.Lock()
	defer clients.Unlock()

	log.Printf("[DEBUG] Attempting to send notification to vendor_id: %d", vendorID)
	if conn, ok := clients.VendorClients[vendorID]; ok {
		log.Printf("[DEBUG] Found active WebSocket connection for vendor_id: %d", vendorID)
		notification := map[string]string{"message": message}
		if err := conn.WriteJSON(notification); err != nil {
			log.Printf("❗ [DEBUG] Gagal mengirim notifikasi ke vendor %d: %v", vendorID, err)
			conn.Close()
			delete(clients.VendorClients, vendorID)
		} else {
			log.Printf("[DEBUG] Successfully sent notification to vendor_id: %d", vendorID)
		}
	} else {
		log.Printf("[DEBUG] No active WebSocket connection found for vendor_id: %d", vendorID)
	}
}

// GetActiveConnections returns lists of active user and vendor connections
func GetActiveConnections() ([]uint, []uint) {
	clients.Lock()
	defer clients.Unlock()
	
	activeUsers := make([]uint, 0, len(clients.UserClients))
	for userID := range clients.UserClients {
		activeUsers = append(activeUsers, userID)
	}
	
	activeVendors := make([]uint, 0, len(clients.VendorClients))
	for vendorID := range clients.VendorClients {
		activeVendors = append(activeVendors, vendorID)
	}
	
	return activeUsers, activeVendors
}
