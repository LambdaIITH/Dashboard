package routes

import (
	"github.com/gin-gonic/gin"
	"net/http"
)

// HealthHandler handles the "/health" route.
func HealthHandler(c *gin.Context) {
	c.Status(http.StatusOK)
}
