package controllers

import (
	"log"
	"net/http"
	"rental-backend/config"
	"rental-backend/models"

	"github.com/gin-gonic/gin"
)

// Create Location Recommendation (Admin Only)
func CreateLocationRecommendation(c *gin.Context) {
	var recommendation models.LocationRecommendation

	if err := c.ShouldBindJSON(&recommendation); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	if err := config.DB.Debug().Create(&recommendation).Error; err != nil {
		log.Printf("Error inserting location recommendation: %v", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal menambahkan rekomendasi lokasi"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Rekomendasi lokasi berhasil ditambahkan", "data": recommendation})
}

// Get All Location Recommendations (Public)
func GetAllLocationRecommendations(c *gin.Context) {
	var recommendations []models.LocationRecommendation

	if err := config.DB.Preload("Kecamatan").Find(&recommendations).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal mengambil data rekomendasi lokasi"})
		return
	}

	c.JSON(http.StatusOK, recommendations)
}

// Get Location Recommendation by ID (Public)
func GetLocationRecommendationByID(c *gin.Context) {
	id := c.Param("id")
	var recommendation models.LocationRecommendation

	if err := config.DB.Preload("Kecamatan").First(&recommendation, id).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Rekomendasi lokasi tidak ditemukan"})
		return
	}

	c.JSON(http.StatusOK, recommendation)
}

// Update Location Recommendation (Admin Only)
func UpdateLocationRecommendation(c *gin.Context) {
	id := c.Param("id")
	var recommendation models.LocationRecommendation

	if err := config.DB.First(&recommendation, id).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Rekomendasi lokasi tidak ditemukan"})
		return
	}

	if err := c.ShouldBindJSON(&recommendation); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	config.DB.Save(&recommendation)
	c.JSON(http.StatusOK, gin.H{"message": "Rekomendasi lokasi berhasil diperbarui", "data": recommendation})
}

// Delete Location Recommendation (Admin Only)
func DeleteLocationRecommendation(c *gin.Context) {
	id := c.Param("id")

	if err := config.DB.Delete(&models.LocationRecommendation{}, id).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal menghapus rekomendasi lokasi"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Rekomendasi lokasi berhasil dihapus"})
}
