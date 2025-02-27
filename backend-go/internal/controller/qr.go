package controller

import (
	"bytes"
	"encoding/json"
	"fmt"
	"net/http"
	"os"
	"time"

	"github.com/LambdaIITH/Dashboard/backend/config"
	queries "github.com/LambdaIITH/Dashboard/backend/internal/db"
	helpers "github.com/LambdaIITH/Dashboard/backend/internal/helpers"
	schema "github.com/LambdaIITH/Dashboard/backend/internal/schema"
	"github.com/gin-gonic/gin"
)

type TransactionRequest struct {
	TransactionId string `json:"transactionId"`
	Amount        string `json:"amount"`
	Start         string `json:"start"`
	Destination   string `json:"destination"`
}

type TransactionResponse struct {
	TransactionId string `json:"transactionId"`
	PaymentTime   string `json:"paymentTime"`
	TravelDate    string `json:"travelDate"`
	BusTiming     string `json:"busTiming"`
	IsUsed        bool   `json:"isUsed"`
	Start         string `json:"start"`
	Destination   string `json:"destination"`
	Amount        string `json:"amount"`
}

type ScanQRModel struct {
	IsScanned bool `json:"isScanned"`
}

func ProcessTransaction(c *gin.Context) {
	userId, err := helpers.GetUserID(c)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	var request TransactionRequest
	if err := c.ShouldBindJSON(&request); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	now := time.Now()
	paymentTime := now.Format("15:04 02/01/06")
	travelDate := now.Format("02/01/06")
	busTiming := "14:30"

	response := TransactionResponse{
		TransactionId: request.TransactionId,
		PaymentTime:   paymentTime,
		TravelDate:    travelDate,
		BusTiming:     busTiming,
		IsUsed:        false,
		Start:         request.Start,
		Destination:   request.Destination,
		Amount:        request.Amount,
	}

	transactionData := map[string]interface{}{
		"transaction_id": response.TransactionId,
		"payment_time":   time.Now(),
		"travel_date":    time.Now(),
		"bus_timing":     response.BusTiming,
		"isUsed":         false,
		"start":          response.Start,
		"destination":    response.Destination,
		"amount":         response.Amount,
	}

	var userDetails schema.UserStruct
	if userId != 0 {
		userDetails = queries.GetUser(c, userId)
	}

	googleSheetsData := map[string]interface{}{
		"transaction_id": response.TransactionId,
		"name":           userDetails.Name,
		"email":          userDetails.Email,
		"amount":         response.Amount,
		"from":           response.Start,
		"to":             response.Destination,
		"travel_date":    travelDate,
		"bus_timing":     response.BusTiming,
	}

	jsonData, err := json.Marshal(googleSheetsData)
	if err != nil {
		fmt.Println("Failed to marshal google sheets data")
	}

	url := os.Getenv("GOOGLE_SHEET_APP_SCRIPT_URL")
	_, err = http.Post(url, "application/json", bytes.NewBuffer(jsonData))
	if err != nil {
		fmt.Println("Failed to log transaction to google sheets")
	}

	result := queries.LogTransactionToDb(c, transactionData)
	if !result {
		query := `
			SELECT payment_time, travel_date, bus_timing, isUsed
			FROM transactions
			WHERE transaction_id = $1
			LIMIT 1;
		`

		var dbResponse struct {
			PaymentTime time.Time
			TravelDate  time.Time
			BusTiming   string
			IsUsed      bool
		}

		err := config.DB.QueryRow(c, query, request.TransactionId).Scan(
			&dbResponse.PaymentTime,
			&dbResponse.TravelDate,
			&dbResponse.BusTiming,
			&dbResponse.IsUsed,
		)

		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch transaction"})
			return
		}

		response = TransactionResponse{
			TransactionId: request.TransactionId,
			PaymentTime:   dbResponse.PaymentTime.Format("15:04 02/01/06"),
			TravelDate:    dbResponse.TravelDate.Format("02/01/06"),
			BusTiming:     dbResponse.BusTiming,
			IsUsed:        dbResponse.IsUsed,
			Start:         request.Start,
			Destination:   request.Destination,
			Amount:        request.Amount,
		}

		c.JSON(http.StatusOK, response)
	}

	c.JSON(http.StatusOK, response)

}

func ScanQRCode(c *gin.Context) {
	var request TransactionRequest
	if err := c.ShouldBindJSON(&request); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	response := ScanQRModel{
		IsScanned: true,
	}

	result := queries.ScanQR(c, map[string]interface{}{"transactionId": request.TransactionId})

	if !result {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Transaction not found"})
		return
	}

	c.JSON(http.StatusOK, response)
}

func GetRecentTransaction(c *gin.Context) {
	userId, err := helpers.GetUserID(c)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	transactions := queries.GetLastTransaction(c, userId)
	if transactions == nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch transaction"})
		return
	}

	response := TransactionResponse{
		TransactionId: transactions["TransactionId"].(string),
		PaymentTime:   transactions["PaymentTime"].(string),
		TravelDate:    transactions["TravelDate"].(string),
		BusTiming:     transactions["BusTiming"].(string),
		IsUsed:        transactions["IsUsed"].(bool),
		Start:         transactions["Start"].(string),
		Destination:   transactions["Destination"].(string),
		Amount:        transactions["Amount"].(string),
	}

	c.JSON(http.StatusOK, response)

}
