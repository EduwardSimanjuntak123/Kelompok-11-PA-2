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
		vendor.GET("/:id", controllers.GetVendorByID)
		vendor.GET("/", controllers.GetAllVendor)
		vendor.POST("/register", controllers.RegisterVendor) // Vendor Register
		vendor.Use(middleware.AuthMiddleware("vendor"))
		{
			vendor.GET("/profile", controllers.GetVendorProfile)
			vendor.GET("/reviews", controllers.GetVendorReviews)
			vendor.POST("/review/:id/reply", controllers.ReplyReview)
			vendor.PUT("/profile/edit", controllers.EditProfileVendor)
			vendor.POST("/manual/bookings", controllers.CreateManualBooking)
			vendor.GET("/extensions", controllers.GetVendorBookingExtensions)
			vendor.PUT("/extensions/:id/approve", controllers.ApproveBookingExtension)
			vendor.PUT("/extensions/:id/reject", controllers.RejectBookingExtension)

			// Booking
			vendor.GET("/bookings/:id", controllers.GetBookingByIDForVendor)
			vendor.GET("/bookings", controllers.GetVendorBookings)

			vendor.PUT("/bookings/:id/confirm", controllers.ConfirmBooking)
			vendor.PUT("/bookings/:id/reject", controllers.RejectBooking)
			
			// Transaksi Otomatis
			vendor.PUT("/bookings/transit/:id", controllers.SetBookingToTransit)
			vendor.PUT("/bookings/inuse/:id", controllers.SetBookingToInUse)
			vendor.PUT("/bookings/complete/:id", controllers.CompleteBooking)


			// Transaksi Manual
		}
	}
}
