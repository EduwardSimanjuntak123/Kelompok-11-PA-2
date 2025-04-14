package websocketupdatemotor

import (
	"log"
	"net/http"
	"sync"

	"github.com/gorilla/websocket"
)

// WebSocket upgrader
var upgrader = websocket.Upgrader{
	CheckOrigin: func(r *http.Request) bool {
		// Izinkan semua origin (pastikan ini aman untuk production)
		return true
	},
}

var (
	clients = make(map[*websocket.Conn]bool)
	mutex   sync.Mutex
)
// Fungsi untuk handle koneksi WebSocket
func HandleMotorWebSocket(w http.ResponseWriter, r *http.Request) {
	conn, err := upgrader.Upgrade(w, r, nil)
	if err != nil {
		log.Println("❌ Gagal upgrade WebSocket:", err)
		return
	}
	defer conn.Close()

	log.Println("🔌 Client WebSocket terhubung")

	clients[conn] = true

	for {
		// WebSocket ini hanya menerima ping (optional)
		_, _, err := conn.ReadMessage()
		if err != nil {
			log.Println("⛔ Client WebSocket terputus")
			delete(clients, conn)
			break
		}
	}
}

// Fungsi untuk mengirim pesan ke semua client
func BroadcastMotorStatus(message string) {
	mutex.Lock()
	defer mutex.Unlock()

	for conn := range clients {
		if err := conn.WriteMessage(websocket.TextMessage, []byte(message)); err != nil {
			log.Println("❌ Gagal mengirim pesan ke WebSocket client:", err)
			conn.Close()
			delete(clients, conn)
		}
	}
}
