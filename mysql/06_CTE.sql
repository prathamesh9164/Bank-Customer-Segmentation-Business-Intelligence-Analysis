-- ============================================================
-- 🏦 IndoSynth Gramin Bank — 06: Common Table Expressions (CTEs)
-- ============================================================
-- Demonstrates single CTEs, multiple CTEs, recursive CTEs,
-- and using CTEs to simplify complex multi-step analytics.
-- Includes Q25 (cohort analysis) from the main script plus
-- comprehensive new CTE-based banking examples.
-- Run after 01_Database_Setup.sql
-- ============================================================

USE indosynth_bank;


-- ============================================================
-- SECTION 1: SINGLE CTE (Basic Readability)
-- ============================================================

-- CTE1: Top 10 customers by total loan portfolio value
-- WHAT: Uses a CTE to first compute each customer's total approved loan amount,
--       then selects the top 10 from that result.
-- WHY:  CTEs make complex queries modular and readable. The same could be done
--       with a subquery, but a CTE names the intermediate result clearly.
WITH customer_loan_portfolio AS (
    SELECT customer_id,
           COUNT(*)                                          AS loan_count,
           ROUND(SUM(loan_amount_approved) / 100000, 2)     AS total_approved_lakhs
    FROM loan_applications
    WHERE status IN ('Disbursed', 'Approved', 'Closed')
    GROUP BY customer_id
)
SELECT c.customer_id, c.full_name, c.customer_segment,
       clp.loan_count, clp.total_approved_lakhs
FROM customer_loan_portfolio clp
JOIN customers c ON clp.customer_id = c.customer_id
ORDER BY clp.total_approved_lakhs DESC
LIMIT 10;


-- CTE2: Branches with above-average interest income
-- WHAT: Computes average branch interest income in a CTE, then filters
--       branches that exceed that average.
-- WHY:  Isolates high-performing branches without needing a nested subquery,
--       making the intent clear to any reader of the code.
WITH branch_interest AS (
    SELECT la.branch_id,
           ROUND(SUM(lp.interest_paid), 0) AS total_interest
    FROM loan_payments lp
    JOIN loan_applications la ON lp.application_id = la.application_id
    GROUP BY la.branch_id
),
avg_interest AS (
    SELECT ROUND(AVG(total_interest), 0) AS bank_avg_interest
    FROM branch_interest
)
SELECT b.branch_name, b.city, b.state,
       bi.total_interest,
       ai.bank_avg_interest,
       ROUND(bi.total_interest - ai.bank_avg_interest, 0) AS above_avg_by
FROM branch_interest bi
JOIN branches b        ON bi.branch_id = b.branch_id
CROSS JOIN avg_interest ai
WHERE bi.total_interest > ai.bank_avg_interest
ORDER BY bi.total_interest DESC;


-- ============================================================
-- SECTION 2: MULTIPLE CTEs (Chained / Sequential)
-- ============================================================

-- CTE3: NPA candidates — customers with high penalty AND poor credit
-- WHAT: Uses two CTEs — one to find high-penalty customers, another for
--       poor credit scores — then JOINs them to find the overlap.
-- WHY:  NPA risk is highest when both payment default AND poor credit score
--       are present. This multi-step logic is cleaner as chained CTEs.
WITH high_penalty_customers AS (
    SELECT customer_id,
           ROUND(SUM(penalty_amount), 2) AS total_penalty,
           COUNT(CASE WHEN payment_status = 'Missed' THEN 1 END) AS missed_count
    FROM loan_payments
    GROUP BY customer_id
    HAVING total_penalty > 500
),
poor_credit_customers AS (
    SELECT customer_id, credit_score, credit_rating
    FROM credit_history
    WHERE credit_score < 600
)
SELECT c.customer_id, c.full_name, c.phone_number,
       hpc.total_penalty, hpc.missed_count,
       pcc.credit_score, pcc.credit_rating
FROM high_penalty_customers hpc
JOIN poor_credit_customers pcc ON hpc.customer_id = pcc.customer_id
JOIN customers c               ON hpc.customer_id = c.customer_id
ORDER BY hpc.total_penalty DESC
LIMIT 20;


-- CTE4: Zone-wise loan approval funnel (Applications → Approved → Disbursed)
-- WHAT: Three CTEs build three different aggregations (totals, approved, disbursed),
--       which are then joined on zone to produce a funnel view.
-- WHY:  The approval funnel reveals where applications are dropping off —
--       a zone with many applications but few disbursements needs process review.
WITH total_apps AS (
    SELECT c.zone, COUNT(*) AS total_applications
    FROM loan_applications la
    JOIN customers c ON la.customer_id = c.customer_id
    GROUP BY c.zone
),
approved_apps AS (
    SELECT c.zone, COUNT(*) AS approved
    FROM loan_applications la
    JOIN customers c ON la.customer_id = c.customer_id
    WHERE la.status IN ('Approved', 'Disbursed', 'Closed')
    GROUP BY c.zone
),
disbursed_apps AS (
    SELECT c.zone, COUNT(*) AS disbursed
    FROM loan_applications la
    JOIN customers c ON la.customer_id = c.customer_id
    WHERE la.status = 'Disbursed'
    GROUP BY c.zone
)
SELECT ta.zone,
       ta.total_applications,
       COALESCE(aa.approved, 0)   AS approved,
       COALESCE(da.disbursed, 0)  AS disbursed,
       ROUND(COALESCE(aa.approved, 0)  * 100.0 / ta.total_applications, 1) AS approval_rate_pct,
       ROUND(COALESCE(da.disbursed, 0) * 100.0 / ta.total_applications, 1) AS disbursal_rate_pct
FROM total_apps ta
LEFT JOIN approved_apps  aa ON ta.zone = aa.zone
LEFT JOIN disbursed_apps da ON ta.zone = da.zone
ORDER BY ta.total_applications DESC;


-- ============================================================
-- SECTION 3: CTE + WINDOW FUNCTION (Combined Power)
-- ============================================================

-- CTE5: Monthly loan disbursements with running total
-- WHAT: CTE aggregates monthly disbursals; the outer query adds a running
--       cumulative total using SUM() OVER() window function.
-- WHY:  Running totals are impossible with GROUP BY alone. A CTE prepares
--       the monthly data cleanly before the window function is applied.
WITH monthly_disbursals AS (
    SELECT DATE_FORMAT(disbursement_date, '%Y-%m') AS disbursement_month,
           COUNT(*)                                AS loans_disbursed,
           ROUND(SUM(loan_amount_approved) / 10000000, 2) AS amount_cr
    FROM loan_applications
    WHERE status = 'Disbursed'
      AND disbursement_date IS NOT NULL
    GROUP BY disbursement_month
)
SELECT disbursement_month,
       loans_disbursed,
       amount_cr,
       SUM(amount_cr) OVER (ORDER BY disbursement_month) AS cumulative_cr
FROM monthly_disbursals
ORDER BY disbursement_month;


-- CTE6: Customer payment health score (CTE + conditional aggregation)
-- WHAT: Computes a simple payment health score per customer (0–100) based
--       on ratio of on-time payments to total payments.
-- WHY:  An internal health score (distinct from CIBIL) can drive early
--       intervention — customers trending downward can be contacted proactively.
WITH payment_summary AS (
    SELECT customer_id,
           COUNT(*)                                                  AS total_payments,
           SUM(CASE WHEN payment_status = 'Paid'   THEN 1 ELSE 0 END) AS on_time_payments,
           SUM(CASE WHEN payment_status = 'Late'   THEN 1 ELSE 0 END) AS late_payments,
           SUM(CASE WHEN payment_status = 'Missed' THEN 1 ELSE 0 END) AS missed_payments
    FROM loan_payments
    GROUP BY customer_id
)
SELECT c.customer_id, c.full_name,
       ps.total_payments, ps.on_time_payments,
       ps.late_payments, ps.missed_payments,
       ROUND(ps.on_time_payments * 100.0 / ps.total_payments, 1) AS payment_health_score
FROM payment_summary ps
JOIN customers c ON ps.customer_id = c.customer_id
ORDER BY payment_health_score ASC
LIMIT 20;


-- ============================================================
-- SECTION 4: COHORT ANALYSIS (from main script Q25)
-- ============================================================

-- CTE7 (Q25): Cohort analysis — loan applications by account opening year
-- WHAT: Groups customers into cohorts based on account opening year, then
--       tracks loan applications and disbursals submitted in subsequent years.
-- WHY:  Reveals customer lifecycle patterns — e.g., do newer customers apply
--       for loans sooner? Are older cohorts more loyal? Drives retention strategy.
WITH cohort_base AS (
    SELECT c.customer_id,
           YEAR(c.account_open_date)   AS cohort_year,
           la.application_id,
           YEAR(la.application_date)   AS app_year,
           la.status
    FROM loan_applications la
    JOIN customers c ON la.customer_id = c.customer_id
)
SELECT cohort_year,
       app_year,
       COUNT(*)                                                       AS applications,
       SUM(CASE WHEN status = 'Disbursed' THEN 1 ELSE 0 END)          AS disbursed,
       ROUND(SUM(CASE WHEN status = 'Disbursed' THEN 1 ELSE 0 END)
             * 100.0 / COUNT(*), 1)                                    AS disbursal_rate_pct
FROM cohort_base
GROUP BY cohort_year, app_year
ORDER BY cohort_year, app_year;


-- ============================================================
-- SECTION 5: RECURSIVE CTE
-- ============================================================

-- CTE8: Generate a sequence of months for a 12-month report skeleton
-- WHAT: Uses a recursive CTE to generate 12 consecutive months starting
--       from January 2024, which can be LEFT JOINed to actual data to
--       ensure all months appear even if there is no activity.
-- WHY:  Recursive CTEs are the SQL standard way to generate sequences without
--       needing a numbers or calendar helper table.
WITH RECURSIVE month_series AS (
    -- Anchor: starting month
    SELECT DATE('2024-01-01') AS report_month
    UNION ALL
    -- Recursive: add one month each iteration, stop after 12
    SELECT DATE_ADD(report_month, INTERVAL 1 MONTH)
    FROM month_series
    WHERE report_month < DATE('2024-12-01')
)
SELECT DATE_FORMAT(ms.report_month, '%Y-%m') AS month,
       COALESCE(COUNT(la.application_id), 0) AS applications,
       COALESCE(ROUND(SUM(la.loan_amount_approved) / 10000000, 2), 0) AS disbursed_cr
FROM month_series ms
LEFT JOIN loan_applications la
       ON DATE_FORMAT(la.application_date, '%Y-%m') = DATE_FORMAT(ms.report_month, '%Y-%m')
      AND la.status = 'Disbursed'
GROUP BY ms.report_month
ORDER BY ms.report_month;


-- ============================================================
-- END OF CTEs
-- ============================================================
