SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


--
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


--
-- Name: account_type; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.account_type AS ENUM (
    'expense',
    'income',
    'other',
    'bank',
    'card',
    'investment',
    'asset',
    'liability',
    'loan'
);


--
-- Name: user_right_type; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.user_right_type AS ENUM (
    'own',
    'read',
    'write'
);


SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: accounts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.accounts (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    book_id uuid NOT NULL,
    parent_id uuid,
    name character varying NOT NULL,
    type public.account_type NOT NULL,
    info jsonb,
    notes character varying,
    currency_id uuid NOT NULL,
    initial_balance integer,
    active boolean DEFAULT true
);


--
-- Name: COLUMN accounts.info; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.accounts.info IS 'A JSON structure containing details about the account. Different account type have different fields.';


--
-- Name: COLUMN accounts.currency_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.accounts.currency_id IS 'Currency in which this account operates.';


--
-- Name: COLUMN accounts.initial_balance; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.accounts.initial_balance IS 'Balance when this account is entered in the system (or `null` for 0).';


--
-- Name: COLUMN accounts.active; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.accounts.active IS 'Inactive accounts stay in the system for historical purposes but are not displayed to the user by default.';


--
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: book_rights; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.book_rights (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    book_id bigint,
    user_id bigint NOT NULL,
    "right" public.user_right_type NOT NULL
);


--
-- Name: books; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.books (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    name character varying NOT NULL,
    owner_id uuid NOT NULL
);


--
-- Name: currencies; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.currencies (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    code character varying,
    book_id uuid,
    name character varying NOT NULL,
    prefix character varying,
    suffix character varying
);


--
-- Name: COLUMN currencies.code; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.currencies.code IS 'ISO-4217 Code (https://en.wikipedia.org/wiki/ISO_4217)';


--
-- Name: COLUMN currencies.book_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.currencies.book_id IS 'Known currencies are general and do not belong to any book (null); custom currencies belong to a specific book.';


--
-- Name: COLUMN currencies.prefix; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.currencies.prefix IS 'Text or symbol to prefix when displaying an amount in this currency.';


--
-- Name: COLUMN currencies.suffix; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.currencies.suffix IS 'Text or symbol to suffix when displaying an amount in this currency.';


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying NOT NULL
);


--
-- Name: sessions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sessions (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    user_id uuid NOT NULL,
    expired_at timestamp without time zone,
    last_active_at timestamp without time zone,
    user_agent character varying,
    ip character varying
);


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    email character varying NOT NULL,
    display_name character varying NOT NULL,
    password_digest character varying
);


--
-- Name: accounts accounts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.accounts
    ADD CONSTRAINT accounts_pkey PRIMARY KEY (id);


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: book_rights book_rights_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.book_rights
    ADD CONSTRAINT book_rights_pkey PRIMARY KEY (id);


--
-- Name: books books_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.books
    ADD CONSTRAINT books_pkey PRIMARY KEY (id);


--
-- Name: currencies currencies_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.currencies
    ADD CONSTRAINT currencies_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: sessions sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sessions
    ADD CONSTRAINT sessions_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: index_accounts_on_active; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_accounts_on_active ON public.accounts USING btree (active);


--
-- Name: index_accounts_on_book_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_accounts_on_book_id ON public.accounts USING btree (book_id);


--
-- Name: index_accounts_on_book_id_and_parent_id_and_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_accounts_on_book_id_and_parent_id_and_name ON public.accounts USING btree (book_id, parent_id, name);


--
-- Name: index_accounts_on_currency_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_accounts_on_currency_id ON public.accounts USING btree (currency_id);


--
-- Name: index_accounts_on_parent_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_accounts_on_parent_id ON public.accounts USING btree (parent_id);


--
-- Name: index_accounts_on_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_accounts_on_type ON public.accounts USING btree (type);


--
-- Name: index_book_rights_on_book_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_book_rights_on_book_id ON public.book_rights USING btree (book_id);


--
-- Name: index_book_rights_on_book_id_and_user_id_and_right; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_book_rights_on_book_id_and_user_id_and_right ON public.book_rights USING btree (book_id, user_id, "right");


--
-- Name: index_book_rights_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_book_rights_on_user_id ON public.book_rights USING btree (user_id);


--
-- Name: index_books_on_name_and_owner_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_books_on_name_and_owner_id ON public.books USING btree (name, owner_id);


--
-- Name: index_books_on_owner_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_books_on_owner_id ON public.books USING btree (owner_id);


--
-- Name: index_currencies_on_book_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_currencies_on_book_id ON public.currencies USING btree (book_id);


--
-- Name: index_currencies_on_code_and_book_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_currencies_on_code_and_book_id ON public.currencies USING btree (code, book_id);


--
-- Name: index_sessions_on_expired_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_sessions_on_expired_at ON public.sessions USING btree (expired_at);


--
-- Name: index_sessions_on_last_active_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_sessions_on_last_active_at ON public.sessions USING btree (last_active_at);


--
-- Name: index_sessions_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_sessions_on_user_id ON public.sessions USING btree (user_id);


--
-- Name: index_users_on_display_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_display_name ON public.users USING btree (display_name);


--
-- Name: index_users_on_email; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_email ON public.users USING btree (email);


--
-- Name: books fk_rails_1b1e135573; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.books
    ADD CONSTRAINT fk_rails_1b1e135573 FOREIGN KEY (owner_id) REFERENCES public.users(id);


--
-- Name: accounts fk_rails_6d4abe3723; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.accounts
    ADD CONSTRAINT fk_rails_6d4abe3723 FOREIGN KEY (parent_id) REFERENCES public.accounts(id);


--
-- Name: accounts fk_rails_a9fc9e89e5; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.accounts
    ADD CONSTRAINT fk_rails_a9fc9e89e5 FOREIGN KEY (book_id) REFERENCES public.books(id);


--
-- Name: accounts fk_rails_dd73f000d2; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.accounts
    ADD CONSTRAINT fk_rails_dd73f000d2 FOREIGN KEY (currency_id) REFERENCES public.currencies(id);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO "schema_migrations" (version) VALUES
('20190406213358'),
('20190406213400'),
('20190406213401'),
('20190406213402'),
('20190414223259'),
('20190414223400'),
('20190414223406'),
('20200212182458'),
('20200212183816'),
('20200212184830');


