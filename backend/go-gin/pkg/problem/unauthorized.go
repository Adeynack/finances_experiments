package problem

import (
	"net/http"
)

// Unauthorized creates a Problem with `Unauthorized` HTTP status
// with a custom detail.
func Unauthorized(detail string) *Problem {
	return &Problem{
		Status: http.StatusUnauthorized,
		Title:  http.StatusText(http.StatusUnauthorized),
		Detail: detail,
	}
}
