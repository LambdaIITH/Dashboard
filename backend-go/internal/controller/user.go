package controller

import (
	"net/http"

	db "github.com/LambdaIITH/Dashboard/backend/internal/db"
	helpers "github.com/LambdaIITH/Dashboard/backend/internal/helpers"
	schema "github.com/LambdaIITH/Dashboard/backend/internal/schema"
	"github.com/gin-gonic/gin"
)

func User(c *gin.Context) {
	userId, err := helpers.GetUserID(c)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized"})
	}

	userDetails := db.GetUser(c, userId)
	c.JSON(http.StatusOK, userDetails)

}

func UpdateUser(c *gin.Context) {
	userId, err := helpers.GetUserID(c)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized"})
	}

	var userUpdate schema.UserUpdate
	if err := c.ShouldBindJSON(&userUpdate); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	userDetails := db.UpdatePhone(c, userId, userUpdate.PhoneNumber)
	c.JSON(http.StatusOK, userDetails)
}

func UpdateUserFCMToken(c *gin.Context) {
	userId, err := helpers.GetUserID(c)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized"})
	}

	var fcmTokenUpdate schema.FCMTokensUpdate
	if err := c.ShouldBindJSON(&fcmTokenUpdate); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	if db.UpsertFCMToken(c, userId, fcmTokenUpdate.Token, fcmTokenUpdate.DeviceType) {
		c.JSON(http.StatusOK, gin.H{"message": "FCM Token updated successfully"})
	} else {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to update FCM Token"})
	}
}
