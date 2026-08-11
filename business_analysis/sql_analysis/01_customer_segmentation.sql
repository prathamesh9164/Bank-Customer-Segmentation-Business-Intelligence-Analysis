-- ============================================================
-- 📊 01 — Customer Segmentation & Profitability Analysis
-- IndoSynth Gramin Bank | Business Analyst SQL Suite
-- ============================================================
-- Business Question:
--   Which customer segments, geographies, and income bands
--   drive the most loan portfolio value?
--   What is the profitability index per segment?
-- ============================================================

USE indosynth_bank;

-- ─────────────────────────────────────────────────────────────
-- QUERY 1: Customer Profitability Index by Segment & Income Band
-- Combines loan disbursements, interest earned, and risk exposure
-- into a composite profitability score per customer group
-- ─────────────────────────────────────────────────────────────
WITH customer_financials AS (
    SELECT
        c.customer_id,
        c.customer_segment,
        c.annual_income,
        CASE
            WHEN c.annual_income < 300000  THEN '< ₹3 LPA (Lower)'
            WHEN c.annual_income < 600000  THEN '₹3–6 LPA (Middle)'
            WHEN c.annual_income < 1200000 THEN '₹6–12 LPA (Upper Middle)'
            ELSE '₹12+ LPA (High Income)'
        END AS income_band,
        ch.credit_score,
        ch.credit_rating,
        COALESCE(SUM(CASE WHEN la.status = 'Disbursed' THEN la.loan_amount_approved ELSE 0 END), 0) AS total_disbursed,
        COALESCE(SUM(lp.interest_paid), 0)    AS total_interest_earned,
        COALESCE(SUM(lp.penalty_amount), 0)   AS total_penalties,
        COALESCE(SUM(lp.outstanding_balance), 0) AS total_outstanding,
        COUNT(DISTINCT la.application_id)      AS total_applications,
        SUM(CASE WHEN lp.payment_status = 'Missed' THEN 1 ELSE 0 END) AS missed_payments
    FROM customers c
    LEFT JOIN credit_history ch    ON c.customer_id = ch.customer_id
    LEFT JOIN loan_applications la ON c.customer_id = la.customer_id
    LEFT JOIN loan_payments lp     ON c.customer_id = lp.customer_id
    GROUP BY
        c.customer_id, c.customer_segment, c.annual_income,
        ch.credit_score, ch.credit_rating
),
segment_summary AS (
    SELECT
        customer_segment,
        income_band,
        COUNT(customer_id)                                          AS customer_count,
        ROUND(AVG(credit_score), 1)                                 AS avg_credit_score,
        ROUND(SUM(total_disbursed) / 10000000, 2)                  AS disbursed_cr,
        ROUND(SUM(total_interest_earned) / 10000000, 2)            AS interest_earned_cr,
        ROUND(SUM(total_penalties) / 100000, 2)                    AS penalties_lakhs,
        ROUND(SUM(total_outstanding) / 10000000, 2)                AS outstanding_cr,
        ROUND(AVG(total_applications), 1)                          AS avg_apps_per_customer,
        SUM(missed_payments)                                        AS total_missed_payments,
        ROUND(SUM(missed_payments) * 100.0 /
              NULLIF(SUM(total_applications) * 3, 0), 2)           AS estimated_default_rate_pct,
        -- Profitability Index = (Interest + Penalties) / Outstanding Balance
        ROUND((SUM(total_interest_earned) + SUM(total_penalties)) /
              NULLIF(SUM(total_outstanding), 0), 4)                AS profitability_index
    FROM customer_financials
    GROUP BY customer_segment, income_band
)
SELECT
    customer_segment,
    income_band,
    customer_count,
    avg_credit_score,
    disbursed_cr          AS `Disbursed (₹ Cr)`,
    interest_earned_cr    AS `Interest Earned (₹ Cr)`,
    penalties_lakhs       AS `Penalties (₹ Lakhs)`,
    outstanding_cr        AS `Outstanding Balance (₹ Cr)`,
    avg_apps_per_customer AS `Avg Apps / Customer`,
    total_missed_payments AS `Missed Payments`,
    estimated_default_rate_pct AS `Est. Default Rate (%)`,
    profitability_index   AS `Profitability Index`,
    CASE
        WHEN profitability_index >= 0.15 THEN '🟢 High Profit'
        WHEN profitability_index >= 0.08 THEN '🟡 Medium Profit'
        ELSE '🔴 Low Profit / Risk'
    END AS profit_tier
FROM segment_summary
ORDER BY profitability_index DESC;


-- ─────────────────────────────────────────────────────────────
-- QUERY 2: Top 15 States by Customer Value (Revenue + Volume)
-- ─────────────────────────────────────────────────────────────
SELECT
    c.state,
    COUNT(DISTINCT c.customer_id)                           AS total_customers,
    ROUND(AVG(c.annual_income) / 100000, 2)                AS avg_income_lpa,
    ROUND(SUM(la.loan_amount_approved) / 10000000, 2)      AS disbursed_cr,
    ROUND(SUM(lp.interest_paid) / 10000000, 2)             AS interest_earned_cr,
    ROUND(AVG(ch.credit_score), 1)                         AS avg_credit_score,
    ROUND(
        SUM(CASE WHEN lp.payment_status = 'Missed' THEN 1 ELSE 0 END) * 100.0 /
        NULLIF(COUNT(lp.payment_id), 0), 2
    )                                                       AS default_rate_pct,
    RANK() OVER (ORDER BY SUM(la.loan_amount_approved) DESC) AS disbursement_rank
FROM customers c
LEFT JOIN credit_history ch     ON c.customer_id  = ch.customer_id
LEFT JOIN loan_applications la  ON c.customer_id  = la.customer_id AND la.status = 'Disbursed'
LEFT JOIN loan_payments lp      ON c.customer_id  = lp.customer_id
GROUP BY c.state
ORDER BY disbursed_cr DESC
LIMIT 15;


-- ─────────────────────────────────────────────────────────────
-- QUERY 3: Customer Lifetime Value (LTV) Ranking — Top 50
-- Identifies highest-value customers for premium retention programs
-- ─────────────────────────────────────────────────────────────
WITH customer_ltv AS (
    SELECT
        c.customer_id,
        CONCAT(c.first_name, ' ', c.last_name) AS full_name,
        c.customer_segment,
        c.state,
        ch.credit_score,
        SUM(lp.interest_paid)   AS lifetime_interest,
        SUM(lp.penalty_amount)  AS lifetime_penalties,
        SUM(lp.principal_paid)  AS principal_repaid,
        COUNT(DISTINCT la.application_id) AS total_loans,
        SUM(CASE WHEN lp.payment_status = 'Missed' THEN 1 ELSE 0 END) AS missed_count
    FROM customers c
    LEFT JOIN credit_history ch    ON c.customer_id = ch.customer_id
    LEFT JOIN loan_applications la ON c.customer_id = la.customer_id
    LEFT JOIN loan_payments lp     ON la.application_id = lp.application_id
    GROUP BY c.customer_id, full_name, c.customer_segment, c.state, ch.credit_score
)
SELECT
    customer_id,
    full_name,
    customer_segment,
    state,
    credit_score,
    total_loans,
    ROUND(lifetime_interest / 100000, 2)   AS `LTV Interest (₹ Lakhs)`,
    ROUND(lifetime_penalties / 1000, 2)    AS `Penalties (₹ K)`,
    ROUND(principal_repaid / 100000, 2)    AS `Principal Repaid (₹ Lakhs)`,
    missed_count                           AS `Missed Payments`,
    ROUND((lifetime_interest + lifetime_penalties) / 100000, 2) AS `Total LTV (₹ Lakhs)`,
    DENSE_RANK() OVER (ORDER BY (lifetime_interest + lifetime_penalties) DESC) AS ltv_rank
FROM customer_ltv
ORDER BY ltv_rank
LIMIT 50;
