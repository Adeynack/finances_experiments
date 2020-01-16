package controller

import (
	"strings"

	"github.com/gin-gonic/gin"
)

func readParameterListAll(c *gin.Context) bool {
	listAll := c.Query("list-all")
	return strings.ToLower(listAll) == "true"
}
