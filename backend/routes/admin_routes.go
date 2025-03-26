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

			admin.PUT("/deactivate-vendor/:id", controllers.DeactivateVendor)
		}
	}
}
