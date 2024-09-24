package server

import (
	"fmt"
	"net/http"
	"os"
	"strconv"
	"time"
	"github.com/gin-gonic/gin"
	"Dashboard/internal/server/routes"  // Import the routes
	"Dashboard/internal/database"
)

type Server struct {
	port int

	db database.Service
}


func (s *Server) RegisterRoutes() http.Handler {
	r := gin.Default()

	// Register routes from different files
	routes.SetupLostRouter(r)
	r.GET("/health", routes.HealthHandler)

	return r
}


func NewServer() *http.Server {
	port, _ := strconv.Atoi(os.Getenv("PORT"))
	NewServer := &Server{
		port: port,

		db: database.New(),
	}

	// Declare Server config
	server := &http.Server{
		Addr:         fmt.Sprintf(":%d", NewServer.port),
		Handler:      NewServer.RegisterRoutes(),
		IdleTimeout:  time.Minute,
		ReadTimeout:  10 * time.Second,
		WriteTimeout: 30 * time.Second,
	}


	return server
}
