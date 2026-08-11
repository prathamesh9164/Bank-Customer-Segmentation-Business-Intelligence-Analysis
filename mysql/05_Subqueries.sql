-- ============================================================
-- 🏦 IndoSynth Gramin Bank — 05: Subqueries
-- ============================================================
-- Demonstrates scalar subqueries, multi-row subqueries (IN, NOT IN),
-- correlated subqueries, subqueries in FROM clause (derived tables),
-- and EXISTS / NOT EXISTS patterns.
-- Includes Q10, Q20 from the main script plus new examples.
-- Run after 01_Database_Setup.sql
-- ============================================================

USE indosynth_bank;


-- ============================================================
-- SECTION 1: SCALAR SUBQUERY (returns a single value)
-- ============================================================

-- SQ1: Customers with above-average annual income
-- WHAT: Uses a scalar subquery to compute the bank-wide average income,
--       then filters customers who earn above that threshold.
-- WHY:  High-income customers are prime targets for wealth management,
--       premium credit cards, and high-value loan products.
SELECT customer_id, full_name, employment_type, annual_income, customer_segment
FROM customers
WHERE annual_income > (SELECT AVG(annual_income) FROM customers)
ORDER BY annual_income DESC
LIMIT 20;


-- SQ2: Loan applications with an approved amount above the product's average
-- WHAT: For each application, checks whether the approved amount is greater
--       than the average approved amount for that specific loan type.
-- WHY:  Identifies unusually large loans within a category — high-value
--       loans need closer monitoring for risk management.
SELECT application_id, loan_type_name, loan_amount_approved, status
FROM loan_applications la
WHERE loan_amount_approved > (
    SELECT AVG(loan_amount_approved)
    FROM loan_applications
    WHERE loan_type_id = la.loan_type_id   -- correlated reference
)
ORDER BY loan_amount_approved DESC
LIMIT 20;


-- SQ3: Employees earning above the department average salary
-- WHAT: Finds employees whose salary exceeds the average for their department.
-- WHY:  Salary benchmarking within departments helps HR identify outliers
--       — both overpaid and underpaid employees relative to peers.
SELECT employee_id, full_name, department, designation, annual_salary
FROM employees e
WHERE annual_salary > (
    SELECT AVG(annual_salary)
    FROM employees
    WHERE department = e.department   -- correlated subquery
)
ORDER BY department, annual_salary DESC;


-- ============================================================
-- SECTION 2: MULTI-ROW SUBQUERY — IN / NOT IN
-- ============================================================

-- SQ4 (Q10): Top rejection reasons — using subquery to pre-filter
-- WHAT: Lists the most common reasons why loan applications get rejected.
-- WHY:  Pinpoints the primary blockers so the bank can offer pre-approval
--       guidance or relax certain criteria.
SELECT rejection_reason, COUNT(*) AS count
FROM loan_applications
WHERE status = 'Rejected' AND rejection_reason IS NOT NULL
GROUP BY rejection_reason
ORDER BY count DESC;


-- SQ5: Customers who have ONLY been rejected (never approved or disbursed)
-- WHAT: Uses a NOT IN subquery to find customers whose ALL applications
--       resulted in rejection — they have never had an approved loan.
-- WHY:  These customers may have persistent eligibility issues. Targeted
--       financial literacy or credit-building programmes can help them qualify.
SELECT customer_id, full_name, annual_income, customer_segment
FROM customers
WHERE customer_id IN (
    SELECT DISTINCT customer_id FROM loan_applications WHERE status = 'Rejected'
)
AND customer_id NOT IN (
    SELECT DISTINCT customer_id FROM loan_applications WHERE status IN ('Approved','Disbursed','Closed')
)
ORDER BY annual_income DESC
LIMIT 20;


-- SQ6: Branches that handle the top-5 highest-volume loan types
-- WHAT: Finds branches that have processed applications for the top 5
--       most popular loan types (identified via a subquery).
-- WHY:  Branches handling popular products need appropriate staffing levels
--       and operational readiness for high throughput.
SELECT DISTINCT b.branch_id, b.branch_name, b.city, b.state
FROM branches b
JOIN loan_applications la ON b.branch_id = la.branch_id
WHERE la.loan_type_id IN (
    SELECT loan_type_id
    FROM loan_applications
    GROUP BY loan_type_id
    ORDER BY COUNT(*) DESC
    LIMIT 5
)
ORDER BY b.branch_name;


-- ============================================================
-- SECTION 3: SUBQUERY IN FROM CLAUSE (Derived Table)
-- ============================================================

-- SQ7 (Q20): Customer lifetime value (deposits + loan interest)
-- WHAT: Calculates CLV by combining total deposits and interest paid using
--       two subqueries as derived tables joined to the customers table.
-- WHY:  CLV identifies the bank's most valuable customers who should receive
--       priority service, premium products, and retention offers.
SELECT c.customer_id, c.full_name, c.customer_segment,
       COALESCE(t.total_credits, 0)   AS total_deposits,
       COALESCE(l.total_interest, 0)  AS interest_paid_to_bank,
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


-- SQ8: Branch-level loan summary as a derived table, then filtered
-- WHAT: Creates a derived table of branch-level loan counts and amounts,
--       then selects only branches with more than 100 applications.
-- WHY:  Demonstrates how derived tables act as virtual tables in the FROM
--       clause, enabling a second level of filtering on aggregated data.
SELECT branch_summary.*
FROM (
    SELECT la.branch_id,
           b.branch_name, b.city, b.state,
           COUNT(*)                                         AS total_applications,
           SUM(CASE WHEN la.status = 'Disbursed' THEN 1 ELSE 0 END) AS disbursed_count,
           ROUND(SUM(la.loan_amount_approved) / 10000000, 2)         AS total_disbursed_cr
    FROM loan_applications la
    JOIN branches b ON la.branch_id = b.branch_id
    GROUP BY la.branch_id, b.branch_name, b.city, b.state
) AS branch_summary
WHERE branch_summary.total_applications > 100
ORDER BY branch_summary.total_disbursed_cr DESC;


-- SQ9: Customers ranked by total transaction value (derived table + ranking)
-- WHAT: Builds a derived table of per-customer transaction totals, then
--       assigns a rank and filters for the top 10.
-- WHY:  Illustrates how derived tables can be combined with ORDER BY and LIMIT
--       for top-N analyses before CTEs or window functions are introduced.
SELECT customer_rank.rank_pos, customer_rank.full_name,
       customer_rank.total_transactions, customer_rank.total_amount
FROM (
    SELECT c.full_name,
           COUNT(t.transaction_id)     AS total_transactions,
           ROUND(SUM(t.amount), 2)     AS total_amount,
           ROW_NUMBER() OVER (ORDER BY SUM(t.amount) DESC) AS rank_pos
    FROM transactions t
    JOIN customers c ON t.customer_id = c.customer_id
    WHERE t.status = 'Success'
    GROUP BY c.customer_id, c.full_name
) AS customer_rank
WHERE customer_rank.rank_pos <= 10;


-- ============================================================
-- SECTION 4: EXISTS / NOT EXISTS
-- ============================================================

-- SQ10: Customers who have at least one missed payment (EXISTS)
-- WHAT: Uses EXISTS to find customers with any missed loan payment.
-- WHY:  EXISTS is more efficient than IN for large tables because it stops
--       scanning as soon as the first match is found. Useful for risk flags.
SELECT c.customer_id, c.full_name, c.phone_number, c.customer_segment
FROM customers c
WHERE EXISTS (
    SELECT 1
    FROM loan_payments lp
    WHERE lp.customer_id = c.customer_id
      AND lp.payment_status = 'Missed'
)
ORDER BY c.customer_id
LIMIT 20;


-- SQ11: Customers with a credit history but no loan application (NOT EXISTS)
-- WHAT: Finds customers who have a credit score on file but have never
--       applied for a loan.
-- WHY:  These customers are credit-ready prospects who have not yet been
--       converted to borrowers — a high-priority cross-sell opportunity.
SELECT c.customer_id, c.full_name, ch.credit_score, ch.credit_rating,
       c.annual_income, c.customer_segment
FROM customers c
JOIN credit_history ch ON c.customer_id = ch.customer_id
WHERE NOT EXISTS (
    SELECT 1
    FROM loan_applications la
    WHERE la.customer_id = c.customer_id
)
  AND ch.credit_score >= 700
ORDER BY ch.credit_score DESC
LIMIT 20;


-- SQ12: Branches that have at least one active employee AND at least one loan application
-- WHAT: Uses two EXISTS subqueries to confirm both conditions are satisfied.
-- WHY:  Ensures branch performance reports only include operationally active
--       branches with both staff and lending activity.
SELECT b.branch_id, b.branch_name, b.city, b.state, b.zone
FROM branches b
WHERE EXISTS (
    SELECT 1 FROM employees e WHERE e.branch_id = b.branch_id AND e.is_active = TRUE
)
  AND EXISTS (
    SELECT 1 FROM loan_applications la WHERE la.branch_id = b.branch_id
)
ORDER BY b.zone, b.state;


-- ============================================================
-- SECTION 5: CORRELATED SUBQUERY
-- ============================================================

-- SQ13: Customers whose most recent loan was rejected
-- WHAT: Uses a correlated subquery to find the latest application date for
--       each customer, then checks whether that latest application was rejected.
-- WHY:  Recently rejected customers may need immediate counselling or referral
--       to alternative products before they approach a competitor bank.
SELECT c.customer_id, c.full_name, c.phone_number,
       la.application_date AS last_application_date,
       la.loan_type_name, la.rejection_reason
FROM customers c
JOIN loan_applications la ON c.customer_id = la.customer_id
WHERE la.application_date = (
    SELECT MAX(application_date)
    FROM loan_applications
    WHERE customer_id = c.customer_id   -- correlated to outer query
)
  AND la.status = 'Rejected'
ORDER BY la.application_date DESC
LIMIT 20;


-- ============================================================
-- END OF SUBQUERIES
-- ============================================================
