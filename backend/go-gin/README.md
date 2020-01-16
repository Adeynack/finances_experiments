finances-service-go
===

# Project

The back-end service behind the _Finances_ (until a better name is found) system.

# Work in Progress

Merged, but not completely done:
- integration of _SQL Boiler_

# Useful commands

## Development Environment Setup

### Prerequisites

* [GO Language](https://golang.org/doc/install) development kit (>=1.10.3)
* [dep](https://golang.github.io/dep/docs/installation.html) GO dependencies tool

### Get ready to develop

```bash
git clone git@github.com:Adeynack/finances-service-go.git
cd finances-service-go
dep ensure
```

### Test

```bash
go test ./...
```

### Execute from sources

Execute (with default configuration `dev`):
```bash
go run src/finances-service/main.go
```

Execute with a specific configuration file (example: `production`):
```bash
FINANCES_SERVICE_CONFIG=docs/config/production.yaml go run src/finances-service/main.go
```

### Build & Execute

This outputs `./finances-service` (`.exe` on Windows) executable.

To start it with a specific configuration, prepend the `FINANCES_SERVICE_CONFIG` environment
variable assignment before calling the executable.

```bash
go build ./src/finances-service
FINANCES_SERVICE_CONFIG=docs/config/production.yaml ./finances-service
# .\finances-service.exe on Windows
```

# Configuration

## Configuration File

By default, the service will try to load `docs/config/dev.yaml`. By change this
behaviour, this environment variable must be set.

```bash
FINANCES_SERVICE_CONFIG=docs/config/integration.yaml
```

## Specific Configuration Key

To set a specific configuration key, per instance `database.password`,
set an environment variable with its path in UPPERCASE, separated by underscores `_` instead
of dots `.` and prefixing it by `FINANCES_SERVICE`.

```bash
FINANCES_SERVICE_DATABASE_PASSWORD=thisISohSOsecure
```


# Database

This application expects a _PostgreSQL_ database to be present (check [application.conf](./src/main/resources/application.conf)
for detailed configuration).

Here is an example of how to create a database from the `psql` CLI.

```sql
CREATE DATABASE "finances"
    WITH 
    OWNER = postgres
    ENCODING = 'UTF8'
    LC_COLLATE = 'en_US.UTF-8'
    LC_CTYPE = 'en_US.UTF-8'
    TABLESPACE = pg_default
    CONNECTION LIMIT = -1;

COMMENT ON DATABASE "finances"
    IS 'Data for the `finances` backend service';
    

-- In the `psql` CLI, connect to that specific database:
-- \c finances

CREATE SCHEMA finances;
```

Or for the development database.
```sql
CREATE DATABASE "finances-dev"
    WITH 
    OWNER = postgres
    ENCODING = 'UTF8'
    LC_COLLATE = 'en_US.UTF-8'
    LC_CTYPE = 'en_US.UTF-8'
    TABLESPACE = pg_default
    CONNECTION LIMIT = -1;

COMMENT ON DATABASE "finances-dev"
    IS 'Development data for the `finances` backend service';

-- In the `psql` CLI, connect to that specific database:
-- \c finances-dev

CREATE SCHEMA finances;
```

To use the schema:
```sql
set search_path to 'finances'
```

# Troubleshoot

## macOS asks if the service is allowed to serve

```bash
/usr/libexec/ApplicationFirewall/socketfilterfw --add $PWD/bin/finservice
/usr/libexec/ApplicationFirewall/socketfilterfw --unblock $PWD/bin/finservice
```
