package service

import (
	"encoding/hex"

	"sync"
)

// Tokens is the service for managing tokens.
type Tokens interface {
	// Controls username and password and create a token for the user.
	// Returns a token when user is authenticated or an empty string if failed.
	CreateToken(email, password string) string

	// ValidateToken checks if a given token is valid.
	// If it is, it returns the email of the user; if not, an empty string.
	ValidateToken(token string) string

	// InvalidateToken voids an existing token.
	// If the token existed and was invalidated, it returns the email of the
	// user; otherwise, an empty string.
	InvalidateToken(token string) string
}

// NewTokens creates a new `Tokens` service.
func NewTokens(userService Users) Tokens {
	s := &tokenService{
		userService: userService,
		lock:        &sync.RWMutex{},
		tokenCache:  map[string]string{},
	}
	return s
}

type tokenService struct {
	userService Users
	lock        *sync.RWMutex
	tokenCache  map[string]string
}

var _ Tokens = (*tokenService)(nil)

func (s tokenService) CreateToken(email, password string) string {
	s.lock.Lock()
	defer s.lock.Unlock()

	// Check username and password
	if !s.userService.AuthenticateUser(email, password) {
		return ""
	}
	// Create token
	// todo: Something more secure than the email itself encoded.
	token := hex.EncodeToString([]byte(email))

	s.tokenCache[token] = email
	return token
}

func (s tokenService) ValidateToken(token string) string {
	s.lock.RLock()
	defer s.lock.RUnlock()

	email, found := s.tokenCache[token]
	if found {
		return email
	}
	return ""
}

func (s tokenService) InvalidateToken(token string) string {
	s.lock.Lock()
	defer s.lock.Unlock()

	email, found := s.tokenCache[token]
	if !found {
		return ""
	}
	delete(s.tokenCache, token)
	return email
}
