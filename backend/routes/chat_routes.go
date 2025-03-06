package routes

import (
	"github.com/gin-gonic/gin"
	"rental-backend/controllers"
	"rental-backend/middleware"
)

func ChatRoutes(router *gin.Engine) {
	chat := router.Group("/chat")
	{
		// Vendor routes
		chat.Use(middleware.AuthMiddleware("vendor"))
		{

			// Mengirim pesan ke dalam chat room (hanya satu route yang digunakan)
			chat.POST("/:chat_room_id/message_vendor", controllers.SendMessage)

			// Mengambil pesan dalam chat room
			chat.GET("/:chat_room_id/messages_vendor", controllers.GetMessages)
		}

		// Customer routes
		chat.Use(middleware.AuthMiddleware("customer"))
		{
			// Membuat chat room baru
			chat.POST("/create", controllers.CreateChatRoom)
			// Customer mengirim pesan ke dalam chat room (hanya satu route yang digunakan)
			chat.POST("/:chat_room_id/message_customer", controllers.SendMessage)

			// Customer melihat pesan dalam chat room (hanya satu route yang digunakan)
			chat.GET("/:chat_room_id/messages_customer", controllers.GetMessages)
		}
	}
}
