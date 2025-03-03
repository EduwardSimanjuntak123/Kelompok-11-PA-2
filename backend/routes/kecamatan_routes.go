package routes

import (
	"rental-backend/controllers"
	"rental-backend/middleware"
	"github.com/gin-gonic/gin"
)

// Kecamatan Routes
func KecamatanRoutes(router *gin.Engine) {
	kecamatan := router.Group("/kecamatan")
	{
		kecamatan.GET("/", controllers.GetAllKecamatan)
		kecamatan.GET("/:id", controllers.GetKecamatanByID)

		// Admin-only routes
		kecamatan.Use(middleware.AuthMiddleware("admin"))
		{
			kecamatan.POST("/", controllers.CreateKecamatan)
			kecamatan.PUT("/:id", controllers.UpdateKecamatan)
			kecamatan.DELETE("/:id", controllers.DeleteKecamatan)
		}
	}
}
