package main

import (
	"fmt"
	"log"
	"os"
	"rental-backend/config"
	"rental-backend/controllers"
	"rental-backend/middleware"
	"rental-backend/routes"

	"github.com/gin-gonic/gin"
)

func main() {
	gin.SetMode(gin.ReleaseMode)

	// Koneksi ke database
	db := config.ConnectDatabase()
	config.MigrateDatabase(db)

	config.SeedAdminUser(db)
	// Inisialisasi router
	router := gin.Default()

	// Middleware CORS
	router.Use(middleware.CORSMiddleware())

	// Route untuk file statis
	router.Static("/fileserver", "./fileserver")

	// === Test route untuk memastikan server hidup ===
	router.GET("/", func(c *gin.Context) {
		c.JSON(200, gin.H{
			"message": "Rental Motor API is running!",
		})
	})

	// Setup route utama aplikasi
	routes.SetupRoutes(router)

	// Auto-update status motor
	go controllers.StartAutoUpdateMotorStatus()
	go controllers.StartAutoAwaitingReturnScheduler()

	// Tentukan port server
	port := os.Getenv("PORT")
	if port == "" {
		port = "8081"
	}

	// Jalankan server
	fmt.Println("✅ Server berjalan di port", port)
	if err := router.Run("0.0.0.0:" + port); err != nil {
		log.Fatal("❌ Gagal menjalankan server:", err)
	}
}
