package routes

import (
	"rental-backend/controllers"
	"rental-backend/websocketupdatemotor"

	"github.com/gin-gonic/gin"
)

func SetupRoutes(router *gin.Engine) {
	router.POST("/login", controllers.LoginUser)
	router.POST("/send-otp", controllers.SendOTPEmailHandler)
	router.POST("/verify-otp", controllers.VerifyOTP)
	// Kirim OTP ke email
	router.POST("/change-password", controllers.ChangePasswordWithOTP)  // Ubah password dengan OTP
	CustomerRoutes(router)
	VendorRoutes(router)
	KecamatanRoutes(router)
	AdminRoutes(router)
	MotorRoutes(router)
	TransactionRoutes(router)
	ChatRoutes(router)


	// WebSocket route
	router.GET("/ws/notifikasi", controllers.WebSocketNotifikasiHandler)
	router.GET("/ws/motor", func(c *gin.Context) {
		websocketupdatemotor.HandleMotorWebSocket(c.Writer, c.Request)
	})

}
