-- ============================================================
-- 🏦 IndoSynth Gramin Bank — 04: GROUP BY
-- ============================================================
-- Demonstrates GROUP BY with aggregation functions (COUNT, SUM,
-- AVG, MIN, MAX), HAVING clauses, multi-column grouping, and
-- conditional aggregation using CASE inside aggregate functions.
-- Includes Q1–Q4, Q6–Q8, Q9–Q12, Q15–Q16 from the main script.
-- Run after 01_Database_Setup.sql
-- ============================================================

USE indosynth_bank;


-- ============================================================
-- SECTION 1: BASIC GROUP BY WITH COUNT
-- ============================================================

-- GB1 (Q1): Total customers by zone
-- WHAT: Counts the number of customers in each geographic zone.
-- WHY:  Identifies which zones have the highest customer concentration,
--       useful for regional marketing strategies and resource allocation.
SELECT zone, COUNT(*) AS total_customers
FROM customers
GROUP BY zone
ORDER BY total_customers DESC;


-- GB2 (Q2): Loan type distribution
-- WHAT: Shows how many loan applications exist for each loan product.
-- WHY:  Reveals which loan products are most popular, guiding the bank
--       on which products to promote and which need better marketing.
SELECT loan_type_name, COUNT(*) AS applications
FROM loan_applications
GROUP BY loan_type_name
ORDER BY applications DESC;


-- GB3 (Q6): Employee count by designation
-- WHAT: Shows how many employees hold each designation.
-- WHY:  Helps HR understand workforce structure and identify if any
--       designation is overstaffed or understaffed.
SELECT designation, COUNT(*) AS count
FROM employees
GROUP BY designation
ORDER BY count DESC;


-- GB4 (Q8): Monthly loan application trend
-- WHAT: Shows the number of loan applications received each month (time series).
-- WHY:  Identifies seasonal trends in loan demand, useful for forecasting
--       workload and planning promotional campaigns.
SELECT DATE_FORMAT(application_date, '%Y-%m') AS month,
       COUNT(*) AS applications
FROM loan_applications
GROUP BY month
ORDER BY month;


-- ============================================================
-- SECTION 2: GROUP BY WITH SUM & AVG
-- ============================================================

-- GB5: Total and average loan amount by loan type
-- WHAT: Aggregates requested and approved loan amounts per loan product.
-- WHY:  Shows which products carry the most financial exposure and
--       what the typical loan size is for each product type.
SELECT loan_type_name,
       COUNT(*)                                          AS applications,
       ROUND(AVG(loan_amount_requested) / 100000, 2)    AS avg_requested_lakhs,
       ROUND(AVG(loan_amount_approved)  / 100000, 2)    AS avg_approved_lakhs,
       ROUND(SUM(loan_amount_approved)  / 10000000, 2)  AS total_approved_cr
FROM loan_applications
WHERE status IN ('Disbursed', 'Approved', 'Closed')
GROUP BY loan_type_name
ORDER BY total_approved_cr DESC;


-- GB6 (Q4): Average credit score by rating category
-- WHAT: Calculates the average credit score within each rating category.
-- WHY:  Validates that credit rating labels align correctly with score ranges
--       and shows the distribution of customers across credit tiers.
SELECT credit_rating,
       ROUND(AVG(credit_score), 0) AS avg_score,
       MIN(credit_score)           AS min_score,
       MAX(credit_score)           AS max_score,
       COUNT(*)                    AS customers
FROM credit_history
GROUP BY credit_rating
ORDER BY avg_score DESC;


-- GB7 (Q7): Transaction mode popularity (successful transactions only)
-- WHAT: Ranks transaction modes by usage count and total amount.
-- WHY:  Reveals customer preferences for digital vs. traditional banking
--       channels to guide technology investment decisions.
SELECT transaction_mode,
       COUNT(*) AS txn_count,
       ROUND(SUM(amount), 2) AS total_amount,
       ROUND(AVG(amount), 2) AS avg_amount
FROM transactions
WHERE status = 'Success'
GROUP BY transaction_mode
ORDER BY txn_count DESC;


-- GB8 (Q16): Spending category breakdown for debit transactions
-- WHAT: Breaks down customer spending by category for successful debit
--       transactions only.
-- WHY:  Understanding spending habits enables targeted credit cards,
--       merchant tie-ups, cashback offers, and personalised financial advice.
SELECT category,
       COUNT(*)                  AS txn_count,
       ROUND(SUM(amount), 2)     AS total_spent,
       ROUND(AVG(amount), 2)     AS avg_spent
FROM transactions
WHERE transaction_type = 'Debit' AND status = 'Success'
GROUP BY category
ORDER BY total_spent DESC;


-- ============================================================
-- SECTION 3: MULTI-COLUMN GROUP BY
-- ============================================================

-- GB9 (Q11): Average income by customer segment and employment type
-- WHAT: Cross-tabulates customer segment with employment type,
--       showing average income for each combination.
-- WHY:  Helps design targeted financial products for different
--       customer profiles (e.g., premium self-employed vs. regular salaried).
SELECT customer_segment, employment_type,
       ROUND(AVG(annual_income), 0) AS avg_income,
       COUNT(*)                     AS count
FROM customers
GROUP BY customer_segment, employment_type
ORDER BY customer_segment, avg_income DESC;


-- GB10: Loan rejection count by loan type AND rejection reason
-- WHAT: Cross-tabulates loan type with rejection reason to show which
--       reasons are most common for each product.
-- WHY:  Product-specific rejection analysis helps tailor eligibility
--       criteria — e.g., income threshold adjustments for Personal Loans.
SELECT loan_type_name, rejection_reason, COUNT(*) AS rejections
FROM loan_applications
WHERE status = 'Rejected' AND rejection_reason IS NOT NULL
GROUP BY loan_type_name, rejection_reason
ORDER BY loan_type_name, rejections DESC;


-- GB11: Transaction volume by zone and transaction type
-- WHAT: Groups transactions by both geographic zone and debit/credit type.
-- WHY:  Reveals whether certain zones are net savers (more credits) or
--       net spenders (more debits), informing regional product strategy.
SELECT c.zone, t.transaction_type,
       COUNT(*)                  AS txn_count,
       ROUND(SUM(t.amount), 2)   AS total_amount
FROM transactions t
JOIN customers c ON t.customer_id = c.customer_id
WHERE t.status = 'Success'
GROUP BY c.zone, t.transaction_type
ORDER BY c.zone, t.transaction_type;


-- ============================================================
-- SECTION 4: HAVING CLAUSE
-- ============================================================

-- GB12 (Q3): Application status breakdown with percentage (using HAVING)
-- WHAT: Breaks down loan applications by status with each as a percentage.
-- WHY:  A high rejection rate may indicate strict policies or poor customer
--       targeting. HAVING demonstrates post-aggregation filtering.
SELECT status,
       COUNT(*) AS count,
       ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS pct
FROM loan_applications
GROUP BY status;


-- GB13: Branches with more than 50 customers (HAVING filter)
-- WHAT: Returns only branches serving more than 50 customers.
-- WHY:  HAVING filters after aggregation, unlike WHERE which filters
--       rows before grouping. This finds genuinely high-volume branches.
SELECT b.branch_name, b.city, b.state, COUNT(c.customer_id) AS customers
FROM branches b
JOIN customers c ON b.branch_id = c.branch_id
GROUP BY b.branch_id, b.branch_name, b.city, b.state
HAVING customers > 50
ORDER BY customers DESC;


-- GB14 (Q12): Payment default rate (Missed payments %)
-- WHAT: Shows the distribution of payment statuses with percentages.
-- WHY:  A key risk metric — a high "Missed" percentage signals rising NPAs
--       and the need for stronger collection processes.
SELECT payment_status,
       COUNT(*) AS count,
       ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS pct
FROM loan_payments
GROUP BY payment_status
ORDER BY count DESC;


-- ============================================================
-- SECTION 5: CONDITIONAL AGGREGATION (CASE inside GROUP BY)
-- ============================================================

-- GB15 (Q9): Loan approval rate by loan type using CASE
-- WHAT: Calculates the approval rate for each loan type using CASE-based
--       conditional aggregation within a single GROUP BY query.
-- WHY:  Highlights which loan products have the easiest or hardest approval
--       criteria, helping management fine-tune underwriting policies.
SELECT loan_type_name,
       COUNT(*) AS total,
       SUM(CASE WHEN status IN ('Disbursed','Approved','Closed') THEN 1 ELSE 0 END) AS approved,
       SUM(CASE WHEN status = 'Rejected' THEN 1 ELSE 0 END)                         AS rejected,
       ROUND(SUM(CASE WHEN status IN ('Disbursed','Approved','Closed') THEN 1 ELSE 0 END)
             * 100.0 / COUNT(*), 2)                                                  AS approval_rate_pct
FROM loan_applications
GROUP BY loan_type_name
ORDER BY approval_rate_pct DESC;


-- GB16 (Q15): Average days late by loan type (conditional average)
-- WHAT: Calculates two metrics per loan type — overall average days late,
--       and average days late only among actually-late payments.
-- WHY:  Reveals which loan products have the worst repayment discipline,
--       helping tighten follow-ups or restructure EMI schedules.
SELECT la.loan_type_name,
       ROUND(AVG(lp.days_late), 1)                                           AS avg_days_late,
       ROUND(AVG(CASE WHEN lp.days_late > 0 THEN lp.days_late END), 1)      AS avg_days_late_when_late
FROM loan_payments lp
JOIN loan_applications la ON lp.application_id = la.application_id
GROUP BY la.loan_type_name
ORDER BY avg_days_late DESC;


-- GB17 (Q22): Seasonal transaction pattern by month
-- WHAT: Aggregates transaction volume and credit/debit amounts by calendar month.
-- WHY:  Banks experience seasonal cash flow variations (festivals, harvest, tax
--       season). This data drives liquidity planning and seasonal loan products.
SELECT MONTHNAME(transaction_date) AS month_name,
       MONTH(transaction_date)     AS month_num,
       COUNT(*)                    AS txn_count,
       ROUND(SUM(CASE WHEN transaction_type = 'Credit' THEN amount ELSE 0 END), 0) AS total_credits,
       ROUND(SUM(CASE WHEN transaction_type = 'Debit'  THEN amount ELSE 0 END), 0) AS total_debits
FROM transactions
WHERE status = 'Success'
GROUP BY month_name, month_num
ORDER BY month_num;


-- ============================================================
-- END OF GROUP BY
-- ============================================================
