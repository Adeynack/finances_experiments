default: build

bindir:
	mkdir -p bin

finservice: bindir
	# ▶️  Build finservice (Finances Service)
	GO111MODULE=on go build -o bin/finservice cmd/finservice/*.go

fincli: bindir
	# ▶️  Build fincli (Finances CLI)
	GO111MODULE=on go build -o bin/fincli cmd/fincli/*.go

build: finservice fincli

run: finservice
	# ▶️  Starting bin/finservice
	bin/finservice

test:
	# ▶️  Executing tests
	GO111MODULE=on go test ./...

test-v:
	# ▶️  Executing tests (verbose)
	GO111MODULE=on go test -v ./...

vet:
	# ▶️  Running GO Vet
	GO111MODULE=on go vet -all ./...

clean:
	# ▶️  Cleaning the GO environment for this project (cache and test cache only)
	GO111MODULE=on go clean -cache -testcache -i ./...
	rm -rf bin

fmt: clean
	# ▶️  Formatting source code
	GO111MODULE=on go fmt ./...

check-fmt: clean
	# ▶️  Checking source formatting
	@if [ "$$(GO111MODULE=on gofmt -d .)" != "" ]; then false; else true; fi

lint:
	# ▶️  Linting   If this fails, execute: GO111MODULE=on golint ./...
	@if [ "$$(GO111MODULE=on golint -set_exit_status cmd/... pkg/...)" != "" ]; then false; else true; fi

check: clean check-fmt lint vet build test

ci-trigger: clean check-fmt build vet test-v

dev-env:
	# ▶️  Starting up local development dependencies (Ctrl-C to shut it down)
	docker-compose up

dev-db:
	#   Connecting to development database
	PGOPTIONS="--search_path=finances" psql -p 5433 -h localhost -U postgres finances-dev

dev-db-drop:
	# ▶️  Dropping development database
	psql -p 5433 -h localhost -U postgres -c 'DROP DATABASE "finances-dev"'

dev-db-create:
	# ▶️  Creating development database
	psql -p 5433 -h localhost -U postgres -f ./docs/database_scripts/create_dev_database.sql
