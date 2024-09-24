package routes

import (
	"net/http"
	"github.com/gin-gonic/gin"
)


func SetupLostRouter(r *gin.Engine){
	lost_handler := r.Group("/some_route")
	{
		lost_handler.GET("/lost", HelloWorldHandler);
	}
}

func HelloWorldHandler(c *gin.Context) {
	resp := make(map[string]string)
	resp["message"] = "Hello World"

	c.JSON(http.StatusOK, resp)
}
