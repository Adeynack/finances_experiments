# README

# How to work with this project / Useful Commands

## Setup

To start working on this project (install dependencies, create and initialize
database, etc.):

```bash
bin/setup
```

On _macOS_, the _PostgreSQL_ Gem will not install without the binaries in
the path.

```bash
PATH=$PATH:/Applications/Postgres.app/Contents/Versions/latest/bin bin/setup
```

## Update database structure

When modifying the database (adding a migration script):

```bash
bin/update
```

## Run the tests

```bash
bin/rails test
```

## Start the Server

```bash
bin/rails server
```

