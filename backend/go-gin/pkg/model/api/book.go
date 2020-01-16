package api

// Book $ref="#/components/schemas/Book"
type Book struct {
	ID      int64  `json:"id"`
	Name    string `json:"name"`
	OwnerID int64  `json:"owner_id"`
}

// BookList $ref="#/components/schemas/BookList"
type BookList struct {
	Items []Book `json:"items"`
}
