package auth

import (
	"fmt"
	"os"
	"time"

	"github.com/golang-jwt/jwt/v4"
)

var secret []byte = []byte(os.Getenv("TOKEN_SECRET"))

func GenerateToken(userID string) (string, error) {
	duration := 15 * 25 * time.Hour // Expires in 15 days
	expTime := time.Now().Add(duration).Unix()

	claims := jwt.MapClaims{
		"sub": userID,
		"exp": expTime,
	}

	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)

	return token.SignedString(secret)

}

func VerifyToken(tokenString string) (bool, interface{}) {
	token, err := jwt.Parse(tokenString, func(token *jwt.Token) (interface{}, error) {
		if _, ok := token.Method.(*jwt.SigningMethodHMAC); !ok {
			return nil, fmt.Errorf("unexpected signing method: %v", token.Header["alg"])
		}
		return secret, nil
	})

	if err != nil {
		if err == jwt.ErrSignatureInvalid {
			return false, "Invalid token"
		}

		if err == jwt.ErrTokenExpired {
			return false, "Token has expired"
		}
		return false, err.Error()

	}

	if !token.Valid {
		return false, "Token is not valid"
	}

	return true, token.Claims

}
