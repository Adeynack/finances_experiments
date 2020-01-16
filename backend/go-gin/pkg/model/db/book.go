package db

// Book represents a book in the database.
type Book struct {
	ID      int64
	Name    string
	OwnerID int64
}
