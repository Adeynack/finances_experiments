package controllerstest

import (
	"encoding/json"
	"fmt"
	"github.com/adeynack/finances-service-go/pkg/controller"
	"github.com/adeynack/finances-service-go/pkg/model/api"
	"github.com/adeynack/finances-service-go/pkg/problem"
	"github.com/adeynack/finances-service-go/pkg/service"
	"github.com/adeynack/finances-service-go/pkg/util"
	"github.com/gin-gonic/gin"
	"github.com/go-http-utils/headers"
	"github.com/olebedev/config"
	"github.com/stretchr/testify/assert"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"
)

func Test_CreateToken_EmptyEmail(t *testing.T) {
	body := `{ "email": "",  "password": "whatever" }`
	req, err := http.NewRequest(http.MethodPost, "/tokens", strings.NewReader(body))
	assert.NoError(t, err)
	rec, _ := test(req)

	assert.Equal(t, http.StatusBadRequest, rec.Code)
	expectedBody := `{
        "status": 400,
        "title": "Unexpected body structure",
        "detail": "Expecting a body similar to: {\"email\":\"name@domain.com\",\"password\":\"something_very_secure\"}"
    }`
	assert.JSONEq(t, expectedBody, rec.Body.String())
}

func Test_CreateToken_EmptyPassword(t *testing.T) {
	body := `{ "email": "max.mustermann@example.com", "password": "" }`
	req, err := http.NewRequest(http.MethodPost, "/tokens", strings.NewReader(body))
	assert.NoError(t, err)
	rec, _ := test(req)

	assert.Equal(t, http.StatusBadRequest, rec.Code)
	expectedBody := `{
        "status": 400,
        "title": "Unexpected body structure",
        "detail": "Expecting a body similar to: {\"email\":\"name@domain.com\",\"password\":\"something_very_secure\"}"
    }    `
	assert.JSONEq(t, expectedBody, rec.Body.String())
}

func Test_CreateToken_UnknownEmail(t *testing.T) {
	body := `{ "email": "do not exist", "password": "whatever" }`
	req, err := http.NewRequest(http.MethodPost, "/tokens", strings.NewReader(body))
	assert.NoError(t, err)
	rec, _ := test(req)

	assert.Equal(t, http.StatusUnauthorized, rec.Code)
	expectedBody := `{
        "status":401,
        "title": "Invalid credentials",
        "detail": "The specified credentials do not represent a known user or the password was invalid."
    }`
	assert.JSONEq(t, expectedBody, rec.Body.String())
}

func Test_CreateToken_BadPassword(t *testing.T) {
	body := `{ "email": "max.mustermann@example.com", "password": "whatever" }`
	req, err := http.NewRequest(http.MethodPost, "/tokens", strings.NewReader(body))
	assert.NoError(t, err)
	rec, _ := test(req)

	assert.Equal(t, http.StatusUnauthorized, rec.Code)
	expectedBody := `{
        "status":401,
        "title": "Invalid credentials",
        "detail": "The specified credentials do not represent a known user or the password was invalid."
    }`
	assert.JSONEq(t, expectedBody, rec.Body.String())
}

func Test_TokenLifecycle_Optimal(t *testing.T) {
	// Create
	token, env := createToken(t)
	authHeader := fmt.Sprintf("Bearer %s", token)

	// Validate
	req, err := http.NewRequest(http.MethodGet, "/tokens", nil)
	assert.NoError(t, err)
	req.Header.Add(headers.Authorization, authHeader)
	rec, _ := testWith(req, env)

	assert.Equal(t, http.StatusOK, rec.Code)
	tokenInfo := api.TokenInfo{}
	err = json.Unmarshal(rec.Body.Bytes(), &tokenInfo)
	assert.NoError(t, err, rec.Body.String())
	assert.Equal(t, api.TokenInfo{
		Token:         token,
		Status:        "Valid",
		Authenticated: true,
	}, tokenInfo)

	// Invalidate
	req, err = http.NewRequest(http.MethodDelete, "/tokens", nil)
	assert.NoError(t, err)
	req.Header.Add(headers.Authorization, authHeader)
	rec, _ = testWith(req, env)

	assert.Equal(t, http.StatusOK, rec.Code)
	tokenInfo = api.TokenInfo{}
	err = json.Unmarshal(rec.Body.Bytes(), &tokenInfo)
	assert.NoError(t, err, rec.Body.String())
	assert.Equal(t, api.TokenInfo{
		Token:         token,
		Status:        "Invalidated",
		Authenticated: false,
	}, tokenInfo)

	// Validate (failing)
	req, err = http.NewRequest(http.MethodDelete, "/tokens", nil)
	assert.NoError(t, err)
	req.Header.Add(headers.Authorization, authHeader)
	rec, _ = testWith(req, env)

	assert.Equal(t, http.StatusUnauthorized, rec.Code)
	respProblem := problem.Problem{}
	err = json.Unmarshal(rec.Body.Bytes(), &respProblem)
	assert.NoError(t, err, rec.Body.String())
	assert.Equal(t, problem.Problem{
		Status: http.StatusUnauthorized,
		Title:  "Unauthorized",
		Detail: "Invalid token.",
	}, respProblem)
}

func Test_ValidateToken_NoAuthorizationHeader(t *testing.T) {
	req, err := http.NewRequest(http.MethodGet, "/tokens", nil)
	assert.NoError(t, err)
	rec, _ := test(req)

	assert.Equal(t, http.StatusUnauthorized, rec.Code)
	expectedBody := `{
        "status": 401,
        "title": "Unauthorized",
        "detail": "Header \"Authorization\" not provided."
    }`
	assert.JSONEq(t, expectedBody, rec.Body.String())
}

func Test_ValidateToken_InvalidToken(t *testing.T) {
	req, err := http.NewRequest(http.MethodGet, "/tokens", nil)
	assert.NoError(t, err)
	req.Header.Add(headers.Authorization, "I am an invalid token")
	rec, _ := test(req)

	assert.Equal(t, http.StatusUnauthorized, rec.Code)
	expectedBody := `{
        "status": 401,
        "title": "Unauthorized",
        "detail": "Header \"Authorization\" is not a valid Bearer token."
    }`
	assert.JSONEq(t, expectedBody, rec.Body.String())
}

func Test_InvalidateToken_NoAuthorizationHeader(t *testing.T) {
	req, err := http.NewRequest(http.MethodDelete, "/tokens", nil)
	assert.NoError(t, err)
	rec, _ := test(req)

	assert.Equal(t, http.StatusUnauthorized, rec.Code)
	expectedBody := `{
        "status": 401,
        "title": "Unauthorized",
        "detail": "Header \"Authorization\" not provided."
    }`
	assert.JSONEq(t, expectedBody, rec.Body.String())
}

func Test_InvalidateToken_InvalidToken(t *testing.T) {
	req, err := http.NewRequest(http.MethodDelete, "/tokens", nil)
	assert.NoError(t, err)
	rec, _ := test(req)

	assert.Equal(t, http.StatusUnauthorized, rec.Code)
	expectedBody := `{
        "status": 401,
        "title": "Unauthorized",
        "detail": "Header \"Authorization\" not provided."
    }`
	assert.JSONEq(t, expectedBody, rec.Body.String())
}

type tokensControllerTestEnv struct {
	TokensService    service.Tokens
	TokensController *controller.Tokens
	TestRoute        *gin.Engine
}

func test(req *http.Request) (*httptest.ResponseRecorder, *tokensControllerTestEnv) {
	return testWith(req, nil)
}

func testWith(req *http.Request, env *tokensControllerTestEnv) (*httptest.ResponseRecorder, *tokensControllerTestEnv) {
	if env == nil {
		testConf := &util.ConfigReader{
			Config: &config.Config{},
		}
		userService := &mockUserServiceForTokenControllerTest{
			usersWithPassword: mockListOfUsersWithPasswords,
		}
		tokensService := service.NewTokens(userService)
		tokensController := controller.NewTokens(tokensService, userService)
		testRoute := gin.New()
		controller.RegisterRoute(testConf, testRoute, tokensController, nil)
		env = &tokensControllerTestEnv{
			TokensService:    tokensService,
			TokensController: tokensController,
			TestRoute:        testRoute,
		}
	}
	rec := httptest.NewRecorder()
	env.TestRoute.ServeHTTP(rec, req)
	return rec, env
}

func createToken(t *testing.T) (string, *tokensControllerTestEnv) {
	reqBody := `{ "email": "max.mustermann@example.com", "password": "maxisthebest" }`
	req, err := http.NewRequest(http.MethodPost, "/tokens", strings.NewReader(reqBody))
	assert.NoError(t, err)
	rec, tokensController := test(req)

	assert.Equal(t, http.StatusCreated, rec.Code)

	tokenInfo := api.TokenInfo{}
	err = json.Unmarshal(rec.Body.Bytes(), &tokenInfo)
	assert.NoError(t, err)

	assert.NotEmpty(t, tokenInfo.Token)
	token := tokenInfo.Token
	tokenInfo.Token = "non deterministic"
	assert.Equal(t, api.TokenInfo{
		Token:         "non deterministic",
		Status:        "Valid",
		Authenticated: true,
	}, tokenInfo)
	return token, tokensController
}

type mockUserServiceForTokenControllerTest struct {
	usersWithPassword map[string]string
}

func (s *mockUserServiceForTokenControllerTest) GetUserInfoAndRights(email string) *service.UserInfo {
	panic("implement me")
}

func (s *mockUserServiceForTokenControllerTest) AuthenticateUser(email, password string) bool {
	expectedPassword, found := s.usersWithPassword[email]
	if !found || password != expectedPassword {
		return false
	}
	return true
}

var mockListOfUsersWithPasswords = map[string]string{
	"max.mustermann@example.com": "maxisthebest",
	"laura.gärtner@example.com":  "mysafepassword",
}
