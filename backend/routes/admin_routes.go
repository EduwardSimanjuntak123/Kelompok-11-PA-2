package routes

import (
	"rental-backend/controllers"
	"rental-backend/middleware"

	"github.com/gin-gonic/gin"
)

// Admin Routes
func AdminRoutes(router *gin.Engine) {
	admin := router.Group("/admin")
	{

		admin.Use(middleware.AuthMiddleware("admin"))
		{
			admin.GET("/vendors", controllers.GetAllVendors)
			admin.GET("/transactions", controllers.GetAllTransactions)
			admin.GET("/users", controllers.GetAllUsers)
			admin.GET("/profile", controllers.GetDataAdmin)
			admin.PUT("/profile/edit", controllers.EditDataAdmin)
			admin.PUT("/activate-vendor/:id", controllers.ActivateVendor)
			admin.PUT("/deactivate-vendor/:id", controllers.DeactivateVendor)
			admin.GET("/CustomerandVendor", controllers.GetAllCustomersAndVendors)
			admin.POST("/location-recommendations", controllers.CreateLocationRecommendation)

			admin.PUT("/location-recommendations/:id", controllers.UpdateLocationRecommendation)
			admin.DELETE("admin/location-recommendations/:id", controllers.DeleteLocationRecommendation)
		}
	}
}
