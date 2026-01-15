package helpers

import (
	"bytes"
	"encoding/json"
	"fmt"
	"net/http"
	"os"
	"time"
)

type WebhookPayload struct {
	ID                   int64                  `json:"id"`
	UserID               int64                  `json:"user_id"`
	UserName             string                 `json:"user_name"`
	UserEmail            string                 `json:"user_email"`
	ComplaintDescription string                 `json:"complaint_description"`
	ComplaintData        map[string]interface{} `json:"complaint_data"`
	ComplaintStatus      string                 `json:"complaint_status"`
	Images               []string               `json:"images"`
	CreatedAt            time.Time              `json:"created_at"`
	ResolvedAt           interface{}            `json:"resolved_at"`
	HostelName           string                 `json:"hostel_name"`
	RoomNumber           string                 `json:"room_number"`
	UserPhone            string                 `json:"user_phone"`
	UserRollNo           string                 `json:"user_roll_no"`
	ComplaintType        string                 `json:"complaint_type"`
	ComplaintSubcategory string                 `json:"complaint_subcategory"`
	IssueType            string                 `json:"issue_type"`
}

func TriggerComplaintWebhook(complaint map[string]interface{}) error {
	webhookURL := os.Getenv("HOSTEL_COMPLAINT_SHEET_WEBHOOK")
	authKey := os.Getenv("HOSTEL_COMPLAINT_SHEET_TOKEN_SECRET")

	if webhookURL == "" {
		fmt.Println("Warning: HOSTEL_COMPLAINT_SHEET_WEBHOOK is not set. Skipping webhook.")
		return nil
	}

	//Get values from complaint map
	var payload WebhookPayload

	if v, ok := complaint["id"].(int64); ok {
		payload.ID = v
	}
	if v, ok := complaint["user_id"].(int64); ok {
		payload.UserID = v
	}
	if v, ok := complaint["user_name"].(string); ok {
		payload.UserName = v
	}
	if v, ok := complaint["user_email"].(string); ok {
		payload.UserEmail = v
	}
	if v, ok := complaint["complaint_description"].(string); ok {
		payload.ComplaintDescription = v
	}
	if v, ok := complaint["complaint_status"].(string); ok {
		payload.ComplaintStatus = v
	}
	if v, ok := complaint["images"].([]string); ok {
		payload.Images = v
	}
	if v, ok := complaint["created_at"].(time.Time); ok {
		payload.CreatedAt = v
	}

	//Extract fields from complaint_data
	if v, ok := complaint["complaint_data"].(map[string]interface{}); ok {
		payload.ComplaintData = v
		
		// Complaint Type
		if t, ok := v["complaint_type"].(string); ok {
			payload.ComplaintType = t
		} else if t, ok := complaint["complaint_type"].(string); ok {
			// Fallback if it's top level (though usually it's in data)
			payload.ComplaintType = t
		}

		// Subcategory Extraction
		// Pattern: "electrical_location", "civil_location", "furniture_type"
		for key, val := range v {
			if strVal, ok := val.(string); ok {
				if len(key) > 9 && key[len(key)-9:] == "_location" {
					payload.ComplaintSubcategory = strVal
				} else if key == "furniture_type" {
					payload.ComplaintSubcategory = strVal
				}
			}
		}

		// Issue Type Extraction
		// Pattern: "electrical_..._issue", "civil_..._issue"
		for key, val := range v {
			if strVal, ok := val.(string); ok {
				if len(key) > 6 && key[len(key)-6:] == "_issue" {
					payload.IssueType = strVal
				}
			}
		}
	} else {
		return fmt.Errorf("complaint_data is invalid or missing in webhook payload for ID %v", payload.ID)
	}

	if v, ok := complaint["user_phone"].(string); ok {
		payload.UserPhone = v
	}

	if v, ok := complaint["user_roll_no"].(string); ok {
		payload.UserRollNo = v
	}

	finalURL := fmt.Sprintf("%s?auth=%s", webhookURL, authKey)

	jsonData, err := json.Marshal(payload)
	if err != nil {
		return fmt.Errorf("error marshaling webhook payload: %w", err)
	}

	client := &http.Client{
		Timeout: 10 * time.Second,
	}

	req, err := http.NewRequest("POST", finalURL, bytes.NewBuffer(jsonData))
	if err != nil {
		return fmt.Errorf("error creating webhook request: %w", err)
	}
	req.Header.Set("Content-Type", "application/json")

	resp, err := client.Do(req)
	if err != nil {
		return fmt.Errorf("error executing webhook request: %w", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode >= 400 {
		return fmt.Errorf("webhook failed with status: %d", resp.StatusCode)
	}
	
	// Read response to check for logical error or success
	var res map[string]interface{}
	if err := json.NewDecoder(resp.Body).Decode(&res); err != nil {
		return fmt.Errorf("failed to decode apps script response (empty or invalid JSON): %w", err)
	}

	if val, ok := res["result"]; !ok || val != "success" {
		//return error message from apps script if it exists
		if errMsg, ok := res["error"]; ok {
			return fmt.Errorf("apps script returned error: %v", errMsg)
		}
		return fmt.Errorf("apps script did not return success. Response: %v", res)
	}
	
	fmt.Printf("Webhook sent successfully for Complaint ID %d\n", payload.ID)
	return nil
}
