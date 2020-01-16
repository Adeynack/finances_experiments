package service

import (
	"github.com/golang-migrate/migrate"
	log "github.com/sirupsen/logrus"
)

type migrateLogrusAdapter struct{}

var _ migrate.Logger = &migrateLogrusAdapter{}

func (m *migrateLogrusAdapter) Printf(format string, v ...interface{}) {
	log.Infof("[migrate] "+format, v...)
}

func (m *migrateLogrusAdapter) Verbose() bool {
	return true
}
