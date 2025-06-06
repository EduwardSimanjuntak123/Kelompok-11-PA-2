package routes

import (
	"rental-backend/controllers"
	"rental-backend/middleware"

	"github.com/gin-gonic/gin"
)

func TransactionRoutes(router *gin.Engine) {
	transaction := router.Group("/transaction")
	{

		// Admin-only routes
		transaction.Use(middleware.AuthMiddleware("vendor"))
		{
			transaction.GET("/", controllers.GetVendorTransactions)

			transaction.POST("/manual", controllers.AddManualTransaction)

		}
	}
}
