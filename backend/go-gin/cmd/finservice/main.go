package main

import (
	"github.com/adeynack/finances-service-go/pkg/server"
	log "github.com/sirupsen/logrus"
)

func main() {
	defer func() {
		err := recover()
		if err != nil {
			log.Fatal(err)
		}
	}()

	server.StartServer()
}
