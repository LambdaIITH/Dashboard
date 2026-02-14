package controller

import (
	"encoding/json"
	"fmt"
	"net/http"
	"os"
	"strconv"

	"github.com/LambdaIITH/Dashboard/backend/config"
	buyandsell "github.com/LambdaIITH/Dashboard/backend/internal/db"
	helpers "github.com/LambdaIITH/Dashboard/backend/internal/helpers"
	schema "github.com/LambdaIITH/Dashboard/backend/internal/schema"

	"github.com/gin-gonic/gin"
)

type BSResponse struct {
	ID              int      `json:"id"`
	ItemName        string   `json:"item_name"`
	ItemDescription string   `json:"item_description"`
	UserName        string   `json:"username"`
	UserEmail       string   `json:"user_email"`
	Images          []string `json:"image_urls"`
	SellingPrice    float64  `json:"selling_price"`
	CreatedAt       string   `json:"created_at"`
}

/*
AddSellingItemHandler handles the addition of a new marketplace item.
It uploads the images to S3 and saves the image URLs in the database.
*/
func AddSellingItemHandler(c *gin.Context) {
	// Step 1: Parse the form data
	formData := c.PostForm("form_data")
	var formDataDict map[string]interface{}
	if err := json.Unmarshal([]byte(formData), &formDataDict); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid form data"})
		return
	}

	// Step 2: Get the user ID
	userId, err := helpers.GetUserID(c)
	if err != nil {
		fmt.Println("ERROR IS HERE", err.Error())
		c.JSON(http.StatusUnauthorized, gin.H{"error": err.Error()})
		return
	}
	// Step 3: Insert the form data into the selling table
	currItem := schema.SellingItem{}

	currItem.ID, err = buyandsell.InsertInSellingTable(c, formDataDict, userId)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to insert data"})
		return
	}

	// Step 5: Upload the images to S3 and save the image URLs in the database
	form, err := c.MultipartForm()
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid file data"})
		return
	}

	files := form.File["images"]
	if len(files) > 0 {
		s3Client := helpers.NewS3Client(os.Getenv("BUCKET_NAME"), os.Getenv("REGION"), os.Getenv("RESOURCE_URI"))

		imagePaths, err := s3Client.UploadImages(files, currItem.ID, "selling")
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to upload images"})
			return
		}

		err = buyandsell.InsertSellingImages(c, imagePaths, currItem.ID)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to save image paths"})
			return
		}
	}

	// Step 6: Return the response
	c.JSON(http.StatusOK, gin.H{"message": "Data inserted successfully"})
}

/*
GetAllItemsHandler fetches all the lost items from the database and returns them as a JSON response.
*/
func GetAllSellingItemsHandler(c *gin.Context) {
	// Step 1: Fetch all the selling items
	items, err := buyandsell.GetAllSellingItems(c)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to fetch items"})
		return
	}

	// Step 2: Fetch the image URLs associated with the items
	rows, err := config.DB.Query(c, "SELECT item_id, image_url FROM selling_images")
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to fetch images"})
		return
	}
	defer rows.Close()

	// Step 3: Organize the image URLs by item ID
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

	c.JSON(http.StatusOK, response)
}

/*
GetItemByIdHandler fetches a particular selling item by its ID and returns it as a JSON response.
*/
func GetSellingItemByIdHandler(c *gin.Context) {
	// Step 1: Fetch the item by its ID
	id, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid item ID"})
		return
	}
	item, err := buyandsell.GetParticularSellingItem(c, id)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Item not found"})
		return
	}

	// Step 2: Fetch the image URLs associated with the item
	var imageURLs []string
	rows, err := config.DB.Query(c, "SELECT image_url FROM selling_images WHERE item_id = $1", id)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch images"})
		return
	}
	defer rows.Close()

	// Step 3: Construct the response
	for rows.Next() {
		var imageURL string
		if err := rows.Scan(&imageURL); err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to scan image URL"})
			return
		}
		imageURLs = append(imageURLs, imageURL)
	}

	// Check for errors after iterating through rows
	if err = rows.Err(); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Error iterating through image results"})
		return
	}

	// Initialize imageURLs as empty slice if nil
	if imageURLs == nil {
		imageURLs = []string{}
	}

	// Step 4: Return the response
	response := BSResponse{
		ID:              item.ID,
		ItemName:        item.ItemName,
		ItemDescription: item.ItemDescription,
		UserEmail:       item.UserEmail,
		UserName:        item.UserName,
		Images:          imageURLs,
		SellingPrice:    item.SellingPrice,
		CreatedAt:       item.CreatedAt.Format("2006-01-02 15:04:05"),
	}

	// Step 5: Return the response
	c.JSON(http.StatusOK, response)
}

func DeleteSellingItemHandler(c *gin.Context) {
	// Step 1: Get the user ID
	userID, err := helpers.GetUserID(c)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Step 2: Get item ID from the request
	// parsing from form data
	idStr := c.PostForm("item_id")

	id, err := strconv.Atoi(idStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid item id"})
		return
	}

	// Step 3: Check if the user is authorized to delete the item
	res, err := buyandsell.AuthorizeEditDeleteItem(c, id, userID)
	if err != nil || !res {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized"})
		return
	}

	// Step 4: Delete images associated with the item
	// Get the image URLs associated with the item
	imageURLs, err := buyandsell.DeleteAllImageUrisSelling(c, id)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch images"})
		return
	}

	// Step 5: Delete the item from the selling table
	_, err = config.DB.Exec(c, "DELETE FROM selling WHERE id = $1", id)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to delete item"})
		return
	}

	// Step 6: Delete the images from the database
	// This step deletes the item images from the 'selling_images' table in the database
	_, err = buyandsell.DeleteItemImagesFromSelling(c, id)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to delete images from database"})
		return
	}

	// Step 7: Delete images from S3 storage
	s3Client := helpers.NewS3Client(os.Getenv("BUCKET_NAME"), os.Getenv("REGION"), os.Getenv("RESOURCE_URI"))
	if err := s3Client.DeleteImages(imageURLs); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to delete images from S3"})
		return
	}

	// Step 8: Send a success response
	c.JSON(http.StatusOK, gin.H{"message": "Item deleted successfully"})
}

/*
EditItemHandler handles the editing of a lost item.
It edits the images in S3 and updates the image URLs in the database.
*/
func EditSellingItemHandler(c *gin.Context) {
	// Step 1: Get the user ID
	userID, err := helpers.GetUserID(c)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}
	// Step 2: Check if the user is authorized to edit the item
	// Get item ID from request body
	var requestData map[string]interface{}
	if err := json.NewDecoder(c.Request.Body).Decode(&requestData); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid request data"})
		return
	}

	itemIDFloat, ok := requestData["item_id"].(float64)
	if !ok {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Missing or invalid item_id"})
		return
	}
	itemID := int(itemIDFloat)

	res, err := buyandsell.AuthorizeEditDeleteItem(c, itemID, userID)
	if err != nil {
		return
	}

	if !res {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized"})
		return
	}

	// Step 3: Update the item with the provided data
	// Remove item_id from requestData before updating
	delete(requestData, "item_id")

	if _, err := buyandsell.UpdateInSellingTable(c, itemID, requestData); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to edit item"})
		return
	}

	// Step 4: Upload the images to S3 and save the image URLs in the database
	c.JSON(http.StatusOK, gin.H{"message": "Item updated successfully"})
}

/*
SearchItemHandler fetches the lost items matching the query and returns them as a JSON response.
*/
func SearchSellingItemHandler(c *gin.Context) {
	query := c.Query("query")

	// Step 1: Fetch selling items matching the query
	lostItems, err := buyandsell.SearchSellingItems(c, query)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch items"})
		return
	}

	var itemIDs []int
	for _, item := range lostItems {
		itemIDs = append(itemIDs, item.ID)
	}

	// Step 2: Fetch image URLs associated with the items
	imageRows, err := buyandsell.GetSomeImgUrisSelling(c, itemIDs)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch images"})
		return
	}

	// Step 3: Organize the image URLs by item ID
	imageDict := make(map[int][]string)
	for _, img := range imageRows {
		imageDict[img.ItemID] = append(imageDict[img.ItemID], img.ImageURL)
	}

	// Step 4: Construct the response
	var response []map[string]interface{}
	for _, item := range lostItems {
		response = append(response, map[string]interface{}{
			"id":               item.ID,
			"item_name":        item.ItemName,
			"item_description": item.ItemDescription,
			"user_id":          item.UserID,
			"created_at":       item.CreatedAt,
			"images":           imageDict[item.ID], // Add the images for this item
		})
	}

	// Step 5: Return the response with item details and images
	c.JSON(http.StatusOK, response)
}
