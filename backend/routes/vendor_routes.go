package routes

import (
	"rental-backend/controllers"
	"rental-backend/middleware"
	"github.com/gin-gonic/gin"
)

// Vendor Routes
func VendorRoutes(router *gin.Engine) {
	vendor := router.Group("/vendor")
	{

		vendor.POST("/login", controllers.VendorLogin) // Vendor Login
		vendor.POST("/register", controllers.RegisterVendor) // Vendor Register
		vendor.Use(middleware.AuthMiddleware("vendor"))
		{
			
			// Booking
			vendor.GET("/bookings", controllers.GetVendorTransactions)
			vendor.PUT("/bookings/:id/confirm", controllers.ConfirmBooking)
			vendor.PUT("/bookings/:id/reject", controllers.RejectBooking)

			// Transaksi Manual
			vendor.POST("/transactions/manual", controllers.AddManualTransaction)
			vendor.GET("/transactions", controllers.GetVendorTransactions)
		}
	}
}
