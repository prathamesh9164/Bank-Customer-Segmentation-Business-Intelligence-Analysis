-- ============================================================
-- 📊 02 — Loan Application Funnel & Conversion Analysis
-- IndoSynth Gramin Bank | Business Analyst SQL Suite
-- ============================================================
-- Business Question:
--   Where is the biggest drop-off in the application-to-disbursement
--   funnel? What is the average time-to-decision per branch/officer?
--   Which rejection reasons are most addressable?
-- ============================================================

USE indosynth_bank;

-- ─────────────────────────────────────────────────────────────
-- QUERY 1: Application Funnel Conversion Rates (Bank-Wide)
-- Shows volume & drop-off at each stage of the loan pipeline
-- ─────────────────────────────────────────────────────────────
WITH funnel_stages AS (
    SELECT
        COUNT(*)                                                        AS total_applications,
        SUM(CASE WHEN status IN ('Under Review','Approved','Disbursed') THEN 1 ELSE 0 END) AS reached_review,
        SUM(CASE WHEN status IN ('Approved','Disbursed')               THEN 1 ELSE 0 END) AS approved,
        SUM(CASE WHEN status = 'Disbursed'                             THEN 1 ELSE 0 END) AS disbursed,
        SUM(CASE WHEN status = 'Rejected'                              THEN 1 ELSE 0 END) AS rejected,
        SUM(CASE WHEN status = 'Pending'                               THEN 1 ELSE 0 END) AS pending
    FROM loan_applications
)
SELECT
    total_applications                                          AS `Total Applications`,
    reached_review                                             AS `Reached Review`,
    approved                                                   AS `Approved`,
    disbursed                                                  AS `Disbursed`,
    rejected                                                   AS `Rejected`,
    pending                                                    AS `Still Pending`,
    ROUND(reached_review * 100.0 / total_applications, 1)     AS `Review Rate (%)`,
    ROUND(approved       * 100.0 / total_applications, 1)     AS `Approval Rate (%)`,
    ROUND(disbursed      * 100.0 / total_applications, 1)     AS `Disbursement Rate (%)`,
    ROUND(rejected       * 100.0 / total_applications, 1)     AS `Rejection Rate (%)`,
    -- Stage-to-stage conversion losses
    ROUND((total_applications - reached_review) * 100.0 / total_applications, 1) AS `Drop at Pending (%)`,
    ROUND((reached_review - approved)           * 100.0 / total_applications, 1) AS `Drop at Review (%)`,
    ROUND((approved - disbursed)                * 100.0 / total_applications, 1) AS `Drop at Approval (%)`
FROM funnel_stages;


-- ─────────────────────────────────────────────────────────────
-- QUERY 2: Average Time-to-Decision by Branch & Officer
-- Uses DATEDIFF to measure processing efficiency
-- ─────────────────────────────────────────────────────────────
SELECT
    b.branch_name,
    b.branch_type,
    r.zone,
    CONCAT(e.first_name, ' ', e.last_name)          AS loan_officer,
    e.designation,
    COUNT(la.application_id)                         AS apps_handled,
    ROUND(AVG(DATEDIFF(la.disbursement_date, la.application_date)), 1) AS avg_days_to_disburse,
    MIN(DATEDIFF(la.disbursement_date, la.application_date))           AS fastest_days,
    MAX(DATEDIFF(la.disbursement_date, la.application_date))           AS slowest_days,
    ROUND(SUM(CASE WHEN la.status IN ('Approved','Disbursed') THEN 1 ELSE 0 END) * 100.0
          / NULLIF(COUNT(la.application_id), 0), 1)                    AS approval_rate_pct,
    ROUND(SUM(la.loan_amount_approved) / 10000000, 2)                  AS disbursed_cr,
    RANK() OVER (ORDER BY AVG(DATEDIFF(la.disbursement_date, la.application_date))) AS speed_rank
FROM loan_applications la
JOIN branches b  ON la.branch_id = b.branch_id
JOIN regions r   ON b.region_id  = r.region_id
JOIN employees e ON la.officer_employee_id = e.employee_id
WHERE la.status = 'Disbursed'
  AND la.disbursement_date IS NOT NULL
GROUP BY b.branch_name, b.branch_type, r.zone, loan_officer, e.designation
HAVING apps_handled >= 10
ORDER BY avg_days_to_disburse
LIMIT 20;


-- ─────────────────────────────────────────────────────────────
-- QUERY 3: Rejection Reason Pareto Analysis
-- (80/20 rule: which reasons account for 80% of rejections?)
-- ─────────────────────────────────────────────────────────────
WITH rejection_counts AS (
    SELECT
        COALESCE(rejection_reason, 'Not Specified') AS rejection_reason,
        COUNT(*)                                     AS rejected_count,
        ROUND(AVG(ch.credit_score), 1)               AS avg_credit_score_rejected,
        ROUND(AVG(la.loan_amount_requested) / 100000, 2) AS avg_requested_lakhs
    FROM loan_applications la
    LEFT JOIN credit_history ch ON la.customer_id = ch.customer_id
    WHERE la.status = 'Rejected'
    GROUP BY rejection_reason
),
totals AS (SELECT SUM(rejected_count) AS grand_total FROM rejection_counts)
SELECT
    rc.rejection_reason,
    rc.rejected_count,
    rc.avg_credit_score_rejected,
    rc.avg_requested_lakhs,
    ROUND(rc.rejected_count * 100.0 / t.grand_total, 2)  AS `Share (%)`,
    ROUND(SUM(rc.rejected_count) OVER (
        ORDER BY rc.rejected_count DESC
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) * 100.0 / t.grand_total, 2)                        AS `Cumulative (%)`,
    CASE
        WHEN SUM(rc.rejected_count) OVER (
            ORDER BY rc.rejected_count DESC
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) * 100.0 / t.grand_total <= 80
        THEN '🔴 Vital Few (Top 80%)'
        ELSE '🟡 Useful Many'
    END AS pareto_class
FROM rejection_counts rc, totals t
ORDER BY rc.rejected_count DESC;


-- ─────────────────────────────────────────────────────────────
-- QUERY 4: Monthly Funnel Trend (Year-over-Year comparison)
-- Tracks if approval rates are improving over time
-- ─────────────────────────────────────────────────────────────
SELECT
    YEAR(application_date)                                     AS yr,
    MONTH(application_date)                                    AS mo,
    DATE_FORMAT(application_date, '%Y-%m')                    AS year_month,
    COUNT(*)                                                   AS total_apps,
    SUM(CASE WHEN status IN ('Approved','Disbursed') THEN 1 ELSE 0 END) AS approved,
    SUM(CASE WHEN status = 'Disbursed'              THEN 1 ELSE 0 END) AS disbursed,
    SUM(CASE WHEN status = 'Rejected'               THEN 1 ELSE 0 END) AS rejected,
    ROUND(SUM(CASE WHEN status IN ('Approved','Disbursed') THEN 1 ELSE 0 END)
          * 100.0 / COUNT(*), 1)                               AS approval_rate_pct,
    ROUND(SUM(CASE WHEN status = 'Disbursed' THEN la.loan_amount_approved ELSE 0 END)
          / 10000000, 2)                                       AS disbursed_cr,
    -- Month-over-month change in approval rate using LAG
    ROUND(
        SUM(CASE WHEN status IN ('Approved','Disbursed') THEN 1 ELSE 0 END) * 100.0 / COUNT(*) -
        LAG(SUM(CASE WHEN status IN ('Approved','Disbursed') THEN 1 ELSE 0 END) * 100.0 / COUNT(*))
            OVER (ORDER BY YEAR(application_date), MONTH(application_date)),
        2
    ) AS approval_rate_mom_change
FROM loan_applications la
GROUP BY yr, mo, year_month
ORDER BY yr, mo;
