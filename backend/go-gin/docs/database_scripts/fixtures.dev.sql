INSERT INTO users (id, email, display_name) values
  (1, 'root@foo.bar', 'I_Am_Root'),
  (2, 'david@something.net', 'David'),
  (3, 'joe@something.net', 'Joe');

INSERT INTO books (id, name, owner_id) values
  (1, 'David Book', 2),
  (2, 'Root Book 1', 1),
  (3, 'Root Book 2', 1),
  (4, 'David and Joe', 2),
  (5, 'Joe Book', 3);

INSERT INTO users_rights (user_id, book_id, role) values
  (1, null, 'admin'),
  (2, 3, 'read'),
  (3, 4, 'admin');
