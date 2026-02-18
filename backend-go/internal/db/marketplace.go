package db

import (
	"context"
	"fmt"
	"strings"

	_ "github.com/lib/pq"

	"github.com/LambdaIITH/Dashboard/backend/config"
	"github.com/LambdaIITH/Dashboard/backend/internal/schema"
)

func InsertInSellingTable(ctx context.Context, form_data map[string]interface{}, user_ID int) (int, error) {
	// Query to insert the selling item in the database
	query := `
        INSERT INTO selling (item_name, item_description, user_id, selling_price)
        VALUES ($1, $2, $3, $4)
        RETURNING id
    `

	// Execute the query and retrieve the inserted ID
	var sellingId int
	err := config.DB.QueryRow(ctx, query, form_data["item_name"], form_data["item_description"], user_ID, form_data["selling_price"]).Scan(&sellingId)
	if err != nil {
		return 0, err
	}

	return sellingId, nil
}

func InsertSellingImages(ctx context.Context, image_paths []string, post_id int) error {
	// Query to insert the selling item images in the database

	query := `INSERT INTO selling_images (image_url, item_id)
        VALUES ($1, $2)`

	// 	Execute the query
	for _, image_paths := range image_paths {
		_, err := config.DB.Exec(ctx, query, image_paths, post_id)
		if err != nil {
			return err
		}
	}

	return nil
}

func GetAllSellingItems(ctx context.Context) ([]schema.SellingItem, error) {
	// Query to get all the selling items from the database
	query := `
        SELECT
            s.id,
            s.item_name,
            s.item_description,
            s.user_id,
            COALESCE(json_agg(fi.image_url) FILTER (WHERE fi.image_url IS NOT NULL), '[]') AS images,
            s.created_at,
            s.selling_price
        FROM
            selling s
        LEFT JOIN
            selling_images fi ON s.id = fi.item_id
        GROUP BY
            s.id, s.item_name, s.item_description, s.user_id, s.created_at, s.selling_price
        ORDER BY
            s.created_at DESC;
	`

	rows, err := config.DB.Query(ctx, query)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var sellingItems []schema.SellingItem

	for rows.Next() {
		var item schema.SellingItem
		var images []string

		if err := rows.Scan(
			&item.ID,
			&item.ItemName,
			&item.ItemDescription,
			&item.UserID,
			&images,
			&item.CreatedAt,
			&item.SellingPrice,
		); err != nil {
			return nil, err
		}

		item.Images = images
		sellingItems = append(sellingItems, item)
	}

	if rows.Err() != nil {
		return nil, rows.Err()
	}

	return sellingItems, nil
}

func UpdateInSellingTable(ctx context.Context, itemID int, formData map[string]interface{}) (schema.SellingItem, error) {
	// Query to update the selling item in the database
	query := `
		UPDATE selling SET
	`

	// List to hold the SET clause of the query
	setParts := []string{}

	// Arguments to pass to the query
	args := []interface{}{}
	argID := 1

	// Loop to build the SET clause and arguments dynamically
	for key, value := range formData {
		if key == "item_name" || key == "item_description" || key == "selling_price" {
			setParts = append(setParts, fmt.Sprintf("%s = $%d", key, argID))
			args = append(args, value)
			argID++
		}
	}

	// Join the parts of the SET clause
	query += strings.Join(setParts, ", ")

	// Add the WHERE clause to filter by item ID
	query += fmt.Sprintf(" WHERE id = $%d", argID)
	args = append(args, itemID)

	// Add RETURNING * to get the updated row
	query += " RETURNING *"

	var updatedItem schema.SellingItem

	// Execute the query and scan the result into updatedItem
	err := config.DB.QueryRow(ctx, query, args...).Scan(
		&updatedItem.ID,
		&updatedItem.ItemName,
		&updatedItem.ItemDescription,
		&updatedItem.UserID,
		&updatedItem.CreatedAt,
		&updatedItem.SellingPrice,
	)
	if err != nil {
		return updatedItem, err
	}

	return updatedItem, nil
}

func GetParticularSellingItem(ctx context.Context, itemID int) (schema.SellingItem, error) {
	// Query to get the particular selling item from the database
	query := `
		SELECT
			s.id,
			s.item_name,
			s.item_description,
			u.name,
			u.email,
			u.phone_number,
			s.created_at,
			s.selling_price
			FROM
			selling s
			JOIN
			users u ON s.user_id = u.id
		WHERE
			s.id = $1
	`

	// Execute the query and scan the result into sellingItem
	var sellingItem schema.SellingItem
	err := config.DB.QueryRow(ctx, query, itemID).Scan(
		&sellingItem.ID,
		&sellingItem.ItemName,
		&sellingItem.ItemDescription,
		&sellingItem.UserName,
		&sellingItem.UserEmail,
		&sellingItem.UserPhoneNumber,
		&sellingItem.CreatedAt,
		&sellingItem.SellingPrice,
	)
	if err != nil {
		return sellingItem, err
	}

	return sellingItem, nil
}

func DeleteItemImagesFromSelling(ctx context.Context, itemID int) (string, error) {
	// Query to delete the particular selling item images from the database
	query := `
		DELETE FROM selling_images
		WHERE item_id = $1
	`

	// Execute the query, passing the itemID as a parameter
	result, err := config.DB.Exec(ctx, query, itemID)
	if err != nil {
		return "", err
	}

	// Get the number of rows affected (i.e., number of images deleted)
	rowsAffected := result.RowsAffected()
	if rowsAffected == 0 {
		return "No images deleted", nil
	}

	// Prepare a message with the number of images deleted
	resultMessage := fmt.Sprintf("%d images deleted", rowsAffected)
	return resultMessage, nil
}

func DeleteAllImageUrisSelling(ctx context.Context, itemId int) ([]string, error) {
	// Query to delete the particular selling item from the database
	query := `
    SELECT image_url FROM selling_images WHERE item_id = $1
  `

	var imageUrls []string
	rows, err := config.DB.Query(ctx, query, itemId)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	// Retrieve image URLs from the result set
	for rows.Next() {
		var imageUrl string
		if err := rows.Scan(&imageUrl); err != nil {
			return nil, err
		}
		imageUrls = append(imageUrls, imageUrl)
	}

	return imageUrls, nil
}

func SearchSellingItems(ctx context.Context, search_query string) ([]schema.SellingItem, error) {
	max_results := 10
	// Query to search for selling items
	query := `
	  SELECT id, item_name, item_description, user_id, created_at, selling_price
	  FROM selling
	  WHERE item_name ILIKE $1
	  ORDER BY created_at DESC
	  LIMIT $2
	`

	// Execute the query
	var sellingItems []schema.SellingItem
	rows, err := config.DB.Query(ctx, query, "%"+search_query+"%", max_results)
	if err != nil {
		return nil, err
	}

	defer rows.Close()

	// Retrieve image URLs from the result set
	for rows.Next() {
		var sellingItem schema.SellingItem
		if err := rows.Scan(&sellingItem.ID, &sellingItem.ItemName, &sellingItem.ItemDescription, &sellingItem.UserID, &sellingItem.CreatedAt, &sellingItem.SellingPrice); err != nil {
			return nil, err
		}
		sellingItems = append(sellingItems, sellingItem)
	}

	return sellingItems, nil
}

func GetSomeImgUrisSelling(ctx context.Context, itemIDs []int) ([]schema.SellingItemImageURI, error) {
	placeholders := make([]string, len(itemIDs))
	args := make([]interface{}, len(itemIDs))

	for i, id := range itemIDs {
		placeholders[i] = fmt.Sprintf("$%d", i+1)
		args[i] = id
	}

	query := fmt.Sprintf(`
		SELECT item_id, image_url
		FROM selling_images
		WHERE item_id IN (%s)
	`, strings.Join(placeholders, ", "))

	var imageURIs []schema.SellingItemImageURI

	rows, err := config.DB.Query(ctx, query, args...)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	for rows.Next() {
		var imageURI schema.SellingItemImageURI
		if err := rows.Scan(&imageURI.ItemID, &imageURI.ImageURL); err != nil {
			return nil, err
		}
		imageURIs = append(imageURIs, imageURI)
	}

	if err := rows.Err(); err != nil {
		return nil, err
	}

	return imageURIs, nil
}

func GetSellingItemsByUserID(ctx context.Context, userID int) ([]schema.SellingItem, error) {
	// Query to get selling items by user ID
	query := `
		SELECT id, item_name, item_description, user_id, created_at, selling_price
		FROM selling
		WHERE user_id = $1
		ORDER BY created_at DESC
	`

	rows, err := config.DB.Query(ctx, query, userID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var sellingItems []schema.SellingItem

	for rows.Next() {
		var item schema.SellingItem
		if err := rows.Scan(&item.ID, &item.ItemName, &item.ItemDescription, &item.UserID, &item.CreatedAt, &item.SellingPrice); err != nil {
			return nil, err
		}
		sellingItems = append(sellingItems, item)
	}

	if rows.Err() != nil {
		return nil, rows.Err()
	}

	return sellingItems, nil
}
