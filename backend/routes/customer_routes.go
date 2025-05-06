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
		customer.POST("/cancel-registration", controllers.CancelRegistration)

		customer.GET("/motors", controllers.GetAllMotors)
		
		customer.GET("/motors/vendor/:vendor_id", controllers.GetAllMotorByVendorID) 

		customer.Use(middleware.AuthMiddleware("customer"))
		{
			customer.POST("/bookings", controllers.CreateBooking)
			customer.GET("/bookings", controllers.GetCustomerBookings)
			customer.GET("/profile", controllers.GetCustomerProfile)
			customer.POST("/review/:id", controllers.CreateReview)
			customer.GET("/extensions", controllers.GetCustomerBookingExtensions)
			customer.GET("/bookings/:booking_id/extensions", controllers.GetBookingExtensionsByBookingID)

			customer.PUT("/bookings/:id/cancel", controllers.CancelBooking)
			customer.POST("/bookings/:id/extend", controllers.RequestBookingExtension)
			customer.GET("/transactions", controllers.GetCustomerTransactions)

			customer.PUT("/profile", controllers.EditProfile)
			customer.PUT("/change-password", controllers.ChangePassword)
		}
	}
}
