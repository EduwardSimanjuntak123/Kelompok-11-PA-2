package controllers

import (
	"net/http"
	ws "rental-backend/websocket"
	"strconv"

	"github.com/gin-gonic/gin"
	"github.com/gorilla/websocket"
)

// Konfigurasi upgrader
var upgrader = websocket.Upgrader{
	CheckOrigin: func(r *http.Request) bool {
		// Izinkan semua origin (bisa dibatasi kalau perlu)
		return true
	},
}

// WebSocket handler
func WebSocketHandler(c *gin.Context) {
	userIDStr := c.Query("user_id")
	userID, err := strconv.Atoi(userIDStr)
	if err != nil || userID == 0 {
		c.JSON(http.StatusBadRequest, gin.H{"error": "user_id tidak valid"})
		return
	}

	conn, err := upgrader.Upgrade(c.Writer, c.Request, nil)
	if err != nil {
		return
	}

	// Register client
	ws.RegisterClient(uint(userID), conn)

	// Handle komunikasi selama koneksi aktif
	for {
		_, _, err := conn.ReadMessage()
		if err != nil {
			ws.UnregisterClient(uint(userID))
			conn.Close()
			break
		}
	}
}
