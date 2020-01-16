CREATE TABLE users_rights (
  "id" BIGSERIAL PRIMARY KEY,
  "user_id" BIGINT NOT NULL REFERENCES "users" ("id"),
  "book_id" BIGINT REFERENCES "books" ("id"),
  "role" TEXT NOT NULL,
  --
  UNIQUE ("user_id", "book_id", "role")
);

