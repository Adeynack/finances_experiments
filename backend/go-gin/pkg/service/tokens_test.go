package service

import (
	"fmt"
	"sync"
	"testing"

	"github.com/stretchr/testify/assert"
)

type mockUserService struct{}

func (mockUserService) GetUserInfoAndRights(email string) *UserInfo {
	panic("implement me")
}

func (mockUserService) AuthenticateUser(username, password string) bool {
	return true
}

// Simulates charge on the `TokensService` to ensure thread safety.
func Test_TokensService_Charge(t *testing.T) {
	parallelExecs := 4
	triesPerExecs := 20000

	service := NewTokens(&mockUserService{})
	wg := sync.WaitGroup{}
	wg.Add(parallelExecs * 2)

	startWg := sync.WaitGroup{}
	startWg.Add(1)

	for i := 0; i < parallelExecs; i++ {
		go func(prefix int) {
			startWg.Wait()
			for v := 0; v < triesPerExecs; v++ {
				token := fmt.Sprintf("token for max.mustermann.%d.%d", prefix, v)
				email := service.ValidateToken(token)
				assert.Empty(t, email, token)
			}
			wg.Done()
		}(i)
		go func(prefix int) {
			startWg.Wait()
			for v := 0; v < triesPerExecs; v++ {
				username := fmt.Sprintf("max.mustermann.%d.%d", prefix, v)
				password := ""

				token := service.CreateToken(username, password)
				assert.NotEmpty(t, token)

				recreatedToken := service.CreateToken(username, password)
				assert.Equal(t, token, recreatedToken)

				email := service.ValidateToken(token)
				assert.NotEmpty(t, email)

				email = service.ValidateToken(token)
				assert.NotEmpty(t, email)

				email = service.InvalidateToken(token)
				assert.NotEmpty(t, email)

				email = service.InvalidateToken(token)
				assert.Empty(t, email)

				email = service.ValidateToken(token)
				assert.Empty(t, email)
			}
			wg.Done()
		}(i)
	}

	startWg.Done()
	wg.Wait()
}
