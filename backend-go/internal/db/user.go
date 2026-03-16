package db

import (
	"context"
	"fmt"

	"github.com/jackc/pgx/v5"

	"github.com/LambdaIITH/Dashboard/backend/config"

	schema "github.com/LambdaIITH/Dashboard/backend/internal/schema"
)

// GetUserEmail retrieves the email of a user based on the ID.
func GetUserEmail(c context.Context, id int) (string, error) {
	query := `
        SELECT email
        FROM users
        WHERE id = $1;
    `
	var userEmail string
	err := config.DB.QueryRow(c, query, id).Scan(&userEmail)
	if err != nil {
		return "", err
	}
	return userEmail, nil
}

// GetPhoneNumber retrieves the phone number of a user based on the email.
func GetPhoneNumber(c context.Context, email string) (string, error) {
	query := `
        SELECT phone_number 
        FROM users 
        WHERE email = $1;
    `

	var phoneNumber string
	err := config.DB.QueryRow(c, query, email).Scan(&phoneNumber)
	if err != nil {
		return "", err
	}
	return phoneNumber, nil
}

func IsUserExists(ctx context.Context, email string) (bool, int, error) {
	var userID int
	query := `SELECT id FROM users WHERE email = $1`

	err := config.DB.QueryRow(ctx, query, email).Scan(&userID)
	if err != nil {
		if err == pgx.ErrNoRows {
			return false, 0, nil
		}
		return false, 0, fmt.Errorf("failed to check if user exists: %v", err)
	}

	return true, userID, nil
}

// InsertUser inserts a user and returns their ID, or an error if something goes wrong
func InsertUser(ctx context.Context, email string, name string) (int, error) {
	insertQuery := `INSERT INTO users (email, name) VALUES ($1, $2)`
	_, err := config.DB.Exec(ctx, insertQuery, email, name)
	if err != nil {
		return 0, fmt.Errorf("failed to insert user: %v", err)
	}

	// Retrieve the user ID
	selectQuery := `SELECT id FROM users WHERE email = $1`
	var userID int
	err = config.DB.QueryRow(ctx, selectQuery, email).Scan(&userID)
	if err != nil {
		return 0, fmt.Errorf("failed to retrieve user ID: %v", err)
	}

	return userID, nil
}

func AuthorizeEditDeleteItem(ctx context.Context, itemID int, userID int) (bool, error) {
	query := `SELECT user_id FROM lost WHERE id = $1`
	var ownerID int
	err := config.DB.QueryRow(ctx, query, itemID).Scan(&ownerID)
	if err != nil {
		return false, fmt.Errorf("failed to authorize edit/delete item: %v", err)
	}

	if ownerID != userID {
		return false, nil
	}

	return true, nil
}

func GetUser(c context.Context, id int) schema.UserStruct {
	query := "SELECT id, email, name, cr, phone_number FROM users WHERE id = $1"
	rows, err := config.DB.Query(c, query, id)
	if err != nil {
		return schema.UserStruct{}
	}

	if rows.Next() {
		var user schema.UserStruct
		err = rows.Scan(&user.ID, &user.Email, &user.Name, &user.Cr, &user.PhoneNumber)
		if err != nil {
			return schema.UserStruct{}
		}
		return user
	} else {
		return schema.UserStruct{}
	}
}

func UpdatePhone(c context.Context, id int, phone string) schema.UserStruct {
	query := "UPDATE users SET phone_number = $1 WHERE id = $2 RETURNING id, email, name ,cr , phone_number"

	rows, err := config.DB.Query(c, query, phone, id)
	if err != nil {
		return schema.UserStruct{}
	}

	if rows.Next() {
		var user schema.UserStruct
		err = rows.Scan(&user.ID, &user.Email, &user.Name, &user.Cr, &user.PhoneNumber)
		if err != nil {

			return schema.UserStruct{}
		}

	} else {
		return schema.UserStruct{}
	}
	return schema.UserStruct{}
}

func UpsertFCMToken(c context.Context, id int, token string, deviceType string) bool {
	query := "INSERT INTO fcm_tokens (user_id, token, device_type) VALUES ($1, $2, $3) ON CONFLICT (user_id, token) DO UPDATE SET device_type = EXCLUDED.device_type, token = EXCLUDED.token RETURNING 1; "

	rows, err := config.DB.Query(c, query, id, token, deviceType)

	if err != nil {
		return false
	}

	if rows.Next() {
		return true
	} else {
		return false
	}
}
