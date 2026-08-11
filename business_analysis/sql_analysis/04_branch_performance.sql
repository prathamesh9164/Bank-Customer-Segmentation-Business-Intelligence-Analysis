-- ============================================================
-- 📊 04 — Branch Operations & Performance ROI Analysis
-- IndoSynth Gramin Bank | Business Analyst SQL Suite
-- ============================================================
-- Business Question:
--   Which branches have the highest disbursement volume
--   but also the highest default rate?
--   How do Rural vs Urban branches compare on ROI metrics?
--   Who are the top loan officers across the network?
-- ============================================================

USE indosynth_bank;

-- ─────────────────────────────────────────────────────────────
-- QUERY 1: Branch ROI Quadrant Analysis
-- Plots branches on a 2×2 matrix:
--   High Disbursement + Low Default  → ⭐ Star Branches
--   Low  Disbursement + Low Default  → 🌱 Growth Potential
--   High Disbursement + High Default → ⚠️ Risk Leaders
--   Low  Disbursement + High Default → 🔴 Underperformers
-- ─────────────────────────────────────────────────────────────
WITH branch_metrics AS (
    SELECT
        b.branch_id,
        b.branch_name,
        b.branch_type,
        b.city,
        r.zone,
        r.primary_state                                                   AS state,
        COUNT(DISTINCT la.application_id)                                AS total_loans,
        ROUND(SUM(la.loan_amount_approved) / 10000000, 2)               AS disbursed_cr,
        ROUND(AVG(la.loan_amount_approved) / 100000, 2)                 AS avg_ticket_lakhs,
        ROUND(SUM(CASE WHEN la.status IN ('Approved','Disbursed') THEN 1 ELSE 0 END)
              * 100.0 / NULLIF(COUNT(la.application_id), 0), 2)        AS approval_rate_pct,
        ROUND(SUM(CASE WHEN lp.payment_status = 'Missed' THEN 1 ELSE 0 END)
              * 100.0 / NULLIF(COUNT(lp.payment_id), 0), 2)            AS default_rate_pct,
        ROUND(SUM(lp.interest_paid) / 10000000, 2)                     AS interest_earned_cr,
        ROUND(SUM(lp.penalty_amount) / 100000, 2)                      AS penalties_lakhs,
        COUNT(DISTINCT c.customer_id)                                    AS unique_customers,
        COUNT(DISTINCT e.employee_id)                                    AS staff_count
    FROM branches b
    JOIN regions r           ON b.region_id        = r.region_id
    LEFT JOIN loan_applications la ON b.branch_id  = la.branch_id
    LEFT JOIN loan_payments lp     ON la.application_id = lp.application_id
    LEFT JOIN customers c          ON la.customer_id = c.customer_id
    LEFT JOIN employees e          ON b.branch_id   = e.branch_id
    WHERE la.status = 'Disbursed'
    GROUP BY b.branch_id, b.branch_name, b.branch_type, b.city, r.zone, state
    HAVING total_loans >= 50
),
bank_averages AS (
    SELECT
        AVG(disbursed_cr)    AS avg_disbursed,
        AVG(default_rate_pct) AS avg_default_rate
    FROM branch_metrics
)
SELECT
    bm.*,
    ROUND(disbursed_cr / NULLIF(staff_count, 0), 2)              AS `Productivity (₹Cr/Staff)`,
    ROUND((interest_earned_cr + penalties_lakhs/100) / NULLIF(disbursed_cr, 0) * 100, 2) AS `Revenue Yield (%)`,
    ba.avg_disbursed,
    ba.avg_default_rate,
    CASE
        WHEN disbursed_cr    >= ba.avg_disbursed    AND default_rate_pct < ba.avg_default_rate  THEN '⭐ Star Performer'
        WHEN disbursed_cr    <  ba.avg_disbursed    AND default_rate_pct < ba.avg_default_rate  THEN '🌱 Growth Potential'
        WHEN disbursed_cr    >= ba.avg_disbursed    AND default_rate_pct >= ba.avg_default_rate THEN '⚠️ Risk Leader'
        ELSE '🔴 Underperformer'
    END AS quadrant_label,
    RANK() OVER (ORDER BY disbursed_cr DESC)     AS volume_rank,
    RANK() OVER (ORDER BY default_rate_pct ASC)  AS quality_rank
FROM branch_metrics bm, bank_averages ba
ORDER BY disbursed_cr DESC;


-- ─────────────────────────────────────────────────────────────
-- QUERY 2: Branch Type Comparison — Rural vs Semi-Urban vs Urban
-- Answers: Is rural banking generating enough revenue vs. its risk?
-- ─────────────────────────────────────────────────────────────
SELECT
    b.branch_type,
    COUNT(DISTINCT b.branch_id)                                          AS branch_count,
    COUNT(DISTINCT la.application_id)                                   AS total_loans,
    ROUND(SUM(la.loan_amount_approved) / 10000000, 2)                   AS total_disbursed_cr,
    ROUND(AVG(la.loan_amount_approved) / 100000, 2)                     AS avg_loan_lakhs,
    ROUND(SUM(CASE WHEN la.status IN ('Approved','Disbursed') THEN 1 ELSE 0 END)
          * 100.0 / NULLIF(COUNT(la.application_id), 0), 2)            AS approval_rate_pct,
    ROUND(SUM(CASE WHEN lp.payment_status = 'Missed' THEN 1 ELSE 0 END)
          * 100.0 / NULLIF(COUNT(lp.payment_id), 0), 2)                AS default_rate_pct,
    ROUND(SUM(lp.interest_paid) / 10000000, 2)                         AS interest_earned_cr,
    ROUND(AVG(ch.credit_score), 1)                                      AS avg_credit_score,
    ROUND(SUM(la.loan_amount_approved) / NULLIF(COUNT(DISTINCT b.branch_id), 0) / 10000000, 2)
                                                                         AS disbursed_per_branch_cr
FROM branches b
JOIN loan_applications la ON b.branch_id = la.branch_id AND la.status = 'Disbursed'
JOIN loan_payments lp     ON la.application_id = lp.application_id
JOIN customers c          ON la.customer_id = c.customer_id
JOIN credit_history ch    ON c.customer_id = ch.customer_id
GROUP BY b.branch_type
ORDER BY total_disbursed_cr DESC;


-- ─────────────────────────────────────────────────────────────
-- QUERY 3: Top 20 Loan Officers Leaderboard
-- Ranks officers on a composite performance score
-- ─────────────────────────────────────────────────────────────
WITH officer_stats AS (
    SELECT
        e.employee_id,
        CONCAT(e.first_name, ' ', e.last_name)                          AS officer_name,
        e.designation,
        b.branch_name,
        r.zone,
        COUNT(la.application_id)                                         AS apps_processed,
        SUM(CASE WHEN la.status IN ('Approved','Disbursed') THEN 1 ELSE 0 END) AS approved_count,
        SUM(CASE WHEN la.status = 'Disbursed' THEN 1 ELSE 0 END)        AS disbursed_count,
        ROUND(SUM(la.loan_amount_approved) / 10000000, 2)               AS disbursed_cr,
        ROUND(SUM(CASE WHEN la.status IN ('Approved','Disbursed') THEN 1 ELSE 0 END)
              * 100.0 / NULLIF(COUNT(la.application_id), 0), 1)        AS approval_rate_pct,
        ROUND(AVG(DATEDIFF(la.disbursement_date, la.application_date)), 1) AS avg_processing_days,
        ROUND(SUM(CASE WHEN lp.payment_status = 'Missed' THEN 1 ELSE 0 END)
              * 100.0 / NULLIF(COUNT(lp.payment_id), 0), 2)            AS portfolio_default_rate
    FROM employees e
    JOIN branches b           ON e.branch_id        = b.branch_id
    JOIN regions r            ON b.region_id         = r.region_id
    JOIN loan_applications la ON e.employee_id       = la.officer_employee_id
    LEFT JOIN loan_payments lp ON la.application_id  = lp.application_id
    WHERE la.status = 'Disbursed'
    GROUP BY e.employee_id, officer_name, e.designation, b.branch_name, r.zone
    HAVING apps_processed >= 20
)
SELECT
    officer_name,
    designation,
    branch_name,
    zone,
    apps_processed,
    approved_count,
    disbursed_count,
    disbursed_cr                                                         AS `Volume (₹ Cr)`,
    approval_rate_pct                                                    AS `Approval Rate (%)`,
    avg_processing_days                                                  AS `Avg Days to Disburse`,
    portfolio_default_rate                                               AS `Portfolio Default Rate (%)`,
    -- Composite score: reward high volume + quality, penalize slow speed + defaults
    ROUND(
        (disbursed_cr * 40)
        + (approval_rate_pct * 0.3)
        - (avg_processing_days * 0.5)
        - (portfolio_default_rate * 2),
    1)                                                                   AS `Performance Score`,
    RANK() OVER (ORDER BY
        (disbursed_cr * 40) + (approval_rate_pct * 0.3)
        - (avg_processing_days * 0.5) - (portfolio_default_rate * 2) DESC
    )                                                                    AS officer_rank
FROM officer_stats
ORDER BY officer_rank
LIMIT 20;


-- ─────────────────────────────────────────────────────────────
-- QUERY 4: Zone-Wise Performance Summary (Executive View)
-- ─────────────────────────────────────────────────────────────
SELECT
    r.zone,
    COUNT(DISTINCT b.branch_id)                                         AS branches,
    COUNT(DISTINCT e.employee_id)                                       AS employees,
    COUNT(DISTINCT c.customer_id)                                       AS customers,
    COUNT(DISTINCT la.application_id)                                   AS total_loans,
    ROUND(SUM(la.loan_amount_approved) / 10000000, 2)                   AS disbursed_cr,
    ROUND(SUM(CASE WHEN la.status IN ('Approved','Disbursed') THEN 1 ELSE 0 END)
          * 100.0 / NULLIF(COUNT(la.application_id), 0), 2)            AS approval_rate_pct,
    ROUND(SUM(CASE WHEN lp.payment_status = 'Missed' THEN 1 ELSE 0 END)
          * 100.0 / NULLIF(COUNT(lp.payment_id), 0), 2)                AS default_rate_pct,
    ROUND(SUM(lp.interest_paid) / 10000000, 2)                         AS interest_earned_cr,
    ROUND(SUM(la.loan_amount_approved)
          / NULLIF(COUNT(DISTINCT b.branch_id), 0) / 10000000, 2)      AS disbursed_per_branch_cr,
    ROUND(SUM(la.loan_amount_approved)
          / NULLIF(COUNT(DISTINCT e.employee_id), 0) / 100000, 2)      AS disbursed_per_staff_lakhs
FROM regions r
JOIN branches b           ON r.region_id  = b.region_id
LEFT JOIN employees e     ON b.branch_id  = e.branch_id
LEFT JOIN customers c     ON b.branch_id  = c.branch_id
LEFT JOIN loan_applications la ON b.branch_id = la.branch_id AND la.status = 'Disbursed'
LEFT JOIN loan_payments lp     ON la.application_id = lp.application_id
GROUP BY r.zone
ORDER BY disbursed_cr DESC;
