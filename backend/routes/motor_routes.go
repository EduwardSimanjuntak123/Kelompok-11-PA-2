package routes

import (
	"rental-backend/controllers"
	"rental-backend/middleware"
	"github.com/gin-gonic/gin"
)


func MotorRoutes(router *gin.Engine) {
	motor := router.Group("/motor")
	{
		motor.GET("/", controllers.GetAllMotor)
		motor.GET("/:id", controllers.GetMotorByID)

		// Admin-only routes																	
		motor.Use(middleware.AuthMiddleware("vendor"))
		{
			motor.POST("/", controllers.CreateMotor)
			motor.PUT("/:id", controllers.UpdateMotor)
			motor.DELETE("/:id", controllers.DeleteMotor)
		}
	}
}