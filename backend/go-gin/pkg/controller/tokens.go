package controller

import (
	"encoding/json"
	"fmt"
	"net/http"
	"strings"

	"github.com/adeynack/finances-service-go/pkg/model/api"
	"github.com/adeynack/finances-service-go/pkg/problem"
	"github.com/adeynack/finances-service-go/pkg/service"
	"github.com/adeynack/finances-service-go/pkg/util"
	"github.com/gin-gonic/gin"
	"github.com/go-http-utils/headers"
	"github.com/sirupsen/logrus"
)

const (
	authBearerPrefix    = "Bearer "
	authDevBypassPrefix = authBearerPrefix + "DEV "
)

// NewTokens creates the controller `Tokens` for managing client tokens.
func NewTokens(tokensService service.Tokens, userService service.Users) *Tokens {
	return &Tokens{
		logrus.WithField("controller", "Tokens"),
		tokensService,
		userService,
	}
}

// Tokens controller
type Tokens struct {
	log           *logrus.Entry
	tokensService service.Tokens
	userService   service.Users
}

// Create takes care of validating a token creation request, create the
// token itself and caches it.
func (ct *Tokens) Create(c *gin.Context) {
	req := api.TokenCreateIn{}
	if err := c.BindJSON(&req); err != nil || req.Email == "" || req.Password == "" {
		example := api.TokenCreateIn{
			Email:    "name@domain.com",
			Password: "something_very_secure",
		}
		exampleJSON, err := json.Marshal(example)
		if err != nil {
			panic(err)
		}
		writeProblem(c, &problem.Problem{
			Status: http.StatusBadRequest,
			Title:  "Unexpected body structure",
			Detail: fmt.Sprintf("Expecting a body similar to: %s", exampleJSON),
		})
		return
	}

	token := ct.tokensService.CreateToken(req.Email, req.Password)
	if token == "" {
		writeProblem(c, &problem.Problem{
			Status: http.StatusUnauthorized,
			Title:  "Invalid credentials",
			Detail: "The specified credentials do not represent a known user or the password was invalid.",
		})
		return
	}

	c.JSON(http.StatusCreated, &api.TokenInfo{
		Token:         token,
		Status:        "Valid",
		Authenticated: true,
	})
}

// Validate confirms the validity of a token.
func (ct *Tokens) Validate(c *gin.Context) {
	token, email := ct.withToken(c, ct.tokensService.ValidateToken)
	if email != "" {
		c.JSON(http.StatusOK, &api.TokenInfo{
			Token:         token,
			Status:        "Valid",
			Authenticated: true,
		})
	}
}

// Invalidate voids an existing token, making any following call using that
// token non-authenticated.
func (ct *Tokens) Invalidate(c *gin.Context) {
	token, email := ct.withToken(c, ct.tokensService.InvalidateToken)
	if email != "" {
		c.JSON(http.StatusOK, &api.TokenInfo{
			Token:         token,
			Status:        "Invalidated",
			Authenticated: false,
		})
	}
}

// withToken performs an operation "op" with the token contained in the "Authorization" header.
// "op" needs to return `true` if the token was valid in the first place.
// Returns:
//   - the token
//   - the email of the user
func (ct *Tokens) withToken(c *gin.Context, op func(string) string) (token string, email string) {
	authHeader := c.GetHeader(headers.Authorization)
	if authHeader == "" {
		writeProblem(c, problem.Unauthorized(fmt.Sprintf("Header %q not provided.", headers.Authorization)))
		return
	}
	if !strings.HasPrefix(authHeader, authBearerPrefix) {
		writeProblem(c, problem.Unauthorized(fmt.Sprintf("Header %q is not a valid Bearer token.", headers.Authorization)))
		return
	}
	token = authHeader[len(authBearerPrefix):]
	email = op(token)
	if email == "" {
		writeProblem(c, problem.Unauthorized("Invalid token."))
		return
	}
	return
}

// CreateAuthorizeMiddleware creates the right middleware for authorization,
// considering elements of the configuration.
func (ct *Tokens) CreateAuthorizeMiddleware(conf *util.ConfigReader) gin.HandlerFunc {
	authMode := conf.UString("security.authentication.mode", "prod")
	switch authMode {
	case "prod":
		return ct.authorizedMiddlewareProd
	case "dev":
		return ct.authorizedMiddlewareDev
	default:
		panic(fmt.Sprintf("Authentication mode %q is not recognized", authMode))
	}
}

func (ct *Tokens) authorizedMiddlewareProd(c *gin.Context) {
	_, email := ct.withToken(c, ct.tokensService.ValidateToken)
	if email == "" {
		c.Abort() // `withToken` takes care of writing a Problem to the response.
		return
	}
	userInfo := ct.userService.GetUserInfoAndRights(email)
	c.Set(keyUser, userInfo)
}

func (ct *Tokens) authorizedMiddlewareDev(c *gin.Context) {
	log := ct.log.WithField("method", "authorizedMiddlewareDev")
	authHeader := c.GetHeader(headers.Authorization)
	if !strings.HasPrefix(authHeader, authDevBypassPrefix) {
		ct.authorizedMiddlewareProd(c)
		return
	}

	email := authHeader[len(authDevBypassPrefix):]
	userInfo := ct.userService.GetUserInfoAndRights(email)
	if userInfo == nil {
		log.Infof("User does not exist: %s", email)
		writeProblem(c, problem.Unauthorized(fmt.Sprintf("User '%s' does not exist (DEV MODE AUTHORIZATION)", email)))
		c.Abort()
		return
	}

	log.Infof("Authenticated user: %s", email)
	c.Set(keyUser, userInfo)
}
