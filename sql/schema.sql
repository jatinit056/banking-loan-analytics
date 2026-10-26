/* =====================================================================
   Banking Customer & Loan Analytics (LendingClub 2007–2011) - schema
   Database : PostgreSQL 13+ (tested on PostgreSQL 16)
   Run      : psql -d lending_db -f sql/schema.sql
   The loans table holds the CLEANED loan file produced by the notebook
   (data/cleaned/loans_clean.csv): one row per loan = one borrower.
   ===================================================================== */

DROP SCHEMA IF EXISTS lending CASCADE;
CREATE SCHEMA lending;
SET search_path TO lending;

-- Reference table (US Census Bureau regions; not from LendingClub) - includes states with no loans
CREATE TABLE states (
    state_code CHAR(2) PRIMARY KEY,
    state_name TEXT NOT NULL,
    region     TEXT NOT NULL
);

CREATE TABLE loans (
    id                      INTEGER PRIMARY KEY,
    member_id               INTEGER NOT NULL UNIQUE,
    issue_d                 DATE NOT NULL,          -- first day of the issue month
    issue_year              SMALLINT NOT NULL,
    issue_quarter           TEXT NOT NULL,          -- e.g. 2011Q4
    issue_month             TEXT NOT NULL,          -- e.g. 2011-12
    loan_amnt               NUMERIC(10, 2) NOT NULL, -- amount requested
    funded_amnt             NUMERIC(10, 2) NOT NULL, -- amount committed to the loan
    funded_amnt_inv         NUMERIC(14, 6) NOT NULL, -- part funded by investors
    funding_gap             NUMERIC(10, 2) NOT NULL, -- requested - funded
    term_months             SMALLINT NOT NULL CHECK (term_months IN (36, 60)),
    int_rate                NUMERIC(5, 2) NOT NULL,  -- % per year
    installment             NUMERIC(10, 2) NOT NULL, -- monthly payment
    grade                   CHAR(1) NOT NULL,
    sub_grade               CHAR(2) NOT NULL,
    purpose                 TEXT NOT NULL,
    title                   TEXT,
    emp_title               TEXT,
    emp_length              TEXT NOT NULL,           -- '< 1 year' ... '10+ years', 'Unknown'
    emp_length_years        SMALLINT,
    home_ownership          TEXT NOT NULL,
    annual_inc              NUMERIC(12, 2),
    income_band             TEXT,
    is_high_income          BOOLEAN NOT NULL,        -- top 10% income
    verification_status     TEXT NOT NULL,
    addr_state              CHAR(2) NOT NULL REFERENCES states (state_code),
    region                  TEXT NOT NULL,
    zip_code                TEXT,                    -- first 3 digits, e.g. 860xx
    dti                     NUMERIC(5, 2) NOT NULL,  -- debt-to-income %
    dti_band                TEXT,
    delinq_2yrs             SMALLINT,
    inq_last_6mths          SMALLINT,
    open_acc                SMALLINT,
    pub_rec                 SMALLINT,
    revol_bal               NUMERIC(12, 2),
    revol_util              NUMERIC(5, 1),
    revol_util_band         TEXT,
    total_acc               SMALLINT,
    earliest_cr_line        DATE,
    credit_history_years    NUMERIC(5, 1),
    loan_amount_band        TEXT,
    installment_to_income   NUMERIC(10, 6),
    loan_status             TEXT NOT NULL,           -- original status (policy prefix removed)
    meets_credit_policy     BOOLEAN NOT NULL,
    outcome                 TEXT NOT NULL CHECK (outcome IN ('Fully Paid', 'Charged Off', 'Active')),
    is_resolved             BOOLEAN NOT NULL,
    is_bad                  BOOLEAN NOT NULL,
    total_pymnt             NUMERIC(14, 6) NOT NULL,
    total_rec_prncp         NUMERIC(12, 2) NOT NULL,
    total_rec_int           NUMERIC(12, 2) NOT NULL,
    total_rec_late_fee      NUMERIC(14, 6) NOT NULL,
    recoveries              NUMERIC(14, 6) NOT NULL,
    collection_recovery_fee NUMERIC(14, 6) NOT NULL,
    out_prncp               NUMERIC(12, 2) NOT NULL,
    last_pymnt_d            DATE,
    last_pymnt_amnt         NUMERIC(12, 2),
    net_return              NUMERIC(12, 6),          -- resolved loans only
    net_principal_loss      NUMERIC(14, 6) NOT NULL  -- charged-off loans only, else 0
);

CREATE INDEX idx_loans_grade   ON loans (grade);
CREATE INDEX idx_loans_state   ON loans (addr_state);
CREATE INDEX idx_loans_issue   ON loans (issue_d);
CREATE INDEX idx_loans_outcome ON loans (outcome);
