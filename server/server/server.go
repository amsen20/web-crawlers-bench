package server

import (
	"fmt"
	"html/template"
	"net/http"

	"github.com/gin-contrib/cors"
	"github.com/gin-gonic/gin"
)

func StartServer() {
	if !DEBUG {
		gin.SetMode(gin.ReleaseMode)
	}
	r := gin.Default()
	r.LoadHTMLFiles("./server/template.html")
	r.Use(cors.Default())

	r.GET("/page/:id", func(c *gin.Context) {
		idStr := c.Param("id")
		var id int
		fmt.Sscanf(idStr, "%d", &id)
		c.HTML(http.StatusOK, "template.html", gin.H{
			"content": template.HTML(generateContent(id)),
		})
	})

	r.Run(fmt.Sprintf("0.0.0.0:%d", PORT))
}
