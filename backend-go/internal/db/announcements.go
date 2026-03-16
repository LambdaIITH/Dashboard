package db

import (
	"fmt"

	"github.com/LambdaIITH/Dashboard/backend/config"
	"github.com/LambdaIITH/Dashboard/backend/internal/schema"
	"github.com/gin-gonic/gin"
)

func GetAnnouncementsFromDB(c *gin.Context, limit int, offset int) ([]schema.AnnouncementWithImages, error) {

	query := `SELECT (id ,title, description, createdat, createdby, tags, category, imageURI) FROM announcements ORDER BY createdat DESC LIMIT $1 OFFSET $2`
	rows, err := config.DB.Query(c, query, limit, offset)
	if err != nil {
		fmt.Printf("ERROR: Querying Announcement Tables")
		return nil, err
	}

	defer rows.Close()

	var announcements []schema.AnnouncementWithImages

	for rows.Next() {
		var announcement schema.AnnouncementWithImages
		if err := rows.Scan(&announcement); err != nil {
			fmt.Printf("Error: Scanning Rows for Announcements\n")
			return nil, err
		}
		announcements = append(announcements, announcement)
	}

	if rows.Err() != nil {
		fmt.Printf("Error: Getting Rows from announcements\n")
		return nil, rows.Err()
	}

	return announcements, nil
}

func PostAnnouncementToDB(c *gin.Context, announcement *schema.AnnouncementRequest) (int, error) {
	query := `INSERT INTO announcements (title, description, createdat, createdby, tags, category, imageURI) VALUES ($1, $2, $3, $4, $5, $6, $7)`
	_, err := config.DB.Exec(c, query, announcement.Title, announcement.Description, announcement.CreatedAt, announcement.CreatedBy, announcement.Tags, announcement.Category, "")

	if err != nil {
		fmt.Printf("ERROR: Adding Announcement to DB\n")
		return 0, err
	}

	query = `SELECT id FROM announcements WHERE createdat=$1 AND createdby=$2`
	rows := config.DB.QueryRow(c, query, announcement.CreatedAt, announcement.CreatedBy)
	var id int
	if rows.Scan(&id) != nil {
		fmt.Println("ERROR: Getting ID of added Annoucment by POST")
	}

	return id, nil
}

func AddAnnouncementImageURIToDB(c *gin.Context, id int, imageURI string) error {
	query := `UPDATE announcements SET imageURI=$1 WHERE id=$2`
	_, err := config.DB.Exec(c, query, imageURI, id)
	if err != nil {
		fmt.Printf("ERROR: Could not add image URI to the announcement")
		return err
	}
	return nil
}

func DeleteAnnouncementFromDB(c *gin.Context, id int) {
	query := `DELETE FROM announcements WHERE id=$1`
	_, err := config.DB.Exec(c, query, id)
	if err != nil {
		fmt.Println("ERROR: Deleting Announcement from DB")
		return
	}
	fmt.Printf("SUCCESS: Deleted Record from Announcement DB with id %v", id)
}
