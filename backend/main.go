package main

import (
	"fmt"
	"log"
	"os"
	"rental-backend/config"
	"rental-backend/controllers"
	"rental-backend/middleware"
	"rental-backend/routes"
	"time"

	"github.com/gin-gonic/gin"
)

func main() {
	gin.SetMode(gin.ReleaseMode)

	// Koneksi ke database
	config.ConnectDatabase()

	router := gin.Default()

	router.Use(middleware.CORSMiddleware())

	// Route untuk file statis
	router.Static("/fileserver", "./fileserver")

	// Setup routes
	routes.SetupRoutes(router)

	// Jalankan auto-update status motor
	go controllers.StartAutoUpdateMotorStatus()

	// Jalankan auto-update status booking
	go func() {
		ticker := time.NewTicker(1 * time.Minute)
		defer ticker.Stop()

		for {
			select {
			case <-ticker.C:
				controllers.UpdateBookingStatus()
			}
		}
	}()

	// Tentukan port server
	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	// Log informasi server dan jalankan
	fmt.Println("✅ Server berjalan di port", port)
	if err := router.Run("0.0.0.0:" + port); err != nil {
		log.Fatal("❌ Gagal menjalankan server:", err)
	}
}
