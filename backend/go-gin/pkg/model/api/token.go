package api

// TokenInfo $ref=TODO
type TokenInfo struct {
	Token         string `json:"token"`
	Status        string `json:"status"`
	Authenticated bool   `json:"authenticated"`
}

// TokenCreateIn $ref=TODO
type TokenCreateIn struct {
	Email    string `json:"email"`
	Password string `json:"password"`
}
