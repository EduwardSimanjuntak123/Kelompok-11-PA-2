package routes

import (
	"rental-backend/controllers"
	"rental-backend/middleware"

	"github.com/gin-gonic/gin"
)

// Customer Routes
func CustomerRoutes(router *gin.Engine) {
	customer := router.Group("/customer")
	{
		customer.POST("/register", controllers.RegisterCustomer)
		customer.POST("/login", controllers.LoginCustomer)

		customer.GET("/motors", controllers.GetAllMotors)

		customer.Use(middleware.AuthMiddleware("customer"))
		{
			customer.POST("/bookings", controllers.CreateBooking)
			customer.PUT("/bookings/:id/cancel", controllers.CancelBooking)

			customer.GET("/transactions", controllers.GetCustomerTransactions)

			customer.PUT("/profile", controllers.UpdateProfile)
			customer.PUT("/change-password", controllers.ChangePassword)
		}
	}
}
