-- Enable required extensions for advanced search capabilities
CREATE EXTENSION IF NOT EXISTS pg_trgm;
CREATE EXTENSION IF NOT EXISTS unaccent;

-- Create schema for cash management application
CREATE SCHEMA IF NOT EXISTS cash_management;

-- Payment table
CREATE TABLE cash_management.payments (
    payment_id SERIAL PRIMARY KEY,
    transaction_id VARCHAR(50) NOT NULL,
    payment_date TIMESTAMP NOT NULL,
    amount DECIMAL(15, 2) NOT NULL,
    currency VARCHAR(3) NOT NULL,
    payment_method VARCHAR(50) NOT NULL,
    status VARCHAR(20) NOT NULL,
    sender_name VARCHAR(100) NOT NULL,
    sender_account VARCHAR(50) NOT NULL,
    recipient_name VARCHAR(100) NOT NULL,
    recipient_account VARCHAR(50) NOT NULL,
    description TEXT,
    reference_number VARCHAR(50),
    category VARCHAR(50),
    tags TEXT[],
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Deposit table
CREATE TABLE cash_management.deposits (
    deposit_id SERIAL PRIMARY KEY,
    account_id VARCHAR(50) NOT NULL,
    deposit_date TIMESTAMP NOT NULL,
    amount DECIMAL(15, 2) NOT NULL,
    currency VARCHAR(3) NOT NULL,
    deposit_type VARCHAR(50) NOT NULL,
    status VARCHAR(20) NOT NULL,
    term_days INTEGER,
    interest_rate DECIMAL(5, 2),
    maturity_date TIMESTAMP,
    auto_renew BOOLEAN DEFAULT FALSE,
    depositor_name VARCHAR(100) NOT NULL,
    description TEXT,
    reference_number VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Loan table
CREATE TABLE cash_management.loans (
    loan_id SERIAL PRIMARY KEY,
    account_id VARCHAR(50) NOT NULL,
    loan_date TIMESTAMP NOT NULL,
    principal_amount DECIMAL(15, 2) NOT NULL,
    currency VARCHAR(3) NOT NULL,
    interest_rate DECIMAL(5, 2) NOT NULL,
    term_months INTEGER NOT NULL,
    payment_frequency VARCHAR(20) NOT NULL,
    status VARCHAR(20) NOT NULL,
    borrower_name VARCHAR(100) NOT NULL,
    purpose TEXT,
    collateral TEXT,
    reference_number VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create search index for payments
ALTER TABLE cash_management.payments ADD COLUMN search_vector tsvector;
CREATE INDEX payments_search_idx ON cash_management.payments USING GIN(search_vector);

-- Create trigger function to update search vector for payments
CREATE OR REPLACE FUNCTION cash_management.payments_search_vector_update() RETURNS trigger AS $$
BEGIN
    NEW.search_vector :=
        setweight(to_tsvector('english', COALESCE(NEW.transaction_id, '')), 'A') ||
        setweight(to_tsvector('english', COALESCE(NEW.payment_method, '')), 'B') ||
        setweight(to_tsvector('english', COALESCE(NEW.status, '')), 'B') ||
        setweight(to_tsvector('english', COALESCE(NEW.sender_name, '')), 'B') ||
        setweight(to_tsvector('english', COALESCE(NEW.recipient_name, '')), 'B') ||
        setweight(to_tsvector('english', COALESCE(NEW.description, '')), 'C') ||
        setweight(to_tsvector('english', COALESCE(NEW.reference_number, '')), 'A') ||
        setweight(to_tsvector('english', COALESCE(NEW.category, '')), 'C') ||
        setweight(to_tsvector('english', array_to_string(NEW.tags, ' ')), 'C');
    RETURN NEW;
END
$$ LANGUAGE plpgsql;

CREATE TRIGGER payments_search_vector_update
BEFORE INSERT OR UPDATE ON cash_management.payments
FOR EACH ROW EXECUTE FUNCTION cash_management.payments_search_vector_update();

-- Create search index for deposits
ALTER TABLE cash_management.deposits ADD COLUMN search_vector tsvector;
CREATE INDEX deposits_search_idx ON cash_management.deposits USING GIN(search_vector);

-- Create trigger function to update search vector for deposits
CREATE OR REPLACE FUNCTION cash_management.deposits_search_vector_update() RETURNS trigger AS $$
BEGIN
    NEW.search_vector :=
        setweight(to_tsvector('english', COALESCE(NEW.account_id, '')), 'A') ||
        setweight(to_tsvector('english', COALESCE(NEW.deposit_type, '')), 'B') ||
        setweight(to_tsvector('english', COALESCE(NEW.status, '')), 'B') ||
        setweight(to_tsvector('english', COALESCE(NEW.depositor_name, '')), 'B') ||
        setweight(to_tsvector('english', COALESCE(NEW.description, '')), 'C') ||
        setweight(to_tsvector('english', COALESCE(NEW.reference_number, '')), 'A');
    RETURN NEW;
END
$$ LANGUAGE plpgsql;

CREATE TRIGGER deposits_search_vector_update
BEFORE INSERT OR UPDATE ON cash_management.deposits
FOR EACH ROW EXECUTE FUNCTION cash_management.deposits_search_vector_update();

-- Create search index for loans
ALTER TABLE cash_management.loans ADD COLUMN search_vector tsvector;
CREATE INDEX loans_search_idx ON cash_management.loans USING GIN(search_vector);

-- Create trigger function to update search vector for loans
CREATE OR REPLACE FUNCTION cash_management.loans_search_vector_update() RETURNS trigger AS $$
BEGIN
    NEW.search_vector :=
        setweight(to_tsvector('english', COALESCE(NEW.account_id, '')), 'A') ||
        setweight(to_tsvector('english', COALESCE(NEW.status, '')), 'B') ||
        setweight(to_tsvector('english', COALESCE(NEW.borrower_name, '')), 'B') ||
        setweight(to_tsvector('english', COALESCE(NEW.purpose, '')), 'C') ||
        setweight(to_tsvector('english', COALESCE(NEW.collateral, '')), 'C') ||
        setweight(to_tsvector('english', COALESCE(NEW.reference_number, '')), 'A');
    RETURN NEW;
END
$$ LANGUAGE plpgsql;

CREATE TRIGGER loans_search_vector_update
BEFORE INSERT OR UPDATE ON cash_management.loans
FOR EACH ROW EXECUTE FUNCTION cash_management.loans_search_vector_update();

-- Create trigram indexes for fuzzy search and autocomplete
CREATE INDEX payments_trgm_idx ON cash_management.payments USING GIN (
    (
        COALESCE(transaction_id, '') || ' ' ||
        COALESCE(payment_method, '') || ' ' ||
        COALESCE(status, '') || ' ' ||
        COALESCE(sender_name, '') || ' ' ||
        COALESCE(recipient_name, '') || ' ' ||
        COALESCE(description, '') || ' ' ||
        COALESCE(reference_number, '') || ' ' ||
        COALESCE(category, '')
    ) gin_trgm_ops
);

CREATE INDEX deposits_trgm_idx ON cash_management.deposits USING GIN (
    (
        COALESCE(account_id, '') || ' ' ||
        COALESCE(deposit_type, '') || ' ' ||
        COALESCE(status, '') || ' ' ||
        COALESCE(depositor_name, '') || ' ' ||
        COALESCE(description, '') || ' ' ||
        COALESCE(reference_number, '')
    ) gin_trgm_ops
);

CREATE INDEX loans_trgm_idx ON cash_management.loans USING GIN (
    (
        COALESCE(account_id, '') || ' ' ||
        COALESCE(status, '') || ' ' ||
        COALESCE(borrower_name, '') || ' ' ||
        COALESCE(purpose, '') || ' ' ||
        COALESCE(collateral, '') || ' ' ||
        COALESCE(reference_number, '')
    ) gin_trgm_ops
);

-- Create a unified search view for all entities
CREATE OR REPLACE VIEW cash_management.unified_search AS
SELECT 
    'payment' AS entity_type,
    payment_id AS entity_id,
    transaction_id AS primary_identifier,
    payment_date AS date,
    amount,
    currency,
    status,
    sender_name || ' to ' || recipient_name AS party_info,
    description,
    reference_number,
    search_vector
FROM 
    cash_management.payments
UNION ALL
SELECT 
    'deposit' AS entity_type,
    deposit_id AS entity_id,
    account_id AS primary_identifier,
    deposit_date AS date,
    amount,
    currency,
    status,
    depositor_name AS party_info,
    description,
    reference_number,
    search_vector
FROM 
    cash_management.deposits
UNION ALL
SELECT 
    'loan' AS entity_type,
    loan_id AS entity_id,
    account_id AS primary_identifier,
    loan_date AS date,
    principal_amount AS amount,
    currency,
    status,
    borrower_name AS party_info,
    purpose AS description,
    reference_number,
    search_vector
FROM 
    cash_management.loans;

-- Create functions for search operations

-- Function for full text search across all entities
create function cash_management.search_all(search_term text)
    returns TABLE(entity_type text, entity_id integer, primary_identifier character varying, date timestamp without time zone, amount numeric, currency character varying, status character varying, party_info text, description text, reference_number character varying, rank double precision)
    language plpgsql
as
$$
BEGIN
    RETURN QUERY
        SELECT
            us.entity_type,
            us.entity_id,
            us.primary_identifier,
            us.date,
            us.amount,
            us.currency,
            us.status,
            us.party_info,
            us.description,
            us.reference_number,
            ts_rank(us.search_vector, to_tsquery('english', regexp_replace(search_term, '\s+', ':* & ', 'g') || ':*'))::double precision AS rank
        FROM
            cash_management.unified_search us
        WHERE
            us.search_vector @@ to_tsquery('english', regexp_replace(search_term, '\s+', ':* & ', 'g') || ':*')
        ORDER BY
            rank DESC;
END;
$$;

-- Function for fuzzy search with trigram similarity
create function cash_management.fuzzy_search(search_term text, similarity_threshold double precision DEFAULT 0.3)
    returns TABLE(entity_type text, entity_id integer, primary_identifier character varying, similarity double precision)
    language plpgsql
as
$$
BEGIN
    RETURN QUERY

        -- From payments
        SELECT
            'payment' AS entity_type,
            payment_id AS entity_id,
            transaction_id AS primary_identifier,
            GREATEST(
                    public.similarity(transaction_id, search_term)::double precision,
                    public.similarity(payment_method, search_term)::double precision,
                    public.similarity(sender_name, search_term)::double precision,
                    public.similarity(recipient_name, search_term)::double precision,
                    public.similarity(description, search_term)::double precision,
                    public.similarity(reference_number, search_term)::double precision,
                    public.similarity(category, search_term)::double precision
            ) AS similarity
        FROM cash_management.payments
        WHERE GREATEST(
                      public.similarity(transaction_id, search_term)::double precision,
                      public.similarity(payment_method, search_term)::double precision,
                      public.similarity(sender_name, search_term)::double precision,
                      public.similarity(recipient_name, search_term)::double precision,
                      public.similarity(description, search_term)::double precision,
                      public.similarity(reference_number, search_term)::double precision,
                      public.similarity(category, search_term)::double precision
              ) > similarity_threshold

        UNION ALL

        -- From deposits
        SELECT
            'deposit' AS entity_type,
            deposit_id AS entity_id,
            account_id AS primary_identifier,
            GREATEST(
                    public.similarity(account_id, search_term)::double precision,
                    public.similarity(deposit_type, search_term)::double precision,
                    public.similarity(depositor_name, search_term)::double precision,
                    public.similarity(description, search_term)::double precision,
                    public.similarity(reference_number, search_term)::double precision
            ) AS similarity
        FROM cash_management.deposits
        WHERE GREATEST(
                      public.similarity(account_id, search_term)::double precision,
                      public.similarity(deposit_type, search_term)::double precision,
                      public.similarity(depositor_name, search_term)::double precision,
                      public.similarity(description, search_term)::double precision,
                      public.similarity(reference_number, search_term)::double precision
              ) > similarity_threshold

        UNION ALL

        -- From loans
        SELECT
            'loan' AS entity_type,
            loan_id AS entity_id,
            account_id AS primary_identifier,
            GREATEST(
                    public.similarity(account_id, search_term)::double precision,
                    public.similarity(borrower_name, search_term)::double precision,
                    public.similarity(purpose, search_term)::double precision,
                    public.similarity(collateral, search_term)::double precision,
                    public.similarity(reference_number, search_term)::double precision
            ) AS similarity
        FROM cash_management.loans
        WHERE GREATEST(
                      public.similarity(account_id, search_term)::double precision,
                      public.similarity(borrower_name, search_term)::double precision,
                      public.similarity(purpose, search_term)::double precision,
                      public.similarity(collateral, search_term)::double precision,
                      public.similarity(reference_number, search_term)::double precision
              ) > similarity_threshold

        ORDER BY similarity DESC;

END;
$$;

-- Function for autocomplete suggestions
create function cash_management.autocomplete(prefix text, limit_count integer DEFAULT 10)
    returns TABLE(suggestion text, source_type text)
    language plpgsql
as
$$
BEGIN
    RETURN QUERY
        WITH terms AS (
            SELECT DISTINCT transaction_id::text AS term, 'transaction_id'::text AS source FROM cash_management.payments
            WHERE transaction_id ILIKE prefix || '%'
            UNION
            SELECT DISTINCT payment_method::text AS term, 'payment_method'::text AS source FROM cash_management.payments
            WHERE payment_method ILIKE prefix || '%'
            UNION
            SELECT DISTINCT sender_name::text AS term, 'sender_name'::text AS source FROM cash_management.payments
            WHERE sender_name ILIKE prefix || '%'
            UNION
            SELECT DISTINCT recipient_name::text AS term, 'recipient_name'::text AS source FROM cash_management.payments
            WHERE recipient_name ILIKE prefix || '%'
            UNION
            SELECT DISTINCT reference_number::text AS term, 'payments_reference_number'::text AS source FROM cash_management.payments
            WHERE reference_number ILIKE prefix || '%'
            UNION
            SELECT DISTINCT category::text AS term, 'category'::text AS source FROM cash_management.payments
            WHERE category ILIKE prefix || '%'
            UNION
            SELECT DISTINCT account_id::text AS term, 'account_id'::text AS source FROM cash_management.deposits
            WHERE account_id ILIKE prefix || '%'
            UNION
            SELECT DISTINCT deposit_type::text AS term, 'deposit_type'::text AS source FROM cash_management.deposits
            WHERE deposit_type ILIKE prefix || '%'
            UNION
            SELECT DISTINCT depositor_name::text AS term, 'depositor_name'::text AS source FROM cash_management.deposits
            WHERE depositor_name ILIKE prefix || '%'
            UNION
            SELECT DISTINCT reference_number::text AS term, 'deposits_reference_number'::text AS source FROM cash_management.deposits
            WHERE reference_number ILIKE prefix || '%'
            UNION
            SELECT DISTINCT account_id::text AS term, 'account_id'::text AS source FROM cash_management.loans
            WHERE account_id ILIKE prefix || '%'
            UNION
            SELECT DISTINCT borrower_name::text AS term, 'borrower_name'::text AS source FROM cash_management.loans
            WHERE borrower_name ILIKE prefix || '%'
            UNION
            SELECT DISTINCT reference_number::text AS term, 'loans_reference_number'::text AS source FROM cash_management.loans
            WHERE reference_number ILIKE prefix || '%'
        )
        SELECT term AS suggestion, source AS source_type
        FROM terms
        WHERE term IS NOT NULL AND term != ''
        ORDER BY
            CASE
                WHEN term ILIKE prefix THEN 0
                WHEN term ILIKE prefix || '%' THEN 1
                ELSE 2
                END,
            LENGTH(term),
            term
        LIMIT limit_count;
END;
$$;

-- Function for spelling correction suggestions
create function cash_management.spelling_suggestions(misspelled_term text, limit_count integer DEFAULT 5)
    returns TABLE(suggestion text, similarity double precision)
    language plpgsql
as
$$
BEGIN
    RETURN QUERY
        WITH all_terms AS (
            SELECT DISTINCT transaction_id::text AS term FROM cash_management.payments WHERE transaction_id IS NOT NULL
            UNION
            SELECT DISTINCT payment_method::text FROM cash_management.payments WHERE payment_method IS NOT NULL
            UNION
            SELECT DISTINCT sender_name::text FROM cash_management.payments WHERE sender_name IS NOT NULL
            UNION
            SELECT DISTINCT recipient_name::text FROM cash_management.payments WHERE recipient_name IS NOT NULL
            UNION
            SELECT DISTINCT category::text FROM cash_management.payments WHERE category IS NOT NULL
            UNION
            SELECT DISTINCT account_id::text FROM cash_management.deposits WHERE account_id IS NOT NULL
            UNION
            SELECT DISTINCT deposit_type::text FROM cash_management.deposits WHERE deposit_type IS NOT NULL
            UNION
            SELECT DISTINCT depositor_name::text FROM cash_management.deposits WHERE depositor_name IS NOT NULL
            UNION
            SELECT DISTINCT account_id::text FROM cash_management.loans WHERE account_id IS NOT NULL
            UNION
            SELECT DISTINCT borrower_name::text FROM cash_management.loans WHERE borrower_name IS NOT NULL
            UNION
            SELECT DISTINCT purpose::text FROM cash_management.loans WHERE purpose IS NOT NULL
            UNION
            SELECT DISTINCT reference_number::text FROM cash_management.payments WHERE reference_number IS NOT NULL
            UNION
            SELECT DISTINCT reference_number::text FROM cash_management.deposits WHERE reference_number IS NOT NULL
            UNION
            SELECT DISTINCT reference_number::text FROM cash_management.loans WHERE reference_number IS NOT NULL
        )
        SELECT
            term AS suggestion,
            public.similarity(term::text, misspelled_term::text)::double precision AS similarity
        FROM
            all_terms
        WHERE
            public.similarity(term::text, misspelled_term::text) > 0.3
        ORDER BY
            similarity DESC
        LIMIT limit_count;
END;
$$;