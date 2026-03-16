package controller

import (
	"encoding/json"
	"fmt"
	"net/http"
	"os"
	"path/filepath"
	"strconv"

	helpers "github.com/LambdaIITH/Dashboard/backend/internal/helpers"

	"github.com/gin-gonic/gin"
)

type menuWeekChangeRequest struct {
	Password string `json:"password"`
	Number   int    `json:"number"`
}

var admins = []string{"lambda@iith.ac.in", "ms22btech11010@iith.ac.in", "ma22btech11003@iith.ac.in", "cs22btech11017@iith.ac.in", "cs22btech11028@iith.ac.in"}
var allowedNumbers = []int{0, 1, 2, 3}

// GetMessMenu handles the GET request to retrieve the mess menu.
func GetMessMenu(c *gin.Context) {
	dir, err := os.Getwd()
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Internal server error"})
		return
	}

	// Read the current week from config.json
	configPath := filepath.Join(dir, "config.json")
	var config map[string]interface{}

	configFile, err := os.Open(configPath)
	if err != nil {
		if os.IsNotExist(err) {
			config = map[string]interface{}{"week": 0}

			file, err := os.Create(configPath)
			if err != nil {
				c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create config.json"})
				return
			}
			defer file.Close()

			if err := json.NewEncoder(file).Encode(config); err != nil {
				c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to write to config.json"})
				return
			}
		} else {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Internal server error: error accessing config.json"})
			return
		}
	} else {
		defer configFile.Close()

		// Read the existing configuration
		if err := json.NewDecoder(configFile).Decode(&config); err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Internal server error: invalid config.json"})
			return
		}
	}

	// reading week number from config.json
	week, _ := config["week"].(float64)
	weekStr := strconv.FormatFloat(week, 'f', -1, 64)

	// Read the menu file for the current week
	menuPath := filepath.Join(dir, weekStr+".json")
	menuFile, err := os.Open(menuPath)
	if err != nil {
		fmt.Println(err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Internal server error: missing menu file"})
		return
	}
	defer menuFile.Close()

	var menu interface{}
	if err := json.NewDecoder(menuFile).Decode(&menu); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Internal server error: invalid menu file"})
		return
	}

	c.JSON(http.StatusOK, menu)
}

// PostMessMenu handles the POST request to update the mess week.
func PostMessMenu(c *gin.Context) {
	var req menuWeekChangeRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid request body"})
		return
	}

	// Check if the provided week number is valid
	isAllowed := false
	for _, num := range allowedNumbers {
		if num == req.Number {
			isAllowed = true
			break
		}
	}
	if !isAllowed {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid week number"})
		return
	}

	// Check if the user is an admin or has the correct password
	isAdmin := false
	token, err := c.Cookie("session")
	if err == nil {
		status, payload := helpers.VerifyIDToken(c, token) // verify token and get email
		if status {
			if email, ok := payload["email"].(string); ok {
				for _, admin := range admins {
					if email == admin {
						isAdmin = true
						break
					}
				}
			}
		}
	}

	// Verify the password if the user is not an admin
	password := os.Getenv("ADMIN_PASS")
	if !isAdmin && req.Password != password {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized: incorrect password"})
		return
	}

	// Update the week in config.json
	dir, err := os.Getwd()
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Internal server error"})
		return
	}
	configPath := filepath.Join(dir, "config.json")
	config := map[string]int{"week": req.Number}

	// create new or overwrite existing file config.json
	file, err := os.Create(configPath)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to update configuration file"})
		return
	}
	defer file.Close()

	// writing the updated week number to config.json
	if err := json.NewEncoder(file).Encode(config); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to write configuration data"})
		return
	}

	// return a JSON response
	c.JSON(http.StatusOK, gin.H{"message": "Week number updated successfully"})
}

// GetCurrentWeekNumber handles the GET request to retrieve the current week number.
func GetCurrentWeekNumber(c *gin.Context) {
	isAdmin := false

	// Validate the user's admin status
	token, err := c.Cookie("session")
	if err == nil {
		status, payload := helpers.VerifyIDToken(c, token)
		if status {
			if email, ok := payload["email"].(string); ok {
				for _, admin := range admins {
					if email == admin {
						isAdmin = true
						break
					}
				}
			}
		}
	}

	if !isAdmin {
		c.JSON(http.StatusUnauthorized, gin.H{"message": "Unauthorized"})
		return
	}

	dir, err := os.Getwd()
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Internal server error"})
		return
	}

	// Read the current week from config.json
	configPath := filepath.Join(dir, "config.json")
	configFile, err := os.Open(configPath)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Internal server error: missing config.json"})
		return
	}
	defer configFile.Close()

	// decode the JSON file to read week number
	var config map[string]interface{}
	if err := json.NewDecoder(configFile).Decode(&config); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Internal server error: invalid config.json"})
		return
	}

	week, _ := config["week"].(float64)

	// send week number in response
	c.JSON(http.StatusOK, gin.H{"week": int(week)})
}
