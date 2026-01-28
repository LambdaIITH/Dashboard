package worker

import (
	"context"
	"fmt"
	"time"

	"github.com/LambdaIITH/Dashboard/backend/config"
	"github.com/LambdaIITH/Dashboard/backend/internal/db"
	"github.com/LambdaIITH/Dashboard/backend/internal/helpers"
)

func StartRetryWorker() {
	ticker := time.NewTicker(10 * time.Minute)
	defer ticker.Stop()

	// Run immediately on start
	go processUnsyncedComplaints()

	for range ticker.C {
		processUnsyncedComplaints()
	}
}

func processUnsyncedComplaints() {
	ctx := context.Background()
	
	// Fetch unsynced complaints
	complaints, err := db.GetUnsyncedComplaints(ctx, config.DB)
	if err != nil {
		fmt.Printf("Error fetching unsynced complaints: %v\n", err)
		return
	}

	if len(complaints) == 0 {
		return
	}

	for _, complaint := range complaints {

		// Try to sync
		err := helpers.TriggerComplaintWebhook(complaint)
		
		complaintID := complaint["id"].(int64)

		if err == nil {
			// Success
			_ = db.MarkComplaintAsSynced(ctx, config.DB, complaintID)
		} else {
			// Failure
			_ = db.IncrementSyncAttempts(ctx, config.DB, complaintID)
		}
	}
}
