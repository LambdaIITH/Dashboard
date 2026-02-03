package db

import (
	"context"
	"errors"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
)

type HostelDetails struct {
	Email       string
	HostelBlock string
	RoomNumber  string
	Gender      *string
}

// GetHostelDetailsByEmail fetches the hostel details for a given email.
func GetHostelDetailsByEmail(ctx context.Context, db *pgxpool.Pool, email string) (*HostelDetails, error) {
	query := `
		SELECT email, hostel_block, room_number, gender
		FROM hostels
		WHERE email = $1
	`

	var details HostelDetails
	
	err := db.QueryRow(ctx, query, email).Scan(
		&details.Email,
		&details.HostelBlock,
		&details.RoomNumber,
		&details.Gender,
	)

	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return nil, errors.New("hostel details not found")
		}
		return nil, err
	}

	return &details, nil
}
