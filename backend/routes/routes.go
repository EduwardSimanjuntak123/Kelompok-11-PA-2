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
	router.POST("/change-password", controllers.ChangePasswordWithOTP)

	CustomerRoutes(router)
	VendorRoutes(router)
	KecamatanRoutes(router)
	AdminRoutes(router)
	MotorRoutes(router)
	TransactionRoutes(router)
	router.GET("/bookings/motor/:idmotor", controllers.GetBookingsByMotorID)
	router.GET("/reviews/motor/:id", controllers.GetReviewsByMotorID)
	router.GET("/reviews/vendor/:id", controllers.GetReviewsByVendorID)

	router.GET("/ws/notifikasi", websocketupdatemotor.WebSocketNotifikasiHandler)
	router.PUT("/notifications/:notification_id/status", websocketupdatemotor.UpdateNotificationStatus)
	router.GET("/notifications", websocketupdatemotor.GetNotificationByUserID)
	router.DELETE("/notifications/:notification_id", websocketupdatemotor.DeleteNotificationByID)

	router.GET("/ws/motor", func(c *gin.Context) {
		websocketupdatemotor.HandleMotorWebSocket(c.Writer, c.Request)
	})

	// === CHAT ROUTES ===
	router.GET("/ws/chat", controllers.ChatWebSocket)
	router.POST("/chat/message", controllers.SendMessage)
	router.GET("/chat/messages", controllers.GetChatMessages)
	router.POST("/chat/room", controllers.GetOrCreateChatRoom)
	router.GET("/chat/rooms", controllers.GetUserChatRooms)
	router.PUT("/chat/messages/:id/read", controllers.MarkMessageAsRead)
	router.POST("/chat/mark-all-read", controllers.MarkAllMessagesAsRead)
	router.GET("/chat/unread", controllers.GetUnreadMessageCount)
	router.DELETE("/chat/room/:id", controllers.DeleteChatRoom)
	router.GET("/chat/search", controllers.SearchChatMessages)
	router.GET("/location-recommendations", controllers.GetAllLocationRecommendations)
	router.GET("/location-recommendations/:id", controllers.GetLocationRecommendationByID)
}
