package routes

import (
	"rental-backend/controllers"

	"github.com/gin-gonic/gin"
)

func SetupRoutes(router *gin.Engine) {
	router.POST("/login", controllers.LoginUser)
	CustomerRoutes(router)
	VendorRoutes(router)
	KecamatanRoutes(router)
	AdminRoutes(router)
	MotorRoutes(router)
	TransactionRoutes(router)
	ChatRoutes(router)
}
