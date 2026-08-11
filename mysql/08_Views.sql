-- ============================================================
-- 🏦 IndoSynth Gramin Bank — 08: Views
-- ============================================================
-- Creates reusable database views for common analytical queries,
-- security-restricted access layers, and simplified reporting.
-- Each view encapsulates complex SQL logic behind a simple name.
-- Run after 01_Database_Setup.sql
-- ============================================================

USE indosynth_bank;


-- ============================================================
-- SECTION 1: OPERATIONAL VIEWS (Day-to-Day Banking)
-- ============================================================

-- VIEW 1: Active customers with branch and region details
-- WHAT: Combines customers, branches, and regions into a flat view
--       with only active customers (is_active = TRUE).
-- WHY:  Avoids repeating the 3-table JOIN in every operational query.
--       Application dashboards and reports can SELECT directly from this view.
CREATE OR REPLACE VIEW vw_active_customers AS
SELECT
    c.customer_id, c.full_name, c.gender, c.age,
    c.phone_number, c.email, c.customer_segment,
    c.employment_type, c.annual_income, c.kyc_status,
    c.account_number, c.account_type, c.account_open_date,
    b.branch_name, b.city, b.state, b.zone,
    r.region_name
FROM customers c
JOIN branches b ON c.branch_id = b.branch_id
JOIN regions  r ON c.region_id = r.region_id
WHERE c.is_active = TRUE;

-- Usage:
SELECT * FROM vw_active_customers WHERE zone = 'North' LIMIT 10;


-- VIEW 2: Loan application summary with customer and branch info
-- WHAT: Denormalised view of loan applications with customer name,
--       branch name, and loan type details in a single row.
-- WHY:  Loan operations teams need all application details at a glance
--       without writing multi-table JOINs each time.
CREATE OR REPLACE VIEW vw_loan_application_summary AS
SELECT
    la.application_id, la.status,
    c.customer_id, c.full_name AS customer_name, c.phone_number,
    la.loan_type_name, lt.base_interest_rate,
    la.loan_amount_requested, la.loan_amount_approved,
    la.interest_rate_pct, la.tenure_months, la.emi_amount,
    la.application_date, la.disbursement_date,
    la.rejection_reason, la.purpose,
    b.branch_name, b.city, b.state, b.zone,
    e.full_name AS officer_name, e.designation
FROM loan_applications la
JOIN customers  c  ON la.customer_id          = c.customer_id
JOIN loan_types lt ON la.loan_type_id         = lt.loan_type_id
LEFT JOIN branches  b ON la.branch_id         = b.branch_id
LEFT JOIN employees e ON la.officer_employee_id = e.employee_id;

-- Usage:
SELECT * FROM vw_loan_application_summary WHERE status = 'Rejected' LIMIT 10;


-- VIEW 3: Overdue payments (payment_status = 'Missed' or 'Late')
-- WHAT: Filters loan_payments to show only overdue records, with
--       customer contact details for the collections team.
-- WHY:  The collections team queries this view daily. A single view
--       definition ensures consistent overdue criteria across all reports.
CREATE OR REPLACE VIEW vw_overdue_payments AS
SELECT
    lp.payment_id, lp.application_id, lp.due_date,
    lp.payment_status, lp.days_late, lp.penalty_amount,
    lp.outstanding_balance, lp.emi_amount,
    c.customer_id, c.full_name, c.phone_number, c.email,
    la.loan_type_name, la.loan_amount_approved,
    b.branch_name, b.city
FROM loan_payments lp
JOIN loan_applications la ON lp.application_id = la.application_id
JOIN customers         c  ON lp.customer_id = c.customer_id
JOIN branches          b  ON la.branch_id   = b.branch_id
WHERE lp.payment_status IN ('Missed', 'Late')
ORDER BY lp.days_late DESC;

-- Usage:
SELECT * FROM vw_overdue_payments WHERE days_late > 30 LIMIT 20;


-- ============================================================
-- SECTION 2: ANALYTICAL / REPORTING VIEWS
-- ============================================================

-- VIEW 4: Branch performance scorecard
-- WHAT: Aggregates per-branch metrics — loan count, total disbursement,
--       interest income, and penalty collections — as a single row per branch.
-- WHY:  Branch scorecards are reviewed by management weekly. This view
--       pre-computes the aggregation, so management dashboards remain fast.
CREATE OR REPLACE VIEW vw_branch_performance AS
SELECT
    b.branch_id, b.branch_name, b.city, b.state, b.zone,
    COUNT(DISTINCT la.application_id)                               AS total_loans,
    SUM(CASE WHEN la.status='Disbursed' THEN 1 ELSE 0 END)          AS disbursed_loans,
    ROUND(SUM(la.loan_amount_approved) / 10000000, 2)               AS disbursed_cr,
    ROUND(SUM(lp.interest_paid), 0)                                 AS interest_income,
    ROUND(SUM(lp.penalty_amount), 0)                                AS penalty_collected,
    COUNT(DISTINCT c.customer_id)                                   AS total_customers
FROM branches b
LEFT JOIN loan_applications la ON b.branch_id    = la.branch_id
LEFT JOIN loan_payments     lp ON la.application_id = lp.application_id
LEFT JOIN customers         c  ON b.branch_id    = c.branch_id
GROUP BY b.branch_id, b.branch_name, b.city, b.state, b.zone;

-- Usage:
SELECT * FROM vw_branch_performance ORDER BY disbursed_cr DESC LIMIT 10;


-- VIEW 5: Customer credit profile view
-- WHAT: Joins customers with their credit history for a complete
--       credit profile — score, rating, utilisation, and delinquencies.
-- WHY:  Underwriters query customer credit profiles during loan assessment.
--       Hiding the JOIN behind a view simplifies the underwriting application.
CREATE OR REPLACE VIEW vw_customer_credit_profile AS
SELECT
    c.customer_id, c.full_name, c.age,
    c.employment_type, c.annual_income, c.customer_segment,
    ch.credit_score, ch.credit_rating,
    ch.number_of_accounts, ch.number_of_delinquencies,
    ch.total_outstanding_debt, ch.credit_utilization_pct,
    ch.payment_history_pct, ch.hard_inquiries_last_6m,
    ch.oldest_account_years, ch.last_updated_date
FROM customers c
JOIN credit_history ch ON c.customer_id = ch.customer_id;

-- Usage:
SELECT * FROM vw_customer_credit_profile WHERE credit_score >= 750 LIMIT 10;


-- VIEW 6: NPA (Non-Performing Asset) watch list
-- WHAT: Identifies loans with 3+ missed payments and outstanding balance > 0.
-- WHY:  Regulatory requirement — RBI mandates NPA identification and reporting.
--       A persistent view ensures the NPA list is always current.
CREATE OR REPLACE VIEW vw_npa_watchlist AS
SELECT
    la.application_id, c.customer_id, c.full_name, c.phone_number,
    la.loan_type_name, la.loan_amount_approved, la.status,
    COUNT(CASE WHEN lp.payment_status = 'Missed' THEN 1 END) AS missed_payments,
    MAX(lp.outstanding_balance)                               AS current_outstanding,
    MAX(lp.days_late)                                         AS max_days_late
FROM loan_applications la
JOIN loan_payments lp ON la.application_id = lp.application_id
JOIN customers     c  ON la.customer_id    = c.customer_id
GROUP BY la.application_id, c.customer_id, c.full_name, c.phone_number,
         la.loan_type_name, la.loan_amount_approved, la.status
HAVING missed_payments >= 3;

-- Usage:
SELECT * FROM vw_npa_watchlist ORDER BY current_outstanding DESC LIMIT 20;


-- ============================================================
-- SECTION 3: SECURITY / RESTRICTED-ACCESS VIEWS
-- ============================================================

-- VIEW 7: Customer view without sensitive PII (for front-office staff)
-- WHAT: Exposes customer information with PAN and Aadhaar masked —
--       only the first 4 and last 4 characters are visible.
-- WHY:  Front-office staff need customer details for service but should
--       NOT see full PAN/Aadhaar. Views enforce data privacy without
--       complex application-level filtering.
CREATE OR REPLACE VIEW vw_customer_public AS
SELECT
    customer_id, full_name, gender, age,
    phone_number, email,
    city, state, zone,
    customer_segment, kyc_status,
    account_type, account_open_date,
    CONCAT(LEFT(pan_number, 3), 'XXXXX', RIGHT(pan_number, 2))      AS masked_pan,
    CONCAT(LEFT(aadhaar_number, 4), 'XXXXXXXX', RIGHT(aadhaar_number, 4)) AS masked_aadhaar
FROM customers
WHERE is_active = TRUE;

-- Usage:
SELECT * FROM vw_customer_public WHERE city = 'Mumbai' LIMIT 10;


-- VIEW 8: Employee directory (no salary info — for general access)
-- WHAT: Shows employee details without the annual_salary column.
-- WHY:  Salary information is HR-confidential. A view without that column
--       can be safely granted to other departments without privilege escalation.
CREATE OR REPLACE VIEW vw_employee_directory AS
SELECT
    e.employee_id, e.full_name, e.gender,
    e.designation, e.department, e.grade,
    e.email, e.phone,
    e.joining_date, e.is_active,
    e.employee_code,
    b.branch_name, b.city, b.state, b.zone
FROM employees e
JOIN branches b ON e.branch_id = b.branch_id
WHERE e.is_active = TRUE;

-- Usage:
SELECT * FROM vw_employee_directory WHERE department = 'Loans' ORDER BY grade DESC;


-- ============================================================
-- SECTION 4: VIEW MANAGEMENT
-- ============================================================

-- List all views in the database
SHOW FULL TABLES IN indosynth_bank WHERE TABLE_TYPE = 'VIEW';

-- Drop a view (example — uncomment if needed)
-- DROP VIEW IF EXISTS vw_overdue_payments;


-- ============================================================
-- END OF VIEWS
-- ============================================================
