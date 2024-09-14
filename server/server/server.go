package server

import (
	"fmt"
	"html/template"
	"io/ioutil"
	"math/rand"
	"net/http"
	"time"

	"github.com/gin-contrib/cors"
	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
)

func StartServer() {
	if !DEBUG {
		gin.SetMode(gin.ReleaseMode)
	}

	templateContent := generateTemplateContent()

	r := gin.Default()
	r.LoadHTMLFiles("./server/template.html")
	r.Use(cors.Default())

	r.GET("/page/:id", func(c *gin.Context) {
		idStr := c.Param("id")
		var id int64
		fmt.Sscanf(idStr, "%d", &id)

		delay := MEAN_ADDITIONAL_DELAY + STANDARD_DERIVATIVE_DELAY*rand.NormFloat64()
		time.Sleep(time.Duration(delay) * time.Millisecond)

		c.HTML(http.StatusOK, "template.html", gin.H{
			"content": template.HTML(generateContent(id, templateContent)),
		})
	})

	r.GET("/http", func(c *gin.Context) {
		randomString := uuid.New().String()
		c.String(http.StatusOK, randomString)
	})

	r.POST("/http/echo", func(c *gin.Context) {
		body, _ := ioutil.ReadAll(c.Request.Body)
		c.String(http.StatusOK, string(body))
	})

	r.Run(fmt.Sprintf("0.0.0.0:%d", PORT))
}
