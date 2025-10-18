package controller

import (
	"context"
	"encoding/json"
	"net/http"
	"os"
	"strconv"

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

	//create complaint in db
	complaintID, err := db.CreateComplaint(ctx, int64(userId), &req)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	//check for image uploads, upload to S3
	form, err := c.MultipartForm()
	if err == nil && form.File["images"] != nil {
		files := form.File["images"]
		if len(files) > 0 {
			s3Client := helpers.NewS3Client(os.Getenv("BUCKET_NAME"), os.Getenv("REGION"), os.Getenv("RESOURCE_URI"))

			imagePaths, err := s3Client.UploadImages(files, int(complaintID), "hostel-complaints")

			if err != nil {
				c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to upload images"})
				return
			}

			//add image uris to db
			err = db.AddComplaintImages(ctx, complaintID, imagePaths)
			if err != nil {
				c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to save images"})
				return
			}

		}

	}

	//fetching created complaint
	complaint, err := db.GetComplaintByID(ctx, complaintID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch complaint after creating"})
		return
	}

	c.JSON(http.StatusCreated, gin.H{
		"message":   "Complaint created Successfully",
		"complaint": complaint,
	})
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

	complaint, err := db.GetComplaintByID(ctx, id)
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

	complaints, err := db.GetUserComplaints(ctx, int64(userID))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, complaints)
}
