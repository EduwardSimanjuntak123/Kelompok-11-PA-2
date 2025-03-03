package controllers

import (
	"net/http"
	"rental-backend/config"
	"rental-backend/models"
	"github.com/gin-gonic/gin"
	"log"
)

// Create Kecamatan (Admin)
func CreateKecamatan(c *gin.Context) {
	var kecamatan models.Kecamatan

	// Bind the JSON payload to the 'kecamatan' struct
	if err := c.ShouldBindJSON(&kecamatan); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Enable GORM Debug to log the SQL queries
	if err := config.DB.Debug().Create(&kecamatan).Error; err != nil {
		// Log the error (optional)
		log.Printf("Error inserting kecamatan: %v", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal menambahkan kecamatan"})
		return
	}

	// Respond with success and the newly created kecamatan data
	c.JSON(http.StatusOK, gin.H{"message": "Kecamatan berhasil ditambahkan", "data": kecamatan})
}


// Get All Kecamatan
func GetAllKecamatan(c *gin.Context) {
	var kecamatan []models.Kecamatan

	if err := config.DB.Find(&kecamatan).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal mengambil data kecamatan"})
		return
	}

	c.JSON(http.StatusOK, kecamatan)
}

// Get Kecamatan by ID
func GetKecamatanByID(c *gin.Context) {
	id := c.Param("id")
	var kecamatan models.Kecamatan

	if err := config.DB.First(&kecamatan, id).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Kecamatan tidak ditemukan"})
		return
	}

	c.JSON(http.StatusOK, kecamatan)
}

// Update Kecamatan (Admin)
func UpdateKecamatan(c *gin.Context) {
	id := c.Param("id")
	var kecamatan models.Kecamatan

	if err := config.DB.First(&kecamatan, id).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Kecamatan tidak ditemukan"})
		return
	}

	if err := c.ShouldBindJSON(&kecamatan); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	config.DB.Save(&kecamatan)
	c.JSON(http.StatusOK, gin.H{"message": "Kecamatan berhasil diperbarui"})
}

// Delete Kecamatan (Admin)
func DeleteKecamatan(c *gin.Context) {
	id := c.Param("id")

	if err := config.DB.Delete(&models.Kecamatan{}, id).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal menghapus kecamatan"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Kecamatan berhasil dihapus"})
}
