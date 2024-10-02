package routes

import (
	"context"
	"database/sql"
	"fmt"
	"net/http"
	"os"
	"regexp"

	"github.com/gin-gonic/gin"
	"github.com/joho/godotenv"
	"google.golang.org/api/idtoken"
)

var (
	clientID string
	db       *sql.DB
)

// User represents a user in the system
type User struct {
	ID    int    `json:"id"`
	Email string `json:"email"`
	Name  string `json:"name"`
}

// Init initializes environment variables and database connection
func Init() {
	// Load environment variables
	err := godotenv.Load()
	if err != nil {
		panic("Error loading .env file")
	}

	clientID = os.Getenv("GOOGLE_CLIENT_ID")
	// Initialize your database connection here
	// db, err = sql.Open("your_driver", "your_data_source_name")
}

// verifyIDToken verifies the Google ID token and returns user information
func verifyIDToken(token string) (bool, map[string]interface{}) {
	idTokenInfo, err := idtoken.Validate(context.Background(), token, clientID)
	if err != nil {
		fmt.Printf("Token verification failed: %v\n", err)
		return false, nil
	}
	return true, idTokenInfo.Claims
}

// handleLogin handles the login process using Google ID token
func handleLogin(c *gin.Context) {
	var loginRequest struct {
		IDToken string `json:"id_token"`
	}
	if err := c.ShouldBindJSON(&loginRequest); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid request"})
		return
	}

	ok, data := verifyIDToken(loginRequest.IDToken)
	if !ok {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Invalid ID token"})
		return
	}

	if !isValidIITHEmail(data["email"].(string)) {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Please use an IITH email"})
		return
	}

	exists, userID := isUserExists(data["email"].(string))
	if !exists {
		userID = insertUser(data["email"].(string), data["name"].(string))
	}

	token,err := generateToken(userID)
	c.JSON(http.StatusOK, gin.H{"token": token, "id": userID, "email": data["email"]})
}

// isValidIITHEmail checks if the email belongs to IITH
func isValidIITHEmail(email string) bool {
	pattern := `^[a-zA-Z0-9._%+-]+@(?:[a-zA-Z0-9-]+\.)?iith\.ac\.in$`
	match, _ := regexp.MatchString(pattern, email)
	return match
}

// insertUser inserts a new user into the database
func insertUser(email string, name string) int {
	var userID int
	query := "INSERT INTO users (email, name) VALUES ($1, $2) RETURNING id"
	err := db.QueryRow(query, email, name).Scan(&userID)
	if err != nil {
		panic(err) // Handle your error properly
	}
	return userID
}

// isUserExists checks if a user exists in the database
func isUserExists(email string) (bool, int) {
	var userID int
	query := "SELECT id FROM users WHERE email = $1"
	err := db.QueryRow(query, email).Scan(&userID)

	if err != nil {
		if err == sql.ErrNoRows {
			return false, 0
		}
		panic(err) // Handle your error properly
	}
	return true, userID
}

