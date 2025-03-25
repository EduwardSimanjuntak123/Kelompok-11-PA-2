package routes

import (
	"rental-backend/controllers"
	"rental-backend/middleware"

	"github.com/gin-gonic/gin"
)

func TransactionRoutes(router *gin.Engine) {
	transaction := router.Group("/transaction")
	{
		// transaction.GET("/", controllers.GetAllMotor)
		// transaction.GET("/:id", controllers.GetMotorByID)

		// Admin-only routes																	
		transaction.Use(middleware.AuthMiddleware("vendor"))
		{
			transaction.GET("/", controllers.GetVendorBookings)

			transaction.POST("/manual", controllers.AddManualTransaction)

		}
	}
}


