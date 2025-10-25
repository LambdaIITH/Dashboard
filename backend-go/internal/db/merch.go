package db

import (
	"context"
	"database/sql"
	"fmt"

	"github.com/LambdaIITH/Dashboard/backend/config"
	"github.com/LambdaIITH/Dashboard/backend/internal/schema"
)

// Fetch additional images for a merchandise item
func GetMerchImages(c context.Context, merchID int) ([]schema.MerchImage, error) {
	rows, err := config.DB.Query(c, `
        SELECT id, merch_id, image_url, created_at
        FROM merch_images WHERE merch_id = $1
        ORDER BY id ASC`, merchID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var images []schema.MerchImage
	for rows.Next() {
		var img schema.MerchImage
		err = rows.Scan(&img.ID, &img.MerchID, &img.ImageURL, &img.CreatedAt)
		if err != nil {
			return nil, err
		}
		images = append(images, img)
	}
	return images, nil
}

// Fetch available sizes for a merchandise item
func GetMerchSizes(c context.Context, merchID int) ([]schema.MerchSize, error) {
	rows, err := config.DB.Query(c, `
        SELECT id, merch_id, size_name, created_at
        FROM merch_sizes WHERE merch_id = $1
        ORDER BY id ASC`, merchID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var sizes []schema.MerchSize
	for rows.Next() {
		var size schema.MerchSize
		err = rows.Scan(&size.ID, &size.MerchID, &size.SizeName, &size.CreatedAt)
		if err != nil {
			return nil, err
		}
		sizes = append(sizes, size)
	}
	return sizes, nil
}

// Fetch all merchandise items
func GetAllMerchItems(c context.Context) ([]schema.Merch, error) {
	rows, err := config.DB.Query(c, `
        SELECT id, title, deadline, price, image_url, description, upi_id, 
               is_oversized, size_guide_url, created_at
        FROM merch ORDER BY id DESC`)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var merchList []schema.Merch
	for rows.Next() {
		var m schema.Merch
		var sizeGuideURL sql.NullString

		err = rows.Scan(
			&m.ID, &m.Title, &m.Deadline, &m.Price, &m.ImageURL,
			&m.Description, &m.UPIID, &m.IsOversized, &sizeGuideURL, &m.CreatedAt)
		if err != nil {
			return nil, err
		}

		if sizeGuideURL.Valid {
			m.SizeGuideURL = sizeGuideURL.String
		}

		images, err := GetMerchImages(c, m.ID)
		if err != nil {
			return nil, err
		}
		m.Images = images

		sizes, err := GetMerchSizes(c, m.ID)
		if err != nil {
			return nil, err
		}
		m.AvailableSizes = sizes
		m.HasSizes = len(sizes) > 0

		merchList = append(merchList, m)
	}
	return merchList, nil
}

// Fetch single merchandise item
func GetMerchItem(c context.Context, id int) (*schema.Merch, error) {
	var m schema.Merch
	var sizeGuideURL sql.NullString

	err := config.DB.QueryRow(c, `
        SELECT id, title, deadline, price, image_url, description, upi_id, 
               is_oversized, size_guide_url, created_at
        FROM merch WHERE id = $1`, id).Scan(
		&m.ID, &m.Title, &m.Deadline, &m.Price, &m.ImageURL, &m.Description,
		&m.UPIID, &m.IsOversized, &sizeGuideURL, &m.CreatedAt)
	if err != nil {
		return nil, err
	}

	if sizeGuideURL.Valid {
		m.SizeGuideURL = sizeGuideURL.String
	}

	images, err := GetMerchImages(c, id)
	if err != nil {
		return nil, err
	}
	m.Images = images

	sizes, err := GetMerchSizes(c, id)
	if err != nil {
		return nil, err
	}
	m.AvailableSizes = sizes
	m.HasSizes = len(sizes) > 0

	return &m, nil
}

// Create an order
func CreateOrder(c context.Context, order schema.Order) (int, error) {
	var exists bool
	err := config.DB.QueryRow(c, `
		SELECT EXISTS(SELECT 1 FROM orders WHERE transaction_id = $1)
	`, order.TransactionID).Scan(&exists)
	if err != nil {
		return 0, err
	}
	if exists {
		return 0, fmt.Errorf("duplicate transaction_id")
	}

	var orderID int
	err = config.DB.QueryRow(c, `
        INSERT INTO orders (user_id, merch_id, size, transaction_id, display_name, status, order_date, is_oversized) 
        VALUES ($1, $2, $3, $4, $5, $6, CURRENT_DATE, $7) RETURNING id`,
		order.UserID, order.MerchID, order.Size, order.TransactionID, order.DisplayName, order.Status, order.IsOversized,
	).Scan(&orderID)

	if err != nil {
		return 0, err
	}
	return orderID, nil
}

// Fetch orders for a specific user
func GetUserOrders(c context.Context, userID int) ([]schema.OrderResponse, error) {
	query := `
        SELECT o.id, o.merch_id, m.title, m.price, m.image_url, o.size, 
               o.status, o.order_date, o.transaction_id, o.display_name, o.is_oversized
        FROM orders o
        JOIN merch m ON o.merch_id = m.id
        WHERE o.user_id = $1
    `

	rows, err := config.DB.Query(c, query, userID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var orders []schema.OrderResponse
	for rows.Next() {
		var order schema.OrderResponse
		var orderDate sql.NullTime
		var size sql.NullString

		err := rows.Scan(
			&order.ID, &order.MerchID, &order.Title, &order.Price, &order.ImageURL,
			&size, &order.Status, &orderDate, &order.TransactionID, &order.DisplayName, &order.IsOversized,
		)
		if err != nil {
			return nil, err
		}

		if orderDate.Valid {
			order.OrderDate = orderDate.Time
		}

		if size.Valid {
			sizeVal := size.String
			order.Size = &sizeVal
		}

		orders = append(orders, order)
	}

	if len(orders) == 0 {
		return nil, err
	}

	return orders, nil
}
