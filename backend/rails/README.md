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

# Notes for development

## Libs to consider

For JSON serialization
- [cache-crispies](https://github.com/codenoble/cache-crispies)

JSON-API Implementation
- [fast_jsonapi](https://github.com/Netflix/fast_jsonapi)

Batch Loading
- [graphql-batch](https://github.com/Shopify/graphql-batch)
- [Batch Loader](https://dev.to/usamaashraf/n1-queries-batch-loading--active-model-serializers-in-rails--3hkf)