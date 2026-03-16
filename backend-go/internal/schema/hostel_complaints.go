package schema

import (
	"mime/multipart"
	"time"
)

type HostelComplaint struct {
	ID                   int                    `db:"id"`
	UserID               int64                  `db:"user_id"`
	UserName             string                 `db:"user_name"`
	UserEmail            string                 `db:"user_email"`
	Hostel               string                 `db:"hostel"`
	RoomNumber           string                 `db:"room_number"`
	ComplaintDescription string                 `db:"complaint_description"`
	ComplaintData        map[string]interface{} `db:"complaint_data"`
	CreatedAt            time.Time              `db:"created_at"`
	ResolvedAt           time.Time              `db:"resolved_at"`
}

type HostelComplaintRequest struct {
	ResultHostel         string                  `json:"hostel"`
	ResultRoomNumber     string                  `json:"room_number"`
	ComplaintDescription string                  `json:"complaint_description"`
	ComplaintData        map[string]interface{}  `json:"complaint_data"`
	Images               []*multipart.FileHeader `json:"images"`
}

type HostelComplaintImage struct {
	ID          int64  `db:"id"`
	ComplaintId int64  `db:"complaint_id"`
	ImageURL    string `db:"image_url"`
}
