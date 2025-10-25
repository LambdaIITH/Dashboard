package controller

import (
	"fmt"
	"net/http"
	"strconv"
	"strings"
	"time"

	"github.com/LambdaIITH/Dashboard/backend/internal/db"
	"github.com/LambdaIITH/Dashboard/backend/internal/helpers"
	"github.com/LambdaIITH/Dashboard/backend/internal/schema"
	"github.com/gin-gonic/gin"
)

// Get all merchandise items
func GetItems(c *gin.Context) {
	items, err := db.GetAllMerchItems(c.Request.Context())
	if err != nil {
		fmt.Println("ERROR", err.Error())
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch merchandise items"})
		return
	}
	c.JSON(http.StatusOK, items)
}

// Get a single merchandise item
func GetItem(c *gin.Context) {
	itemID, err := strconv.Atoi(c.Param("item_id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid item ID"})
		return
	}

	item, err := db.GetMerchItem(c.Request.Context(), itemID)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Merchandise item not found"})
		return
	}

	c.JSON(http.StatusOK, item)
}

// Create an order
func CreateOrder(c *gin.Context) {
	userId, err := helpers.GetUserID(c)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": err.Error()})
		return
	}

	var orderRequest schema.Order
	if err := c.ShouldBindJSON(&orderRequest); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid input"})
		return
	}

	merch, err := db.GetMerchItem(c.Request.Context(), orderRequest.MerchID)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Merchandise item not found"})
		return
	}

	if merch.Deadline.Before(time.Now()) {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Order deadline has passed"})
		return
	}

	if orderRequest.IsOversized && !merch.IsOversized {
		c.JSON(http.StatusBadRequest, gin.H{"error": "This merchandise does not have an oversized option"})
		return
	}

	if merch.HasSizes {
		if orderRequest.Size == nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "Size is required for this merchandise"})
			return
		}

		validSize := false
		for _, size := range merch.AvailableSizes {
			if *orderRequest.Size == size.SizeName {
				validSize = true
				break
			}
		}

		if !validSize {
			var availableSizes []string
			for _, size := range merch.AvailableSizes {
				availableSizes = append(availableSizes, size.SizeName)
			}
			c.JSON(http.StatusBadRequest, gin.H{
				"error": fmt.Sprintf("Invalid size. Must be one of: %s", strings.Join(availableSizes, ", ")),
			})
			return
		}
	} else if orderRequest.Size != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "This merchandise does not have size options"})
		return
	}

	order := schema.Order{
		MerchID:       orderRequest.MerchID,
		UserID:        userId,
		Size:          orderRequest.Size,
		TransactionID: orderRequest.TransactionID,
		DisplayName:   orderRequest.DisplayName,
		Status:        false,
		IsOversized:   orderRequest.IsOversized,
	}

	orderID, err := db.CreateOrder(c.Request.Context(), order)
	if err != nil {
		fmt.Println("ERROR", err.Error())
		if strings.Contains(err.Error(), "duplicate transaction_id") {
			c.JSON(http.StatusConflict, gin.H{"error": "This transaction ID has already been used. Please verify and try again."})
			return
		}
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create order"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message":        "Order created successfully",
		"order_id":       orderID,
		"transaction_id": orderRequest.TransactionID,
		"payment_status": "completed",
	})
}

// Get user orders
func GetUserOrders(c *gin.Context) {
	userId, err := helpers.GetUserID(c)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": err.Error()})
		return
	}

	orders, err := db.GetUserOrders(c.Request.Context(), userId)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, orders)
}
