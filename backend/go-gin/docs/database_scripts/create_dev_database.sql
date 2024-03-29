CREATE DATABASE "finances-dev"
    WITH 
    OWNER = postgres
    ENCODING = 'UTF8'
    LC_COLLATE = 'en_US.utf8'
    LC_CTYPE = 'en_US.utf8'
    TABLESPACE = pg_default
    CONNECTION LIMIT = -1;

COMMENT ON DATABASE "finances-dev"
    IS 'Development data for the `finances` backend service';

\c finances-dev

CREATE SCHEMA finances;
