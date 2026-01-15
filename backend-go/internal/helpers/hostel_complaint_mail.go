package helpers

import (
	"fmt"
	"net/smtp"
	"os"
	"path/filepath"
	"strings"
	"text/template"
	"time"

	"github.com/jordan-wright/email"
)

//sends an email for hostel complaints
func SendHostelComplaintEmail(receiver, mailType string, data map[string]interface{}) error {
	// Copy of complaint map
	emailData := make(map[string]interface{})
	for k, v := range data {
		emailData[k] = v
	}

	// Modify the format of created_at
	if t, ok := emailData["created_at"].(time.Time); ok {
		emailData["created_at"] = t.Format("02 Jan 2006, 03:04 PM")
	}

	// Add status color logic
	status, _ := emailData["complaint_status"].(string)
	statusLower := strings.ToLower(status)

	if statusLower == "resolved" {
		emailData["status_color"] = "#28a745" // Green
	} else if statusLower == "on going" || statusLower == "ongoing" {
		emailData["status_color"] = "#ffc107" // Orange/Yellow
	} else {
		emailData["status_color"] = "#007bff" // Blue default
	}


	// Extract Location and Issue
	if complaintData, ok := emailData["complaint_data"].(map[string]interface{}); ok {
		for k, v := range complaintData {
			if k == "furniture_type" || strings.HasSuffix(k, "_location") {
				emailData["Location"] = v
			} else if strings.HasSuffix(k, "_issue") {
				emailData["Issue"] = v
			}
		}
	}

	// Parse subject and body
	subject, err := ParseComplaintTemplate(fmt.Sprintf("internal/templates/%s/subject.txt", mailType), emailData)
	if err != nil {
		return err
	}

	body, err := ParseComplaintTemplate(fmt.Sprintf("internal/templates/%s/body.html", mailType), emailData)
	if err != nil {
		return err
	}

	// Load email and password from environment variables
	emailAddress := os.Getenv("HOSTEL_COMPLAINT_EMAIL")
	emailPassword := os.Getenv("HOSTEL_COMPLAINT_EMAIL_PASSWORD")

	e := email.NewEmail()
	e.From = emailAddress
	e.To = []string{receiver}
	e.Subject = subject
	e.HTML = []byte(body)

	err = e.Send("smtp.gmail.com:587", smtp.PlainAuth("", emailAddress, emailPassword, "smtp.gmail.com"))
	if err != nil {
		return err
	}
	return nil
}

//parses a template file with helper functions
func ParseComplaintTemplate(filePath string, data map[string]interface{}) (string, error) {
	funcMap := template.FuncMap{
		"formatKey": func(key string) string {
			key = strings.ReplaceAll(key, "_", " ")
			
			// Title Case
			words := strings.Fields(key)
			for i, w := range words {
				if len(w) > 0 {
					words[i] = strings.ToUpper(w[:1]) + w[1:]
				}
			}
			return strings.Join(words, " ")
		},
	}

	fileName := filepath.Base(filePath)

	tmpl, err := template.New(fileName).Funcs(funcMap).ParseFiles(filePath)
	if err != nil {
		return "", err
	}

	var builder strings.Builder
	err = tmpl.Execute(&builder, data)
	if err != nil {
		return "", err
	}
	return builder.String(), nil
}
