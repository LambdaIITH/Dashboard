package controller

import (
	"github.com/gin-gonic/gin"
)

func AddFoundItemHandler(c *gin.Context) {
	AddItemGenericHandler(c, "found", "found_images")
}

func GetAllFoundItemsHandler(c *gin.Context) {
	GetAllItemsGenericHandler(c, "found", "found_images")
}

func GetFoundItemByIdHandler(c *gin.Context) {
	GetItemByIDGenericHandler(c, "found", "found_images")
}

func DeleteFoundItemHandler(c *gin.Context) {
	DeleteItemGenericHandler(c, "found", "found_images")
}

func EditFoundItemHandler(c *gin.Context) {
	EditItemGenericHandler(c, "found")
}

func SearchFoundItemHandler(c *gin.Context) {
	SearchItemsGenericHandler(c, "found", "found_images")
}
