package middlewares

import (
	"fmt"
	"net/http"
	"time"

	"github.com/gin-gonic/gin"

	"github.com/LambdaIITH/Dashboard/backend/internal/helpers"
)

func AuthMiddleware() gin.HandlerFunc {
	return func(c *gin.Context) {
		token, err := c.Cookie("session")

		if err != nil || token == "" {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "Invalid or missing authentication token"})
			c.Abort()
			return
		}

		claims, err := helpers.VerifyJWTToken(token)
		if err != nil {
			fmt.Println("Token verification failed:", err)
			c.JSON(http.StatusUnauthorized, gin.H{"error": "Invalid token"})
			c.Abort()
		} else {
			// not suggested to store email in cookie
			c.Set("user_id", claims["sub"])
		}
		c.Next()
	}
}

// CookieVerificationMiddleware verifies the session cookie.
func CookieVerificationMiddleware() gin.HandlerFunc {
	return func(c *gin.Context) {
		// Skip OPTIONS method
		if c.Request.Method == http.MethodOptions {
			c.Next()
			return
		}

		// Retrieve the session cookie
		token, err := c.Cookie("session")
		if err != nil {
			c.JSON(http.StatusUnauthorized, gin.H{"detail": "Session cookie is missing"})
			c.Abort()
			return
		}

		// Verify the token
		status, data := verifyToken(token)
		if !status {
			// Clear the cookie and return a 401 response
			c.SetCookie("session", "", -1, "/", "", false, true)
			c.JSON(http.StatusUnauthorized, gin.H{"detail": data})
			c.Abort()
			return
		}

		// Store user_id in the context
		if userID, exists := data["sub"]; exists {
			c.Set("user_id", userID)
		}

		// Update the cookie before responding
		c.Next()

		c.SetCookie("session", token, int((time.Hour * 24 * 15).Seconds()), "/", "", false, true)
	}
}

// verifyToken is a placeholder for your token verification logic.
func verifyToken(token string) (bool, map[string]string) {
	// Mock verification logic
	if token == "valid-token" {
		return true, map[string]string{"sub": "12345"}
	}
	return false, map[string]string{"error": "Invalid token"}
}
