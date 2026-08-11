-- ============================================================
-- 🏦 IndoSynth Gramin Bank — Complete MySQL Script
-- ============================================================
-- Run this script in MySQL Workbench (8.0+)
-- Ensure CSVs are placed at: B:/Major Project/data/
-- ============================================================


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
-- PHASE 6: ANALYTICAL SQL QUERIES (25+ Queries)
-- ============================================================


-- ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
-- 🟢 BASIC LEVEL (Q1 – Q8)
-- ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

-- Q1: Total customers by zone
SELECT zone, COUNT(*) AS total_customers
FROM customers
GROUP BY zone
ORDER BY total_customers DESC;
-- WHAT: Counts the number of customers in each geographic zone (North, South, East, West).
-- WHY:  Helps identify which zones have the highest customer concentration,
--       useful for regional marketing strategies and resource allocation.

-- Q2: Loan type distribution — how many applications per loan product
SELECT loan_type_name, COUNT(*) AS applications
FROM loan_applications
GROUP BY loan_type_name
ORDER BY applications DESC;
-- WHAT: Shows how many loan applications exist for each loan product (Home, Personal, Agri, etc.).
-- WHY:  Reveals which loan products are most popular, guiding the bank on which products
--       to promote more and which may need better marketing.

-- Q3: Application status breakdown with percentage
SELECT status, COUNT(*) AS count,
       ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS pct
FROM loan_applications
GROUP BY status;
-- WHAT: Breaks down loan applications by status (Approved, Rejected, Disbursed, etc.)
--       with each status as a percentage of total applications.
-- WHY:  Gives an overall health check of the loan pipeline — a high rejection rate
--       may indicate strict policies or poor customer targeting.

-- Q4: Average credit score by rating category
SELECT credit_rating, 
       ROUND(AVG(credit_score), 0) AS avg_score,
       COUNT(*) AS customers
FROM credit_history
GROUP BY credit_rating
ORDER BY avg_score DESC;
-- WHAT: Calculates the average credit score within each rating category (Excellent, Good, Fair, Poor).
-- WHY:  Validates that the credit rating labels align correctly with score ranges,
--       and shows the distribution of customers across credit tiers.

-- Q5: Top 10 branches by number of customers
SELECT b.branch_name, b.city, b.state, COUNT(c.customer_id) AS customers
FROM branches b
JOIN customers c ON b.branch_id = c.branch_id
GROUP BY b.branch_id, b.branch_name, b.city, b.state
ORDER BY customers DESC
LIMIT 10;
-- WHAT: Lists the top 10 branches that serve the most customers.
-- WHY:  Identifies the busiest branches, which may need more staff, better infrastructure,
--       or could serve as flagship branches for the bank.

-- Q6: Employee count by designation
SELECT designation, COUNT(*) AS count
FROM employees
GROUP BY designation
ORDER BY count DESC;
-- WHAT: Shows how many employees hold each designation (Manager, Officer, Clerk, etc.).
-- WHY:  Helps HR understand the workforce structure and identify if any designation
--       is overstaffed or understaffed relative to operational needs.

-- Q7: Transaction mode popularity (successful transactions only)
SELECT transaction_mode, COUNT(*) AS txn_count,
       ROUND(SUM(amount), 2) AS total_amount
FROM transactions
WHERE status = 'Success'
GROUP BY transaction_mode
ORDER BY txn_count DESC;
-- WHAT: Ranks transaction modes (UPI, NEFT, Cash, ATM, etc.) by usage count and total amount.
-- WHY:  Reveals customer preferences for digital vs. traditional banking channels,
--       helping the bank invest in the right technology and infrastructure.

-- Q8: Monthly loan application trend
SELECT DATE_FORMAT(application_date, '%Y-%m') AS month,
       COUNT(*) AS applications
FROM loan_applications
GROUP BY month
ORDER BY month;
-- WHAT: Shows the number of loan applications received each month (time series).
-- WHY:  Identifies seasonal trends and growth patterns in loan demand,
--       useful for forecasting workload and planning promotional campaigns.


-- ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
-- 🟡 INTERMEDIATE LEVEL (Q9 – Q17)
-- ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

-- Q9: Loan approval rate by loan type
SELECT loan_type_name,
       COUNT(*) AS total,
       SUM(CASE WHEN status IN ('Disbursed','Approved','Closed') THEN 1 ELSE 0 END) AS approved,
       ROUND(SUM(CASE WHEN status IN ('Disbursed','Approved','Closed') THEN 1 ELSE 0 END) 
             * 100.0 / COUNT(*), 2) AS approval_rate_pct
FROM loan_applications
GROUP BY loan_type_name
ORDER BY approval_rate_pct DESC;
-- WHAT: Calculates the approval rate for each loan type using CASE-based conditional aggregation.
-- WHY:  Highlights which loan products have the easiest/hardest approval criteria,
--       helping management fine-tune underwriting policies per product.

-- Q10: Top rejection reasons
SELECT rejection_reason, COUNT(*) AS count
FROM loan_applications
WHERE status = 'Rejected' AND rejection_reason IS NOT NULL
GROUP BY rejection_reason
ORDER BY count DESC;
-- WHAT: Lists the most common reasons why loan applications get rejected.
-- WHY:  Pinpoints the primary blockers (low income, poor credit, incomplete docs, etc.)
--       so the bank can offer pre-approval guidance or relax certain criteria.

-- Q11: Average income by customer segment and employment type
SELECT customer_segment, employment_type,
       ROUND(AVG(annual_income), 0) AS avg_income,
       COUNT(*) AS count
FROM customers
GROUP BY customer_segment, employment_type
ORDER BY customer_segment, avg_income DESC;
-- WHAT: Cross-tabulates customer segment (Premium, Regular, etc.) with employment type
--       (Salaried, Self-Employed, etc.) showing average income for each combination.
-- WHY:  Helps design targeted financial products — e.g., premium self-employed customers
--       may need different loan products than regular salaried customers.

-- Q12: Payment default rate (Missed payments as % of total)
SELECT payment_status, COUNT(*) AS count,
       ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS pct
FROM loan_payments
GROUP BY payment_status
ORDER BY count DESC;
-- WHAT: Shows the distribution of payment statuses (Paid, Late, Missed) with percentages.
-- WHY:  A key risk metric — a high "Missed" percentage signals rising NPAs and
--       the need for stronger collection processes or early warning systems.

-- Q13: Top 10 customers with highest total penalty
SELECT c.full_name, c.customer_id,
       ROUND(SUM(lp.penalty_amount), 2) AS total_penalty,
       COUNT(CASE WHEN lp.payment_status = 'Missed' THEN 1 END) AS missed_count
FROM loan_payments lp
JOIN customers c ON lp.customer_id = c.customer_id
GROUP BY c.customer_id, c.full_name
HAVING total_penalty > 0
ORDER BY total_penalty DESC
LIMIT 10;
-- WHAT: Identifies the 10 customers who have accumulated the highest penalty charges.
-- WHY:  These are high-risk borrowers who consistently miss payments. The bank can
--       proactively reach out for restructuring or initiate recovery proceedings.

-- Q14: Zone-wise total disbursed amount (in Crores)
SELECT c.zone,
       COUNT(DISTINCT la.application_id) AS loans,
       ROUND(SUM(la.loan_amount_approved) / 10000000, 2) AS disbursed_cr
FROM loan_applications la
JOIN customers c ON la.customer_id = c.customer_id
WHERE la.status = 'Disbursed'
GROUP BY c.zone
ORDER BY disbursed_cr DESC;
-- WHAT: Aggregates total loan disbursement amount per zone, converted to Crores (₹1 Cr = ₹1,00,00,000).
-- WHY:  Shows the bank's lending exposure across geographic zones, critical for
--       risk diversification and meeting RBI's priority sector lending targets.

-- Q15: Average days late by loan type
SELECT la.loan_type_name,
       ROUND(AVG(lp.days_late), 1) AS avg_days_late,
       ROUND(AVG(CASE WHEN lp.days_late > 0 THEN lp.days_late END), 1) AS avg_days_late_when_late
FROM loan_payments lp
JOIN loan_applications la ON lp.application_id = la.application_id
GROUP BY la.loan_type_name
ORDER BY avg_days_late DESC;
-- WHAT: Calculates two metrics per loan type — overall average days late, and average days late
--       only among payments that were actually late (excluding on-time payments).
-- WHY:  Reveals which loan products have the worst repayment discipline,
--       helping the bank tighten follow-ups or restructure EMI schedules for those products.

-- Q16: Spending category breakdown for debit transactions
SELECT category, 
       COUNT(*) AS txn_count,
       ROUND(SUM(amount), 2) AS total_spent,
       ROUND(AVG(amount), 2) AS avg_spent
FROM transactions
WHERE transaction_type = 'Debit' AND status = 'Success'
GROUP BY category
ORDER BY total_spent DESC;
-- WHAT: Breaks down customer spending by category (Groceries, Utilities, Shopping, etc.)
--       for successful debit transactions only.
-- WHY:  Understanding spending habits enables the bank to offer targeted credit cards,
--       merchant tie-ups, cashback offers, and personalized financial advice.

-- Q17: Year-over-year loan application growth
SELECT YEAR(application_date) AS yr,
       COUNT(*) AS applications,
       LAG(COUNT(*)) OVER (ORDER BY YEAR(application_date)) AS prev_year,
       ROUND((COUNT(*) - LAG(COUNT(*)) OVER (ORDER BY YEAR(application_date))) 
             * 100.0 / LAG(COUNT(*)) OVER (ORDER BY YEAR(application_date)), 2) AS yoy_growth_pct
FROM loan_applications
GROUP BY yr
ORDER BY yr;
-- WHAT: Uses the LAG() window function to compare each year's loan applications with
--       the previous year, calculating year-over-year growth percentage.
-- WHY:  Tracks the bank's lending business growth trajectory. Declining growth signals
--       competitive pressure, while spikes may indicate market expansion or seasonal effects.


-- ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
-- 🔴 ADVANCED LEVEL (Q18 – Q25)
-- ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

-- Q18: Credit score bands vs loan default rate
SELECT 
    CASE 
        WHEN ch.credit_score >= 800 THEN '800+ (Excellent)'
        WHEN ch.credit_score >= 700 THEN '700-799 (Good)'
        WHEN ch.credit_score >= 600 THEN '600-699 (Fair)'
        ELSE 'Below 600 (Poor)'
    END AS credit_band,
    COUNT(DISTINCT la.application_id) AS total_loans,
    COUNT(DISTINCT CASE WHEN lp.payment_status = 'Missed' THEN la.application_id END) AS loans_with_missed,
    ROUND(COUNT(DISTINCT CASE WHEN lp.payment_status = 'Missed' THEN la.application_id END) 
          * 100.0 / COUNT(DISTINCT la.application_id), 2) AS default_rate_pct
FROM loan_applications la
JOIN credit_history ch ON la.customer_id = ch.customer_id
JOIN loan_payments lp ON la.application_id = lp.application_id
WHERE la.status IN ('Disbursed', 'Closed')
GROUP BY credit_band
ORDER BY default_rate_pct DESC;
-- WHAT: Groups customers into credit score bands using CASE and calculates the default rate
--       (loans with at least one missed payment) for each band.
-- WHY:  Validates the bank's credit scoring model — if "Excellent" customers also default at
--       high rates, the scoring criteria need revision. Essential for credit risk management.

-- Q19: Branch-wise profitability (Interest earned vs penalties)
SELECT b.branch_name, b.city,
       ROUND(SUM(lp.interest_paid), 0) AS total_interest_earned,
       ROUND(SUM(lp.penalty_amount), 0) AS total_penalties,
       COUNT(DISTINCT la.application_id) AS active_loans
FROM loan_payments lp
JOIN loan_applications la ON lp.application_id = la.application_id
JOIN branches b ON la.branch_id = b.branch_id
GROUP BY b.branch_id, b.branch_name, b.city
ORDER BY total_interest_earned DESC
LIMIT 15;
-- WHAT: Ranks the top 15 branches by total interest income, also showing penalty collections
--       and active loan count. Uses multi-table JOINs across payments → applications → branches.
-- WHY:  Branch profitability analysis helps management decide where to expand, where to
--       cut costs, and which branches are the bank's revenue engines.

-- Q20: Customer lifetime value (deposits + loan interest)
SELECT c.customer_id, c.full_name, c.customer_segment,
       COALESCE(t.total_credits, 0) AS total_deposits,
       COALESCE(l.total_interest, 0) AS interest_paid_to_bank,
       COALESCE(t.total_credits, 0) + COALESCE(l.total_interest, 0) AS lifetime_value
FROM customers c
LEFT JOIN (
    SELECT customer_id, SUM(amount) AS total_credits
    FROM transactions WHERE transaction_type = 'Credit' AND status = 'Success'
    GROUP BY customer_id
) t ON c.customer_id = t.customer_id
LEFT JOIN (
    SELECT customer_id, SUM(interest_paid) AS total_interest
    FROM loan_payments WHERE payment_status IN ('Paid', 'Late')
    GROUP BY customer_id
) l ON c.customer_id = l.customer_id
ORDER BY lifetime_value DESC
LIMIT 20;
-- WHAT: Calculates Customer Lifetime Value (CLV) by combining total deposits (credit transactions)
--       and interest paid to the bank from loans. Uses subqueries with LEFT JOINs and COALESCE
--       to handle customers with no transactions or no loans.
-- WHY:  CLV is a critical business metric — it identifies the bank's most valuable customers
--       who should receive priority service, premium products, and retention offers.

-- Q21: Loan officer performance ranking
SELECT e.full_name, e.designation,
       COUNT(la.application_id) AS total_processed,
       SUM(CASE WHEN la.status = 'Disbursed' THEN 1 ELSE 0 END) AS disbursed,
       ROUND(SUM(CASE WHEN la.status = 'Disbursed' THEN 1 ELSE 0 END) 
             * 100.0 / COUNT(*), 2) AS success_rate,
       ROUND(SUM(CASE WHEN la.status = 'Disbursed' THEN la.loan_amount_approved ELSE 0 END) 
             / 100000, 2) AS disbursed_lakhs
FROM loan_applications la
JOIN employees e ON la.officer_employee_id = e.employee_id
GROUP BY e.employee_id, e.full_name, e.designation
HAVING total_processed >= 10
ORDER BY success_rate DESC
LIMIT 15;
-- WHAT: Ranks loan officers by their disbursement success rate (only those who processed 10+ applications).
--       Also shows total volume in Lakhs. Uses HAVING to filter out low-volume officers.
-- WHY:  Enables performance-based appraisals and incentive programs. Officers with low success rates
--       may need training, while top performers can be rewarded or promoted.

-- Q22: Seasonal transaction pattern analysis
SELECT MONTHNAME(transaction_date) AS month_name,
       MONTH(transaction_date) AS month_num,
       COUNT(*) AS txn_count,
       ROUND(SUM(CASE WHEN transaction_type = 'Credit' THEN amount ELSE 0 END), 0) AS total_credits,
       ROUND(SUM(CASE WHEN transaction_type = 'Debit' THEN amount ELSE 0 END), 0) AS total_debits
FROM transactions
WHERE status = 'Success'
GROUP BY month_name, month_num
ORDER BY month_num;
-- WHAT: Aggregates transaction volume and credit/debit amounts by calendar month to reveal
--       seasonal patterns. Uses MONTHNAME() for readability and MONTH() for correct ordering.
-- WHY:  Banks experience seasonal cash flow variations (festivals, harvest season, tax season).
--       This data helps plan liquidity, ATM cash loading, and seasonal loan products.

-- Q23: NPA (Non-Performing Asset) identification
-- Loans with 3+ missed payments
SELECT la.application_id, c.full_name, la.loan_type_name,
       la.loan_amount_approved, la.status,
       COUNT(CASE WHEN lp.payment_status = 'Missed' THEN 1 END) AS missed_payments,
       MAX(lp.outstanding_balance) AS current_outstanding
FROM loan_applications la
JOIN loan_payments lp ON la.application_id = lp.application_id
JOIN customers c ON la.customer_id = c.customer_id
GROUP BY la.application_id, c.full_name, la.loan_type_name,
         la.loan_amount_approved, la.status
HAVING missed_payments >= 3
ORDER BY current_outstanding DESC
LIMIT 20;
-- WHAT: Flags loans as potential NPAs (Non-Performing Assets) by identifying those with 3 or more
--       missed payments. Shows the outstanding balance at risk. Uses HAVING for post-aggregation filtering.
-- WHY:  NPA identification is an RBI regulatory requirement. Early detection allows the bank to
--       initiate recovery, restructure loans, or provision for bad debts before they escalate.

-- Q24: Customer segmentation by RFM-like metrics
SELECT c.customer_id, c.full_name,
       DATEDIFF(CURDATE(), MAX(t.transaction_date)) AS recency_days,
       COUNT(t.transaction_id) AS frequency,
       ROUND(SUM(t.amount), 2) AS monetary
FROM customers c
JOIN transactions t ON c.customer_id = t.customer_id
WHERE t.status = 'Success'
GROUP BY c.customer_id, c.full_name
ORDER BY monetary DESC
LIMIT 20;
-- WHAT: Applies the RFM (Recency, Frequency, Monetary) framework — a classic marketing analysis model.
--       Recency = days since last transaction, Frequency = total transaction count, Monetary = total amount.
-- WHY:  RFM segmentation helps identify high-value active customers vs. dormant ones.
--       The bank can target dormant high-value customers with re-engagement campaigns,
--       and reward frequent transactors with loyalty programs.

-- Q25: Cohort analysis — loan applications by account opening year
SELECT YEAR(c.account_open_date) AS cohort_year,
       YEAR(la.application_date) AS app_year,
       COUNT(*) AS applications,
       SUM(CASE WHEN la.status = 'Disbursed' THEN 1 ELSE 0 END) AS disbursed
FROM loan_applications la
JOIN customers c ON la.customer_id = c.customer_id
GROUP BY cohort_year, app_year
ORDER BY cohort_year, app_year;
-- WHAT: Groups customers into cohorts based on when they opened their account, then tracks
--       how many loan applications each cohort submitted in subsequent years.
-- WHY:  Cohort analysis reveals customer lifecycle patterns — e.g., do newer customers apply
--       for loans sooner? Are older cohorts more loyal? This drives retention strategy
--       and helps predict future loan demand from recent account openers.


-- ============================================================
-- END OF SCRIPT
-- ============================================================
