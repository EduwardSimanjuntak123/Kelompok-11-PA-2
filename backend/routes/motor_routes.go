package routes

import (
	"rental-backend/controllers"
	"rental-backend/middleware"

	"github.com/gin-gonic/gin"
)

func MotorRoutes(router *gin.Engine) {
	motor := router.Group("/motor")
	{
		// Akses untuk semua user (tanpa login)
		motor.GET("/", controllers.GetAllMotor)     // Semua user bisa melihat daftar motor
		motor.GET("/:id", controllers.GetMotorByID) // Semua user bisa melihat detail motor

		// Akses untuk vendor (dengan login)
		motorVendor := router.Group("/motor/vendor")
		motorVendor.Use(middleware.AuthMiddleware("vendor"))
		{
			motorVendor.GET("/:id", controllers.GetMotorByIDolehvendor) // Vendor hanya melihat motor mereka sendiri
			motorVendor.GET("/", controllers.GetAllMotorbyVendor) // Vendor hanya melihat motor mereka sendiri
			motorVendor.POST("/", controllers.CreateMotor)        // Vendor bisa menambahkan motor
			motorVendor.PUT("/:id", controllers.UpdateMotor)      // Vendor bisa mengupdate motor mereka
			motorVendor.DELETE("/:id", controllers.DeleteMotor)   // Vendor bisa menghapus motor mereka
		}
	}
}
