-- ============================================================
-- 🏦 IndoSynth Gramin Bank — 07: Window Functions
-- ============================================================
-- Demonstrates ROW_NUMBER, RANK, DENSE_RANK, LAG, LEAD, NTILE,
-- SUM/AVG OVER partitions, and running totals / moving averages.
-- Includes Q3, Q12, Q17 from the main script plus comprehensive
-- new window function banking examples.
-- Run after 01_Database_Setup.sql
-- ============================================================

USE indosynth_bank;


-- ============================================================
-- SECTION 1: RANKING FUNCTIONS (ROW_NUMBER, RANK, DENSE_RANK)
-- ============================================================

-- WF1: Rank customers within each zone by annual income
-- WHAT: Assigns a rank to each customer within their zone based on income,
--       using all three ranking functions to illustrate differences.
-- WHY:  Within-zone income ranking helps identify high-net-worth individuals
--       in each region for targeted wealth management outreach.
--       RANK() leaves gaps for ties; DENSE_RANK() does not; ROW_NUMBER() is always unique.
SELECT customer_id, full_name, zone, annual_income,
       ROW_NUMBER() OVER (PARTITION BY zone ORDER BY annual_income DESC) AS row_num,
       RANK()       OVER (PARTITION BY zone ORDER BY annual_income DESC) AS rnk,
       DENSE_RANK() OVER (PARTITION BY zone ORDER BY annual_income DESC) AS dense_rnk
FROM customers
ORDER BY zone, rnk
LIMIT 40;


-- WF2: Top 3 loan officers per zone by disbursement success rate
-- WHAT: Ranks loan officers within each zone by success rate; filters top 3 per zone.
-- WHY:  Zonal rankings allow fair comparisons — an officer in a difficult zone
--       may rank high locally but low nationally. Rewards fairness improves morale.
SELECT *
FROM (
    SELECT b.zone,
           e.full_name, e.designation,
           COUNT(la.application_id) AS processed,
           ROUND(SUM(CASE WHEN la.status='Disbursed' THEN 1 ELSE 0 END)*100.0/COUNT(*),2) AS success_rate,
           RANK() OVER (
               PARTITION BY b.zone
               ORDER BY SUM(CASE WHEN la.status='Disbursed' THEN 1 ELSE 0 END)*100.0/COUNT(*) DESC
           ) AS zone_rank
    FROM loan_applications la
    JOIN employees e ON la.officer_employee_id = e.employee_id
    JOIN branches  b ON la.branch_id = b.branch_id
    GROUP BY b.zone, e.employee_id, e.full_name, e.designation
    HAVING processed >= 5
) ranked
WHERE zone_rank <= 3
ORDER BY zone, zone_rank;


-- WF3: Nth highest salary per department (DENSE_RANK)
-- WHAT: Finds the employee with the 2nd-highest salary in each department
--       using DENSE_RANK() inside a subquery.
-- WHY:  Common interview pattern; useful for succession planning to identify
--       next-in-line employees for promotions.
SELECT *
FROM (
    SELECT department, full_name, designation, annual_salary,
           DENSE_RANK() OVER (PARTITION BY department ORDER BY annual_salary DESC) AS sal_rank
    FROM employees
) ranked
WHERE sal_rank = 2
ORDER BY department;


-- ============================================================
-- SECTION 2: LAG / LEAD (Row Comparison)
-- ============================================================

-- WF4 (Q17): Year-over-year loan application growth using LAG
-- WHAT: Uses LAG() to compare each year's loan applications with the
--       previous year, calculating YoY growth percentage.
-- WHY:  Tracks the bank's lending business growth trajectory. Declining
--       growth signals competitive pressure or market saturation.
SELECT YEAR(application_date) AS yr,
       COUNT(*)               AS applications,
       LAG(COUNT(*)) OVER (ORDER BY YEAR(application_date)) AS prev_year,
       ROUND(
           (COUNT(*) - LAG(COUNT(*)) OVER (ORDER BY YEAR(application_date)))
           * 100.0 / LAG(COUNT(*)) OVER (ORDER BY YEAR(application_date)), 2
       ) AS yoy_growth_pct
FROM loan_applications
GROUP BY yr
ORDER BY yr;


-- WF5: Month-over-month change in successful transaction volume
-- WHAT: Uses LAG() to compare each month's transaction count and amount
--       with the previous month.
-- WHY:  MoM changes quickly highlight unusual spikes or drops in banking
--       activity that may need investigation (fraud, system downtime, etc.).
SELECT month,
       txn_count,
       total_amount,
       LAG(txn_count)    OVER (ORDER BY month) AS prev_month_count,
       LAG(total_amount) OVER (ORDER BY month) AS prev_month_amount,
       ROUND(
           (txn_count - LAG(txn_count) OVER (ORDER BY month))
           * 100.0 / LAG(txn_count) OVER (ORDER BY month), 2
       ) AS mom_growth_pct
FROM (
    SELECT DATE_FORMAT(transaction_date, '%Y-%m') AS month,
           COUNT(*)                               AS txn_count,
           ROUND(SUM(amount), 2)                  AS total_amount
    FROM transactions
    WHERE status = 'Success'
    GROUP BY month
) monthly
ORDER BY month;


-- WF6: Next payment due date for each active loan (LEAD)
-- WHAT: Uses LEAD() to look ahead at the next due_date for each loan.
-- WHY:  Allows the collections team to proactively contact customers before
--       the upcoming EMI due date, reducing missed payments.
SELECT application_id, payment_number, due_date, payment_status,
       LEAD(due_date) OVER (PARTITION BY application_id ORDER BY payment_number) AS next_due_date,
       LEAD(emi_amount) OVER (PARTITION BY application_id ORDER BY payment_number) AS next_emi_amount
FROM loan_payments
ORDER BY application_id, payment_number
LIMIT 40;


-- ============================================================
-- SECTION 3: RUNNING TOTALS / CUMULATIVE SUM
-- ============================================================

-- WF7: Running total of loan disbursements over time
-- WHAT: Adds a cumulative SUM of disbursed loan amounts ordered by month.
-- WHY:  Shows the bank's total lending book growth — a rising cumulative
--       disbursement means the portfolio is expanding healthily.
SELECT DATE_FORMAT(disbursement_date, '%Y-%m')                        AS month,
       ROUND(SUM(loan_amount_approved) / 10000000, 2)                  AS monthly_disbursed_cr,
       ROUND(SUM(SUM(loan_amount_approved)) OVER (
           ORDER BY DATE_FORMAT(disbursement_date, '%Y-%m')
       ) / 10000000, 2)                                                AS cumulative_disbursed_cr
FROM loan_applications
WHERE status = 'Disbursed' AND disbursement_date IS NOT NULL
GROUP BY DATE_FORMAT(disbursement_date, '%Y-%m')
ORDER BY month;


-- WF8: Cumulative penalty collected per customer (running total within partition)
-- WHAT: Shows the running total of penalty charges for each customer's payments,
--       ordered chronologically.
-- WHY:  A rising cumulative penalty for a customer is an early warning signal
--       that can trigger automated alerts to the collections team.
SELECT customer_id, payment_id, due_date, penalty_amount,
       SUM(penalty_amount) OVER (
           PARTITION BY customer_id
           ORDER BY due_date
           ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
       ) AS cumulative_penalty
FROM loan_payments
WHERE penalty_amount > 0
ORDER BY customer_id, due_date
LIMIT 40;


-- ============================================================
-- SECTION 4: MOVING AVERAGE
-- ============================================================

-- WF9: 3-month moving average of loan applications
-- WHAT: Computes a 3-month rolling average of applications using a sliding
--       window of the current row and 2 preceding rows.
-- WHY:  Moving averages smooth out monthly noise and make long-term trends
--       more visible, which is standard in banking time-series analysis.
SELECT month,
       applications,
       ROUND(AVG(applications) OVER (
           ORDER BY month
           ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
       ), 1) AS moving_avg_3m
FROM (
    SELECT DATE_FORMAT(application_date, '%Y-%m') AS month,
           COUNT(*)                               AS applications
    FROM loan_applications
    GROUP BY month
) monthly
ORDER BY month;


-- ============================================================
-- SECTION 5: NTILE (Percentile Bucketing)
-- ============================================================

-- WF10: Divide customers into income quartiles using NTILE(4)
-- WHAT: Assigns each customer to one of four income quartiles (Q1–Q4).
-- WHY:  Quartile-based segmentation is a standard analytical technique.
--       Instead of hardcoded income thresholds, NTILE adapts to the actual
--       data distribution — useful for fair, data-driven segmentation.
SELECT customer_id, full_name, annual_income,
       NTILE(4) OVER (ORDER BY annual_income) AS income_quartile,
       CASE NTILE(4) OVER (ORDER BY annual_income)
           WHEN 1 THEN 'Q1 — Low Income'
           WHEN 2 THEN 'Q2 — Lower-Middle'
           WHEN 3 THEN 'Q3 — Upper-Middle'
           WHEN 4 THEN 'Q4 — High Income'
       END AS income_segment
FROM customers
WHERE annual_income IS NOT NULL
ORDER BY annual_income DESC
LIMIT 30;


-- WF11: Credit score percentile bands using NTILE(10) — deciles
-- WHAT: Splits customers into 10 equal groups (deciles) by credit score.
-- WHY:  Decile analysis is standard in credit risk modelling —
--       the bottom decile is the highest risk, the top decile is the safest.
SELECT customer_id, credit_score, credit_rating,
       NTILE(10) OVER (ORDER BY credit_score) AS credit_decile
FROM credit_history
ORDER BY credit_score DESC
LIMIT 30;


-- ============================================================
-- SECTION 6: PERCENT_RANK & CUME_DIST
-- ============================================================

-- WF12: Application status breakdown with percentage (PERCENT_RANK window)
-- WHAT: Uses PERCENT_RANK and CUME_DIST as alternative to manual percentage
--       calculations. CUME_DIST = proportion of rows <= current row.
-- WHY:  Demonstrates advanced distribution functions; also included from Q3
--       using OVER() for percentage without needing a subquery.
SELECT status,
       COUNT(*) AS count,
       ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS pct
FROM loan_applications
GROUP BY status;


-- WF13: Loan amount percentile for each customer
-- WHAT: Shows where each application's approved amount falls in the
--       overall distribution using PERCENT_RANK.
-- WHY:  Reveals whether a customer received an above-average or below-average
--       loan amount relative to all borrowers — useful for fairness audits.
SELECT application_id, customer_id, loan_type_name, loan_amount_approved,
       ROUND(PERCENT_RANK() OVER (ORDER BY loan_amount_approved) * 100, 1) AS amount_percentile,
       ROUND(CUME_DIST()    OVER (ORDER BY loan_amount_approved) * 100, 1) AS cumulative_dist_pct
FROM loan_applications
WHERE status IN ('Disbursed', 'Approved', 'Closed')
ORDER BY loan_amount_approved DESC
LIMIT 20;


-- WF14: Payment default rate with OVER() — no GROUP BY needed (Q12 variant)
-- WHAT: Uses SUM() OVER() to calculate the total payment count without a
--       separate GROUP BY, directly embedding the denominator in the SELECT.
-- WHY:  Illustrates how window functions can compute percentages inline,
--       avoiding the need for self-joins or subqueries for the total count.
SELECT payment_status,
       COUNT(*) AS count,
       ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS pct
FROM loan_payments
GROUP BY payment_status
ORDER BY count DESC;


-- ============================================================
-- END OF WINDOW FUNCTIONS
-- ============================================================
