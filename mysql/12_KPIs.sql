-- ============================================================
-- 🏦 IndoSynth Gramin Bank — 12: KPIs (Key Performance Indicators)
-- ============================================================
-- Calculates the standard banking KPIs used in executive dashboards,
-- regulatory filings (RBI), and board-level reporting.
-- Covers portfolio quality, profitability, growth, and efficiency KPIs.
-- Run after 01_Database_Setup.sql
-- ============================================================

USE indosynth_bank;


-- ============================================================
-- KPI CATEGORY 1: PORTFOLIO QUALITY KPIs
-- ============================================================

-- KPI-01: Non-Performing Asset (NPA) Rate
-- DEFINITION: % of active loans with 3+ missed payments (RBI NPA proxy).
-- TARGET:     Below 5% (industry benchmark for healthy banks).
-- WHY:        NPA rate is the single most-watched metric by RBI regulators.
--             A rising NPA signals deteriorating loan book quality.
SELECT
    COUNT(DISTINCT la.application_id) AS total_active_loans,
    COUNT(DISTINCT npa.application_id) AS npa_loans,
    ROUND(COUNT(DISTINCT npa.application_id) * 100.0 /
          NULLIF(COUNT(DISTINCT la.application_id), 0), 2) AS npa_rate_pct
FROM loan_applications la
LEFT JOIN (
    SELECT application_id
    FROM loan_payments
    GROUP BY application_id
    HAVING COUNT(CASE WHEN payment_status = 'Missed' THEN 1 END) >= 3
) npa ON la.application_id = npa.application_id
WHERE la.status IN ('Disbursed', 'Closed');


-- KPI-02: Loan Default Rate (Missed Payment %)
-- DEFINITION: % of total EMI payments that were missed.
-- TARGET:     Below 8% for retail lending portfolios.
-- WHY:        Unlike the NPA rate (loan-level), this measures payment-level
--             discipline and is an earlier leading indicator of credit stress.
SELECT
    COUNT(*)                                                   AS total_emi_payments,
    SUM(CASE WHEN payment_status = 'Missed' THEN 1 ELSE 0 END) AS missed_payments,
    SUM(CASE WHEN payment_status = 'Late'   THEN 1 ELSE 0 END) AS late_payments,
    ROUND(SUM(CASE WHEN payment_status = 'Missed' THEN 1 ELSE 0 END)
          * 100.0 / COUNT(*), 2)                               AS default_rate_pct,
    ROUND(SUM(CASE WHEN payment_status = 'Late'   THEN 1 ELSE 0 END)
          * 100.0 / COUNT(*), 2)                               AS late_rate_pct
FROM loan_payments;


-- KPI-03: Loan Approval Rate
-- DEFINITION: % of applications that were Approved, Disbursed, or Closed.
-- TARGET:     Depends on risk appetite; typically 55–75% for gramin banks.
-- WHY:        Very low rates indicate over-strict criteria or poor targeting;
--             very high rates may signal lax underwriting.
SELECT
    COUNT(*)                                                      AS total_applications,
    SUM(CASE WHEN status IN ('Approved','Disbursed','Closed')
             THEN 1 ELSE 0 END)                                   AS approved_count,
    SUM(CASE WHEN status = 'Rejected' THEN 1 ELSE 0 END)          AS rejected_count,
    ROUND(SUM(CASE WHEN status IN ('Approved','Disbursed','Closed')
                   THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2)      AS approval_rate_pct,
    ROUND(SUM(CASE WHEN status = 'Rejected' THEN 1 ELSE 0 END)
          * 100.0 / COUNT(*), 2)                                  AS rejection_rate_pct
FROM loan_applications;


-- KPI-04: Portfolio at Risk (PAR 30) — Outstanding balance of loans 30+ days late
-- DEFINITION: Total outstanding balance of loans with any payment 30+ days overdue
--             as a % of total disbursed portfolio.
-- TARGET:     PAR30 < 10% for healthy microfinance/gramin institutions.
-- WHY:        PAR30 is the international standard metric for loan portfolio health,
--             used by MFI regulators and the World Bank for benchmarking.
SELECT
    ROUND(SUM(CASE WHEN lp.days_late >= 30 THEN lp.outstanding_balance ELSE 0 END)
          / 10000000, 2) AS par30_balance_cr,
    ROUND(SUM(lp.outstanding_balance) / 10000000, 2) AS total_outstanding_cr,
    ROUND(
        SUM(CASE WHEN lp.days_late >= 30 THEN lp.outstanding_balance ELSE 0 END) * 100.0 /
        NULLIF(SUM(lp.outstanding_balance), 0), 2
    ) AS par30_rate_pct
FROM loan_payments lp
JOIN loan_applications la ON lp.application_id = la.application_id
WHERE la.status = 'Disbursed';


-- ============================================================
-- KPI CATEGORY 2: GROWTH KPIs
-- ============================================================

-- KPI-05: Year-over-Year (YoY) Loan Disbursement Growth
-- DEFINITION: % change in total disbursed amount vs. previous year.
-- TARGET:     10–20% annual growth for an expanding gramin bank.
-- WHY:        Growth KPIs are the primary metric for board strategy reviews
--             and investor presentations. LAG() provides the YoY comparison.
SELECT yr,
       total_disbursed_cr,
       LAG(total_disbursed_cr) OVER (ORDER BY yr) AS prev_year_cr,
       ROUND(
           (total_disbursed_cr - LAG(total_disbursed_cr) OVER (ORDER BY yr))
           * 100.0 / NULLIF(LAG(total_disbursed_cr) OVER (ORDER BY yr), 0), 2
       ) AS yoy_growth_pct
FROM (
    SELECT YEAR(disbursement_date) AS yr,
           ROUND(SUM(loan_amount_approved) / 10000000, 2) AS total_disbursed_cr
    FROM loan_applications
    WHERE status = 'Disbursed' AND disbursement_date IS NOT NULL
    GROUP BY yr
) yearly
ORDER BY yr;


-- KPI-06: Customer Acquisition Rate (new customers per year)
-- DEFINITION: Number of new accounts opened each year.
-- TARGET:     Positive year-on-year growth in account openings.
-- WHY:        Customer acquisition is the top-of-funnel growth metric.
--             Declining new accounts signal loss of market competitiveness.
SELECT
    YEAR(account_open_date) AS year,
    COUNT(*)                AS new_customers,
    LAG(COUNT(*)) OVER (ORDER BY YEAR(account_open_date)) AS prev_year_customers,
    ROUND(
        (COUNT(*) - LAG(COUNT(*)) OVER (ORDER BY YEAR(account_open_date)))
        * 100.0 / NULLIF(LAG(COUNT(*)) OVER (ORDER BY YEAR(account_open_date)), 0), 2
    ) AS yoy_growth_pct
FROM customers
WHERE account_open_date IS NOT NULL
GROUP BY YEAR(account_open_date)
ORDER BY year;


-- KPI-07: Loan Application Growth (MoM trend)
-- DEFINITION: Month-over-month change in loan application count.
-- WHY:        MoM application trends reveal short-term momentum and can
--             flag sudden drops (seasonal dips, system outages, or competition).
-- Note: Original Q8 extended with MoM growth calculation.
SELECT month,
       applications,
       LAG(applications) OVER (ORDER BY month) AS prev_month,
       ROUND(
           (applications - LAG(applications) OVER (ORDER BY month))
           * 100.0 / NULLIF(LAG(applications) OVER (ORDER BY month), 0), 2
       ) AS mom_growth_pct
FROM (
    SELECT DATE_FORMAT(application_date, '%Y-%m') AS month,
           COUNT(*) AS applications
    FROM loan_applications
    GROUP BY month
) monthly
ORDER BY month;


-- ============================================================
-- KPI CATEGORY 3: PROFITABILITY KPIs
-- ============================================================

-- KPI-08: Total Interest Income
-- DEFINITION: Total interest collected from all loan payments (Paid + Late).
-- WHY:        Interest income is the primary revenue line for a bank.
--             It is compared against cost of funds to determine net interest margin.
SELECT
    ROUND(SUM(CASE WHEN payment_status IN ('Paid','Late') THEN interest_paid ELSE 0 END)
          / 10000000, 2) AS total_interest_income_cr,
    ROUND(SUM(CASE WHEN payment_status IN ('Paid','Late') THEN penalty_amount ELSE 0 END)
          / 10000000, 2) AS total_penalty_income_cr,
    ROUND(SUM(CASE WHEN payment_status IN ('Paid','Late')
                   THEN interest_paid + penalty_amount ELSE 0 END)
          / 10000000, 2) AS total_revenue_cr
FROM loan_payments;


-- KPI-09: Net Interest Margin (NIM) proxy
-- DEFINITION: (Total Interest Income / Total Disbursed Portfolio) × 100
-- TARGET:     3–5% NIM is healthy for Indian rural banks.
-- WHY:        NIM measures how efficiently the bank earns from its loan book.
--             A declining NIM with rising NPAs is a danger signal.
SELECT
    ROUND(SUM(lp.interest_paid) / 10000000, 2)         AS interest_income_cr,
    ROUND(SUM(la.loan_amount_approved) / 10000000, 2)   AS total_portfolio_cr,
    ROUND(SUM(lp.interest_paid) * 100.0 /
          NULLIF(SUM(la.loan_amount_approved), 0), 2)    AS nim_proxy_pct
FROM loan_payments lp
JOIN loan_applications la ON lp.application_id = la.application_id
WHERE lp.payment_status IN ('Paid', 'Late')
  AND la.status IN ('Disbursed', 'Closed');


-- KPI-10: Revenue per branch (Top 10 branches)
-- DEFINITION: Total interest + penalty income generated per branch.
-- WHY:        Branch-level profitability determines which branches justify
--             their operating costs and which need performance improvement.
SELECT b.branch_name, b.city, b.state, b.zone,
       ROUND(SUM(lp.interest_paid), 0)   AS interest_income,
       ROUND(SUM(lp.penalty_amount), 0)  AS penalty_income,
       ROUND(SUM(lp.interest_paid + lp.penalty_amount), 0) AS total_revenue
FROM loan_payments lp
JOIN loan_applications la ON lp.application_id = la.application_id
JOIN branches b            ON la.branch_id = b.branch_id
WHERE lp.payment_status IN ('Paid', 'Late')
GROUP BY b.branch_id, b.branch_name, b.city, b.state, b.zone
ORDER BY total_revenue DESC
LIMIT 10;


-- ============================================================
-- KPI CATEGORY 4: EFFICIENCY & OPERATIONAL KPIs
-- ============================================================

-- KPI-11: Average Loan Processing Time (Application → Disbursement)
-- DEFINITION: Average number of days from application_date to disbursement_date.
-- TARGET:     < 15 working days for retail loans (RBI guideline).
-- WHY:        Slow processing times lead to customer dissatisfaction and
--             abandonment. This KPI drives operational efficiency initiatives.
SELECT
    loan_type_name,
    COUNT(*) AS disbursed_loans,
    ROUND(AVG(DATEDIFF(disbursement_date, application_date)), 1) AS avg_processing_days,
    MIN(DATEDIFF(disbursement_date, application_date))            AS min_days,
    MAX(DATEDIFF(disbursement_date, application_date))            AS max_days
FROM loan_applications
WHERE status = 'Disbursed'
  AND disbursement_date IS NOT NULL
  AND application_date IS NOT NULL
GROUP BY loan_type_name
ORDER BY avg_processing_days DESC;


-- KPI-12: Employee Productivity (Loans processed per officer)
-- DEFINITION: Total applications and disbursed loans per loan officer.
-- TARGET:     Each officer should handle 20+ applications/month for efficiency.
-- WHY:        Under-utilised officers are a cost centre; over-utilised ones
--             face burnout and quality issues. This drives optimal staffing.
SELECT e.full_name, e.designation, b.branch_name,
       COUNT(la.application_id)                                        AS total_processed,
       SUM(CASE WHEN la.status = 'Disbursed' THEN 1 ELSE 0 END)        AS disbursed,
       ROUND(SUM(CASE WHEN la.status='Disbursed'
                      THEN la.loan_amount_approved ELSE 0 END) / 100000, 2) AS disbursed_lakhs,
       ROUND(COUNT(la.application_id) /
             NULLIF(TIMESTAMPDIFF(MONTH, e.joining_date, CURDATE()), 0), 1) AS apps_per_month
FROM loan_applications la
JOIN employees e ON la.officer_employee_id = e.employee_id
JOIN branches  b ON la.branch_id = b.branch_id
GROUP BY e.employee_id, e.full_name, e.designation, b.branch_name, e.joining_date
HAVING total_processed >= 5
ORDER BY disbursed_lakhs DESC
LIMIT 15;


-- KPI-13: KYC Compliance Rate
-- DEFINITION: % of active customers with KYC status = 'Verified'.
-- TARGET:     95%+ (RBI mandates full KYC compliance for lending customers).
-- WHY:        Non-KYC customers cannot receive loans. A low compliance rate
--             limits the bank's lending capacity and poses regulatory risk.
SELECT
    COUNT(*) AS total_active_customers,
    SUM(CASE WHEN kyc_status = 'Verified' THEN 1 ELSE 0 END) AS kyc_verified,
    SUM(CASE WHEN kyc_status = 'Pending'  THEN 1 ELSE 0 END) AS kyc_pending,
    SUM(CASE WHEN kyc_status = 'Rejected' THEN 1 ELSE 0 END) AS kyc_rejected,
    ROUND(SUM(CASE WHEN kyc_status = 'Verified' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS kyc_compliance_rate_pct
FROM customers
WHERE is_active = TRUE;


-- KPI-14: Transaction Success Rate
-- DEFINITION: % of all transactions that completed successfully.
-- TARGET:     > 99% for digital banking channels (industry standard).
-- WHY:        Failed transactions damage customer trust and may indicate
--             technical issues in the payments infrastructure.
SELECT
    COUNT(*) AS total_transactions,
    SUM(CASE WHEN status = 'Success' THEN 1 ELSE 0 END) AS successful,
    SUM(CASE WHEN status = 'Failed'  THEN 1 ELSE 0 END) AS failed,
    ROUND(SUM(CASE WHEN status = 'Success' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS success_rate_pct
FROM transactions;


-- ============================================================
-- KPI SUMMARY DASHBOARD (All KPIs in One View)
-- ============================================================

-- KPI-15: Executive KPI Summary — single-row scorecard
-- WHAT: Consolidates the most critical KPIs into a single summary row
--       for quick executive review.
-- WHY:  C-suite dashboards need a single-glance view of bank health.
--       This query powers the top-level scorecard tile.
SELECT
    -- Portfolio
    (SELECT COUNT(DISTINCT customer_id) FROM customers WHERE is_active = TRUE) AS active_customers,

    (SELECT COUNT(*) FROM loan_applications WHERE status = 'Disbursed') AS active_loans,

    ROUND((SELECT SUM(loan_amount_approved) FROM loan_applications WHERE status = 'Disbursed')
          / 10000000, 2) AS active_portfolio_cr,

    -- Quality
    ROUND((SELECT COUNT(DISTINCT application_id) FROM (
        SELECT application_id FROM loan_payments
        GROUP BY application_id
        HAVING COUNT(CASE WHEN payment_status='Missed' THEN 1 END) >= 3
    ) npa) * 100.0 /
    NULLIF((SELECT COUNT(*) FROM loan_applications WHERE status IN ('Disbursed','Closed')), 0), 2)
    AS npa_rate_pct,

    -- Profitability
    ROUND((SELECT SUM(interest_paid) FROM loan_payments WHERE payment_status IN ('Paid','Late'))
          / 10000000, 2) AS interest_income_cr,

    -- Efficiency
    (SELECT ROUND(AVG(DATEDIFF(disbursement_date, application_date)),1)
     FROM loan_applications WHERE status='Disbursed' AND disbursement_date IS NOT NULL)
    AS avg_processing_days,

    -- Compliance
    ROUND((SELECT SUM(CASE WHEN kyc_status='Verified' THEN 1 ELSE 0 END) FROM customers WHERE is_active=TRUE)
          * 100.0 / NULLIF((SELECT COUNT(*) FROM customers WHERE is_active=TRUE), 0), 2)
    AS kyc_compliance_pct,

    -- Transactions
    ROUND((SELECT SUM(CASE WHEN status='Success' THEN 1 ELSE 0 END) FROM transactions)
          * 100.0 / NULLIF((SELECT COUNT(*) FROM transactions), 0), 2)
    AS txn_success_rate_pct;


-- ============================================================
-- END OF KPIs
-- ============================================================
