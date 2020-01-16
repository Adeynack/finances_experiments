package controller

import (
	"fmt"
	"net/http"
	"strconv"

	"github.com/adeynack/finances-service-go/pkg/problem"
	"github.com/adeynack/finances-service-go/pkg/service"
	"github.com/gin-gonic/gin"
	"github.com/go-http-utils/headers"
)

// Typical problems related to books
var (
	probUnauthorizedOnBook = &problem.Problem{
		Status: http.StatusUnauthorized,
		Title:  "Insufficient rights on book",
	}
)

// writeProblem writes a HTTP response to the provided GIN context "c" with
// a ProblemJSON body, automatically setting the response's status code to
// the one in the problem object.
func writeProblem(c *gin.Context, problem *problem.Problem) {
	if problem.Title == "" {
		problem.Title = http.StatusText(problem.Status)
	}
	c.Header(headers.ContentType, "application/problem+json")
	c.JSON(problem.Status, problem)
}

func withUser(
	c *gin.Context,
	f func(c *gin.Context, user *service.UserInfo),
) {
	if val, ok := c.Get(keyUser); ok {
		if user, ok := val.(*service.UserInfo); ok && user != nil {
			f(c, user)
			return
		}
	}
	writeProblem(c, &problem.Problem{
		Status: http.StatusUnauthorized,
		Cause:  fmt.Errorf("unable to retrieve user from context"),
	})
}

func withBook(
	c *gin.Context,
	bookRight string,
	f func(c *gin.Context, userInfo *service.UserInfo, bookID int64),
) {
	withUser(c, func(c *gin.Context, user *service.UserInfo) {

		// todo: Come up with some "admin mode" (right now, only accepts the request if the user has explicit right on book)

		rawBookID := c.Param("bookId")
		bookID, err := strconv.ParseInt(rawBookID, 10, 64)
		if err != nil {
			writeProblem(c, probUnauthorizedOnBook)
			return
		}

		if !user.HasRightForBook(bookID, bookRight) {
			writeProblem(c, probUnauthorizedOnBook)
			return
		}

		f(c, user, bookID)
	})
}

// withBookRead ensure the caller has READ access to the book in the URL before executing function f, providing
// it with the ID of the book and the user information.
func withBookRead(c *gin.Context, f func(c *gin.Context, userInfo *service.UserInfo, bookID int64)) {
	withBook(c, service.BookRightRead, f)
}

// withBookWrite ensure the caller has WRITE access to the book in the URL before executing function f, providing
// it with the ID of the book and the user information.
func withBookWrite(c *gin.Context, f func(c *gin.Context, userInfo *service.UserInfo, bookID int64)) {
	withBook(c, service.BookRightWrite, f)
}
