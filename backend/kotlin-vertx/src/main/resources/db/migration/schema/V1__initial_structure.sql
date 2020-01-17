CREATE TABLE users (
  id           BIGSERIAL PRIMARY KEY, -- uniquely identifies the user forever
  email        TEXT NOT NULL UNIQUE, -- uniquely identifies the user at this moment, can be changed but has to remain unique
  display_name TEXT NOT NULL -- courtesy name, to be displayed, but not used to uniquely identify the user
);

CREATE TABLE books (
  id       BIGSERIAL PRIMARY KEY,
  name     TEXT NOT NULL,
  owner_id BIGINT NOT NULL REFERENCES USERS (id),

  UNIQUE (name, owner_id)
);

CREATE TABLE users_rights (
  user_id BIGINT NOT NULL REFERENCES USERS (id),
  book_id BIGINT REFERENCES BOOKS (id),
  role    TEXT NOT NULL,

  UNIQUE (user_id, book_id, role)
);

