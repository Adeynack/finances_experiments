package service

import (
	"context"
	"fmt"
	"github.com/adeynack/finances-service-go/models"
	"github.com/adeynack/finances-service-go/pkg/model/db"
)

// Books is the service for persisting books.
type Books interface {
	GetBooks() ([]db.Book, error)
	GetBooksForUser(userID int64) ([]db.Book, error)
	GetBookByID(bookID int64) (db.Book, error)
}

// NewBooks creates a new `Books` service.
func NewBooks(db Database) Books {
	return &booksService{
		db,

		db.InitQuery("GetBooks", `
			select id, name, owner_id
			from books
		`),

		db.InitQuery("GetBooksForUser", `
			select b.id, b.name, b.owner_id
			from books b
				inner join users_rights ur on ur.book_id = b.id or b.owner_id = $1
			where ur.user_id = $1
		`),

		db.InitQuery("GetQueryByID", `
			select id, name, owner_id
			from books b
			where b.id = $1
		`),
	}
}

type booksService struct {
	databaseService Database

	queryGetBooks        *queryInfo
	queryGetBooksForUser *queryInfo
	queryGetBookByID     *queryInfo
}

var _ Books = (*booksService)(nil)

func (s booksService) GetBooks() ([]db.Book, error) {
	dbBooks, err := models.Books().All(context.Background(), s.databaseService.Db())
	if err != nil {
		return nil, fmt.Errorf("loading books from the database: %w", err)
	}
	var result []db.Book
	for _, b := range dbBooks {
		result = append(result, db.Book{
			ID:      b.ID,
			Name:    b.Name,
			OwnerID: b.OwnerID,
		})
	}
	return result, nil
}

func (s booksService) GetBooksForUser(userID int64) ([]db.Book, error) {
	rows, err := s.databaseService.Query(s.queryGetBooksForUser, userID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	var result []db.Book
	var book db.Book
	for rows.Next() {
		err = rows.Scan(&book.ID, &book.Name, &book.OwnerID)
		if err != nil {
			return nil, err
		}
		result = append(result, book)
	}
	return result, nil

	//select b.id, b.name, b.owner_id
	//	from books b
	//	inner join users_rights ur on ur.book_id = b.id or b.owner_id = $1
	//	where ur.user_id = $1

	//dbBooks, err := models.
	//	Books(
	//		qm.InnerJoin("users_rights ur on ur.book_id = b.id or b.owner_id = $1", userID),
	//		qm.Where("ur." + models.UsersRightColumns.UserID + "= $1", userID), // todo: Try removing the owner_id = $1 from the join
	//	).
	//	All(context.Background(), s.databaseService.Db())
	//if err != nil {
	//	return nil, fmt.Errorf("loading books for user %q: %w", userID, err)
	//}
	//var result []db.Book
	//for _, b := range dbBooks {
	//	result = append(result, db.Book{
	//		ID:      b.ID,
	//		Name:    b.Name,
	//		OwnerID: b.OwnerID,
	//	})
	//}
	//return result, nil
}

func (s booksService) GetBookByID(bookID int64) (db.Book, error) {
	row := s.databaseService.QueryRow(s.queryGetBookByID, bookID)
	var book db.Book
	err := row.Scan(&book.ID, &book.Name, &book.OwnerID)
	if err != nil {
		return book, err
	}
	return book, nil
}
