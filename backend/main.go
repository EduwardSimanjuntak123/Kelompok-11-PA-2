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
	if err := router.Run("0.0.0.0:" + port); err != nil { // ✅ Dengarkan di semua IP
		log.Fatal("❌ Gagal menjalankan server:", err)
	}
}
