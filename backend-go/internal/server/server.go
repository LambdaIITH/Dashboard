package server

import (
	"Dashboard/internal/auth"
	"Dashboard/internal/database"
	"Dashboard/internal/server/routes" // Import the routes
	"fmt"
	"net/http"
	"time"

	"github.com/gin-gonic/gin"
)

type Server struct {
	port int

	db database.Service
}

func (s *Server) RegisterRoutes() http.Handler {
	r := gin.Default()

	// Register routes from different files
	r.GET("/health", routes.HealthHandler)

	auth.SetupAuthRoutes(r)

	protected := r.Group("/protected")

	protected.Use(auth.AuthMiddleware())

	routes.SetupLostRouter(protected)

	return r
}

func NewServer() *http.Server {
	// port, _ := strconv.Atoi(os.Getenv("PORT"))
	// port, _ := strconv.Atoi(os.Getenv("8000"))
	NewServer := &Server{
		port: 8000,

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
