package db

import (
	"context"
	"encoding/json"
	"errors"
	"time"

	_ "github.com/lib/pq"

	"github.com/LambdaIITH/Dashboard/backend/config"
	"github.com/LambdaIITH/Dashboard/backend/internal/schema"
)

// GetTimetable retrieves the timetable of the user with the given user_id.
func GetTimetable(ctx context.Context, userID int) (string, error) {
	query := "SELECT timetable FROM users WHERE id = $1"

	var result string
	err := config.DB.QueryRow(ctx, query, userID).Scan(&result)
	if err != nil {
		return "", err
	}
	return result, nil
}

// PostTimetable updates the timetable of the user with the given user_id.
func PostTimetable(ctx context.Context, userID int, timetable schema.Timetable) (map[string]interface{}, error) {
	timetableJSON, err := json.Marshal(timetable)
	if err != nil {
		return nil, err
	}

	query := "UPDATE users SET timetable = $1 WHERE id = $2"

	var result map[string]interface{}
	_, err = config.DB.Exec(ctx, query, string(timetableJSON), userID)
	if err != nil {
		return nil, err
	}
	return result, nil
}

// GetSharedTimetable retrieves the timetable with the given code.
func GetSharedTimetable(ctx context.Context, code string) (string, error) {
	query := "SELECT timetable, expiry FROM shared_timetable WHERE code = $1"
 
	var result string
	var expiry time.Time
	err := config.DB.QueryRow(ctx, query, code).Scan(&result, &expiry)

	if err != nil {
		if result == "" {
			return "", errors.New("no timetable found for the given code")
		}
		return "", err
	}

	if expiry.Before(time.Now()) {
		// Delete expired timetable
		deleteQuery := "DELETE FROM shared_timetable WHERE code = $1"
		_, err := config.DB.Exec(ctx, deleteQuery, code)
		if err != nil {
			return "", err
		}
		return "", errors.New("timetable has expired")
	}
	return result, nil
}

// PostSharedTimetable inserts a timetable into the shared_timetable table.
func PostSharedTimetable(ctx context.Context, code string, userID int, timetable interface{}, expiry time.Time) (map[string]interface{}, error) {
	timetableJSON, err := json.Marshal(timetable)
	if err != nil {
		return nil, err
	}

	query := "INSERT INTO shared_timetable (code, user_id, timetable, expiry) VALUES ($1, $2, $3, $4)"
	var result map[string]interface{}
	_, err = config.DB.Exec(ctx, query, code, userID, string(timetableJSON), expiry.Format(time.RFC3339))
	if err != nil {
		return nil, err
	}
	return result, nil
}

// DeleteSharedTimetable deletes the timetable with the given code.
func DeleteSharedTimetable(ctx context.Context, code string) (map[string]interface{}, error) {
	query := "DELETE FROM shared_timetable WHERE code = $1"
	var result map[string]interface{}
	_, err := config.DB.Exec(ctx, query, code)
	if err != nil {
		return nil, err
	}
	return result, nil
}
