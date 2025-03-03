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
		admin.POST("/login", controllers.AdminLogin)

		admin.Use(middleware.AuthMiddleware("admin"))
		{
			admin.GET("/transactions", controllers.GetAllTransactions)
			admin.GET("/users", controllers.GetAllUsers)
			admin.PUT("/deactivate-vendor/:id", controllers.DeactivateVendor)
		}
	}
}
