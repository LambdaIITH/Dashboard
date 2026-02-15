// Package controller provides generic HTTP handlers for Lost and Found items
// This module eliminates code duplication between lost.go and found.go controllers
package controller

import (
	"encoding/json"
	"fmt"
	"net/http"
	"os"
	"strconv"

	"github.com/LambdaIITH/Dashboard/backend/config"
	"github.com/LambdaIITH/Dashboard/backend/internal/db"
	"github.com/LambdaIITH/Dashboard/backend/internal/helpers"
	"github.com/LambdaIITH/Dashboard/backend/internal/schema"
	"github.com/gin-gonic/gin"
)

// LfResponse represents the response structure for Lost and Found items
type LfResponse struct {
	ID              int      `json:"id"`
	ItemName        string   `json:"item_name"`
	ItemDescription string   `json:"item_description"`
	UserName        string   `json:"username"`
	UserEmail       string   `json:"user_email"`
	Images          []string `json:"image_urls"`
	CreatedAt       string   `json:"created_at"`
	username        string
	user_email      string
}

// Whitelist of allowed table names to prevent SQL injection
var allowedControllerTables = map[string]bool{
	"lost":         true,
	"found":        true,
	"lost_images":  true,
	"found_images": true,
}

// validateTableName checks if a table name is in the allowed list
func validateControllerTableName(tableName string) error {
	if !allowedControllerTables[tableName] {
		return fmt.Errorf("invalid table name: %s", tableName)
	}
	return nil
}

// AddItemGenericHandler handles adding a new item (lost or found)
func AddItemGenericHandler(c *gin.Context, tableName, imagesTableName string) {
	if err := validateControllerTableName(tableName); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}
	if err := validateControllerTableName(imagesTableName); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Parse form data
	formData := c.PostForm("form_data")
	var formDataDict map[string]interface{}
	if err := json.Unmarshal([]byte(formData), &formDataDict); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid form data"})
		return
	}

	// Get user ID
	userID, err := helpers.GetUserID(c)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": err.Error()})
		return
	}

	// Insert item into table
	itemID, err := db.InsertInTable(c, tableName, formDataDict, userID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to insert data"})
		return
	}

	// Upload images if provided
	form, err := c.MultipartForm()
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid file data"})
		return
	}

	files := form.File["images"]
	if len(files) > 0 {
		s3Client := helpers.NewS3Client(os.Getenv("BUCKET_NAME"), os.Getenv("REGION"), os.Getenv("RESOURCE_URI"))

		imagePaths, err := s3Client.UploadImages(files, itemID, tableName)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to upload images"})
			return
		}

		err = db.InsertImages(c, imagesTableName, imagePaths, itemID)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to save image paths"})
			return
		}
	}

	c.JSON(http.StatusOK, gin.H{"message": "Data inserted successfully"})
}

// GetAllItemsGenericHandler fetches all items with their images
func GetAllItemsGenericHandler(c *gin.Context, tableName, imagesTableName string) {
	if err := validateControllerTableName(tableName); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}
	if err := validateControllerTableName(imagesTableName); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Fetch all items
	items, err := db.GetAllItems(c, tableName, imagesTableName)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to fetch items"})
		return
	}

	// Fetch image URLs
	rows, err := config.DB.Query(c, "SELECT item_id, image_url FROM "+imagesTableName)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to fetch images"})
		return
	}
	defer rows.Close()

	// Organize images by item ID
	imageDict := make(map[int][]string)
	for rows.Next() {
		var img schema.ImageURI
		if err := rows.Scan(&img.ItemID, &img.ImageURL); err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to scan images"})
			return
		}
		imageDict[img.ItemID] = append(imageDict[img.ItemID], img.ImageURL)
	}

	// Build response
	response := make([]map[string]any, 0, len(items))
	for _, item := range items {
		itemID := item["id"].(int)
		images := imageDict[itemID]
		if images == nil {
			images = []string{}
		}

		itemData := map[string]any{
			"id":     itemID,
			"name":   item["item_name"],
			"images": images,
		}
		response = append(response, itemData)
	}

	c.JSON(http.StatusOK, response)
}

// GetItemByIDGenericHandler fetches a specific item by ID
func GetItemByIDGenericHandler(c *gin.Context, tableName, imagesTableName string) {
	if err := validateControllerTableName(tableName); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}
	if err := validateControllerTableName(imagesTableName); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Parse item ID
	id, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid item ID"})
		return
	}

	// Get item details
	item, err := db.GetParticularItem(c, tableName, id)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Item not found"})
		return
	}

	// Fetch image URLs
	var imageURLs []string
	rows, err := config.DB.Query(c, "SELECT image_url FROM "+imagesTableName+" WHERE item_id = $1", id)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch images"})
		return
	}
	defer rows.Close()

	for rows.Next() {
		var imageURL string
		if err := rows.Scan(&imageURL); err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to scan image URL"})
			return
		}
		imageURLs = append(imageURLs, imageURL)
	}

	if err = rows.Err(); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Error iterating through image results"})
		return
	}

	if imageURLs == nil {
		imageURLs = []string{}
	}

	// Build response
	response := LfResponse{
		ID:              item.ID,
		ItemName:        item.ItemName,
		ItemDescription: item.ItemDescription,
		UserEmail:       item.UserEmail,
		UserName:        item.UserName,
		Images:          imageURLs,
		username:        item.UserName,
	}

	c.JSON(http.StatusOK, response)
}

// DeleteItemGenericHandler deletes an item
func DeleteItemGenericHandler(c *gin.Context, tableName, imagesTableName string) {
	if err := validateControllerTableName(tableName); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}
	if err := validateControllerTableName(imagesTableName); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Get user ID
	userID, err := helpers.GetUserID(c)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Get item ID
	id, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid item id"})
		return
	}

	// Check authorization
	res, err := db.AuthorizeEditDeleteItem(c, id, userID)
	if err != nil || !res {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized"})
		return
	}

	// Get image URLs for deletion from S3
	imageURLs, err := db.DeleteAllImageURIs(c, imagesTableName, id)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch images"})
		return
	}

	// Delete item from main table
	_, err = config.DB.Exec(c, "DELETE FROM "+tableName+" WHERE id = $1", id)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to delete item"})
		return
	}

	// Delete images from database
	_, err = db.DeleteItemImages(c, imagesTableName, id)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to delete images from database"})
		return
	}

	// Delete images from S3
	s3Client := helpers.NewS3Client(os.Getenv("BUCKET_NAME"), os.Getenv("REGION"), os.Getenv("RESOURCE_URI"))
	if err := s3Client.DeleteImages(imageURLs); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to delete images from S3"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Item deleted successfully"})
}

// EditItemGenericHandler edits an existing item
func EditItemGenericHandler(c *gin.Context, tableName string) {
	if err := validateControllerTableName(tableName); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Get user ID
	userID, err := helpers.GetUserID(c)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Get item ID
	itemID, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid item id"})
		return
	}

	// Check authorization
	res, err := db.AuthorizeEditDeleteItem(c, itemID, userID)
	if err != nil || !res {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized"})
		return
	}

	// Parse form data
	var formData map[string]interface{}
	if err := json.NewDecoder(c.Request.Body).Decode(&formData); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid form data"})
		return
	}

	// Update item
	if _, err := db.UpdateInTable(c, tableName, itemID, formData); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to edit item"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Item updated successfully"})
}

// SearchItemsGenericHandler searches for items
func SearchItemsGenericHandler(c *gin.Context, tableName, imagesTableName string) {
	if err := validateControllerTableName(tableName); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}
	if err := validateControllerTableName(imagesTableName); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	query := c.Query("query")

	// Search items
	items, err := db.SearchItems(c, tableName, query)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch items"})
		return
	}

	var itemIDs []int
	for _, item := range items {
		itemIDs = append(itemIDs, item["id"].(int))
	}

	// Fetch image URLs
	imageRows, err := db.GetSomeImageURIs(c, imagesTableName, itemIDs)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch images"})
		return
	}

	// Organize images by item ID
	imageDict := make(map[int][]string)
	for _, img := range imageRows {
		imageDict[img.ItemID] = append(imageDict[img.ItemID], img.ImageURL)
	}

	// Build response
	var response []map[string]interface{}
	for _, item := range items {
		itemID := item["id"].(int)
		response = append(response, map[string]interface{}{
			"id":               itemID,
			"item_name":        item["item_name"],
			"item_description": item["item_description"],
			"user_id":          item["user_id"],
			"created_at":       item["created_at"],
			"images":           imageDict[itemID],
		})
	}

	c.JSON(http.StatusOK, response)
}
