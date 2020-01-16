# Finances Backend − Ktor Version

## Run during development

### Database

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
```

### Generating the database related code

Before being able to compile the project, the database DSL must be generated using the `JOOQ` library. A convenience
`Makefile` is in place for doing just that. It is using `Docker`, so your machine needs it to have a daemon up and
running (check [here](https://store.docker.com/search?type=edition&offering=community) for installation instructions).

Run the code generation script every time there is a new [database migration script](./src/main/resources/db/migration/schema)
being added.

```bash
make generate-jooq-source
```

### Gradle

| Environment | Command             | Configuration file (in `src/main/resources`) |
|-------------|---------------------|----------------------------------------------|
| Development | `./gradlew run`     | `application.conf`                           |
| Production  | `./gradlew runProd` | `production.conf`                            |

### IntelliJ

Create a configuration of type `Application`.

###### Main class

    com.github.adeynack.finances.service.Main

###### Program arguments

Normally, nothing to be set there. Will run the development environment using `application.conf`.

For custom environment (ex: Production), set this to:

    -config=production.conf

###### Working directory

Should be by default set to the root of the project. It can also simply be set to:

    $MODULE_DIR$

###### Use classpath of module

    finances-service-ktor_main

## Package and run

Create a _distribution_. That will package all needed JARs in one folder, dependencies
and main project.

    ./gradlew installDist

Change directory to its result. This is the directory you want to publish.

    cd build/install/finances-service-ktor

Execute the generated script (use the `.bat` version if on Windows).

    bin/finances-service-ktor

