CREATE TYPE account_type AS ENUM (
    -- categories
    'expense',
    'income',
    -- accounts
    'other',
    'bank',
    'card',
    'investment',
    'asset',
    'liability',
    'loan'
);

CREATE TABLE accounts (
    "id" BIGSERIAL PRIMARY KEY,
    "name" TEXT NOT NULL,
    "type" account_type NOT NULL,
    "book_id" BIGINT REFERENCES books (id),
    --
    UNIQUE ("name", "book_id")
);

