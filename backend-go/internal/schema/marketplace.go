package schema

import (
	"time"
)

type SellingItem struct {
	ID              int       `db:"id"`
	ItemName        string    `db:"item_name"`
	ItemDescription string    `db:"item_description"`
	SellingPrice    float64   `db:"selling_price"`
	UserID          int       `db:"user_id"`
	UserName        string    `db:"username"`
	UserEmail       string    `db:"user_email"`
	Images          []string  `db:"images"`
	CreatedAt       time.Time `db:"created_at"`
}

type SellingItemWithUser struct {
	ID              int    `db:"id"`
	ItemName        string `db:"item_name"`
	ItemDescription string `db:"item_description"`
	UserID          int    `db:"user_id"`
	UserName        string `db:"username"`
	CreatedAt       string `db:"created_at"`
}

type SellingItemImageURI struct {
	ItemID   int    `db:"item_id"`
	ImageURL string `db:"image_url"`
}
