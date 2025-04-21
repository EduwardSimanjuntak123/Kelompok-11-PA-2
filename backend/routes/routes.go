package routes

import (
	"rental-backend/controllers"
	"rental-backend/middleware"
	"rental-backend/websocketupdatemotor"

	"github.com/gin-gonic/gin"
)

func SetupRoutes(router *gin.Engine) {
	router.POST("/login", controllers.LoginUser)
	router.POST("/send-otp", controllers.SendOTPEmailHandler)
	router.POST("/verify-otp", controllers.VerifyOTP)

	router.POST("/request-reset-password-otp", middleware.AuthMiddleware(), controllers.RequestResetPasswordOTP)

	router.POST("/verify-reset-password-otp", controllers.VerifyResetPasswordOTP)
	router.POST("/reset-password", middleware.AuthMiddleware(), controllers.ChangePassword)
	// Kirim OTP ke email
	router.POST("/change-password", controllers.ChangePasswordWithOTP) // Ubah password dengan OTP
	CustomerRoutes(router)
	VendorRoutes(router)
	KecamatanRoutes(router)
	AdminRoutes(router)
	MotorRoutes(router)
	TransactionRoutes(router)

	// Review routes
	router.GET("/reviews/motor/:id", controllers.GetReviewsByMotorID)
	router.GET("/reviews/vendor/:id", controllers.GetReviewsByVendorID)
	// WebSocket route
	router.GET("/ws/notifikasi", websocketupdatemotor.WebSocketNotifikasiHandler)
	router.GET("/ws/motor", func(c *gin.Context) {
		websocketupdatemotor.HandleMotorWebSocket(c.Writer, c.Request)
	})
	// Route untuk WebSocket chat
	router.GET("/ws/chat", controllers.ChatWebSocket)

	// Route untuk kirim pesan (hanya customer dan vendor yang bisa kirim)
	router.POST("/chat/message", controllers.SendMessage)

	// Route untuk ambil pesan berdasarkan chat_room_id (harus login)
	router.GET("/chat/messages", controllers.GetChatMessages)

	// Route untuk dapat/buat ChatRoom (harus login)
	router.POST("/chat/room", controllers.GetOrCreateChatRoom)

	router.GET("/chat/rooms", controllers.GetUserChatRooms)
	router.PUT("/messages/:id/read", controllers.MarkMessageAsRead)

}
