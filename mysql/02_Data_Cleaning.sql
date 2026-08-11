-- ============================================================
-- 🏦 IndoSynth Gramin Bank — 02: Data Cleaning
-- ============================================================
-- Demonstrates data cleaning techniques: NULL checks,
-- duplicate detection, value standardisation, and data
-- quality audit queries used after CSV import.
-- Run after 01_Database_Setup.sql
-- ============================================================

USE indosynth_bank;


-- ============================================================
-- SECTION 1: NULL VALUE AUDIT
-- ============================================================

-- DC1: Count NULLs in key customer columns
-- WHAT: Checks how many records have missing values in critical fields.
-- WHY:  Missing PAN, phone, or email can block KYC compliance and
--       customer communication. Helps prioritise data collection drives.
SELECT
    COUNT(*) AS total_customers,
    SUM(CASE WHEN pan_number    IS NULL OR pan_number    = '' THEN 1 ELSE 0 END) AS missing_pan,
    SUM(CASE WHEN aadhaar_number IS NULL OR aadhaar_number = '' THEN 1 ELSE 0 END) AS missing_aadhaar,
    SUM(CASE WHEN phone_number  IS NULL OR phone_number  = '' THEN 1 ELSE 0 END) AS missing_phone,
    SUM(CASE WHEN email         IS NULL OR email         = '' THEN 1 ELSE 0 END) AS missing_email,
    SUM(CASE WHEN annual_income IS NULL THEN 1 ELSE 0 END) AS missing_income
FROM customers;


-- DC2: Count NULLs in loan_applications critical columns
-- WHAT: Identifies how many loan records are missing key financial details.
-- WHY:  Null interest rates or EMI amounts suggest incomplete data entry
--       or import errors that need to be corrected before analysis.
SELECT
    COUNT(*) AS total_applications,
    SUM(CASE WHEN loan_amount_approved      IS NULL THEN 1 ELSE 0 END) AS null_approved_amount,
    SUM(CASE WHEN interest_rate_pct         IS NULL THEN 1 ELSE 0 END) AS null_interest_rate,
    SUM(CASE WHEN emi_amount                IS NULL THEN 1 ELSE 0 END) AS null_emi,
    SUM(CASE WHEN disbursement_date         IS NULL AND status = 'Disbursed' THEN 1 ELSE 0 END) AS disbursed_no_date,
    SUM(CASE WHEN rejection_reason          IS NULL AND status = 'Rejected'  THEN 1 ELSE 0 END) AS rejected_no_reason
FROM loan_applications;


-- DC3: Count NULLs in loan_payments
-- WHAT: Checks for missing payment dates or amounts in payment records.
-- WHY:  A payment record with no payment_date or emi_amount is unusable
--       for EMI reconciliation or overdue calculations.
SELECT
    COUNT(*) AS total_payments,
    SUM(CASE WHEN payment_date    IS NULL THEN 1 ELSE 0 END) AS missing_payment_date,
    SUM(CASE WHEN emi_amount      IS NULL THEN 1 ELSE 0 END) AS missing_emi_amount,
    SUM(CASE WHEN principal_paid  IS NULL THEN 1 ELSE 0 END) AS missing_principal,
    SUM(CASE WHEN interest_paid   IS NULL THEN 1 ELSE 0 END) AS missing_interest
FROM loan_payments;


-- ============================================================
-- SECTION 2: DUPLICATE DETECTION
-- ============================================================

-- DC4: Detect duplicate customers by PAN number
-- WHAT: Finds PAN numbers that appear more than once in the customers table.
-- WHY:  Each PAN should uniquely identify an individual. Duplicates may
--       indicate data entry errors or multiple accounts for the same person
--       (a regulatory concern under RBI KYC norms).
SELECT pan_number, COUNT(*) AS occurrences
FROM customers
WHERE pan_number IS NOT NULL AND pan_number <> ''
GROUP BY pan_number
HAVING occurrences > 1
ORDER BY occurrences DESC;


-- DC5: Detect duplicate customers by Aadhaar number
-- WHAT: Finds Aadhaar numbers appearing more than once.
-- WHY:  Similar to PAN, each Aadhaar is unique to an individual.
--       Duplicates suggest data quality issues needing reconciliation.
SELECT aadhaar_number, COUNT(*) AS occurrences
FROM customers
WHERE aadhaar_number IS NOT NULL AND aadhaar_number <> ''
GROUP BY aadhaar_number
HAVING occurrences > 1
ORDER BY occurrences DESC;


-- DC6: Detect duplicate loan applications (same customer, same loan type, same date)
-- WHAT: Identifies potentially duplicate application submissions.
-- WHY:  A customer applying twice for the same loan type on the same day
--       likely indicates a system or user error during submission.
SELECT customer_id, loan_type_id, application_date, COUNT(*) AS count
FROM loan_applications
GROUP BY customer_id, loan_type_id, application_date
HAVING count > 1
ORDER BY count DESC;


-- ============================================================
-- SECTION 3: DATA CONSISTENCY CHECKS
-- ============================================================

-- DC7: Loan applications where approved amount exceeds requested amount
-- WHAT: Flags cases where the bank approved more than was requested.
-- WHY:  This is logically invalid (banks never sanction more than requested)
--       and indicates a data entry or import error.
SELECT application_id, customer_id, loan_type_name,
       loan_amount_requested, loan_amount_approved,
       (loan_amount_approved - loan_amount_requested) AS excess_amount
FROM loan_applications
WHERE loan_amount_approved > loan_amount_requested
ORDER BY excess_amount DESC;


-- DC8: Customers with negative or zero annual income
-- WHAT: Finds customer records with implausible income values.
-- WHY:  A negative or zero income for an employed customer is a data error
--       that would distort income-based segmentation and loan eligibility.
SELECT customer_id, full_name, employment_type, annual_income
FROM customers
WHERE annual_income <= 0 OR annual_income IS NULL
ORDER BY annual_income ASC;


-- DC9: Credit scores outside the valid range (300–900)
-- WHAT: Identifies credit_history records with out-of-range scores.
-- WHY:  Credit scores in India typically range from 300 to 900 (CIBIL).
--       Scores outside this range indicate corrupt or incorrectly imported data.
SELECT credit_history_id, customer_id, credit_score, credit_rating
FROM credit_history
WHERE credit_score < 300 OR credit_score > 900;


-- DC10: Payments where payment_date is before due_date but days_late > 0
-- WHAT: Checks for logical inconsistency between payment date and days late.
-- WHY:  If a payment was made before the due date it cannot be late.
--       Such records reveal data pipeline issues in the payments system.
SELECT payment_id, application_id, due_date, payment_date, days_late
FROM loan_payments
WHERE payment_date < due_date AND days_late > 0
LIMIT 20;


-- ============================================================
-- SECTION 4: VALUE STANDARDISATION AUDIT
-- ============================================================

-- DC11: Distinct values in customer gender column
-- WHAT: Lists all unique values in the gender field.
-- WHY:  Inconsistent casing or spelling (e.g. 'M', 'Male', 'MALE') will
--       break GROUP BY queries. This audit reveals values needing normalisation.
SELECT gender, COUNT(*) AS count
FROM customers
GROUP BY gender
ORDER BY count DESC;


-- DC12: Distinct values in customer KYC status
-- WHAT: Lists all unique KYC status values.
-- WHY:  Only standard values (Verified, Pending, Rejected) are expected.
--       Any other value is a data quality issue requiring correction.
SELECT kyc_status, COUNT(*) AS count
FROM customers
GROUP BY kyc_status
ORDER BY count DESC;


-- DC13: Distinct loan application status values
-- WHAT: Lists all unique status values in loan_applications.
-- WHY:  Detects any non-standard or misspelled statuses that would
--       cause them to be excluded from Approved/Rejected analyses.
SELECT status, COUNT(*) AS count
FROM loan_applications
GROUP BY status
ORDER BY count DESC;


-- DC14: Distinct payment status values in loan_payments
-- WHAT: Lists all unique payment_status values.
-- WHY:  Only 'Paid', 'Late', 'Missed' are expected.
--       Rogue values corrupt NPA and default rate calculations.
SELECT payment_status, COUNT(*) AS count
FROM loan_payments
GROUP BY payment_status
ORDER BY count DESC;


-- ============================================================
-- SECTION 5: AGE & DATE VALIDATION
-- ============================================================

-- DC15: Customers whose calculated age doesn't match the stored age column
-- WHAT: Compares the stored age value against age calculated from date_of_birth.
-- WHY:  If the age column was pre-computed at data entry time, it may now be
--       stale. Large discrepancies indicate the column needs to be refreshed.
SELECT customer_id, full_name, date_of_birth, age AS stored_age,
       TIMESTAMPDIFF(YEAR, date_of_birth, CURDATE()) AS calculated_age,
       ABS(age - TIMESTAMPDIFF(YEAR, date_of_birth, CURDATE())) AS age_diff
FROM customers
WHERE ABS(age - TIMESTAMPDIFF(YEAR, date_of_birth, CURDATE())) > 1
ORDER BY age_diff DESC
LIMIT 20;


-- DC16: Future-dated transactions (transaction_date > today)
-- WHAT: Finds transactions with dates in the future.
-- WHY:  Future-dated transactions are impossible in a real banking system.
--       They signal clock/timezone issues in the source system.
SELECT transaction_id, customer_id, transaction_date, amount, status
FROM transactions
WHERE transaction_date > CURDATE()
ORDER BY transaction_date DESC;


-- ============================================================
-- END OF DATA CLEANING
-- ============================================================
