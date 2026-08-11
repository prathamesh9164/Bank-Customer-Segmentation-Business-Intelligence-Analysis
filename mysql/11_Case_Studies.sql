-- ============================================================
-- 🏦 IndoSynth Gramin Bank — 11: Case Studies
-- ============================================================
-- End-to-end analytical case studies that combine multiple SQL
-- concepts (JOINs, GROUP BY, CTEs, Window Functions, CASE) to
-- answer real banking business questions.
-- Includes Q18, Q20, Q23, Q24 from the main script plus
-- new comprehensive case studies.
-- Run after 01_Database_Setup.sql
-- ============================================================

USE indosynth_bank;


-- ============================================================
-- CASE STUDY 1: Credit Risk Analysis
-- "Do higher credit scores really mean fewer defaults?"
-- ============================================================
-- CS1 (Q18): Credit score bands vs. loan default rate
-- WHAT: Groups customers into credit score bands and calculates the
--       default rate (loans with at least one missed payment) for each band.
-- WHY:  Validates the bank's credit scoring model. If Excellent customers
--       also default at high rates, scoring criteria need revision.
--       Essential for credit risk management and RBI reporting.
SELECT
    CASE
        WHEN ch.credit_score >= 800 THEN '800+ (Excellent)'
        WHEN ch.credit_score >= 700 THEN '700-799 (Good)'
        WHEN ch.credit_score >= 600 THEN '600-699 (Fair)'
        ELSE 'Below 600 (Poor)'
    END AS credit_band,
    COUNT(DISTINCT la.application_id)  AS total_loans,
    COUNT(DISTINCT CASE WHEN lp.payment_status = 'Missed'
                        THEN la.application_id END) AS loans_with_missed,
    ROUND(
        COUNT(DISTINCT CASE WHEN lp.payment_status = 'Missed'
                            THEN la.application_id END)
        * 100.0 / COUNT(DISTINCT la.application_id), 2
    ) AS default_rate_pct
FROM loan_applications la
JOIN credit_history ch ON la.customer_id  = ch.customer_id
JOIN loan_payments  lp ON la.application_id = lp.application_id
WHERE la.status IN ('Disbursed', 'Closed')
GROUP BY credit_band
ORDER BY default_rate_pct DESC;


-- ============================================================
-- CASE STUDY 2: Customer Lifetime Value (CLV)
-- "Who are the bank's most valuable customers?"
-- ============================================================
-- CS2 (Q20): Customer lifetime value — deposits + loan interest
-- WHAT: Calculates CLV by combining total deposits (credit transactions)
--       and interest paid to the bank from loans. Uses subqueries with
--       LEFT JOINs and COALESCE for customers with no transactions or loans.
-- WHY:  CLV is a critical business metric — identifies the bank's most
--       valuable customers for priority service and retention offers.
SELECT c.customer_id, c.full_name, c.customer_segment,
       COALESCE(t.total_credits, 0)  AS total_deposits,
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


-- ============================================================
-- CASE STUDY 3: NPA Identification
-- "Which loans are at risk of becoming Non-Performing Assets?"
-- ============================================================
-- CS3 (Q23): NPA identification — loans with 3+ missed payments
-- WHAT: Flags loans as potential NPAs by identifying those with 3 or more
--       missed payments, showing the outstanding balance at risk.
-- WHY:  NPA identification is an RBI regulatory requirement. Early detection
--       allows the bank to initiate recovery or provision for bad debts.
SELECT la.application_id, c.full_name, la.loan_type_name,
       la.loan_amount_approved, la.status,
       COUNT(CASE WHEN lp.payment_status = 'Missed' THEN 1 END) AS missed_payments,
       MAX(lp.outstanding_balance)                               AS current_outstanding
FROM loan_applications la
JOIN loan_payments lp ON la.application_id = lp.application_id
JOIN customers     c  ON la.customer_id    = c.customer_id
GROUP BY la.application_id, c.full_name, la.loan_type_name,
         la.loan_amount_approved, la.status
HAVING missed_payments >= 3
ORDER BY current_outstanding DESC
LIMIT 20;


-- ============================================================
-- CASE STUDY 4: RFM Customer Segmentation
-- "How active and valuable is each customer?"
-- ============================================================
-- CS4 (Q24): RFM Analysis — Recency, Frequency, Monetary
-- WHAT: Applies the RFM (Recency, Frequency, Monetary) marketing model.
--       Recency = days since last transaction, Frequency = total transactions,
--       Monetary = total spend/transaction amount.
-- WHY:  RFM segmentation identifies high-value active customers vs. dormant ones.
--       The bank can target dormant high-value customers with re-engagement
--       campaigns and reward frequent transactors with loyalty programs.
SELECT c.customer_id, c.full_name,
       DATEDIFF(CURDATE(), MAX(t.transaction_date)) AS recency_days,
       COUNT(t.transaction_id)                      AS frequency,
       ROUND(SUM(t.amount), 2)                      AS monetary
FROM customers c
JOIN transactions t ON c.customer_id = t.customer_id
WHERE t.status = 'Success'
GROUP BY c.customer_id, c.full_name
ORDER BY monetary DESC
LIMIT 20;


-- CS4b: RFM scoring — assign R, F, M scores (1–5) using NTILE
-- WHAT: Extends the RFM model by assigning 1–5 scores to each dimension
--       and computing a combined RFM score for each customer.
-- WHY:  A numeric RFM score enables automated segmentation and tiering
--       without manual threshold tuning — the quintile approach is data-driven.
WITH rfm_base AS (
    SELECT c.customer_id, c.full_name,
           DATEDIFF(CURDATE(), MAX(t.transaction_date)) AS recency_days,
           COUNT(t.transaction_id)                       AS frequency,
           ROUND(SUM(t.amount), 2)                       AS monetary
    FROM customers c
    JOIN transactions t ON c.customer_id = t.customer_id
    WHERE t.status = 'Success'
    GROUP BY c.customer_id, c.full_name
),
rfm_scored AS (
    SELECT *,
           -- Lower recency is better → invert with 6 - NTILE
           (6 - NTILE(5) OVER (ORDER BY recency_days DESC)) AS r_score,
           NTILE(5) OVER (ORDER BY frequency)               AS f_score,
           NTILE(5) OVER (ORDER BY monetary)                AS m_score
    FROM rfm_base
)
SELECT customer_id, full_name,
       recency_days, frequency, monetary,
       r_score, f_score, m_score,
       (r_score + f_score + m_score) AS rfm_total,
       CASE
           WHEN (r_score + f_score + m_score) >= 13 THEN 'Champions'
           WHEN (r_score + f_score + m_score) >= 10 THEN 'Loyal Customers'
           WHEN (r_score + f_score + m_score) >= 7  THEN 'Potential Loyalists'
           WHEN (r_score + f_score + m_score) >= 4  THEN 'At Risk'
           ELSE 'Lost'
       END AS rfm_segment
FROM rfm_scored
ORDER BY rfm_total DESC
LIMIT 30;


-- ============================================================
-- CASE STUDY 5: Zone-Level Business Intelligence Dashboard
-- "How does each zone compare across all key metrics?"
-- ============================================================
-- CS5: Comprehensive zone-level performance summary
-- WHAT: Produces a single multi-metric zone dashboard combining
--       customer count, loan applications, disbursals, interest income,
--       default rate, and average credit score.
-- WHY:  Regional banking strategy requires a unified view of zone health.
--       This single query replaces five separate reports with one.
WITH zone_customers AS (
    SELECT zone, COUNT(*) AS total_customers,
           ROUND(AVG(annual_income), 0) AS avg_income
    FROM customers
    GROUP BY zone
),
zone_loans AS (
    SELECT c.zone,
           COUNT(la.application_id)                                              AS total_applications,
           SUM(CASE WHEN la.status = 'Disbursed' THEN 1 ELSE 0 END)              AS disbursed,
           ROUND(SUM(CASE WHEN la.status = 'Disbursed'
                          THEN la.loan_amount_approved ELSE 0 END) / 10000000, 2) AS disbursed_cr
    FROM loan_applications la
    JOIN customers c ON la.customer_id = c.customer_id
    GROUP BY c.zone
),
zone_payments AS (
    SELECT c.zone,
           ROUND(SUM(lp.interest_paid), 0)     AS interest_income,
           ROUND(SUM(lp.penalty_amount), 0)    AS penalty_collected,
           SUM(CASE WHEN lp.payment_status = 'Missed' THEN 1 ELSE 0 END) AS missed_payments,
           COUNT(lp.payment_id)                AS total_payments
    FROM loan_payments lp
    JOIN loan_applications la ON lp.application_id = la.application_id
    JOIN customers         c  ON la.customer_id = c.customer_id
    GROUP BY c.zone
),
zone_credit AS (
    SELECT c.zone, ROUND(AVG(ch.credit_score), 0) AS avg_credit_score
    FROM credit_history ch
    JOIN customers c ON ch.customer_id = c.customer_id
    GROUP BY c.zone
)
SELECT
    zc.zone,
    zc.total_customers, zc.avg_income,
    zl.total_applications, zl.disbursed, zl.disbursed_cr,
    zp.interest_income, zp.penalty_collected,
    ROUND(zp.missed_payments * 100.0 / NULLIF(zp.total_payments, 0), 2) AS default_rate_pct,
    zcr.avg_credit_score
FROM zone_customers   zc
JOIN zone_loans       zl  ON zc.zone = zl.zone
JOIN zone_payments    zp  ON zc.zone = zp.zone
JOIN zone_credit      zcr ON zc.zone = zcr.zone
ORDER BY zl.disbursed_cr DESC;


-- ============================================================
-- CASE STUDY 6: Loan Product Profitability Analysis
-- "Which loan products generate the most revenue?"
-- ============================================================
-- CS6: Loan product revenue and risk profile
-- WHAT: Analyses each loan type across three dimensions:
--       volume (number and amount), revenue (interest), and risk (defaults).
-- WHY:  Product managers need to know which products are high-volume vs.
--       high-margin vs. high-risk to optimise the product portfolio.
SELECT
    la.loan_type_name,
    lt.base_interest_rate,
    COUNT(DISTINCT la.application_id)                                 AS total_applications,
    SUM(CASE WHEN la.status='Disbursed' THEN 1 ELSE 0 END)            AS disbursed_count,
    ROUND(AVG(la.interest_rate_pct), 2)                               AS avg_actual_rate,
    ROUND(SUM(la.loan_amount_approved) / 10000000, 2)                 AS total_disbursed_cr,
    ROUND(SUM(lp.interest_paid), 0)                                   AS total_interest_earned,
    ROUND(SUM(lp.penalty_amount), 0)                                  AS total_penalties,
    SUM(CASE WHEN lp.payment_status = 'Missed' THEN 1 ELSE 0 END)    AS missed_payments,
    COUNT(lp.payment_id)                                              AS total_payments,
    ROUND(SUM(CASE WHEN lp.payment_status = 'Missed' THEN 1 ELSE 0 END)
          * 100.0 / NULLIF(COUNT(lp.payment_id), 0), 2)               AS default_rate_pct
FROM loan_applications la
JOIN loan_types   lt ON la.loan_type_id   = lt.loan_type_id
LEFT JOIN loan_payments lp ON la.application_id = lp.application_id
GROUP BY la.loan_type_name, lt.base_interest_rate
ORDER BY total_interest_earned DESC;


-- ============================================================
-- CASE STUDY 7: High-Risk Customer Early Warning System
-- "Which active loan customers need immediate attention?"
-- ============================================================
-- CS7: Multi-factor risk scoring for active loan customers
-- WHAT: Assigns a composite risk score based on: missed payment ratio,
--       days late average, credit score, and total penalty accumulated.
--       Flags customers as HIGH / MEDIUM / LOW risk.
-- WHY:  A data-driven early warning system allows the collections and
--       risk teams to prioritise outreach before loans turn NPA.
WITH customer_risk AS (
    SELECT
        c.customer_id, c.full_name, c.phone_number,
        ch.credit_score, ch.credit_rating,
        COUNT(lp.payment_id)                                                 AS total_payments,
        SUM(CASE WHEN lp.payment_status = 'Missed' THEN 1 ELSE 0 END)        AS missed_count,
        ROUND(AVG(lp.days_late), 1)                                           AS avg_days_late,
        ROUND(SUM(lp.penalty_amount), 2)                                      AS total_penalty,
        MAX(lp.outstanding_balance)                                           AS max_outstanding
    FROM customers c
    JOIN loan_applications la ON c.customer_id     = la.customer_id
    JOIN loan_payments     lp ON la.application_id = lp.application_id
    JOIN credit_history    ch ON c.customer_id     = ch.customer_id
    WHERE la.status = 'Disbursed'
    GROUP BY c.customer_id, c.full_name, c.phone_number,
             ch.credit_score, ch.credit_rating
)
SELECT *,
    CASE
        WHEN missed_count >= 3 OR credit_score < 550 OR avg_days_late > 45 THEN 'HIGH RISK'
        WHEN missed_count >= 1 OR credit_score < 650 OR avg_days_late > 15 THEN 'MEDIUM RISK'
        ELSE 'LOW RISK'
    END AS risk_level
FROM customer_risk
ORDER BY
    CASE WHEN missed_count >= 3 OR credit_score < 550 THEN 1
         WHEN missed_count >= 1 OR credit_score < 650 THEN 2
         ELSE 3 END,
    max_outstanding DESC
LIMIT 30;


-- ============================================================
-- END OF CASE STUDIES
-- ============================================================
