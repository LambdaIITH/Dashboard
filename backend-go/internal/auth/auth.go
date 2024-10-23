package auth

import (
	"context"
	"fmt"
	"log"
	"net/http"
	"os"
	"regexp"
	"strings"

	"google.golang.org/api/idtoken"

	"github.com/gin-gonic/gin"
	"github.com/golang-jwt/jwt/v4"
	"github.com/jmoiron/sqlx"
	_ "github.com/lib/pq"
)

var clientID string = os.Getenv("GOOGLE_CLIENT_ID") // get from env to validate tokenid

// User data structure
type UserResponse struct {
	ID    int64  `json:"id"`
	Email string `json:"email"`
}

// Verify ID Token
func VerifyIDToken(token string) (bool, map[string]interface{}) {
	ctx := context.Background()

	// Validate the ID token
	payload, err := idtoken.Validate(ctx, token, clientID)
	if err != nil {
		return false, map[string]interface{}{"error": fmt.Sprintf("Token validation failed: %v", err)}
	}

	// Convert payload to a map[string]interface{}
	payloadMap := make(map[string]interface{})
	payloadMap["email"] = payload.Claims["email"]
	payloadMap["name"] = payload.Claims["name"]
	// Add other fields you may need from payload.Claims as necessary

	// Return true and the ID information as a map
	return true, payloadMap
}

// Handle login
func HandleLogin(idToken string) (bool, string, map[string]interface{}) {
	// Step 1: Verify the ID token
	ok, data := VerifyIDToken(idToken)
	if !ok {
		return false, "", map[string]interface{}{"error": "Invalid ID token"}
	}

	// Step 2: Check if the email is valid (must be an IITH email)
	if !IsValidIITHEmail(data["email"].(string)) {
		return false, "", map[string]interface{}{"error": "Please use an IITH email"}
	}

	// Step 3: Check if the user already exists
	exists, userID, err := IsUserExists(data["email"].(string))
	if err != nil {
		// Handle the error if checking for existing user fails
		log.Fatalf("Error checking if user exists: %v", err)
		return false, "", map[string]interface{}{"error": "Error checking if user exists"}
	}

	if !exists {
		// Step 4: Insert new user if they don't exist
		userID, err = InsertUser(data["email"].(string), data["name"].(string))
		if err != nil {
			// Handle the error if inserting the user fails
			log.Fatalf("Error inserting user: %v", err)
			return false, "", map[string]interface{}{"error": "Error adding user"}
		}
	}

	// Now you can use userID for further steps

	// Step 5: Generate JWT token for the user
	token, err := GenerateToken(fmt.Sprint(userID))
	if err != nil {
		log.Printf("Token generation failed: %v", err)
		return false, "", map[string]interface{}{"error": "Token generation failed"}
	}

	// Return successful login response
	return true, token, map[string]interface{}{
		"id":    userID,
		"email": data["email"].(string),
	}
}

// Validate IITH Email
func IsValidIITHEmail(email string) bool {
	pattern := `^[a-zA-Z0-9._%+-]+@(?:[a-zA-Z0-9-]+\.)?iith\.ac\.in$`
	return regexp.MustCompile(pattern).MatchString(email)
}

// Inseting user into database

var db *sqlx.DB

// InsertUser inserts a user and returns their ID, or an error if something goes wrong
func InsertUser(email string, name string) (int, error) {
	// Start a transaction
	tx, err := db.Beginx()
	if err != nil {
		return 0, fmt.Errorf("failed to start transaction: %v", err)
	}

	// Defer the transaction rollback or commit
	defer func(tx *sqlx.Tx) {
		if p := recover(); p != nil {
			tx.Rollback() // If panic occurs, rollback transaction
			panic(p)      // Re-throw panic after rollback
		} else if err != nil {
			tx.Rollback() // Rollback transaction if there was an error
		} else {
			tx.Commit() // Commit transaction if all went well
		}
	}(tx)

	// Insert user query
	insertQuery := `INSERT INTO users (email, name) VALUES ($1, $2)`
	_, err = tx.Exec(insertQuery, email, name)
	if err != nil {
		return 0, fmt.Errorf("failed to insert user: %v", err)
	}

	// Retrieve the user ID
	selectQuery := `SELECT id FROM users WHERE email = $1`
	var userID int
	err = tx.Get(&userID, selectQuery, email)
	if err != nil {
		return 0, fmt.Errorf("failed to retrieve user ID: %v", err)
	}

	return userID, nil
}

func IsUserExists(email string) (bool, int, error) {
	var userID int
	query := `SELECT id FROM users WHERE email = $1`

	err := db.Get(&userID, query, email)
	if err != nil {
		if err.Error() == "sql: no rows in result set" {
			return false, 0, nil
		}
		return false, 0, fmt.Errorf("failed to check if user exists: %v", err)
	}

	return true, userID, nil
}

func AuthMiddleware() gin.HandlerFunc {
	return func(c *gin.Context) {
		authHeader := c.GetHeader("Authorization")
		if authHeader == "" {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "Authorization header is missing"})
			c.Abort()
			return
		}

		tokenString := strings.TrimPrefix(authHeader, "Bearer ")
		if tokenString == authHeader { // No "Bearer" prefix
			c.JSON(http.StatusUnauthorized, gin.H{"error": "Invalid token format"})
			c.Abort()
			return
		}

		isValid, claims := VerifyToken(tokenString)
		if !isValid {
			c.JSON(http.StatusUnauthorized, gin.H{"error": claims.(string)}) // Claims will be the error message
			c.Abort()
			return
		}

		// Extract user ID from the claims (assuming it's stored under the "sub" key)
		claimsMap := claims.(jwt.MapClaims)
		userID := claimsMap["sub"].(string)

		// Store the userID in the context so that handlers can access it
		c.Set("user_id", userID)

		// Proceed to the next handler
		c.Next()
	}
}
