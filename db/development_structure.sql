--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = off;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET escape_string_warning = off;

--
-- Name: plpgsql; Type: PROCEDURAL LANGUAGE; Schema: -; Owner: -
--

CREATE OR REPLACE PROCEDURAL LANGUAGE plpgsql;


SET search_path = public, pg_catalog;

--
-- Name: transaction_update_timestamps(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION transaction_update_timestamps() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
      begin
        -- update
        if OLD != NULL then
          if OLD.reconciled = false and NEW.reconciled = true then
            NEW.locked := true;
          end if;
          if OLD.locked = true then
            -- unlocking record
            if NEW.locked = false then
              NEW.locked_at := _null_;
            end if;
          else
            -- locking record
            if NEW.locked = true then
              NEW.locked_at := current_timestamp;
            end if;
          end if;
        else
          -- insert
          if NEW.reconciled then
            NEW.reconciled_at := current_timestamp;
            NEW.locked := true;
          end if;
          if NEW.locked then
            NEW.locked_at := current_timestamp;
          end if;
        end if;
        return NEW;
      end
      $$;


--
-- Name: transaction_validate_on_update(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION transaction_validate_on_update() RETURNS trigger
    LANGUAGE plpgsql
    AS $_$
      begin
        if OLD.reconciled = true then
          if NEW.reconciled = false then
            raise exception $$It is not possible to unreconcile a transaction after it has been reconciled.$$;
          elsif OLD.debit_account_id IS DISTINCT FROM NEW.debit_account_id then
            raise exception $$This record is reconciled and does not allow updating 'debit_account_id'.$$;
          elsif OLD.credit_account_id IS DISTINCT FROM NEW.credit_account_id then
            raise exception $$This record is reconciled and does not allow updating 'credit_account_id'.$$;
          elsif OLD.amount IS DISTINCT FROM NEW.amount then
            raise exception $$This record is reconciled and does not allow updating 'amount'.$$;
          elsif OLD.reconciled IS DISTINCT FROM NEW.reconciled then
            raise exception $$This record is reconciled and does not allow updating 'reconciled'.$$;
          elsif OLD.date IS DISTINCT FROM NEW.date then
            raise exception $$This record is reconciled and does not allow updating 'date'.$$;
          elsif OLD.text IS DISTINCT FROM NEW.text then
            raise exception $$This record is reconciled and does not allow updating 'text'.$$;
          end if;
        end if;
        if OLD.locked = true then
          if OLD.debit_account_id IS DISTINCT FROM NEW.debit_account_id then
            raise exception $$This record is locked and does not allow updating 'debit_account_id'.$$;
          elsif OLD.credit_account_id IS DISTINCT FROM NEW.credit_account_id then
            raise exception $$This record is locked and does not allow updating 'credit_account_id'.$$;
          elsif OLD.amount IS DISTINCT FROM NEW.amount then
            raise exception $$This record is locked and does not allow updating 'amount'.$$;
          elsif OLD.reconciled IS DISTINCT FROM NEW.reconciled then
            raise exception $$This record is locked and does not allow updating 'reconciled'.$$;
          elsif OLD.date IS DISTINCT FROM NEW.date then
            raise exception $$This record is locked and does not allow updating 'date'.$$;
          elsif OLD.text IS DISTINCT FROM NEW.text then
            raise exception $$This record is locked and does not allow updating 'text'.$$;
          elsif OLD.notes IS DISTINCT FROM NEW.notes then
            raise exception $$This record is locked and does not allow updating 'notes'.$$;
          end if;
        end if;
        return NEW;
      end
      $_$;


--
-- Name: transaction_validate_on_update_insert(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION transaction_validate_on_update_insert() RETURNS trigger
    LANGUAGE plpgsql
    AS $_$
      begin
        if NEW.debit_account_id IS NOT DISTINCT FROM NEW.credit_account_id then
          raise exception $$Debit and credit accounts cannot be identical.$$;
        end if;
        return NEW;
      end
      $_$;


SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: account_types; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE account_types (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: account_types_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE account_types_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: account_types_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE account_types_id_seq OWNED BY account_types.id;


--
-- Name: accounts; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE accounts (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    account_type_id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: accounts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE accounts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: accounts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE accounts_id_seq OWNED BY accounts.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE schema_migrations (
    version character varying(255) NOT NULL
);


--
-- Name: transactions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE transactions (
    id integer NOT NULL,
    date date NOT NULL,
    debit_account_id integer NOT NULL,
    credit_account_id integer NOT NULL,
    amount numeric NOT NULL,
    text character varying(255) NOT NULL,
    notes text,
    locked boolean DEFAULT false NOT NULL,
    locked_at timestamp without time zone,
    reconciled boolean DEFAULT false NOT NULL,
    reconciled_at timestamp without time zone,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: transactions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE transactions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: transactions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE transactions_id_seq OWNED BY transactions.id;


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE account_types ALTER COLUMN id SET DEFAULT nextval('account_types_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE accounts ALTER COLUMN id SET DEFAULT nextval('accounts_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE transactions ALTER COLUMN id SET DEFAULT nextval('transactions_id_seq'::regclass);


--
-- Name: account_types_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY account_types
    ADD CONSTRAINT account_types_pkey PRIMARY KEY (id);


--
-- Name: accounts_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY accounts
    ADD CONSTRAINT accounts_pkey PRIMARY KEY (id);


--
-- Name: transactions_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY transactions
    ADD CONSTRAINT transactions_pkey PRIMARY KEY (id);


--
-- Name: index_transactions_on_amount; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_transactions_on_amount ON transactions USING btree (amount);


--
-- Name: index_transactions_on_credit_account_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_transactions_on_credit_account_id ON transactions USING btree (credit_account_id);


--
-- Name: index_transactions_on_date; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_transactions_on_date ON transactions USING btree (date);


--
-- Name: index_transactions_on_debit_account_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_transactions_on_debit_account_id ON transactions USING btree (debit_account_id);


--
-- Name: index_transactions_on_text; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_transactions_on_text ON transactions USING btree (text);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


--
-- Name: transaction_update_timestamps_ui_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER transaction_update_timestamps_ui_trigger BEFORE INSERT OR UPDATE ON transactions FOR EACH ROW EXECUTE PROCEDURE transaction_update_timestamps();


--
-- Name: transaction_validate_on_update_insert_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER transaction_validate_on_update_insert_trigger BEFORE INSERT OR UPDATE ON transactions FOR EACH ROW EXECUTE PROCEDURE transaction_validate_on_update_insert();


--
-- Name: transaction_validate_u_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER transaction_validate_u_trigger BEFORE UPDATE ON transactions FOR EACH ROW EXECUTE PROCEDURE transaction_validate_on_update();


--
-- Name: accounts_account_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY accounts
    ADD CONSTRAINT accounts_account_type_id_fkey FOREIGN KEY (account_type_id) REFERENCES account_types(id);


--
-- Name: transactions_credit_account_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY transactions
    ADD CONSTRAINT transactions_credit_account_id_fkey FOREIGN KEY (credit_account_id) REFERENCES accounts(id);


--
-- Name: transactions_debit_account_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY transactions
    ADD CONSTRAINT transactions_debit_account_id_fkey FOREIGN KEY (debit_account_id) REFERENCES accounts(id);


--
-- PostgreSQL database dump complete
--

INSERT INTO schema_migrations (version) VALUES ('20110920233742');

INSERT INTO schema_migrations (version) VALUES ('20110920234137');

INSERT INTO schema_migrations (version) VALUES ('20110921005219');

INSERT INTO schema_migrations (version) VALUES ('20110921043139');

INSERT INTO schema_migrations (version) VALUES ('20110921230047');

INSERT INTO schema_migrations (version) VALUES ('20111106024034');