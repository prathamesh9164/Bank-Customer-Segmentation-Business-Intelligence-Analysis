-- ============================================================
-- 🏦 IndoSynth Gramin Bank — 01: Database Setup
-- ============================================================
-- Creates the database, all tables, loads CSV data,
-- verifies row counts, and creates performance indexes.
-- Run this first before any other script.
-- ============================================================

USE indosynth_bank;

-- ============================================================
-- PHASE 1: CREATE DATABASE
-- ============================================================

CREATE DATABASE IF NOT EXISTS indosynth_bank;
USE indosynth_bank;


-- ============================================================
-- PHASE 2: CREATE TABLES (Dependency Order)
-- ============================================================

-- ───────────────────────────────────────────────────────────
-- Table 1: regions (Parent — no FK dependencies)
-- ───────────────────────────────────────────────────────────
CREATE TABLE regions (
    region_id       INT PRIMARY KEY,
    region_name     VARCHAR(100) NOT NULL,
    zone            VARCHAR(20) NOT NULL,
    primary_state   VARCHAR(50) NOT NULL,
    states_covered  VARCHAR(50),
    num_states      INT DEFAULT 1
);

select * from regions;

-- ───────────────────────────────────────────────────────────
-- Table 2: loan_types (Parent — no FK dependencies)
-- ───────────────────────────────────────────────────────────
CREATE TABLE loan_types (
    loan_type_id        INT PRIMARY KEY,
    loan_type_name      VARCHAR(50) NOT NULL,
    description         VARCHAR(200),
    min_amount          DECIMAL(15,2),
    max_amount          DECIMAL(15,2),
    min_tenure_months   INT,
    max_tenure_months   INT,
    base_interest_rate  DECIMAL(5,2),
    processing_fee_pct  DECIMAL(5,2),
    collateral_required BOOLEAN,
    collateral_type     VARCHAR(30)
);

INSERT INTO loan_types (
    loan_type_id,
    loan_type_name,
    description,
    min_amount,
    max_amount,
    min_tenure_months,
    max_tenure_months,
    base_interest_rate,
    processing_fee_pct,
    collateral_required,
    collateral_type
)
VALUES
(1, 'Home Loan', 'Loan for purchase or construction of residential property', 500000, 50000000, 60, 360, 8.50, 0.50, TRUE, 'Property'),

(2, 'Personal Loan', 'Unsecured loan for personal expenses', 10000, 3000000, 12, 84, 11.50, 2.00, FALSE, NULL),

(3, 'Auto Loan', 'Loan for purchase of four-wheelers', 100000, 5000000, 12, 84, 9.25, 1.00, TRUE, 'Vehicle'),

(4, 'Education Loan', 'Loan for higher education in India or abroad', 50000, 2000000, 12, 180, 9.00, 0.00, FALSE, NULL),

(5, 'Business Loan', 'Loan for business expansion or working capital', 200000, 20000000, 12, 120, 12.00, 1.50, FALSE, NULL),

(6, 'Gold Loan', 'Loan against gold jewellery', 10000, 2000000, 3, 36, 10.50, 0.25, TRUE, 'Gold'),

(7, 'Agricultural Loan', 'Kisan credit card and farm loan for crop production', 10000, 1500000, 12, 60, 7.00, 0.00, FALSE, NULL),

(8, 'MSME Loan', 'Loan for micro, small and medium enterprises', 100000, 10000000, 12, 84, 11.00, 1.00, FALSE, NULL),

(9, 'Two-Wheeler Loan', 'Loan for purchase of motorcycles and scooters', 20000, 500000, 12, 60, 10.00, 1.25, TRUE, 'Vehicle'),

(10, 'Consumer Durable Loan', 'Loan for purchase of consumer electronics and appliances', 5000, 300000, 6, 36, 13.00, 2.50, FALSE, NULL);

select * from loan_types;

-- ───────────────────────────────────────────────────────────
-- Table 3: branches (FK → regions)
-- ───────────────────────────────────────────────────────────
CREATE TABLE branches (
    branch_id        INT PRIMARY KEY,
    branch_name      VARCHAR(150) NOT NULL,
    region_id        INT NOT NULL,
    city             VARCHAR(50) NOT NULL,
    state            VARCHAR(50) NOT NULL,
    zone             VARCHAR(20) NOT NULL,
    branch_type      VARCHAR(30),
    ifsc_code        VARCHAR(20) UNIQUE,
    micr_code        VARCHAR(20),
    established_date DATE,
    is_active        BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (region_id) REFERENCES regions(region_id)
);

select * from branches;

-- ───────────────────────────────────────────────────────────
-- Table 4: employees (FK → branches)
-- ───────────────────────────────────────────────────────────
CREATE TABLE employees (
    employee_id    INT PRIMARY KEY,
    branch_id      INT NOT NULL,
    first_name     VARCHAR(50),
    last_name      VARCHAR(50),
    full_name      VARCHAR(100),
    gender         VARCHAR(10),
    date_of_birth  DATE,
    designation    VARCHAR(50),
    grade          INT,
    department     VARCHAR(30),
    annual_salary  DECIMAL(12,2),
    joining_date   DATE,
    employee_code  VARCHAR(20) UNIQUE,
    email          VARCHAR(100),
    phone          VARCHAR(15),
    is_active      BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (branch_id) REFERENCES branches(branch_id)
);

select * from employees;

-- ───────────────────────────────────────────────────────────
-- Table 5: customers (FK → regions, branches)
-- ───────────────────────────────────────────────────────────
CREATE TABLE customers (
    customer_id      INT PRIMARY KEY,
    first_name       VARCHAR(50),
    last_name        VARCHAR(50),
    full_name        VARCHAR(100),
    gender           VARCHAR(10),
    date_of_birth    DATE,
    age              INT,
    marital_status   VARCHAR(20),
    education        VARCHAR(30),
    pan_number       VARCHAR(15),
    aadhaar_number   VARCHAR(20),
    phone_number     VARCHAR(15),
    email            VARCHAR(100),
    address          VARCHAR(200),
    city             VARCHAR(50),
    state            VARCHAR(50),
    pincode          VARCHAR(10),
    zone             VARCHAR(20),
    region_id        INT,
    branch_id        INT,
    employment_type  VARCHAR(30),
    occupation       VARCHAR(60),
    annual_income    DECIMAL(12,2),
    account_number   VARCHAR(20),
    account_type     VARCHAR(20),
    account_open_date DATE,
    kyc_status       VARCHAR(20),
    is_active        BOOLEAN DEFAULT TRUE,
    customer_segment VARCHAR(20),
    FOREIGN KEY (region_id) REFERENCES regions(region_id),
    FOREIGN KEY (branch_id) REFERENCES branches(branch_id)
);

SET GLOBAL local_infile = 1;

LOAD DATA LOCAL INFILE 'B:/Major Project/data/customers.csv'
INTO TABLE customers
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

select * from customers;

-- ───────────────────────────────────────────────────────────
-- Table 6: credit_history (FK → customers)
-- ───────────────────────────────────────────────────────────
CREATE TABLE credit_history (
    credit_history_id       INT PRIMARY KEY,
    customer_id             INT NOT NULL,
    credit_score            INT,
    credit_rating           VARCHAR(20),
    number_of_accounts      INT,
    number_of_delinquencies INT,
    total_outstanding_debt  DECIMAL(15,2),
    credit_utilization_pct  DECIMAL(5,2),
    payment_history_pct     DECIMAL(5,2),
    hard_inquiries_last_6m  INT,
    oldest_account_years    INT,
    last_updated_date       DATE,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

select count(*) from credit_history;

-- ───────────────────────────────────────────────────────────
-- Table 7: loan_applications (FK → customers, loan_types, branches, employees)
-- ───────────────────────────────────────────────────────────
CREATE TABLE loan_applications (
    application_id            INT PRIMARY KEY,
    customer_id               INT NOT NULL,
    loan_type_id              INT NOT NULL,
    loan_type_name            VARCHAR(50),
    branch_id                 INT,
    officer_employee_id       INT,
    application_date          DATE,
    loan_amount_requested     bigint,
    loan_amount_approved      bigint,
    tenure_months             INT,
    interest_rate_pct         DECIMAL(5,2),
    processing_fee            DECIMAL(12,2),
    emi_amount                DECIMAL(12,2),
    status                    VARCHAR(20),
    rejection_reason          VARCHAR(100),
    purpose                   VARCHAR(100),
    collateral_required       BOOLEAN,
    collateral_type           VARCHAR(30),
    disbursement_date         DATE,
    credit_score_at_application INT,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (loan_type_id) REFERENCES loan_types(loan_type_id),
    FOREIGN KEY (branch_id) REFERENCES branches(branch_id),
    FOREIGN KEY (officer_employee_id) REFERENCES employees(employee_id)
);

LOAD DATA LOCAL INFILE 'B:/Major Project/data/loan_applications.csv'
INTO TABLE loan_applications
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
    application_id, customer_id, loan_type_id, @loan_type_name,
    @branch_id, @officer_employee_id, @application_date,
    @loan_amount_requested, @loan_amount_approved, @tenure_months,
    @interest_rate_pct, @processing_fee, @emi_amount,
    @status, @rejection_reason, @purpose,
    @collateral_required, @collateral_type,
    @disbursement_date, @credit_score_at_application
)
SET
    loan_type_name            = NULLIF(@loan_type_name, ''),
    branch_id                 = NULLIF(@branch_id, ''),
    officer_employee_id       = NULLIF(@officer_employee_id, ''),
    application_date          = NULLIF(@application_date, ''),
    loan_amount_requested     = NULLIF(@loan_amount_requested, ''),
    loan_amount_approved      = NULLIF(@loan_amount_approved, ''),
    tenure_months             = NULLIF(@tenure_months, ''),
    interest_rate_pct         = NULLIF(@interest_rate_pct, ''),
    processing_fee            = NULLIF(@processing_fee, ''),
    emi_amount                = NULLIF(@emi_amount, ''),
    status                    = NULLIF(@status, ''),
    rejection_reason          = NULLIF(@rejection_reason, ''),
    purpose                   = NULLIF(@purpose, ''),
    collateral_required       = NULLIF(@collateral_required, ''),
    collateral_type           = NULLIF(@collateral_type, ''),
    disbursement_date         = NULLIF(@disbursement_date, ''),
    credit_score_at_application = NULLIF(@credit_score_at_application, '');

select count(*) from loan_applications;

-- ───────────────────────────────────────────────────────────
-- Table 8: loan_payments (FK → loan_applications, customers)
-- ───────────────────────────────────────────────────────────
CREATE TABLE loan_payments (
    payment_id          INT PRIMARY KEY,
    application_id      INT NOT NULL,
    customer_id         INT NOT NULL,
    payment_number      INT,
    due_date            DATE,
    payment_date        DATE,
    emi_amount          DECIMAL(12,2),
    principal_paid      DECIMAL(12,2),
    interest_paid       DECIMAL(12,2),
    penalty_amount      DECIMAL(12,2),
    payment_status      VARCHAR(20),
    days_late           INT DEFAULT 0,
    outstanding_balance DECIMAL(15,2),
    FOREIGN KEY (application_id) REFERENCES loan_applications(application_id),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

LOAD DATA LOCAL INFILE 'B:/Major Project/data/loan_payments.csv'
INTO TABLE loan_payments
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
    payment_id, application_id, customer_id, @payment_number,
    @due_date, @payment_date, @emi_amount, @principal_paid,
    @interest_paid, @penalty_amount, @payment_status,
    @days_late, @outstanding_balance
)
SET
    payment_number      = NULLIF(@payment_number, ''),
    due_date            = NULLIF(@due_date, ''),
    payment_date        = NULLIF(@payment_date, ''),
    emi_amount          = NULLIF(@emi_amount, ''),
    principal_paid      = NULLIF(@principal_paid, ''),
    interest_paid       = NULLIF(@interest_paid, ''),
    penalty_amount      = NULLIF(@penalty_amount, ''),
    payment_status      = NULLIF(@payment_status, ''),
    days_late           = NULLIF(@days_late, ''),
    outstanding_balance = NULLIF(@outstanding_balance, '');

select * from loan_payments;

-- ───────────────────────────────────────────────────────────
-- Table 9: transactions (FK → customers, branches)
-- ───────────────────────────────────────────────────────────
CREATE TABLE transactions (
    transaction_id    INT PRIMARY KEY,
    customer_id       INT NOT NULL,
    transaction_date  DATE,
    transaction_type  VARCHAR(10),
    transaction_mode  VARCHAR(20),
    amount            DECIMAL(15,2),
    balance_after     DECIMAL(15,2),
    category          VARCHAR(50),
    merchant_name     VARCHAR(60),
    reference_number  VARCHAR(30),
    description       VARCHAR(150),
    branch_id         INT,
    status            VARCHAR(20),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (branch_id) REFERENCES branches(branch_id)
);

LOAD DATA LOCAL INFILE 'B:/Major Project/data/transactions.csv'
INTO TABLE transactions
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
    transaction_id, customer_id, @transaction_date, @transaction_type,
    @transaction_mode, @amount, @balance_after, @category,
    @merchant_name, @reference_number, @description,
    @branch_id, @status
)
SET
    transaction_date  = NULLIF(@transaction_date, ''),
    transaction_type  = NULLIF(@transaction_type, ''),
    transaction_mode  = NULLIF(@transaction_mode, ''),
    amount            = NULLIF(@amount, ''),
    balance_after     = NULLIF(@balance_after, ''),
    category          = NULLIF(@category, ''),
    merchant_name     = NULLIF(@merchant_name, ''),
    reference_number  = NULLIF(@reference_number, ''),
    description       = NULLIF(@description, ''),
    branch_id         = NULLIF(@branch_id, ''),
    status            = NULLIF(@status, '');


-- ============================================================
-- PHASE 3: LOAD CSV DATA (via Import Wizard)
-- ============================================================
-- Use MySQL Workbench → Table Data Import Wizard
-- Load CSVs from B:/Major Project/ in this order:
--   1. regions.csv        → regions
--   2. loan_types.csv     → loan_types
--   3. branches.csv       → branches
--   4. employees.csv      → employees
--   5. customers.csv      → customers
--   6. credit_history.csv → credit_history
--   7. loan_applications.csv → loan_applications
--   8. loan_payments.csv  → loan_payments
--   9. transactions.csv   → transactions
-- ============================================================


-- ============================================================
-- PHASE 4: VERIFY DATA LOAD
-- ============================================================

SELECT 'regions' AS table_name, COUNT(*) AS row_count FROM regions
UNION ALL SELECT 'loan_types', COUNT(*) FROM loan_types
UNION ALL SELECT 'branches', COUNT(*) FROM branches
UNION ALL SELECT 'employees', COUNT(*) FROM employees
UNION ALL SELECT 'customers', COUNT(*) FROM customers
UNION ALL SELECT 'credit_history', COUNT(*) FROM credit_history
UNION ALL SELECT 'loan_applications', COUNT(*) FROM loan_applications
UNION ALL SELECT 'loan_payments', COUNT(*) FROM loan_payments
UNION ALL SELECT 'transactions', COUNT(*) FROM transactions;


-- ============================================================
-- PHASE 5: CREATE INDEXES FOR PERFORMANCE
-- ============================================================

-- Customers
CREATE INDEX idx_customers_region ON customers(region_id);
CREATE INDEX idx_customers_branch ON customers(branch_id);
CREATE INDEX idx_customers_segment ON customers(customer_segment);
CREATE INDEX idx_customers_state ON customers(state);

-- Credit History
CREATE INDEX idx_credit_customer ON credit_history(customer_id);
CREATE INDEX idx_credit_score ON credit_history(credit_score);
CREATE INDEX idx_credit_rating ON credit_history(credit_rating);

-- Loan Applications
CREATE INDEX idx_loan_app_customer ON loan_applications(customer_id);
CREATE INDEX idx_loan_app_type ON loan_applications(loan_type_id);
CREATE INDEX idx_loan_app_status ON loan_applications(status);
CREATE INDEX idx_loan_app_date ON loan_applications(application_date);
CREATE INDEX idx_loan_app_branch ON loan_applications(branch_id);

-- Loan Payments
CREATE INDEX idx_payment_app ON loan_payments(application_id);
CREATE INDEX idx_payment_customer ON loan_payments(customer_id);
CREATE INDEX idx_payment_status ON loan_payments(payment_status);
CREATE INDEX idx_payment_due_date ON loan_payments(due_date);

-- Transactions
CREATE INDEX idx_txn_customer ON transactions(customer_id);
CREATE INDEX idx_txn_date ON transactions(transaction_date);
CREATE INDEX idx_txn_type ON transactions(transaction_type);
CREATE INDEX idx_txn_category ON transactions(category);
CREATE INDEX idx_txn_status ON transactions(status);


-- ============================================================
-- END OF DATABASE SETUP
-- ============================================================
