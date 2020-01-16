package server

import (
	"context"
	"fmt"
	"net/http"
	"os"
	"os/signal"
	"strings"
	"time"

	"github.com/adeynack/finances-service-go/pkg/controller"
	"github.com/adeynack/finances-service-go/pkg/service"
	"github.com/adeynack/finances-service-go/pkg/util"
	"github.com/gin-gonic/gin"
	"github.com/olebedev/config"
	ginlogrus "github.com/toorop/gin-logrus"

	log "github.com/sirupsen/logrus"
)

// StartServer bootstraps the Finances HTTP server.
func StartServer() {
	// Configuration
	conf := readConfiguration()
	setupLogging(conf)
	printBanner(conf)

	// Services
	databaseService := service.NewDatabase(conf)
	userService := service.NewUsers(databaseService)
	tokenService := service.NewTokens(userService)
	booksService := service.NewBooks(databaseService)

	// Controllers
	tokensController := controller.NewTokens(tokenService, userService)
	booksController := controller.NewBooks(booksService)

	// Create route and start listening to requests.
	gin.SetMode(conf.UString("gin.mode", "debug"))
	engine := gin.New()
	if conf.UBool("gin.log_requests", false) {
		engine.Use(ginlogrus.Logger(log.StandardLogger()))
	}
	engine.Use(gin.Recovery())
	controller.RegisterRoute(
		conf,
		engine,
		tokensController,
		booksController,
	)

	handleHTTP(engine, conf.UInt("gin.port", 3000))
}

func handleHTTP(engine *gin.Engine, port int) {
	srv := &http.Server{
		Addr:    fmt.Sprintf("localhost:%d", port),
		Handler: engine,
	}

	go func() {
		log.Infof("Finances Services available at %s", srv.Addr)
		if err := srv.ListenAndServe(); err != nil && err != http.ErrServerClosed {
			log.Fatalf("listen: %s\n", err)
		}
	}()

	// Wait for interrupt signal to gracefully shutdown the server with a timeout of 5 seconds.
	quit := make(chan os.Signal)
	signal.Notify(quit, os.Interrupt)
	log.Infof("Shutting down server (received signal %q)", <-quit)

	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()
	if err := srv.Shutdown(ctx); err != nil {
		log.Fatal("Server Shutdown:", err)
	}
	log.Info("Server exiting")
}

func readConfiguration() *util.ConfigReader {
	envVarConfigFile := "FINANCES_SERVICE_CONFIG"
	envConfigFile, found := os.LookupEnv(envVarConfigFile)
	if found && len(envConfigFile) > 0 {
		log.Infof("Environment variable '%s' set. Using configuration file '%s'.", envVarConfigFile, envConfigFile)
	} else {
		defaultConfigFile := "docs/config/dev.yaml"
		log.Infof("Environment variable '%s' not set. Using default configuration file '%s'.", envVarConfigFile, defaultConfigFile)
		envConfigFile = defaultConfigFile
	}
	conf, err := config.ParseYamlFile(envConfigFile)
	if err != nil {
		panic(err)
	}
	conf.EnvPrefix("FINANCES_SERVICE").Flag()
	return &util.ConfigReader{Config: conf}
}

func setupLogging(conf *util.ConfigReader) {
	conf = conf.MustGet("log")

	log.SetOutput(os.Stdout)

	formatter := conf.UString("formatter", "text")
	switch formatter {
	case "text":
		log.SetFormatter(&log.TextFormatter{
			TimestampFormat: time.RFC3339,
			FullTimestamp:   true,
		})
	case "json":
		log.SetFormatter(&log.JSONFormatter{
			TimestampFormat: time.RFC3339,
		})
	default:
		panic(fmt.Errorf("unsupported formatter: %s", formatter))
	}

	logLevel := conf.UString("level", "info")
	parsedLevel, err := log.ParseLevel(logLevel)
	if err != nil {
		panic(fmt.Errorf("unsupported log level: %s", logLevel))
	}
	log.SetLevel(parsedLevel)
}

func printBanner(conf *util.ConfigReader) {
	banner := conf.MustString("banner")
	bannerLines := strings.Split(banner, "\n")
	for _, line := range bannerLines {
		log.Info(line)
	}
}
