package websocket

import (
	"log"
	"sync"

	"github.com/gorilla/websocket"
)

var (
	clients   = make(map[uint]*websocket.Conn) // user_id -> websocket.Conn
	clientsMu sync.Mutex                        // supaya thread-safe
)

// Daftarkan koneksi websocket user
func RegisterClient(userID uint, conn *websocket.Conn) {
	clientsMu.Lock()
	defer clientsMu.Unlock()
	clients[userID] = conn
	log.Printf("✅ User %d terhubung ke WebSocket", userID)
}

// Hapus koneksi user saat disconnect
func UnregisterClient(userID uint) {
	clientsMu.Lock()
	defer clientsMu.Unlock()
	delete(clients, userID)
	log.Printf("❌ User %d terputus dari WebSocket", userID)
}

// Kirim notifikasi real-time ke user tertentu
func SendNotificationToUser(userID uint, message string) {
	clientsMu.Lock()
	defer clientsMu.Unlock()

	if conn, ok := clients[userID]; ok {
		notification := map[string]string{"message": message}
		if err := conn.WriteJSON(notification); err != nil {
			log.Printf("❗ Gagal mengirim notifikasi ke user %d: %v", userID, err)
			conn.Close()
			delete(clients, userID)
		}
	}
}
