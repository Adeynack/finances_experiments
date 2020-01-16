package service

import (
	"database/sql"
	"fmt"
	"io/ioutil"
	"strings"

	"github.com/adeynack/finances-service-go/pkg/util"

	"github.com/golang-migrate/migrate"
	"github.com/golang-migrate/migrate/database/postgres"

	// Import the "migrate" source driver for local files.
	_ "github.com/golang-migrate/migrate/source/file"

	log "github.com/sirupsen/logrus"

	// Import the database drive within the service itself to avoid managing DB related
	// concerns in the main package.
	_ "github.com/lib/pq"
)

// Database allows interactions with the database to be done through an interface,
// so it can easily be mocked for test purposes.
type Database interface {
	// MustInitQuery takes a raw SQL string and perform checks and optimization
	// on it. Since this is used typically at initialization time, it panics
	// if an error occurs.
	InitQuery(name, query string) *queryInfo

	// Query executes a query that returns rows, typically a SELECT.
	// The args are for any placeholder parameters in the query.
	Query(query *queryInfo, args ...interface{}) (*sql.Rows, error)

	// QueryRow executes a query that is expected to return at most one row.
	QueryRow(query *queryInfo, args ...interface{}) *sql.Row

	Close()

	Db() *sql.DB
}

// NewDatabase initializes the default production `Database`.
// It will panic if the connection to the database cannot be established.
func NewDatabase(conf *util.ConfigReader) Database {
	dbConf := conf.MustGet("database")

	// CONNECTION

	username := dbConf.MustString("username")
	password := dbConf.MustString("password")
	hostname := dbConf.MustString("hostname")
	port := dbConf.MustInt("port")
	database := dbConf.MustString("database")
	schema := dbConf.MustString("schema")
	options := dbConf.MustMap("options")
	options["search_path"] = schema
	optionsString := toURLQuery(options)
	connStr := fmt.Sprintf(
		"postgresql://%s:%s@%s:%d/%s%s",
		username, password, hostname, port, database, optionsString)
	log.Infof("Connecting to database using connection string: %s", connStr)
	db, err := sql.Open("postgres", connStr)
	if err != nil {
		log.Fatal(err)
		panic(err)
	}

	// EVOLUTION

	err = migrateDatabase(db, database, dbConf.MustGet("evolution"), schema)
	if err != nil {
		log.Fatal(err)
		panic(err)
	}

	// SERVICE

	checkQueriesOnInit := dbConf.UBool("check_queries_on_init", false)
	return &databaseService{db, checkQueriesOnInit}
}

type queryInfo struct {
	Name           string
	MinimizedQuery string
}

func toURLQuery(m map[string]interface{}) string {
	if len(m) > 0 {
		builder := strings.Builder{}
		builder.WriteRune('?')
		separate := false
		for k, v := range m {
			if separate {
				builder.WriteRune('&')
			}
			builder.WriteString(k)
			builder.WriteRune('=')
			builder.WriteString(fmt.Sprint(v))
			separate = true
		}
		return builder.String()
	}
	return ""
}

func migrateDatabase(db *sql.DB, database string, evConf *util.ConfigReader, schema string) error {

	if err := recreateSchema(db, evConf, schema); err != nil {
		return fmt.Errorf("recreating schema: %w", err)
	}

	runAtStartup := evConf.MustBool("run_at_startup")
	if !runAtStartup {
		log.Infof("Database evolution are configured not to run.")
		return nil
	}

	driver, err := postgres.WithInstance(db, &postgres.Config{})
	if err != nil {
		return fmt.Errorf("creating migrate postgresql driver: %w", err)
	}

	sourceURL := fmt.Sprintf("file://%s/", evConf.MustString("scripts_folders"))
	mig, err := migrate.NewWithDatabaseInstance(sourceURL, database, driver)
	if err != nil {
		return fmt.Errorf("initializing migrate: %w", err)
	}
	mig.Log = &migrateLogrusAdapter{}

	err = mig.Up()
	if err == migrate.ErrNoChange {
		mig.Log.Printf("%v", err)
	} else if err != nil {
		return fmt.Errorf("migrating upward: %w", err)
	}

	if err := loadFixtures(db, evConf, schema); err != nil {
		return fmt.Errorf("loading fixtures: %w", err)
	}

	return nil
}

func recreateSchema(db *sql.DB, evConf *util.ConfigReader, schemaName string) error {
	if !evConf.UBool("recreate_schema", false) {
		return nil
	}
	log.Infof("Forcing re-creation of the database schema. HINT: THIS SHOULD NEVER HAPPEN IN PRODUCTION")
	schemaExists, err := doesSchemaExist(db, schemaName)
	if err != nil {
		return err
	}
	if schemaExists {
		err = dropSchema(db, schemaName)
		if err != nil {
			return err
		}
	}
	return createSchema(db, schemaName)
}

func doesSchemaExist(db *sql.DB, schemaName string) (exists bool, err error) {
	res, err := db.Query(
		"SELECT schema_name FROM information_schema.schemata WHERE schema_name = $1",
		schemaName)
	if err != nil {
		return false, fmt.Errorf("recreate schema: checking if schema exists: %w", err)
	}
	defer func() {
		err = res.Close()
	}()
	return res.Next(), nil
}

func dropSchema(db *sql.DB, schemaName string) error {
	log.Infof("recreate schema: schema %q exists: dropping", schemaName)
	_, err := db.Exec(fmt.Sprintf("drop schema %q cascade", schemaName))
	if err != nil {
		return fmt.Errorf("recreate schema: droping schema %q: %w", schemaName, err)
	}
	log.Infof("recreate schema: schema dropped")
	return nil
}

func createSchema(db *sql.DB, schemaName string) error {
	log.Infof("create schema: creating schema %q", schemaName)
	_, err := db.Exec(fmt.Sprintf("create schema %q", schemaName))
	if err != nil {
		return fmt.Errorf("create schema: creating schema %q: %w", schemaName, err)
	}
	return nil
}

func loadFixtures(db *sql.DB, evConf *util.ConfigReader, schema string) error {
	fixturesToLoad := evConf.UList("load_fixtures")
	if len(fixturesToLoad) == 0 {
		return nil
	}

	for i, f := range fixturesToLoad {
		fixturePath, ok := f.(string)
		if !ok {
			return fmt.Errorf("error reading configuration: fixture at index %d is not a string as expected", i)
		}
		err := loadAndExecuteFixture(db, schema, fixturePath)
		if err != nil {
			return fmt.Errorf("loading fixture %q: %w", f, err)
		}
	}
	return nil
}

func loadAndExecuteFixture(db *sql.DB, schema string, fixturePath string) error {
	content, err := ioutil.ReadFile(fixturePath)
	if err != nil {
		return fmt.Errorf("reading fixture at %q: %w", fixturePath, err)
	}

	result, err := db.Exec(string(content))
	if err != nil {
		return fmt.Errorf("executing fixture at %q: %w", fixturePath, err)
	}

	log.Printf("DEBUG executing fixture %q resulted in: %v", fixturePath, result)
	return nil
}
