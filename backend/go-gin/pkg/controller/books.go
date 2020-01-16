package controller

import (
	"net/http"

	"github.com/adeynack/finances-service-go/pkg/model/api"
	"github.com/adeynack/finances-service-go/pkg/model/db"
	"github.com/adeynack/finances-service-go/pkg/problem"
	"github.com/adeynack/finances-service-go/pkg/service"
	"github.com/gin-gonic/gin"
	"github.com/sirupsen/logrus"
)

// NewBooks creates a new `Books` controller.
func NewBooks(booksService service.Books) *Books {
	return &Books{
		logrus.WithField("controller", "books"),
		booksService,
	}
}

// Books controller
type Books struct {
	log          *logrus.Entry
	booksService service.Books
}

// GetBookList lists books
func (ct *Books) GetBookList(c *gin.Context) {
	withUser(c, func(c *gin.Context, user *service.UserInfo) {
		listAll := readParameterListAll(c)
		var err error
		var books []db.Book
		if listAll {
			if user.HasAdminRights() {
				books, err = ct.booksService.GetBooks()
			} else {
				writeProblem(c, &problem.Problem{
					Status: http.StatusForbidden,
					Detail: "No permission to list all books",
				})
				return
			}
		} else {
			books, err = ct.booksService.GetBooksForUser(user.ID)
		}
		if err != nil {
			ct.log.WithError(err).Error("getting all books from persistence")
			writeProblem(c, problem.Error(err))
			return
		}
		booksForList := make([]api.Book, len(books))
		for i, b := range books {
			booksForList[i] = api.Book{
				ID:      b.ID,
				Name:    b.Name,
				OwnerID: b.OwnerID,
			}
		}
		c.JSON(http.StatusOK, api.BookList{
			Items: booksForList,
		})
	})
}

// CreateBook creates a new book
func (ct *Books) CreateBook(c *gin.Context) {

}

// GetBook gets details of a single book
func (ct *Books) GetBook(c *gin.Context) {
	withBookRead(c, func(c *gin.Context, user *service.UserInfo, bookID int64) {
		book, err := ct.booksService.GetBookByID(bookID)
		if err != nil {
			ct.log.WithError(err).Errorf("getting book with ID %d", bookID)
			writeProblem(c, problem.Error(err))
			return
		}
		c.JSON(http.StatusOK, api.Book{
			ID:      book.ID,
			Name:    book.Name,
			OwnerID: book.OwnerID,
		})
	})
}
