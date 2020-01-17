.PHONY: build run generate-jooq-source


run: build
	docker run --name sample-db -e POSTGRES_PASSWORD=postgres -e POSTGRES_DB=sample -d -p5433:5432 postgres:9.6.6-alpine
	until docker run --rm --link sample-db:pg postgres:9.6.6-alpine pg_isready -U postgres -h pg; do sleep 1; done
	JOOQ_SAMPLE_OPTS="-Ddb.url=jdbc:postgresql://localhost:5433/sample -Ddb.user=postgres -Ddb.password=postgres" ./build/install/jooq-sample/bin/jooq-sample
	docker rm -f sample-db


build: generate-jooq-source
	./gradlew clean check installDist


generate-jooq-source:
	docker run --name sample-db-gen -e POSTGRES_PASSWORD=postgres -e POSTGRES_DB=sample -d -p5433:5432 postgres:9.6.6-alpine
	until docker run --rm --link sample-db-gen:pg postgres:9.6.6-alpine pg_isready -U postgres -h pg; do sleep 1; done
	./gradlew flywayMigrate -Pflyway.url=jdbc:postgresql://localhost:5433/sample -Pflyway.user=postgres -Pflyway.password=postgres -Pflyway.schemas=finances
	./gradlew generateJooqSource -Pjooq.url=jdbc:postgresql://localhost:5433/sample -Pjooq.user=postgres -Pjooq.password=postgres -Pjooq.schema=finances
	docker rm -f sample-db-gen

