package controller

import (
	"encoding/json"
	"fmt"
	"net/http"
	"os"
	"strconv"

	"github.com/LambdaIITH/Dashboard/backend/config"
	found "github.com/LambdaIITH/Dashboard/backend/internal/db"
	helpers "github.com/LambdaIITH/Dashboard/backend/internal/helpers"
	schema "github.com/LambdaIITH/Dashboard/backend/internal/schema"

	"github.com/gin-gonic/gin"
)

func AddFoundItemHandler(c *gin.Context) {
	// Parsing the form data
	formData := c.PostForm("form_data")
	var formDataDict map[string]interface{}
	if err := json.Unmarshal([]byte(formData), &formDataDict); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid form data"})
		return
	}

	// Get and Verify the user ID
	userId, err := helpers.GetUserID(c)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": err.Error()})
		return
	}

	// Insert the form data into the found table
	result, err := found.InsertInFoundTable(c, formDataDict, userId)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to insert data"})
		return
	}
	
	fmt.Println("Inserted data:", result)

	// Upload the images to S3 and save the image URLs in the database
	form, err := c.MultipartForm()
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid file data"})
		return
	}
	
	files := form.File["images"]
	if len(files) > 0 {
		s3Client := helpers.NewS3Client(os.Getenv("BUCKET_NAME"), os.Getenv("REGION"), os.Getenv("RESOURCE_URI"))

		imagePaths, err := s3Client.UploadImages(files, result["id"].(int), "found")
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to upload images"})
			return
		}

		err = found.InsertFoundImages(c, imagePaths, result["id"].(int))
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to save image paths"})
			return
		}
	}
	c.JSON(http.StatusOK, gin.H{"message": "Data inserted successfully"})
}

func GetAllFoundItemsHandler(c *gin.Context) {
	// Fetch all the found items
	items, err := found.GetAllFoundItems(c)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to fetch items"})
		return
	}

	// Fetch the image URLs associated with the items
	rows, err := config.DB.Query(c, "SELECT item_id, image_url FROM found_images")
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to fetch images"})
		return
	}
	defer rows.Close()

	// Organize the image URLs by item ID
	imageDict := make(map[int][]string)
	for rows.Next() {
		var img schema.ImageURI
		if err := rows.Scan(&img.ItemID, &img.ImageURL); err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to scan images"})
			return
		}
		imageDict[img.ItemID] = append(imageDict[img.ItemID], img.ImageURL)
	}

	response := make([]map[string]any, 0, len(items))

	for _, item := range items {
		images := imageDict[item.ID]
		if images == nil {
			images = []string{}
		}

		itemData := map[string]any{
			"id":     item.ID,
			"name":   item.ItemName,
			"images": images,
		}
		response = append(response, itemData)
	}

	// Always return an array (empty if no items found)
	c.JSON(http.StatusOK, response)
}

func GetFoundItemByIdHandler(c *gin.Context) {
	// Fetch the item by its ID
	id, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid item ID"})
		return
	}
	item, err := found.GetParticularFoundItem(c, id)
	if err != nil {
		fmt.Println(err.Error())
		c.JSON(http.StatusNotFound, gin.H{"error": "Item not found"})
		return
	}

	// Fetch the image URLs associated with the item
	var imageURLs []string
	rows, err := config.DB.Query(c, "SELECT image_url FROM found_images WHERE item_id = $1", id)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch images"})
		return
	}
	defer rows.Close()

	// Construct the response
	for rows.Next() {
		var imageURL string
		if err := rows.Scan(&imageURL); err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to scan image URL"})
			return
		}
		imageURLs = append(imageURLs, imageURL)
	}
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

func DeleteFoundItemHandler(c *gin.Context) {
	// Get the user ID
	userID, err := helpers.GetUserID(c)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Get item ID from the request
	idStr := c.PostForm("item_id")
	
	id, err := strconv.Atoi(idStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid item id"})
		return
	}

	// Check if the user is authorized to delete the item
	res, err := found.AuthorizeEditDeleteItem(c, id, userID)
	if err != nil || !res {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized"})
		return
	}

	// Get the image URLs associated with the item
	imageURLs, err := found.DeleteAllImageURIsFromFound(c, id)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch images"})
		return
	}

	// Delete the item from the found table
	_, err = config.DB.Exec(c, "DELETE FROM found WHERE id = $1", id)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to delete item"})
		return
	}

	// Deletes the images uris from the 'found_images' table in the database
	_, err = found.DeleteAnItemImagesFromFound(c, id)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to delete images from database"})
		return
	}

	// Delete images from S3 storage
	s3Client := helpers.NewS3Client(os.Getenv("BUCKET_NAME"), os.Getenv("REGION"), os.Getenv("RESOURCE_URI"))
	if err := s3Client.DeleteImages(imageURLs); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to delete images from S3"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Item deleted successfully"})
}

func EditFoundItemHandler(c *gin.Context) {
	// Get the user ID
	userID, err := helpers.GetUserID(c)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Check if the user is authorized to edit the item
	itemID, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid item id"})
		return
	}
	res, err := found.AuthorizeEditDeleteItem(c, itemID, userID)
	if err != nil || !res {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized"})
		return
	}

	// Parse the form data
	var formData map[string]interface{}
	if err := json.NewDecoder(c.Request.Body).Decode(&formData); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid form data"})
		return
	}

	if _, err := found.UpdateInFoundTable(c, itemID, formData); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to edit item"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Item updated successfully"})
}

func SearchFoundItemHandler(c *gin.Context) {
	query := c.Query("query")

	// Fetch found items matching the query
	foundItems, err := found.SearchLostItemsFromFound(c, query)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch items"})
		return
	}

	var itemIDs []int
	for _, item := range foundItems {
		itemIDs = append(itemIDs, item.ID)
	}

	// Fetch image URLs associated with the items
	imageRows, err := found.GetSomeImgUrisFromFound(c, itemIDs)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch images"})
		return
	}

	// Organize the image URLs by item ID
	imageDict := make(map[int][]string)
	for _, img := range imageRows {
		imageDict[img.ItemID] = append(imageDict[img.ItemID], img.ImageURL)
	}

	// Construct the response
	var response []map[string]interface{}
	for _, item := range foundItems {
		response = append(response, map[string]interface{}{
			"id":               item.ID,
			"item_name":        item.ItemName,
			"item_description": item.ItemDescription,
			"user_id":          item.UserID,
			"created_at":       item.CreatedAt,
			"images":           imageDict[item.ID], // Add the images for this item
		})
	}
	c.JSON(http.StatusOK, response)
}
