package routes

import (
	"github.com/gin-gonic/gin"
)

func SetupRoutes(router *gin.Engine) {
	CustomerRoutes(router)
	VendorRoutes(router)
	KecamatanRoutes(router)
	AdminRoutes(router)
	MotorRoutes(router)

}
