CREATE TABLE transactions (
    "id" BIGSERIAL PRIMARY KEY,
    "transaction_date" DATE NOT NULL,
    "source_account_id" BIGINT REFERENCES "accounts" ("id"),
    "summary" TEXT,
    "description" TEXT
);

CREATE TABLE transactions_splits (
    "id" BIGSERIAL PRIMARY KEY,
    "transaction_id" BIGINT REFERENCES "transactions" ("id") NOT NULL,
    "destination_account_id" BIGINT REFERENCES "accounts" ("id") NOT NULL,
    "amount" INTEGER NOT NULL,
    "summary" TEXT,
    "description" TEXT
);

