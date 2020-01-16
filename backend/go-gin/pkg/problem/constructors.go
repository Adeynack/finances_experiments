package problem

import "net/http"

// Error creates a Problem value from an error, with the `Internal Server
// Error` HTTP status code and the given err as its cause.
func Error(err error) *Problem {
	return &Problem{
		Status: http.StatusInternalServerError,
		Cause:  err,
	}
}
