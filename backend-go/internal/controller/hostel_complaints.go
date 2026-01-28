package controller

import (
	"context"
	"encoding/json"
	"net/http"
	"os"
	"fmt"
	"strconv"
	"strings"

	"github.com/LambdaIITH/Dashboard/backend/config"
	"github.com/LambdaIITH/Dashboard/backend/internal/db"
	"github.com/LambdaIITH/Dashboard/backend/internal/helpers"
	"github.com/LambdaIITH/Dashboard/backend/internal/schema"
	"github.com/gin-gonic/gin"
)

func CreateComplaintHandler(c *gin.Context) {
	userId, err := helpers.GetUserID(c)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized"})
		return
	}

	//parse form data
	formDataStr := c.PostForm("form_data")
	if formDataStr == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "form_data is empty."})
		return
	}

	var req schema.HostelComplaintRequest
	if err := json.Unmarshal([]byte(formDataStr), &req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid form_data"})
		return
	}

	//validating the complaintdescription
	if req.ComplaintDescription == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "complaint_description is required"})
		return
	}

	ctx := context.Background()

	// Start Transaction
	tx, err := config.DB.Begin(ctx)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to start transaction"})
		return
	}
	defer tx.Rollback(ctx)

	//create complaint in db
	complaintID, err := db.CreateComplaint(ctx, tx, int64(userId), &req)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	//check for image uploads, upload to S3
	form, err := c.MultipartForm()
	if err == nil && form.File["images"] != nil {
		files := form.File["images"]
		if len(files) > 0 {
			if len(files) > 5 {
				c.JSON(http.StatusBadRequest, gin.H{"error": "Cannot upload more than 5 images"})
				return
			}
			for _, file := range files {
				if file.Size > 10*1024*1024 { // 10MB limit
					c.JSON(http.StatusBadRequest, gin.H{"error": "One or more files exceed the 10MB size limit"})
					return
				}
			}

			s3Client := helpers.NewS3Client(os.Getenv("BUCKET_NAME"), os.Getenv("REGION"), os.Getenv("RESOURCE_URI"))

			imagePaths, err := s3Client.UploadImages(files, int(complaintID), "hostel-complaints")

			if err != nil {
				c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to upload images"})
				return
			}

			//add image uris to db
			err = db.AddComplaintImages(ctx, tx, complaintID, imagePaths)
			if err != nil {
				c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to save images"})
				return
			}

		}

	}

	//fetching created complaint
	complaint, err := db.GetComplaintByID(ctx, tx, complaintID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch complaint after creating"})
		return
	}

	// Commit Transaction
	if err := tx.Commit(ctx); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to commit transaction"})
		return
	}

	// Send response to user immediately
	c.JSON(http.StatusCreated, gin.H{
		"message":   "Complaint created Successfully",
		"complaint": complaint,
	})
	
	//Trigger Webhook for updating to sheet
	
	// Fetch user details to get phone number
	user := db.GetUser(ctx, int(userId))
	complaint["user_phone"] = user.PhoneNumber

	// parse roll number from email
	if strings.Contains(user.Email, "@") {
		parts := strings.Split(user.Email, "@")
		complaint["user_roll_no"] = parts[0]
	}

	go func(cmp map[string]interface{}) {
		err := helpers.TriggerComplaintWebhook(cmp)
		
		ctx := context.Background()

		if err != nil {
			if err.Error() == "HOSTEL_COMPLAINT_SHEET_WEBHOOK is not set" {
				fmt.Println("Skipping sheet sync marking: Webhook env var not set")
				return
			}
			_ = db.IncrementSyncAttempts(ctx, config.DB, cmp["id"].(int64))
		} else {
			//success
			_ = db.MarkComplaintAsSynced(ctx, config.DB, cmp["id"].(int64))
		}
	}(complaint)

	// Send Email
	go helpers.SendHostelComplaintEmail(user.Email, "hostel_complaint_created", complaint)
}

// get specific complaint
func GetComplaintByIDHandler(c *gin.Context) {
	idstr := c.Param("id")
	id, err := strconv.ParseInt(idstr, 10, 64)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid complaint ID"})
		return
	}

	ctx := context.Background()

	complaint, err := db.GetComplaintByID(ctx, config.DB, id)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, complaint)
}

// fetch the complaints for the current user
func GetUserComplaintsHandler(c *gin.Context) {
	userID, err := helpers.GetUserID(c)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized"})
		return
	}

	ctx := context.Background()

	complaints, err := db.GetUserComplaints(ctx, config.DB, int64(userID))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, complaints)
}

func AdminUpdateComplaintStatusHandler(c *gin.Context) {
	//verifying admin
	adminKey := c.GetHeader("X-Admin-Key")
	if adminKey == "" || adminKey != os.Getenv("HOSTEL_COMPLAINT_ADMIN_KEY") {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized"})
		return
	}

	// getting complaintID, new status, and validating them
	idStr := c.Param("id")
	id, err := strconv.ParseInt(idStr, 10, 64)
	if err != nil || id <= 0 {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid Complaint ID"})
		return
	}
	var m map[string]string
	if err := c.ShouldBindJSON(&m); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid JSON body"})
		return
	}

	v, ok := m["new_status"]
	status := strings.TrimSpace(v)
	if !ok || status == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Missing or empty new_status"})
		return
	}

	ctx := context.Background()

	// updating in db
	if err := db.UpdateComplaintStatus(ctx, config.DB, id, status); err != nil {
		if strings.Contains(err.Error(), "not found") {
			c.JSON(http.StatusNotFound, gin.H{"error": "Complaint not found"})
			return
		}
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to update status in db"})
		return
	}

	complaint, err := db.GetComplaintByID(ctx, config.DB, id)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Status update, but complaint fetch failed."})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message":   "Status updated",
		"complaint": complaint,
	})

	// Send Email
	go helpers.SendHostelComplaintEmail(complaint["user_email"].(string), "hostel_complaint_status_update", complaint)
}
