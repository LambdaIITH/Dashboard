package routes

import (
	"fmt"
	"net/http"
	"os"
	"time"

	"github.com/joho/godotenv"
)

var cookieDomain string

func init() {
	// Load environment variables from .env file
	err := godotenv.Load()
	if err != nil {
		fmt.Println("Error loading .env file")
	}
	cookieDomain = os.Getenv("COOKIE_DOMAIN")
}

// setCookie sets a cookie with the given parameters
func setCookie(w http.ResponseWriter, key string, value string, daysExpire int) {
	expiration := time.Now().Add(time.Duration(daysExpire) * 24 * time.Hour)
	http.SetCookie(w, &http.Cookie{
		Name:     key,
		Value:    value,
		Expires:  expiration,
		HttpOnly: true,
		Secure:   true,
		SameSite: http.SameSiteNoneMode,
		Domain:   cookieDomain,
		Path:     "/",
		MaxAge:   daysExpire * 24 * 60 * 60, // seconds
	})
}

// getUserID retrieves the user ID from the request context
func getUserID(r *http.Request) (int, error) {
	userID, ok := r.Context().Value("user_id").(int)
	if !ok {
		return 0, fmt.Errorf("User ID not found")
	}
	return userID, nil
}


