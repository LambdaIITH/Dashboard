package auth

import (
	"fmt"
	"net/http"
	"os"
	"time"
)

var cookieDomain string = os.Getenv("COOKIE_DOMAIN")

// setCookie sets a cookie with the given parameters
func SetCookie(w http.ResponseWriter, key string, value string, daysExpire int) {
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
func GetUserID(r *http.Request) (int, error) {
	userID, ok := r.Context().Value("user_id").(int)
	if !ok {
		return 0, fmt.Errorf("User ID not found")
	}
	return userID, nil
}
