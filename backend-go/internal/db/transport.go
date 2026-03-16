package db

import (
	"context"
	"fmt"
	"log"
	"time"

	_ "github.com/lib/pq"

	"github.com/LambdaIITH/Dashboard/backend/config"
)

func LogTransactionToDb(ctx context.Context, transactionData map[string]interface{}) bool {
	// Query to insert the transaction data in the database
	query := `
		INSERT INTO transactions (transaction_id, payment_time, travel_date, bus_timing, isUsed) 
		VALUES ($1, $2, $3, $4, $5);
	`

	// Execute the query
	// no need to scan the resutl
	_, err := config.DB.Exec(ctx, query, transactionData["transactionId"], transactionData["paymentTime"], transactionData["travelDate"], transactionData["busTiming"], transactionData["isUsed"])
	if err != nil {
		return false
	}

	return true
}

func ScanQR(ctx context.Context, transactionData map[string]interface{}) bool {
	// Query to update the transaction data in the database
	query := `
		UPDATE transactions 
		SET isUsed = true 
		WHERE transaction_id = $1;
	`

	// Execute the query
	// no need to scan the resutl
	_, err := config.DB.Exec(ctx, query, transactionData["transactionId"])
	if err != nil {
		return false
	}

	return true
}

func GetLastTransaction(ctx context.Context, userId int) map[string]interface{} {
	query := `
    SELECT transaction_id, payment_time, travel_date, bus_timing, isused, start, destination, amount
    FROM transactions
    WHERE user_id = $1 AND payment_time >= NOW() - INTERVAL '2 hours'
    ORDER BY payment_time DESC
    LIMIT 1`

	rows, err := config.DB.Query(ctx, query, userId)
	if err != nil {
		log.Printf("Error fetching transaction data: %v", err)
		return nil
	}
	defer rows.Close()

	columns := make([]string, 0)
	colTypes := rows.FieldDescriptions()

	for _, col := range colTypes {
		columns = append(columns, string(col.Name))
	}

	if !rows.Next() {
		return nil
	}

	values := make([]interface{}, len(columns))
	scanArgs := make([]interface{}, len(columns))
	for i := range values {
		scanArgs[i] = &values[i]
	}

	err = rows.Scan(scanArgs...)
	if err != nil {
		log.Printf("Error scanning row: %v", err)
		return nil
	}

	transaction := make(map[string]interface{})
	for i, col := range columns {
		val := values[i]
		switch col {
		case "transaction_id":
			if v, ok := val.(string); ok {
				transaction["transactionId"] = v
			}
		case "user_id":
			if v, ok := val.(int64); ok {
				transaction["userId"] = v
			}
		case "payment_time":
			if v, ok := val.(time.Time); ok {
				transaction["paymentTime"] = v.Format("13:12")
			}
		case "bus_timing":
			if v, ok := val.(time.Time); ok {
				transaction["busTiming"] = v.Format("13:12")
			}
		case "travel_date":
			if v, ok := val.(time.Time); ok {
				transaction["travelDate"] = v.Format("04/02/09")
			}
		case "isUsed":
			if v, ok := val.(bool); ok {
				transaction["isUsed"] = fmt.Sprintf("%v", v)
			}
		default:
			if v, ok := val.(string); ok {
				transaction[col] = v
			}
		}
	}
	return transaction
}
