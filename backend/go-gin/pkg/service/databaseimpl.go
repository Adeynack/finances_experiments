package service

import (
	"database/sql"
	"fmt"
	"strings"

	log "github.com/sirupsen/logrus"
)

type databaseService struct {
	db                 *sql.DB
	checkQueriesOnInit bool
}

var _ Database = (*databaseService)(nil)

func (srv *databaseService) InitQuery(name, query string) *queryInfo {
	minQuery := minifySQL(query)

	if srv.checkQueriesOnInit {
		log.Infof("Checking query %q", name)
		stmt, err := srv.db.Prepare(minQuery)
		if err != nil {
			panic(fmt.Errorf("error preparing query %q: %s", name, err))
		}
		stmt.Close()
	}

	return &queryInfo{
		Name:           name,
		MinimizedQuery: minQuery,
	}
}

func (srv *databaseService) Query(query *queryInfo, args ...interface{}) (*sql.Rows, error) {
	return srv.db.Query(query.MinimizedQuery, args...)
}

func (srv *databaseService) QueryRow(query *queryInfo, args ...interface{}) *sql.Row {
	return srv.db.QueryRow(query.MinimizedQuery, args...)
}

func (srv *databaseService) Close() {
	srv.db.Close()
}

func (srv *databaseService) Db() *sql.DB {
	return srv.db
}

func minifySQL(source string) string {
	const separators = " \t\n\v\f\r" // space, tab, line feed / new line, vertical tab, form feed, carriage return
	sb := &strings.Builder{}
	wasSep := false
	hasContent := false
	for _, r := range source {
		if strings.ContainsRune(separators, r) {
			wasSep = true
		} else {
			if wasSep {
				wasSep = false
				if hasContent {
					sb.WriteByte(' ')
				}
			}
			sb.WriteRune(r)
			hasContent = true
		}
	}
	return strings.TrimSpace(sb.String())
}
