package auth

import (
	"context"
	"fmt"
	"log"
	"os"
	"regexp"

	"google.golang.org/api/idtoken"
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
	exists, userID := IsUserExists(data["email"].(string))
	if !exists {
		// Step 4: Insert new user if they don't exist
		userID = InsertUser(data["email"].(string), data["name"].(string))
	}

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

// TODO: write insetUser and isUserExists GOPI or SUSI

// Insert User
func InsertUser(email string, name string) int64 {
	// some one write code
	var userID int64 = 0
	return userID
}

// Check if user exists
func IsUserExists(email string) (bool, int64) {
	// some one write code
	var userID int64 = 0
	return true, userID
}
