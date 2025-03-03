package main

import (
	"fmt"
	"os"

	"github.com/gin-gonic/gin"
	"rental-backend/config"
	"rental-backend/routes"
)

func main() {
	// Gunakan mode release agar log tidak terlalu banyak
	gin.SetMode(gin.ReleaseMode)

	// Koneksi ke Database
	config.ConnectDatabase()

	// Setup Router tanpa middleware logging default
	router := gin.New()
	router.Use(gin.Recovery()) // Tangani panic tanpa menampilkan log yang tidak perlu

	// Register Routes
	routes.SetupRoutes(router)

	// Tentukan port server
	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	fmt.Println("✅ Server berjalan di port", port)
	router.Run(":" + port)
}
