package websocketupdatemotor


import (
	"net/http"
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
