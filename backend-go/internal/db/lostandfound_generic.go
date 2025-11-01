// Package db provides generic database functions for Lost and Found items
// This module eliminates code duplication between lost.go and found.go
package db

import (
	"context"
	"fmt"

	"github.com/LambdaIITH/Dashboard/backend/config"
	"github.com/LambdaIITH/Dashboard/backend/internal/schema"
)

// Whitelist of allowed table names to prevent SQL injection
var allowedTables = map[string]bool{
	"lost":         true,
	"found":        true,
	"lost_images":  true,
	"found_images": true,
}

// validateTableName checks if a table name is in the allowed list
func validateTableName(tableName string) error {
	if !allowedTables[tableName] {
		return fmt.Errorf("invalid table name: %s", tableName)
	}
	return nil
}

// InsertInTable inserts a new item (lost or found) into the specified table
func InsertInTable(ctx context.Context, tableName string, formData map[string]interface{}, userID int) (int, error) {
	if err := validateTableName(tableName); err != nil {
		return 0, err
	}

	query := fmt.Sprintf(`
        INSERT INTO %s (item_name, item_description, user_id)
        VALUES ($1, $2, $3)
        RETURNING id
    `, tableName)

	var itemID int
	err := config.DB.QueryRow(ctx, query, formData["item_name"], formData["item_description"], userID).Scan(&itemID)
	if err != nil {
		return 0, err
	}

	return itemID, nil
}

// InsertImages inserts image URLs for an item into the specified images table
func InsertImages(ctx context.Context, imagesTableName string, imagePaths []string, postID int) error {
	if err := validateTableName(imagesTableName); err != nil {
		return err
	}

	query := fmt.Sprintf(`INSERT INTO %s (image_url, item_id) VALUES ($1, $2)`, imagesTableName)

	for _, imagePath := range imagePaths {
		_, err := config.DB.Exec(ctx, query, imagePath, postID)
		if err != nil {
			return err
		}
	}

	return nil
}

// GetAllItems retrieves all items from the specified table with their images
func GetAllItems(ctx context.Context, tableName, imagesTableName string) ([]map[string]interface{}, error) {
	if err := validateTableName(tableName); err != nil {
		return nil, err
	}
	if err := validateTableName(imagesTableName); err != nil {
		return nil, err
	}

	query := fmt.Sprintf(`
        SELECT
            f.id,
            f.item_name,
            f.item_description,
            f.user_id,
            COALESCE(json_agg(fi.image_url) FILTER (WHERE fi.image_url IS NOT NULL), '[]') AS images,
            f.created_at
        FROM
            %s f
        LEFT JOIN
            %s fi ON f.id = fi.item_id
        GROUP BY
            f.id, f.item_name, f.item_description, f.user_id, f.created_at
        ORDER BY
            f.created_at DESC;
	`, tableName, imagesTableName)

	rows, err := config.DB.Query(ctx, query)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var items []map[string]interface{}

	for rows.Next() {
		var (
			id              int
			itemName        string
			itemDescription string
			userID          int
			images          []string
			createdAt       string
		)

		err := rows.Scan(&id, &itemName, &itemDescription, &userID, &images, &createdAt)
		if err != nil {
			return nil, err
		}

		item := map[string]interface{}{
			"id":               id,
			"item_name":        itemName,
			"item_description": itemDescription,
			"user_id":          userID,
			"images":           images,
			"created_at":       createdAt,
		}
		items = append(items, item)
	}

	return items, nil
}

// GetParticularItem retrieves a specific item with user details
func GetParticularItem(ctx context.Context, tableName string, itemID int) (*schema.LostFoundItem, error) {
	if err := validateTableName(tableName); err != nil {
		return nil, err
	}

	query := fmt.Sprintf(`
        SELECT 
            %s.id, 
            %s.item_name, 
            %s.item_description, 
            %s.user_id, 
            users.name, 
            users.email, 
            %s.created_at 
        FROM %s 
        INNER JOIN users ON users.id = %s.user_id 
        WHERE %s.id = $1
    `, tableName, tableName, tableName, tableName, tableName, tableName, tableName, tableName)

	var item schema.LostFoundItem
	err := config.DB.QueryRow(ctx, query, itemID).Scan(
		&item.ID,
		&item.ItemName,
		&item.ItemDescription,
		&item.UserID,
		&item.UserName,
		&item.UserEmail,
		&item.CreatedAt,
	)

	if err != nil {
		return nil, err
	}

	return &item, nil
}

// UpdateInTable updates an item in the specified table
func UpdateInTable(ctx context.Context, tableName string, itemID int, formData map[string]interface{}) (map[string]interface{}, error) {
	if err := validateTableName(tableName); err != nil {
		return nil, err
	}

	query := fmt.Sprintf(`
        UPDATE %s 
        SET item_name = $1, item_description = $2 
        WHERE id = $3 
        RETURNING id, item_name, item_description, user_id, created_at
    `, tableName)

	var (
		id              int
		itemName        string
		itemDescription string
		userID          int
		createdAt       string
	)

	err := config.DB.QueryRow(ctx, query, formData["item_name"], formData["item_description"], itemID).Scan(
		&id, &itemName, &itemDescription, &userID, &createdAt,
	)

	if err != nil {
		return nil, err
	}

	result := map[string]interface{}{
		"id":               id,
		"item_name":        itemName,
		"item_description": itemDescription,
		"user_id":          userID,
		"created_at":       createdAt,
	}

	return result, nil
}

// DeleteAllImageURIs deletes and returns all image URLs for an item
func DeleteAllImageURIs(ctx context.Context, imagesTableName string, itemID int) ([]string, error) {
	if err := validateTableName(imagesTableName); err != nil {
		return nil, err
	}

	query := fmt.Sprintf(`SELECT image_url FROM %s WHERE item_id = $1`, imagesTableName)
	rows, err := config.DB.Query(ctx, query, itemID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var imageURLs []string
	for rows.Next() {
		var imageURL string
		if err := rows.Scan(&imageURL); err != nil {
			return nil, err
		}
		imageURLs = append(imageURLs, imageURL)
	}

	return imageURLs, nil
}

// DeleteItemImages deletes all images for an item from the images table
func DeleteItemImages(ctx context.Context, imagesTableName string, itemID int) (int64, error) {
	if err := validateTableName(imagesTableName); err != nil {
		return 0, err
	}

	query := fmt.Sprintf(`DELETE FROM %s WHERE item_id = $1`, imagesTableName)
	result, err := config.DB.Exec(ctx, query, itemID)
	if err != nil {
		return 0, err
	}

	return result.RowsAffected(), nil
}

// SearchItems searches for items matching the query string
func SearchItems(ctx context.Context, tableName, searchQuery string) ([]map[string]interface{}, error) {
	if err := validateTableName(tableName); err != nil {
		return nil, err
	}

	query := fmt.Sprintf(`
        SELECT * 
        FROM %s 
        WHERE item_name ILIKE $1 OR item_description ILIKE $1 
        ORDER BY created_at DESC
    `, tableName)

	searchPattern := "%" + searchQuery + "%"
	rows, err := config.DB.Query(ctx, query, searchPattern)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var items []map[string]interface{}

	for rows.Next() {
		var (
			id              int
			itemName        string
			itemDescription string
			userID          int
			createdAt       string
		)

		err := rows.Scan(&id, &itemName, &itemDescription, &userID, &createdAt)
		if err != nil {
			return nil, err
		}

		item := map[string]interface{}{
			"id":               id,
			"item_name":        itemName,
			"item_description": itemDescription,
			"user_id":          userID,
			"created_at":       createdAt,
		}
		items = append(items, item)
	}

	return items, nil
}

// GetSomeImageURIs retrieves image URLs for multiple items
func GetSomeImageURIs(ctx context.Context, imagesTableName string, itemIDs []int) ([]schema.ImageURI, error) {
	if err := validateTableName(imagesTableName); err != nil {
		return nil, err
	}

	if len(itemIDs) == 0 {
		return []schema.ImageURI{}, nil
	}

	query := fmt.Sprintf(`SELECT item_id, image_url FROM %s WHERE item_id = ANY($1)`, imagesTableName)

	rows, err := config.DB.Query(ctx, query, itemIDs)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var imageURIs []schema.ImageURI
	for rows.Next() {
		var img schema.ImageURI
		if err := rows.Scan(&img.ItemID, &img.ImageURL); err != nil {
			return nil, err
		}
		imageURIs = append(imageURIs, img)
	}

	return imageURIs, nil
}
