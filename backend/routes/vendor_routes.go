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

		vendor.POST("/register", controllers.RegisterVendor) // Vendor Register
		vendor.Use(middleware.AuthMiddleware("vendor"))
		{
			vendor.GET("/profile", controllers.GetVendorProfile)
			vendor.GET("/reviews", controllers.GetVendorReviews)
			vendor.POST("/review/:id/reply", controllers.ReplyReview)
			vendor.PUT("/profile/edit", controllers.EditProfileVendor)
			vendor.POST("/manual/bookings", controllers.CreateManualBooking)

			// Booking
			vendor.GET("/bookings", controllers.GetVendorBookings)
			vendor.PUT("/bookings/:id/confirm", controllers.ConfirmBooking)
			vendor.PUT("/bookings/:id/reject", controllers.RejectBooking)
			
			// Transaksi Otomatis
			vendor.PUT("/bookings/complete/:id", controllers.CompleteBooking)

			// Transaksi Manual
		}
	}
}
