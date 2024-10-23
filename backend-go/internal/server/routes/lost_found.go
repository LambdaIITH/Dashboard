package routes

import (
	"net/http"

	"github.com/gin-gonic/gin"
)

func SetupLostRouter(rg *gin.RouterGroup) {
	rg.GET("/lost", HelloWorldHandler)
	rg.POST("/lost", HelloWorldHandler)
}

func HelloWorldHandler(c *gin.Context) {
	resp := make(map[string]string)
	resp["message"] = "Hello World"

	c.JSON(http.StatusOK, resp)
}
