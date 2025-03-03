package middleware

import (
	"fmt"
	"net/http"
	"strings"

	"github.com/gin-gonic/gin"
	"github.com/golang-jwt/jwt/v4"
)

// Secret Key JWT
var jwtSecret = []byte("secret123")

// Auth Middleware dengan fleksibilitas untuk banyak role
func AuthMiddleware(allowedRoles ...string) gin.HandlerFunc {
	return func(c *gin.Context) {
		// Ambil token dari header Authorization
		tokenString := c.GetHeader("Authorization")
		if tokenString == "" {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "Token tidak ditemukan"})
			c.Abort()
			return
		}

		// Pastikan format "Bearer <token>"
		tokenString = strings.TrimPrefix(tokenString, "Bearer ")
		if tokenString == "" {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "Format token salah"})
			c.Abort()
			return
		}

		// Parse token
		token, err := jwt.Parse(tokenString, func(token *jwt.Token) (interface{}, error) {
			// Pastikan token menggunakan metode HS256
			if _, ok := token.Method.(*jwt.SigningMethodHMAC); !ok {
				return nil, jwt.ErrSignatureInvalid
			}
			return jwtSecret, nil
		})

		// Jika token tidak valid atau error
		if err != nil || !token.Valid {
			fmt.Println("Debug: Token Parsing Error ->", err) // Debugging
			c.JSON(http.StatusUnauthorized, gin.H{"error": "Token tidak valid"})
			c.Abort()
			return
		}

		// Ambil claims dari token
		claims, ok := token.Claims.(jwt.MapClaims)
		if !ok {
			fmt.Println("Debug: Gagal membaca claims dari token") // Debugging
			c.JSON(http.StatusUnauthorized, gin.H{"error": "Token tidak valid"})
			c.Abort()
			return
		}

		// Debugging: Lihat isi token
		fmt.Println("Debug: Token Claims ->", claims)

		// Ambil `user_id`
		userIDFloat, ok := claims["user_id"].(float64)
		if !ok {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "User ID tidak ditemukan dalam token"})
			c.Abort()
			return
		}
		userID := uint(userIDFloat) // Konversi dari float64 ke uint
		c.Set("user_id", userID)

		// Ambil `role`
		userRole, ok := claims["role"].(string)
		if !ok {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "Role tidak valid dalam token"})
			c.Abort()
			return
		}

		// Jika role dibatasi, pastikan user memiliki salah satu role yang diizinkan
		if len(allowedRoles) > 0 {
			roleAllowed := false
			for _, role := range allowedRoles {
				if userRole == role {
					roleAllowed = true
					break
				}
			}

			if !roleAllowed {
				c.JSON(http.StatusForbidden, gin.H{"error": "Tidak memiliki izin akses"})
				c.Abort()
				return
			}
		}

		// // Jika role adalah "vendor", pastikan vendor_id ada
		// if userRole == "vendor" {
		// 	vendorIDFloat, ok := claims["vendor_id"].(float64)
		// 	if !ok {
		// 		c.JSON(http.StatusUnauthorized, gin.H{"error": "Vendor ID tidak ditemukan dalam token"})
		// 		c.Abort()
		// 		return
		// 	}
		// 	vendorID := uint(vendorIDFloat) // Konversi dari float64 ke uint
		// 	c.Set("vendor_id", vendorID)
		// }

		// Lanjut ke request berikutnya
		c.Next()
	}
}
