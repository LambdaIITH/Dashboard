package controller

import (
	"encoding/json"
	"log"
	"net/http"
	"strconv"
	"time"

	db "github.com/LambdaIITH/Dashboard/backend/internal/db"
	helpers "github.com/LambdaIITH/Dashboard/backend/internal/helpers"
	schema "github.com/LambdaIITH/Dashboard/backend/internal/schema"
	"github.com/gin-gonic/gin"
)

func CheckAuth(c *gin.Context) {

	userID, err := helpers.GetUserID(c)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized"})
		return
	}

	email, err := db.GetUserEmail(c, userID)
	if err != nil {
		log.Printf("Error fetching user email: %v", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch user email"})
		return
	}

	phoneNumber, err := db.GetPhoneNumber(c, email)
	if err != nil {
		log.Printf("Error fetching phone number: %v", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch phone number"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"phone_number": phoneNumber,
	})
}

func CreateBooking(c *gin.Context) {
	var raw map[string]interface{}

	// Bind JSON to a raw map first
	if err := c.ShouldBindJSON(&raw); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid booking data"})
		return
	}

	// Convert time fields to UTC manually
	if startTimeStr, ok := raw["start_time"].(string); ok {
		parsedTime, err := time.Parse("2006-01-02T15:04:05", startTimeStr)
		if err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid start_time format"})
			return
		}
		raw["start_time"] = parsedTime.UTC()
	}

	if endTimeStr, ok := raw["end_time"].(string); ok {
		parsedTime, err := time.Parse("2006-01-02T15:04:05", endTimeStr)
		if err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid end_time format"})
			return
		}
		raw["end_time"] = parsedTime.UTC()
	}

	// Convert the updated map to JSON again
	jsonData, err := json.Marshal(raw)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Internal server error"})
		return
	}

	// Bind to the final struct after UTC conversion
	var booking schema.CabBooking
	if err := json.Unmarshal(jsonData, &booking); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Error parsing booking data"})
		return
	}

	// Get user ID from the context
	userID, err := helpers.GetUserID(c)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized"})
		return
	}

	// Fetch user email
	email, err := db.GetUserEmail(c, userID)
	if err != nil {
		log.Printf("Error fetching user email: %v", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch user email"})
		return
	}

	fromLocID, err := db.GetLocationID(c, booking.FromLoc)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch from_loc location"})
		return
	}
	toLocID, err := db.GetLocationID(c, booking.ToLoc)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to to_loc location"})
		return
	}

	bookingID, err := db.CreateBooking(c, booking.StartTime, booking.EndTime, booking.Capacity, &fromLocID, &toLocID, email, booking.Comments)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create booking"})
		return
	}

	// Add traveller
	err = db.AddTraveller(c, email, bookingID, booking.Comments)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to add traveller"})
		return
	}

	// Send email notification
	err = helpers.SendEmail(email, "create", bookingID, map[string]interface{}{})
	if err != nil {
		log.Printf("Error sending email notification: %v", err)
	}

	// Respond with booking ID
	c.JSON(http.StatusCreated, gin.H{"message": "Booking created successfully"})
}

func UpdateBooking(c *gin.Context) {
	// Extract the booking ID from the path parameter
	bookingID, err := strconv.Atoi(c.Param("booking_id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid booking ID"})
		return
	}

	var raw map[string]interface{}

	// Bind JSON to a raw map first
	if err := c.ShouldBindJSON(&raw); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid booking data"})
		return
	}

	// Convert time fields to UTC manually
	if startTimeStr, ok := raw["start_time"].(string); ok {
		parsedTime, err := time.Parse("2006-01-02T15:04:05", startTimeStr)
		if err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid start_time format"})
			return
		}
		raw["start_time"] = parsedTime.UTC()
	}

	if endTimeStr, ok := raw["end_time"].(string); ok {
		parsedTime, err := time.Parse("2006-01-02T15:04:05", endTimeStr)
		if err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid end_time format"})
			return
		}
		raw["end_time"] = parsedTime.UTC()
	}

	// Convert the updated map to JSON again
	jsonData, err := json.Marshal(raw)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Internal server error"})
		return
	}

	// Bind to the final struct after UTC conversion
	var patch schema.CabBooking
	if err := json.Unmarshal(jsonData, &patch); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Error parsing booking data"})
		return
	}

	// Get user ID from the context
	userID, err := helpers.GetUserID(c)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized"})
		return
	}

	// Fetch user email
	email, err := db.GetUserEmail(c, userID)
	if err != nil {
		log.Printf("Error fetching user email: %v", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch user email"})
		return
	}

	ownerEmail, err := db.GetOwnerEmail(c, bookingID)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid booking ID"})
		return
	}

	if ownerEmail != email {
		c.JSON(http.StatusForbidden, gin.H{"error": "Unauthorized"})
		return
	}

	// Update booking
	err = db.UpdateBooking(c, bookingID, patch.StartTime, patch.EndTime)
	if err != nil {
		log.Printf("Error updating booking: %v", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to update booking"})
		return
	}

	// Commit transaction if applicable
	c.JSON(http.StatusOK, gin.H{"message": "Booking updated successfully"})
}

func UserBookings(c *gin.Context) {
	// Get user ID from the context
	userID, err := helpers.GetUserID(c)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized"})
		return
	}

	// Fetch user email
	email, err := db.GetUserEmail(c, userID)
	if err != nil {
		log.Printf("Error fetching user email: %v", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch user email"})
		return
	}

	// Fetch past and future bookings
	pastBookings, err := db.GetUserPastBookings(c, email)
	if err != nil {
		log.Printf("Error fetching past bookings: %v", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch past bookings"})
		return
	}

	futureBookings, err := db.GetUserFutureBookings(c, email)
	if err != nil {
		log.Printf("Error fetching future bookings: %v", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch future bookings"})
		return
	}

	pastBookingsProcessed, err := helpers.GetBookings(c, pastBookings)
	if err != nil {
		log.Printf("Error fetching past bookings: %v", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch past bookings"})
		return
	}
	futureBookingsProcessed, err := helpers.GetBookings(c, futureBookings)
	if err != nil {
		log.Printf("Error fetching future bookings: %v", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch future bookings"})
		return
	}
	// Construct response
	response := gin.H{
		"past_bookings":   pastBookingsProcessed,
		"future_bookings": futureBookingsProcessed,
	}
	c.JSON(http.StatusOK, response)
}

func UserRequests(c *gin.Context) {
	// Get user ID from the context
	userID, err := helpers.GetUserID(c)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized"})
		return
	}

	// Fetch user email
	email, err := db.GetUserEmail(c, userID)
	if err != nil {
		log.Printf("Error fetching user email: %v", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch user email"})
		return
	}

	// Fetch pending requests
	pendingRequests, err := db.GetUserPendingRequests(c, email)
	if err != nil {
		log.Printf("Error fetching pending requests: %v", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch pending requests"})
		return
	}

	// Construct response
	response := gin.H{
		"pending_requests": pendingRequests,
	}
	c.JSON(http.StatusOK, response)
}

func SearchBookings(c *gin.Context) {
	// Extract query parameters
	fromLoc := c.Query("from_loc")
	toLoc := c.Query("to_loc")

	// Validate and parse locations
	var fromLocID, toLocID int
	var err error
	if fromLoc != "" {
		fromLocID, err = db.GetLocationID(c, fromLoc)
		if err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid from_loc value"})
			return
		}
	}
	if toLoc != "" {
		toLocID, err = db.GetLocationID(c, toLoc)
		if err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid to_loc value"})
			return
		}
	}

	// Validate that both or neither locations are provided
	if (fromLoc != "" && toLoc == "") || (fromLoc == "" && toLoc != "") {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Both from_loc and to_loc must be provided or omitted"})
		return
	}

	// Parse start_time and end_time with validation
	startTimeStr := c.Query("start_time")
	endTimeStr := c.Query("end_time")

	const layoutNoTZ = "2006-01-02T15:04:05"

	var startTime, endTime time.Time

	// Parse start_time
	if startTimeStr != "" {
		// Parsing without timezone and assuming UTC
		startTime, err = time.Parse(layoutNoTZ, startTimeStr)
		if err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid start_time. Expected format: RFC3339 or 'YYYY-MM-DDTHH:MM:SS'"})
			return
		}
	} else {
		startTime = time.Date(1970, 1, 1, 0, 0, 0, 0, time.UTC)
	}

	// Parse end_time
	if endTimeStr != "" {
		// Parsing without timezone and assuming UTC
		endTime, err = time.Parse(layoutNoTZ, endTimeStr)
		if err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid end_time. Expected format: RFC3339 or 'YYYY-MM-DDTHH:MM:SS'"})
			return
		}
	} else {
		endTime = time.Date(2100, 1, 1, 0, 0, 0, 0, time.UTC)
	}

	// Normalize times to UTC
	startTime = startTime.UTC()
	endTime = endTime.UTC()

	// Query database based on parameters
	var res []map[string]interface{}
	if fromLocID == 0 && toLocID == 0 {
		res, err = db.FilterTimes(c, startTime, endTime)
	} else {
		res, err = db.FilterAll(c, fromLocID, toLocID, startTime, endTime)
	}

	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to retrieve bookings"})
		return
	}

	var bookings []map[string]interface{}
	bookings, err = helpers.GetBookings(c, res)

	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to retrieve bookings"})
		return
	}

	c.JSON(http.StatusOK, bookings)
}

func RequestToJoinBooking(c *gin.Context) {
	// Extract booking ID from path parameter
	bookingID, err := strconv.Atoi(c.Param("booking_id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid booking ID"})
		return
	}

	// Parse JoinBooking struct from request body
	var joinBooking schema.CabBooking
	if err := c.ShouldBindJSON(&joinBooking); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid join booking data"})
		return
	}

	// Get user ID from context
	userID, err := helpers.GetUserID(c)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized"})
		return
	}

	// Fetch user email
	email, err := db.GetUserEmail(c, userID)
	if err != nil {
		log.Printf("Error fetching user email: %v", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch user email"})
		return
	}

	// Check if the booking exists and is not owned by the requester
	ownerEmail, err := db.GetOwnerEmail(c, bookingID)
	if err != nil || ownerEmail == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid ride ID"})
		return
	}
	if ownerEmail == email {
		c.JSON(http.StatusBadRequest, gin.H{"error": "You cannot join your own ride"})
		return
	}

	// Check if the cab is full
	isCabFull, err := db.IsCabFull(c, bookingID)
	if isCabFull {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Ride is full"})
		return
	}

	// Check if a request already exists
	requestStatus, err := db.GetRequestStatus(c, bookingID, email)
	if err == nil {
		var detail string
		switch requestStatus {
		case "pending":
			detail = "Request already sent"
		case "accepted":
			detail = "You are already a traveller"
		case "cancelled":
			detail = "Request already cancelled"
		case "rejected":
			detail = "Request already rejected"
		default:
			detail = "Unknown request status"
		}
		c.JSON(http.StatusBadRequest, gin.H{"error": detail})
		return
	}

	// Create a new request
	err = db.CreateRequest(c, bookingID, email, joinBooking.Comments)
	if err != nil {
		log.Printf("Error creating request: %v", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create request"})
		return
	}

	// Send email to owner
	phone, _ := db.GetPhoneNumber(c, email)
	requesterName, _ := db.GetName(c, email)
	err = helpers.SendEmail(
		ownerEmail,
		"request",
		bookingID,
		map[string]interface{}{
			"x_requester_name":  requesterName,
			"x_requester_phone": phone,
			"x_requester_email": email,
		},
	)
	if err != nil {
		log.Printf("Error sending email: %v", err)
	}

	c.JSON(http.StatusOK, gin.H{"message": "Request sent successfully"})
}

// DELETE /bookings/:booking_id/request
func DeleteRequest(c *gin.Context) {
	bookingID, err := strconv.Atoi(c.Param("booking_id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid booking ID"})
		return
	}

	userID, err := helpers.GetUserID(c)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized"})
		return
	}

	email, err := db.GetUserEmail(c, userID)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized"})
		return
	}

	// Check if there is a pending request
	requestStatus, err := db.GetRequestStatus(c, bookingID, email)
	if requestStatus != "pending" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "No pending request found"})
		return
	}

	// Try to delete the request
	err = db.DeleteRequest(c, bookingID, email)
	if err != nil {
		log.Printf("Error deleting request: %v", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to delete request"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Request deleted successfully"})
}

// POST /bookings/:booking_id/accept
func AcceptRequest(c *gin.Context) {
	bookingID, err := strconv.Atoi(c.Param("booking_id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid booking ID"})
		return
	}
	// Parse the RequestResponse object from the request body
	var request schema.RequestResponse
	if err := c.ShouldBindJSON(&request); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid request data"})
		return
	}
	userID, err := helpers.GetUserID(c)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized"})
		return
	}

	email, err := db.GetUserEmail(c, userID)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized"})
		return
	}

	ownerEmail, err := db.GetOwnerEmail(c, bookingID)
	if ownerEmail == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Booking does not exist"})
		return
	} else if ownerEmail != email {
		c.JSON(http.StatusForbidden, gin.H{"error": "You are not the owner of this booking"})
		return
	}

	isCabFull, err := db.IsCabFull(c, bookingID)
	if isCabFull {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Cab is already full"})
		return
	}

	status, err := db.GetRequestStatus(c, bookingID, request.RequesterEmail)
	if status != "pending" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "No pending request found"})
		return
	}

	// Accept request and add traveller
	comments, err := db.UpdateRequest(c, bookingID, request.RequesterEmail, "accepted")
	if err != nil {
		log.Printf("Error updating request: %v", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to accept request"})
		return
	}

	err = db.AddTraveller(c, request.RequesterEmail, bookingID, comments)
	if err != nil {
		log.Printf("Error adding traveller: %v", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to add traveller"})
		return
	}

	// Send acceptance email
	err = helpers.SendEmail(request.RequesterEmail, "accept", bookingID, map[string]interface{}{})
	if err != nil {
		log.Printf("Error sending email: %v", err)
	}

	// Notify other travellers
	name, err := db.GetName(c, request.RequesterEmail)
	if err != nil {
		log.Printf("Error fetching traveller user email: %v", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch user email"})
		return
	}

	phone, err := db.GetPhoneNumber(c, request.RequesterEmail)
	if err != nil {
		log.Printf("Error fetching traveller phone number: %v", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch phone number"})
		return
	}

	travellers, err := db.GetTravellers(c, bookingID)
	for _, traveller := range travellers {
		travellerEmail := traveller.Email
		if travellerEmail == request.RequesterEmail {
			continue
		}

		err = helpers.SendEmail(travellerEmail, "accept_notif", bookingID, map[string]interface{}{
			"x_accepted_email": request.RequesterEmail,
			"x_accepted_name":  name,
			"x_accepted_phone": phone,
		})
		if err != nil {
			log.Printf("Error sending notification email: %v", err)
		}
	}

	c.JSON(http.StatusOK, gin.H{"message": "Request accepted successfully"})
}

// POST /bookings/:booking_id/reject
func RejectRequest(c *gin.Context) {
	bookingID, err := strconv.Atoi(c.Param("booking_id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid booking ID"})
		return
	}
	// Parse the RequestResponse object from the request body
	var request schema.RequestResponse
	if err := c.ShouldBindJSON(&request); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid request data"})
		return
	}

	userID, err := helpers.GetUserID(c)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized"})
		return
	}

	email, err := db.GetUserEmail(c, userID)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized"})
		return
	}

	ownerEmail, err := db.GetOwnerEmail(c, bookingID)
	if ownerEmail == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Ride does not exist"})
		return
	} else if ownerEmail != email {
		c.JSON(http.StatusForbidden, gin.H{"error": "You are not the owner of this booking"})
		return
	}

	status, err := db.GetRequestStatus(c, bookingID, request.RequesterEmail)
	if status != "pending" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "No pending request found"})
		return
	}

	// Reject the request
	_, err = db.UpdateRequest(c, bookingID, request.RequesterEmail, "rejected")
	if err != nil {
		log.Printf("Error rejecting request: %v", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to reject request"})
		return
	}

	// Send rejection email
	err = helpers.SendEmail(request.RequesterEmail, "reject", bookingID, map[string]interface{}{})
	if err != nil {
		log.Printf("Error sending rejection email: %v", err)
	}

	c.JSON(http.StatusOK, gin.H{"message": "Request rejected successfully"})
}

// DELETE /bookings/:booking_id
func DeleteExistingBooking(c *gin.Context) {
	bookingID, err := strconv.Atoi(c.Param("booking_id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid booking ID"})
		return
	}

	userID, err := helpers.GetUserID(c)
	email, err := db.GetUserEmail(c, userID)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized"})
		return
	}

	ownerEmail, err := db.GetOwnerEmail(c, bookingID)
	if ownerEmail == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Booking does not exist"})
		return
	} else if ownerEmail != email {
		c.JSON(http.StatusForbidden, gin.H{"error": "You are not the owner of this booking"})
		return
	}

	// Notify travellers and delete the booking
	travellers, err := db.GetTravellers(c, bookingID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch travellers"})
		return
	}

	for _, traveller := range travellers {
		err = helpers.SendEmail(traveller.Email, "delete_notif", bookingID, map[string]interface{}{})
		if err != nil {
			log.Printf("Error sending notification email to traveller: %v", err)
		}
	}

	err = db.DeleteBooking(c, bookingID)
	if err != nil {
		log.Printf("Error deleting booking: %v", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to delete booking"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Booking deleted successfully"})
}

// DELETE /bookings/:booking_id/self
func ExitBooking(c *gin.Context) {
	bookingID, err := strconv.Atoi(c.Param("booking_id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid booking ID"})
		return
	}

	userID, err := helpers.GetUserID(c)
	email, err := db.GetUserEmail(c, userID)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized"})
		return
	}

	ownerEmail, err := db.GetOwnerEmail(c, bookingID)
	switch ownerEmail {
	case "":
		c.JSON(http.StatusBadRequest, gin.H{"error": "Ride does not exist"})
		return
	case email:
		c.JSON(http.StatusBadRequest, gin.H{"error": "Owner cannot exit a ride, but you can delete it"})
		return
	}

	// Remove traveller from booking
	err = db.DeleteParticularTraveller(c, bookingID, email, ownerEmail)
	if err != nil {
		log.Printf("Error exiting booking: %v", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to exit booking"})
		return
	}

	// Send confirmation email to exiting user
	err = helpers.SendEmail(email, "exit", bookingID, map[string]interface{}{})
	if err != nil {
		log.Printf("Error sending exit confirmation email: %v", err)
	}

	// Notify remaining travellers
	name, err := db.GetName(c, email)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch user name"})
		return
	}
	travellers, err := db.GetTravellers(c, bookingID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch travellers"})
		return
	}
	for _, traveller := range travellers {
		err = helpers.SendEmail(traveller.Email, "exit_notif", bookingID, map[string]interface{}{
			"x_exited_email": email,
			"x_exited_name":  name,
		})
		if err != nil {
			log.Printf("Error sending exit notification email: %v", err)
		}
	}

	c.JSON(http.StatusOK, gin.H{"message": "Exited booking successfully"})
}
