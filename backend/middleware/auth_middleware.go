package middleware

import (
	"fmt"
	"net/http"
	"strings"

	"github.com/gin-gonic/gin"
	"github.com/golang-jwt/jwt/v4"
)

// Secret Key JWT (Harus sama dengan yang digunakan saat generate token)
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
				fmt.Println("Debug: Algoritma JWT tidak sesuai")
				return nil, jwt.ErrSignatureInvalid
			}
			return jwtSecret, nil
		})

		// Jika token tidak valid atau error
		if err != nil || !token.Valid {
			fmt.Println("Debug: Token Parsing Error ->", err)
			c.JSON(http.StatusUnauthorized, gin.H{"error": "Token tidak valid"})
			c.Abort()
			return
		}

		// Ambil claims dari token
		claims, ok := token.Claims.(jwt.MapClaims)
		if !ok {
			fmt.Println("Debug: Gagal membaca claims dari token")
			c.JSON(http.StatusUnauthorized, gin.H{"error": "Token tidak valid"})
			c.Abort()
			return
		}

		// Debugging: Lihat isi token
		fmt.Println("Debug: Token Claims ->", claims)

		// Ambil `user_id`
		var userID uint
		switch v := claims["user_id"].(type) {
		case float64:
			userID = uint(v) // Jika user_id berupa angka (float64), konversi ke uint
		case string:
			fmt.Println("Debug: User ID dalam token adalah string, seharusnya float64")
			c.JSON(http.StatusUnauthorized, gin.H{"error": "Format user_id salah"})
			c.Abort()
			return
		default:
			c.JSON(http.StatusUnauthorized, gin.H{"error": "User ID tidak ditemukan dalam token"})
			c.Abort()
			return
		}

		// Simpan user_id dalam context untuk digunakan di controller
		c.Set("user_id", userID)

		// Ambil `role`
		userRole, ok := claims["role"].(string)
		if !ok {
			fmt.Println("Debug: Role tidak ditemukan dalam token")
			c.JSON(http.StatusUnauthorized, gin.H{"error": "Role tidak valid dalam token"})
			c.Abort()
			return
		}

		// Simpan role ke dalam context
		c.Set("user_role", userRole)

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
				fmt.Println("Debug: Akses ditolak untuk role:", userRole)
				c.JSON(http.StatusForbidden, gin.H{"error": "Tidak memiliki izin akses"})
				c.Abort()
				return
			}
		}

		// Debugging
		fmt.Println("Debug: User ID dari token:", userID)
		fmt.Println("Debug: User Role dari token:", userRole)

		c.Next()
	}
}
