-- ============================================================
-- 📊 05 — Digital Transformation & UPI Adoption Analysis
-- IndoSynth Gramin Bank | Business Analyst SQL Suite
-- ============================================================
-- Business Question:
--   Which customer segments adopted UPI the fastest?
--   What is the YoY growth of digital channels?
--   Is digital adoption correlated with better loan repayment?
-- ============================================================

USE indosynth_bank;

-- ─────────────────────────────────────────────────────────────
-- QUERY 1: UPI Adoption Cohort by Year & Customer Segment
-- Shows the shift from cash/traditional to digital per group
-- ─────────────────────────────────────────────────────────────
SELECT
    YEAR(t.transaction_date)                                            AS txn_year,
    c.customer_segment,
    t.transaction_mode,
    COUNT(t.transaction_id)                                             AS txn_count,
    ROUND(SUM(t.amount) / 10000000, 2)                                 AS volume_cr,
    ROUND(COUNT(t.transaction_id) * 100.0 /
        SUM(COUNT(t.transaction_id)) OVER (
            PARTITION BY YEAR(t.transaction_date), c.customer_segment
        ), 2)                                                           AS `Mode Share (%)`,
    -- YoY change in share using LAG
    ROUND(
        COUNT(t.transaction_id) * 100.0 /
        SUM(COUNT(t.transaction_id)) OVER (
            PARTITION BY YEAR(t.transaction_date), c.customer_segment
        )
        - LAG(COUNT(t.transaction_id) * 100.0 /
              SUM(COUNT(t.transaction_id)) OVER (
                  PARTITION BY YEAR(t.transaction_date), c.customer_segment
              ))
          OVER (PARTITION BY c.customer_segment, t.transaction_mode
                ORDER BY YEAR(t.transaction_date)),
    2)                                                                  AS `YoY Share Change (pp)`
FROM transactions t
JOIN customers c ON t.customer_id = c.customer_id
GROUP BY txn_year, c.customer_segment, t.transaction_mode
ORDER BY txn_year, c.customer_segment, `Mode Share (%)` DESC;


-- ─────────────────────────────────────────────────────────────
-- QUERY 2: Digital vs Traditional Channel Performance Comparison
-- ─────────────────────────────────────────────────────────────
WITH channel_groups AS (
    SELECT
        CASE
            WHEN transaction_mode IN ('UPI', 'IMPS', 'NEFT', 'RTGS') THEN 'Digital'
            WHEN transaction_mode IN ('ATM/Cash', 'Branch/Cash')      THEN 'Traditional'
            ELSE 'Card/POS'
        END AS channel_type,
        transaction_mode,
        transaction_type,
        amount,
        status,
        customer_id,
        YEAR(transaction_date) AS txn_year
    FROM transactions
)
SELECT
    txn_year,
    channel_type,
    COUNT(*)                                                            AS txn_count,
    COUNT(DISTINCT customer_id)                                         AS unique_customers,
    ROUND(SUM(amount) / 10000000, 2)                                   AS total_volume_cr,
    ROUND(AVG(amount), 0)                                              AS avg_txn_value,
    ROUND(SUM(CASE WHEN status = 'Success' THEN 1 ELSE 0 END)
          * 100.0 / COUNT(*), 2)                                       AS success_rate_pct,
    ROUND(COUNT(*) * 100.0 /
        SUM(COUNT(*)) OVER (PARTITION BY txn_year), 2)                AS `Year Share (%)`,
    ROUND(SUM(amount) * 100.0 /
        SUM(SUM(amount)) OVER (PARTITION BY txn_year), 2)             AS `Volume Share (%)`
FROM channel_groups
GROUP BY txn_year, channel_type
ORDER BY txn_year, channel_type;


-- ─────────────────────────────────────────────────────────────
-- QUERY 3: Does Digital Banking Correlate with Better Repayment?
-- Tests hypothesis: Customers using UPI have lower default rates
-- ─────────────────────────────────────────────────────────────
WITH customer_digital_usage AS (
    SELECT
        customer_id,
        COUNT(*)                                                         AS total_txns,
        SUM(CASE WHEN transaction_mode = 'UPI' THEN 1 ELSE 0 END)      AS upi_txns,
        ROUND(SUM(CASE WHEN transaction_mode = 'UPI' THEN 1 ELSE 0 END)
              * 100.0 / NULLIF(COUNT(*), 0), 1)                        AS upi_share_pct
    FROM transactions
    GROUP BY customer_id
),
customer_repayment AS (
    SELECT
        lp.customer_id,
        COUNT(lp.payment_id)                                            AS total_emis,
        SUM(CASE WHEN lp.payment_status = 'Missed' THEN 1 ELSE 0 END) AS missed_emis,
        ROUND(SUM(CASE WHEN lp.payment_status = 'Missed' THEN 1 ELSE 0 END)
              * 100.0 / NULLIF(COUNT(lp.payment_id), 0), 2)           AS default_rate_pct
    FROM loan_payments lp
    GROUP BY lp.customer_id
)
SELECT
    CASE
        WHEN du.upi_share_pct >= 80  THEN 'Heavy UPI (≥80%)'
        WHEN du.upi_share_pct >= 50  THEN 'Moderate UPI (50–79%)'
        WHEN du.upi_share_pct >= 20  THEN 'Light UPI (20–49%)'
        WHEN du.upi_share_pct > 0    THEN 'Minimal UPI (<20%)'
        ELSE 'No UPI'
    END AS upi_usage_tier,
    COUNT(DISTINCT du.customer_id)                                      AS customer_count,
    ROUND(AVG(du.upi_share_pct), 1)                                   AS avg_upi_share_pct,
    ROUND(AVG(cr.total_emis), 0)                                       AS avg_total_emis,
    ROUND(AVG(cr.default_rate_pct), 2)                                 AS `Avg Default Rate (%)`,
    ROUND(AVG(ch.credit_score), 1)                                     AS avg_credit_score,
    -- Business insight: lower default rate for digital adopters?
    CASE
        WHEN AVG(cr.default_rate_pct) < 3 THEN '🟢 Excellent Repayment'
        WHEN AVG(cr.default_rate_pct) < 6 THEN '🟡 Average Repayment'
        ELSE '🔴 Poor Repayment'
    END AS repayment_quality
FROM customer_digital_usage du
JOIN customer_repayment cr ON du.customer_id = cr.customer_id
JOIN credit_history ch     ON du.customer_id = ch.customer_id
GROUP BY upi_usage_tier
ORDER BY AVG(du.upi_share_pct) DESC;


-- ─────────────────────────────────────────────────────────────
-- QUERY 4: Monthly Transaction Volume Heatmap (Channel x Month)
-- Identifies seasonal peaks for digital banking
-- ─────────────────────────────────────────────────────────────
SELECT
    transaction_mode,
    SUM(CASE WHEN MONTH(transaction_date) = 1  THEN amount ELSE 0 END) / 10000000 AS Jan_Cr,
    SUM(CASE WHEN MONTH(transaction_date) = 2  THEN amount ELSE 0 END) / 10000000 AS Feb_Cr,
    SUM(CASE WHEN MONTH(transaction_date) = 3  THEN amount ELSE 0 END) / 10000000 AS Mar_Cr,
    SUM(CASE WHEN MONTH(transaction_date) = 4  THEN amount ELSE 0 END) / 10000000 AS Apr_Cr,
    SUM(CASE WHEN MONTH(transaction_date) = 5  THEN amount ELSE 0 END) / 10000000 AS May_Cr,
    SUM(CASE WHEN MONTH(transaction_date) = 6  THEN amount ELSE 0 END) / 10000000 AS Jun_Cr,
    SUM(CASE WHEN MONTH(transaction_date) = 7  THEN amount ELSE 0 END) / 10000000 AS Jul_Cr,
    SUM(CASE WHEN MONTH(transaction_date) = 8  THEN amount ELSE 0 END) / 10000000 AS Aug_Cr,
    SUM(CASE WHEN MONTH(transaction_date) = 9  THEN amount ELSE 0 END) / 10000000 AS Sep_Cr,
    SUM(CASE WHEN MONTH(transaction_date) = 10 THEN amount ELSE 0 END) / 10000000 AS Oct_Cr,
    SUM(CASE WHEN MONTH(transaction_date) = 11 THEN amount ELSE 0 END) / 10000000 AS Nov_Cr,
    SUM(CASE WHEN MONTH(transaction_date) = 12 THEN amount ELSE 0 END) / 10000000 AS Dec_Cr,
    ROUND(SUM(amount) / 10000000, 2)                                              AS Total_Cr
FROM transactions
GROUP BY transaction_mode
ORDER BY Total_Cr DESC;


-- ─────────────────────────────────────────────────────────────
-- QUERY 5: Top Spending Categories by Customer Segment
-- Supports product cross-sell strategy decisions
-- ─────────────────────────────────────────────────────────────
SELECT
    c.customer_segment,
    t.category,
    COUNT(t.transaction_id)                                             AS txn_count,
    ROUND(SUM(t.amount) / 10000000, 2)                                 AS volume_cr,
    ROUND(AVG(t.amount), 0)                                            AS avg_txn_value,
    ROUND(COUNT(t.transaction_id) * 100.0 /
        SUM(COUNT(t.transaction_id)) OVER (PARTITION BY c.customer_segment), 2)
                                                                        AS `Category Share (%)`,
    RANK() OVER (PARTITION BY c.customer_segment ORDER BY SUM(t.amount) DESC) AS category_rank
FROM transactions t
JOIN customers c ON t.customer_id = c.customer_id
WHERE t.transaction_type = 'Debit'
  AND t.category IS NOT NULL
GROUP BY c.customer_segment, t.category
ORDER BY c.customer_segment, category_rank;
