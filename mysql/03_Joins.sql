-- ============================================================
-- 🏦 IndoSynth Gramin Bank — 03: JOINs
-- ============================================================
-- Demonstrates INNER JOIN, LEFT JOIN, RIGHT JOIN, SELF JOIN,
-- and multi-table JOINs using the bank's relational schema.
-- Includes Q5, Q13, Q14, Q19, Q21 from the main analytical
-- script plus additional dedicated JOIN examples.
-- Run after 01_Database_Setup.sql
-- ============================================================

USE indosynth_bank;


-- ============================================================
-- SECTION 1: INNER JOIN
-- ============================================================

-- J1 (Q5): Top 10 branches by number of customers
-- WHAT: Lists the top 10 branches that serve the most customers.
-- WHY:  Identifies the busiest branches, which may need more staff,
--       better infrastructure, or could serve as flagship branches.
SELECT b.branch_name, b.city, b.state, COUNT(c.customer_id) AS customers
FROM branches b
JOIN customers c ON b.branch_id = c.branch_id
GROUP BY b.branch_id, b.branch_name, b.city, b.state
ORDER BY customers DESC
LIMIT 10;


-- J2: Customer details with their home branch and region
-- WHAT: Combines customer, branch, and region data in a single result.
-- WHY:  A complete customer view (with branch name and region) is the
--       basis for personalised communication and regional reporting.
SELECT c.customer_id, c.full_name, c.customer_segment,
       b.branch_name, b.city, b.state,
       r.region_name, r.zone
FROM customers c
INNER JOIN branches b ON c.branch_id = b.branch_id
INNER JOIN regions  r ON c.region_id = r.region_id
ORDER BY r.zone, b.branch_name
LIMIT 30;


-- J3: Loan applications with loan type details (interest rate comparison)
-- WHAT: Joins loan_applications with loan_types to compare the actual
--       interest rate granted vs. the base rate for that product.
-- WHY:  A rate below base rate may indicate special schemes or errors;
--       a rate above may represent risk-based pricing. Both need scrutiny.
SELECT la.application_id, la.loan_type_name,
       lt.base_interest_rate,
       la.interest_rate_pct AS actual_rate,
       ROUND(la.interest_rate_pct - lt.base_interest_rate, 2) AS rate_spread,
       la.status
FROM loan_applications la
INNER JOIN loan_types lt ON la.loan_type_id = lt.loan_type_id
ORDER BY rate_spread DESC
LIMIT 20;


-- J4: Loan payments with application and customer details
-- WHAT: A 3-table INNER JOIN linking payments → applications → customers.
-- WHY:  Required for EMI receipts, customer-level payment history reports,
--       and collections team dashboards.
SELECT lp.payment_id, c.full_name, c.phone_number,
       la.loan_type_name, lp.due_date, lp.payment_date,
       lp.emi_amount, lp.payment_status, lp.days_late, lp.penalty_amount
FROM loan_payments lp
INNER JOIN loan_applications la ON lp.application_id = la.application_id
INNER JOIN customers c ON lp.customer_id = c.customer_id
ORDER BY lp.due_date DESC
LIMIT 30;


-- ============================================================
-- SECTION 2: LEFT JOIN (include all records from left table)
-- ============================================================

-- J5: All customers with their loan application count (including those with no loans)
-- WHAT: Uses LEFT JOIN so customers who have never applied for a loan are still
--       included with a 0 application count.
-- WHY:  Identifies prospects who are customers but not yet borrowers —
--       prime targets for loan product cross-selling campaigns.
SELECT c.customer_id, c.full_name, c.customer_segment,
       COUNT(la.application_id) AS total_applications
FROM customers c
LEFT JOIN loan_applications la ON c.customer_id = la.customer_id
GROUP BY c.customer_id, c.full_name, c.customer_segment
ORDER BY total_applications ASC
LIMIT 30;


-- J6: Customers with no loan applications at all
-- WHAT: Filters the LEFT JOIN result to only show customers with zero applications.
-- WHY:  These are untapped lending opportunities. A targeted campaign offering
--       pre-approved loans can convert them into borrowers.
SELECT c.customer_id, c.full_name, c.customer_segment,
       c.employment_type, c.annual_income, c.account_open_date
FROM customers c
LEFT JOIN loan_applications la ON c.customer_id = la.customer_id
WHERE la.application_id IS NULL
ORDER BY c.annual_income DESC
LIMIT 20;


-- J7: All loan applications with their officer name (some may have no officer assigned)
-- WHAT: LEFT JOIN ensures applications with no assigned officer (NULL officer_employee_id)
--       still appear in the result.
-- WHY:  Unassigned applications may be stuck in the pipeline, risking SLA breaches
--       and customer dissatisfaction.
SELECT la.application_id, la.loan_type_name, la.status,
       la.loan_amount_requested,
       COALESCE(e.full_name, 'Unassigned') AS officer_name,
       COALESCE(e.designation, 'N/A')      AS designation
FROM loan_applications la
LEFT JOIN employees e ON la.officer_employee_id = e.employee_id
ORDER BY officer_name
LIMIT 30;


-- J8: Branches with no active loan applications
-- WHAT: Finds branches that have no loan application records at all.
-- WHY:  These branches may be newly opened, underperforming, or have
--       data issues — management attention is warranted.
SELECT b.branch_id, b.branch_name, b.city, b.state, b.zone
FROM branches b
LEFT JOIN loan_applications la ON b.branch_id = la.branch_id
WHERE la.application_id IS NULL
ORDER BY b.zone, b.state;


-- ============================================================
-- SECTION 3: RIGHT JOIN
-- ============================================================

-- J9: All loan types including those with no applications (RIGHT JOIN)
-- WHAT: Ensures every loan type appears even if no customer has ever applied for it.
-- WHY:  A loan product with zero applications is either brand new or not being
--       marketed effectively — either way it needs management attention.
SELECT lt.loan_type_id, lt.loan_type_name, lt.base_interest_rate,
       COUNT(la.application_id) AS application_count
FROM loan_applications la
RIGHT JOIN loan_types lt ON la.loan_type_id = lt.loan_type_id
GROUP BY lt.loan_type_id, lt.loan_type_name, lt.base_interest_rate
ORDER BY application_count DESC;


-- ============================================================
-- SECTION 4: SELF JOIN
-- ============================================================

-- J10: Employees in the same branch (peer listing using SELF JOIN)
-- WHAT: Joins the employees table to itself to find pairs of employees
--       who work in the same branch.
-- WHY:  Useful for team roster reports and identifying branch staffing levels.
--       A self join demonstrates how a table can reference itself.
SELECT e1.full_name AS employee,
       e2.full_name AS colleague,
       e1.designation AS emp_designation,
       e2.designation AS col_designation,
       e1.branch_id
FROM employees e1
INNER JOIN employees e2
    ON e1.branch_id = e2.branch_id
   AND e1.employee_id < e2.employee_id   -- avoid duplicate pairs & self-pairing
ORDER BY e1.branch_id
LIMIT 30;


-- ============================================================
-- SECTION 5: MULTI-TABLE JOINS (from original analytics)
-- ============================================================

-- J11 (Q13): Top 10 customers with highest total penalty
-- WHAT: Identifies the 10 customers who have accumulated the highest penalty charges.
-- WHY:  These are high-risk borrowers who consistently miss payments. The bank can
--       proactively reach out for restructuring or initiate recovery proceedings.
SELECT c.full_name, c.customer_id,
       ROUND(SUM(lp.penalty_amount), 2) AS total_penalty,
       COUNT(CASE WHEN lp.payment_status = 'Missed' THEN 1 END) AS missed_count
FROM loan_payments lp
JOIN customers c ON lp.customer_id = c.customer_id
GROUP BY c.customer_id, c.full_name
HAVING total_penalty > 0
ORDER BY total_penalty DESC
LIMIT 10;


-- J12 (Q14): Zone-wise total disbursed amount (in Crores)
-- WHAT: Aggregates total loan disbursement per zone, converted to Crores.
-- WHY:  Shows the bank's lending exposure across geographic zones, critical for
--       risk diversification and meeting RBI priority sector lending targets.
SELECT c.zone,
       COUNT(DISTINCT la.application_id) AS loans,
       ROUND(SUM(la.loan_amount_approved) / 10000000, 2) AS disbursed_cr
FROM loan_applications la
JOIN customers c ON la.customer_id = c.customer_id
WHERE la.status = 'Disbursed'
GROUP BY c.zone
ORDER BY disbursed_cr DESC;


-- J13 (Q19): Branch-wise profitability (Interest earned vs penalties)
-- WHAT: Ranks top 15 branches by total interest income, also showing penalty
--       collections and active loan count via 3-table JOINs.
-- WHY:  Branch profitability helps management decide where to expand, cut costs,
--       and identify the bank's revenue engines.
SELECT b.branch_name, b.city,
       ROUND(SUM(lp.interest_paid), 0)         AS total_interest_earned,
       ROUND(SUM(lp.penalty_amount), 0)        AS total_penalties,
       COUNT(DISTINCT la.application_id)        AS active_loans
FROM loan_payments lp
JOIN loan_applications la ON lp.application_id = la.application_id
JOIN branches b            ON la.branch_id = b.branch_id
GROUP BY b.branch_id, b.branch_name, b.city
ORDER BY total_interest_earned DESC
LIMIT 15;


-- J14 (Q21): Loan officer performance ranking
-- WHAT: Ranks loan officers by disbursement success rate (10+ applications only).
-- WHY:  Enables performance-based appraisals. Top performers can be rewarded;
--       low success rates may indicate a training need.
SELECT e.full_name, e.designation,
       COUNT(la.application_id)                                          AS total_processed,
       SUM(CASE WHEN la.status = 'Disbursed' THEN 1 ELSE 0 END)         AS disbursed,
       ROUND(SUM(CASE WHEN la.status = 'Disbursed' THEN 1 ELSE 0 END)
             * 100.0 / COUNT(*), 2)                                      AS success_rate,
       ROUND(SUM(CASE WHEN la.status = 'Disbursed' THEN la.loan_amount_approved ELSE 0 END)
             / 100000, 2)                                                AS disbursed_lakhs
FROM loan_applications la
JOIN employees e ON la.officer_employee_id = e.employee_id
GROUP BY e.employee_id, e.full_name, e.designation
HAVING total_processed >= 10
ORDER BY success_rate DESC
LIMIT 15;


-- ============================================================
-- END OF JOINS
-- ============================================================
