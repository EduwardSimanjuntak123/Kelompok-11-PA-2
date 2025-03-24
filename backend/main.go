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
	config.ConnectDatabase()

	router := gin.Default()

	router.Use(middleware.CORSMiddleware())
	// ✅ Route untuk file statis
	// Akan mengizinkan akses ke http://localhost:8080/fileserver/...
	router.Static("/fileserver", "./fileserver")

	// Setup routes
	routes.SetupRoutes(router)

	// Jalankan auto-update status motor
	go controllers.StartAutoUpdateMotorStatus()

	// Tentukan port server
	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	// Log informasi server
	fmt.Println("✅ Server berjalan di port", port)
	if err := router.Run(":" + port); err != nil {
		log.Fatal("❌ Gagal menjalankan server:", err)
	}
}
