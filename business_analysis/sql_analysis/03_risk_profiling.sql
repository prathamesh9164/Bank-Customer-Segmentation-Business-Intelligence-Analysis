-- ============================================================
-- 📊 03 — Risk Profiling & NPA Early Warning System
-- IndoSynth Gramin Bank | Business Analyst SQL Suite
-- ============================================================
-- Business Question:
--   Who are the top 100 highest-risk borrowers?
--   Which loan products have the worst NPA rate?
--   Can we build an early warning score from available data?
-- ============================================================

USE indosynth_bank;

-- ─────────────────────────────────────────────────────────────
-- QUERY 1: Borrower Risk Scoring Model (Rule-Based)
-- Assigns a composite Risk Score (0–100) to every active borrower
-- Higher score = higher default probability
-- ─────────────────────────────────────────────────────────────
WITH borrower_risk AS (
    SELECT
        c.customer_id,
        CONCAT(c.first_name, ' ', c.last_name)  AS full_name,
        c.customer_segment,
        c.state,
        ch.credit_score,
        ch.credit_rating,
        ch.credit_utilization_pct,
        ch.number_of_defaults,
        -- Payment behavior metrics
        COUNT(lp.payment_id)                                                AS total_emis,
        SUM(CASE WHEN lp.payment_status = 'Missed' THEN 1 ELSE 0 END)      AS missed_emis,
        SUM(CASE WHEN lp.payment_status = 'Late'   THEN 1 ELSE 0 END)      AS late_emis,
        SUM(CASE WHEN lp.days_late > 30            THEN 1 ELSE 0 END)      AS severely_late_emis,
        ROUND(AVG(lp.days_late), 1)                                         AS avg_days_late,
        SUM(lp.outstanding_balance)                                          AS total_outstanding,
        -- Loan exposure
        COUNT(DISTINCT la.application_id)                                    AS total_loans,
        SUM(la.loan_amount_approved)                                         AS total_exposure
    FROM customers c
    JOIN credit_history ch     ON c.customer_id = ch.customer_id
    JOIN loan_applications la  ON c.customer_id = la.customer_id AND la.status = 'Disbursed'
    JOIN loan_payments lp      ON la.application_id = lp.application_id
    WHERE c.is_active = TRUE
    GROUP BY
        c.customer_id, full_name, c.customer_segment, c.state,
        ch.credit_score, ch.credit_rating, ch.credit_utilization_pct, ch.number_of_defaults
),
risk_scored AS (
    SELECT
        *,
        ROUND(
            -- Credit score penalty (low score = higher risk)
            CASE WHEN credit_score < 600 THEN 35
                 WHEN credit_score < 700 THEN 20
                 WHEN credit_score < 750 THEN 10
                 ELSE 0 END
            -- Missed payment penalty
            + LEAST(missed_emis * 5, 30)
            -- Late payment penalty
            + LEAST(late_emis * 2, 15)
            -- Credit utilization penalty
            + CASE WHEN credit_utilization_pct > 90 THEN 15
                   WHEN credit_utilization_pct > 75 THEN 10
                   WHEN credit_utilization_pct > 50 THEN 5
                   ELSE 0 END
            -- Prior defaults penalty
            + LEAST(number_of_defaults * 10, 20)
            -- High outstanding balance penalty
            + CASE WHEN total_outstanding > 5000000 THEN 10
                   WHEN total_outstanding > 2000000 THEN 5
                   ELSE 0 END,
        0) AS risk_score
    FROM borrower_risk
)
SELECT
    customer_id,
    full_name,
    customer_segment,
    state,
    credit_score,
    credit_rating,
    ROUND(credit_utilization_pct, 1)          AS `Credit Util (%)`,
    number_of_defaults                         AS `Prior Defaults`,
    total_loans                                AS `Active Loans`,
    total_emis                                 AS `Total EMIs`,
    missed_emis                                AS `Missed EMIs`,
    late_emis                                  AS `Late EMIs`,
    avg_days_late                              AS `Avg Days Late`,
    ROUND(total_outstanding / 100000, 2)       AS `Outstanding (₹ Lakhs)`,
    ROUND(total_exposure / 100000, 2)          AS `Total Exposure (₹ Lakhs)`,
    risk_score                                 AS `Risk Score (0-100)`,
    CASE
        WHEN risk_score >= 70 THEN '🔴 Critical Risk — Immediate Action'
        WHEN risk_score >= 50 THEN '🟠 High Risk — Close Monitoring'
        WHEN risk_score >= 30 THEN '🟡 Moderate Risk — Watch List'
        ELSE '🟢 Low Risk — Healthy'
    END AS risk_category,
    DENSE_RANK() OVER (ORDER BY risk_score DESC) AS risk_rank
FROM risk_scored
ORDER BY risk_score DESC
LIMIT 100;


-- ─────────────────────────────────────────────────────────────
-- QUERY 2: NPA Rate by Loan Product (Portfolio Risk by Type)
-- ─────────────────────────────────────────────────────────────
SELECT
    lt.loan_type_name,
    lt.base_interest_rate_pct,
    lt.collateral_required,
    COUNT(DISTINCT la.application_id)                                    AS total_loans,
    ROUND(SUM(la.loan_amount_approved) / 10000000, 2)                   AS disbursed_cr,
    ROUND(AVG(la.loan_amount_approved) / 100000, 2)                     AS avg_ticket_lakhs,
    SUM(CASE WHEN lp.payment_status = 'Missed' THEN 1 ELSE 0 END)       AS missed_payments,
    COUNT(lp.payment_id)                                                 AS total_payments,
    ROUND(SUM(CASE WHEN lp.payment_status = 'Missed' THEN 1 ELSE 0 END)
          * 100.0 / NULLIF(COUNT(lp.payment_id), 0), 2)                AS `NPA Rate (%)`,
    ROUND(SUM(lp.outstanding_balance) / 10000000, 2)                   AS outstanding_cr,
    ROUND(SUM(lp.interest_paid) / 10000000, 2)                         AS interest_earned_cr,
    RANK() OVER (ORDER BY
        SUM(CASE WHEN lp.payment_status = 'Missed' THEN 1 ELSE 0 END)
        * 100.0 / NULLIF(COUNT(lp.payment_id), 0) DESC)                AS npa_rank
FROM loan_types lt
JOIN loan_applications la ON lt.loan_type_id = la.loan_type_id AND la.status = 'Disbursed'
JOIN loan_payments lp     ON la.application_id = lp.application_id
GROUP BY lt.loan_type_name, lt.base_interest_rate_pct, lt.collateral_required
ORDER BY `NPA Rate (%)` DESC;


-- ─────────────────────────────────────────────────────────────
-- QUERY 3: Delinquency Trend — Rolling 3-Month Default Rate
-- Shows if the NPA situation is improving or deteriorating
-- ─────────────────────────────────────────────────────────────
WITH monthly_payments AS (
    SELECT
        DATE_FORMAT(due_date, '%Y-%m')                                   AS year_month,
        YEAR(due_date)                                                    AS yr,
        MONTH(due_date)                                                   AS mo,
        COUNT(*)                                                           AS total_emis,
        SUM(CASE WHEN payment_status = 'Missed' THEN 1 ELSE 0 END)       AS missed_emis,
        SUM(CASE WHEN payment_status = 'Late'   THEN 1 ELSE 0 END)       AS late_emis,
        SUM(outstanding_balance)                                           AS outstanding_balance
    FROM loan_payments
    WHERE due_date IS NOT NULL
    GROUP BY year_month, yr, mo
)
SELECT
    year_month,
    total_emis,
    missed_emis,
    late_emis,
    ROUND(missed_emis * 100.0 / NULLIF(total_emis, 0), 2)               AS `Monthly Default Rate (%)`,
    -- Rolling 3-month average default rate
    ROUND(AVG(missed_emis * 100.0 / NULLIF(total_emis, 0))
        OVER (ORDER BY yr, mo ROWS BETWEEN 2 PRECEDING AND CURRENT ROW), 2) AS `3M Rolling Default Rate (%)`,
    ROUND(outstanding_balance / 10000000, 2)                            AS `Outstanding (₹ Cr)`,
    -- Month-over-month change in defaults
    missed_emis - LAG(missed_emis) OVER (ORDER BY yr, mo)              AS `MoM Change in Missed EMIs`
FROM monthly_payments
ORDER BY yr, mo;


-- ─────────────────────────────────────────────────────────────
-- QUERY 4: High-Risk Zones — Branch-Level NPA Hotspots
-- Identifies geographic concentrations of risk
-- ─────────────────────────────────────────────────────────────
SELECT
    r.zone,
    b.state,
    b.branch_name,
    b.branch_type,
    COUNT(DISTINCT la.application_id)                                    AS disbursed_loans,
    ROUND(SUM(la.loan_amount_approved) / 10000000, 2)                   AS disbursed_cr,
    SUM(CASE WHEN lp.payment_status = 'Missed' THEN 1 ELSE 0 END)       AS missed_payments,
    COUNT(lp.payment_id)                                                 AS total_payments,
    ROUND(SUM(CASE WHEN lp.payment_status = 'Missed' THEN 1 ELSE 0 END)
          * 100.0 / NULLIF(COUNT(lp.payment_id), 0), 2)                AS `Default Rate (%)`,
    ROUND(SUM(lp.outstanding_balance) / 10000000, 2)                   AS `Outstanding Exposure (₹ Cr)`,
    CASE
        WHEN SUM(CASE WHEN lp.payment_status = 'Missed' THEN 1 ELSE 0 END)
             * 100.0 / NULLIF(COUNT(lp.payment_id), 0) > 10 THEN '🔴 High Risk Zone'
        WHEN SUM(CASE WHEN lp.payment_status = 'Missed' THEN 1 ELSE 0 END)
             * 100.0 / NULLIF(COUNT(lp.payment_id), 0) > 5  THEN '🟡 Watch Zone'
        ELSE '🟢 Healthy Zone'
    END AS zone_risk_flag
FROM loan_applications la
JOIN branches b  ON la.branch_id = b.branch_id
JOIN regions r   ON b.region_id  = r.region_id
JOIN loan_payments lp ON la.application_id = lp.application_id
WHERE la.status = 'Disbursed'
GROUP BY r.zone, b.state, b.branch_name, b.branch_type
HAVING disbursed_loans >= 50
ORDER BY `Default Rate (%)` DESC
LIMIT 25;
