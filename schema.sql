-- To-do list schema:
DROP TABLE IF EXISTS todos;
DROP TABLE IF EXISTS lists;

CREATE TABLE lists (
  id serial PRIMARY KEY,
  name text UNIQUE NOT NULL
);

CREATE TABLE todos (
  id serial PRIMARY KEY,
  name text NOT NULL,
  list_id integer NOT NULL REFERENCES lists ON DELETE CASCADE,
  completed boolean NOT NULL DEFAULT false
);

INSERT INTO lists (name)
VALUES ('Homework'), ('Chores'), ('Misc');

INSERT INTO todos(name, list_id, completed)
VALUES ('Math', 1, false), ('Science', 1, false), ('Art', 1, true),
       ('Clean', 2, false), ('Cook', 2, false), ('Sleep', 2, true), ('Buy', 2, false);