package service

import (
	"github.com/adeynack/finances-service-go/pkg/util"
)

// UserInfo represents a user of the service.
type UserInfo struct {
	ID           int64
	Email        string
	DisplayName  string
	GlobalRights []string
	BooksRights  map[int64][]string
}

const (
	// Global rights

	// RightAdmin : User is an administrator of the service
	RightAdmin = "admin"

	// Books rights

	// BookRightRead : User is allowed to read the book
	BookRightRead = "read"
	// BookRightWrite : User is allowed to modify the book
	BookRightWrite = "write"
	// BookRightAdmin : User is allowed to administrate the book
	BookRightAdmin = "admin"
	// BookRightOwner : User owns the book
	BookRightOwner = "owner"
)

var (
	// bookRightsCoveredBy is a map from a right to the rights that implicitly cover it.
	// NOTE: value is a map[string]interface{} (string to whatever) in order to have a "set" of strings.
	// ex: "read": {"read", "write", "admin"} means that if someone has "write", he has implicitly "read".
	bookRightsCoveredBy util.MapStringToStringSet
)

func init() {

	// Build up hierarchy of rights

	bookRightsByParents := map[string][]string{}

	bookRightsRead := []string{BookRightRead}
	bookRightsByParents[BookRightRead] = bookRightsRead

	bookRightsWrite := append(bookRightsRead, BookRightWrite)
	bookRightsByParents[BookRightWrite] = bookRightsWrite

	bookRightsAdmin := append(bookRightsWrite, BookRightAdmin)
	bookRightsByParents[BookRightAdmin] = bookRightsAdmin

	bookRightsOwner := append(bookRightsAdmin, BookRightOwner)
	bookRightsByParents[BookRightOwner] = bookRightsOwner

	// Build up bookRightsCoveredBy (reverse map from bookRightsByParents)
	b := make(util.MapStringToStringSet)
	for ak, av := range bookRightsByParents {
		for _, ave := range av {
			b.Put(ave, ak)
		}
	}
	bookRightsCoveredBy = b
}

// HasAdminRights indicates if the user has administrative rights.
func (info *UserInfo) HasAdminRights() bool {
	for _, r := range info.GlobalRights {
		if r == RightAdmin {
			return true
		}
	}
	return false
}

// HasRightForBook indicates if the user has the specific right for a given bookID.
func (info *UserInfo) HasRightForBook(bookID int64, right string) bool {
	rightsCov, ok := bookRightsCoveredBy[right]
	if !ok {
		return false // the right is not recognized
	}

	userRightsForBook, ok := info.BooksRights[bookID]
	if !ok {
		return false // user has no right at all for this book
	}

	for _, r := range userRightsForBook {
		if rightsCov.Contains(r) {
			// requested right is covered by one of the right the user has on this book.
			return true
		}
	}
	// requested right was not covered by any right the user has on this book
	return false
}
