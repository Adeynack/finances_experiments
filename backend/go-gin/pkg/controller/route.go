package controller

import (
	"github.com/adeynack/finances-service-go/pkg/util"
	"github.com/gin-gonic/gin"
)

// RegisterRoute creates the HTTP router for the Finances API
func RegisterRoute(
	conf *util.ConfigReader,
	engine *gin.Engine,
	tokensController *Tokens,
	booksController *Books,
) {
	build("tokens", engine, func(b *routeBuilder) {
		b.post(tokensController.Create)
		b.get(tokensController.Validate)
		b.delete(tokensController.Invalidate)
	})

	authorizeMiddleware := tokensController.CreateAuthorizeMiddleware(conf)

	build("books", engine.Group("", authorizeMiddleware), func(b *routeBuilder) {
		b.get(booksController.GetBookList)
		b.post(booksController.CreateBook)

		b.sub(":bookId", func(b *routeBuilder) {
			b.get(booksController.GetBook)
		})
	})

	engine.StaticFile("finances.api.yaml", "docs/api/finances.api.yaml")
	engine.Static("docs", "public/swagger-ui")
}

type routeBuilder struct {
	path   string
	engine gin.IRoutes
}

func build(p string, engine gin.IRoutes, f func(b *routeBuilder)) {
	builder := &routeBuilder{p, engine}
	f(builder)
}

func (rb *routeBuilder) sub(p string, f func(b *routeBuilder)) {
	subRb := &routeBuilder{
		engine: rb.engine,
		path:   rb.path + "/" + p,
	}
	f(subRb)
}

func (rb *routeBuilder) get(f gin.HandlerFunc)    { rb.engine.GET(rb.path, f) }
func (rb *routeBuilder) post(f gin.HandlerFunc)   { rb.engine.POST(rb.path, f) }
func (rb *routeBuilder) put(f gin.HandlerFunc)    { rb.engine.PUT(rb.path, f) }
func (rb *routeBuilder) delete(f gin.HandlerFunc) { rb.engine.DELETE(rb.path, f) }
