package worker

import (
	"context"
	"fmt"
	"sync/atomic"
	"time"

	"github.com/LambdaIITH/Dashboard/backend/config"
	"github.com/LambdaIITH/Dashboard/backend/internal/db"
	"github.com/LambdaIITH/Dashboard/backend/internal/helpers"
)

var isProcessing int32

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
	if !atomic.CompareAndSwapInt32(&isProcessing, 0, 1) {
		return
	}
	defer atomic.StoreInt32(&isProcessing, 0)

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

		if err != nil {
			if err.Error() == "HOSTEL_COMPLAINT_SHEET_WEBHOOK is not set" {
				fmt.Println("Skipping sheet sync retry: Webhook env var not set")
				continue 
			}
			// Failure
			_ = db.IncrementSyncAttempts(ctx, config.DB, complaintID)
		} else {
			// Success
			_ = db.MarkComplaintAsSynced(ctx, config.DB, complaintID)
		}
	}
}
