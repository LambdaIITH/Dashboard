package controller

import (
	"github.com/gin-gonic/gin"
)

/*
AddItemHandler handles the addition of a new lost item.
It uploads the images to S3 and saves the image URLs in the database.
*/
func AddItemHandler(c *gin.Context) {
	AddItemGenericHandler(c, "lost", "lost_images")
}

/*
GetAllItemsHandler fetches all the lost items from the database and returns them as a JSON response.
*/
func GetAllItemsHandler(c *gin.Context) {
	GetAllItemsGenericHandler(c, "lost", "lost_images")
}

/*
GetItemByIdHandler fetches a particular lost item by its ID and returns it as a JSON response.
*/
func GetItemByIdHandler(c *gin.Context) {
	GetItemByIDGenericHandler(c, "lost", "lost_images")
}

func DeleteItemHandler(c *gin.Context) {
	DeleteItemGenericHandler(c, "lost", "lost_images")
}

/*
EditItemHandler handles the editing of a lost item.
It edits the images in S3 and updates the image URLs in the database.
*/
func EditItemHandler(c *gin.Context) {
	EditItemGenericHandler(c, "lost")
}

/*
SearchItemHandler fetches the lost items matching the query and returns them as a JSON response.
*/
func SearchItemHandler(c *gin.Context) {
	SearchItemsGenericHandler(c, "lost", "lost_images")
}
