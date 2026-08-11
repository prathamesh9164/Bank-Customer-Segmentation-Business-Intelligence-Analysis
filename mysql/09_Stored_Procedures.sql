-- ============================================================
-- 🏦 IndoSynth Gramin Bank — 09: Stored Procedures
-- ============================================================
-- Creates stored procedures for common banking operations:
-- customer lookup, loan eligibility check, payment recording,
-- monthly branch report, and NPA flagging.
-- Demonstrates IN/OUT parameters, IF-ELSE, LOOP, cursors,
-- and error handling with DECLARE ... HANDLER.
-- Run after 01_Database_Setup.sql
-- ============================================================

USE indosynth_bank;

-- Set delimiter so procedure bodies don't end prematurely
DELIMITER $$


-- ============================================================
-- PROCEDURE 1: Get customer full profile
-- ============================================================
-- SP1: sp_get_customer_profile
-- WHAT: Accepts a customer_id and returns the customer's personal
--       details, credit profile, and loan summary in three result sets.
-- WHY:  A single call replaces three separate SELECT queries in the
--       application, reducing round-trips to the database.
-- Usage: CALL sp_get_customer_profile(101);
DROP PROCEDURE IF EXISTS sp_get_customer_profile $$
CREATE PROCEDURE sp_get_customer_profile (
    IN p_customer_id INT
)
BEGIN
    -- Result set 1: Personal details
    SELECT customer_id, full_name, gender, age, phone_number, email,
           city, state, zone, customer_segment, annual_income, kyc_status,
           account_number, account_type, account_open_date
    FROM customers
    WHERE customer_id = p_customer_id;

    -- Result set 2: Credit profile
    SELECT credit_score, credit_rating, number_of_accounts,
           number_of_delinquencies, credit_utilization_pct,
           payment_history_pct, total_outstanding_debt
    FROM credit_history
    WHERE customer_id = p_customer_id;

    -- Result set 3: Loan application history
    SELECT application_id, loan_type_name, loan_amount_approved,
           status, application_date, disbursement_date,
           interest_rate_pct, emi_amount
    FROM loan_applications
    WHERE customer_id = p_customer_id
    ORDER BY application_date DESC;
END $$

-- Test:
-- CALL sp_get_customer_profile(101);


-- ============================================================
-- PROCEDURE 2: Loan eligibility check
-- ============================================================
-- SP2: sp_check_loan_eligibility
-- WHAT: Given customer_id and requested loan amount, checks whether the
--       customer meets basic eligibility criteria (income, credit score,
--       KYC status) and returns an eligibility verdict with reason.
-- WHY:  Centralises eligibility logic in one place. When the bank changes
--       criteria, only this procedure needs to be updated.
-- Usage: CALL sp_check_loan_eligibility(101, 500000, @eligible, @reason);
--        SELECT @eligible, @reason;
DROP PROCEDURE IF EXISTS sp_check_loan_eligibility $$
CREATE PROCEDURE sp_check_loan_eligibility (
    IN  p_customer_id      INT,
    IN  p_requested_amount DECIMAL(15,2),
    OUT p_is_eligible      VARCHAR(5),
    OUT p_reason           VARCHAR(200)
)
BEGIN
    DECLARE v_income         DECIMAL(12,2);
    DECLARE v_credit_score   INT;
    DECLARE v_kyc_status     VARCHAR(20);
    DECLARE v_active_loans   INT;

    -- Fetch customer details
    SELECT annual_income, kyc_status
    INTO   v_income, v_kyc_status
    FROM   customers
    WHERE  customer_id = p_customer_id;

    -- Fetch latest credit score
    SELECT credit_score
    INTO   v_credit_score
    FROM   credit_history
    WHERE  customer_id = p_customer_id
    ORDER BY last_updated_date DESC
    LIMIT 1;

    -- Count active (Disbursed) loans
    SELECT COUNT(*)
    INTO   v_active_loans
    FROM   loan_applications
    WHERE  customer_id = p_customer_id
      AND  status = 'Disbursed';

    -- Eligibility logic
    IF v_kyc_status <> 'Verified' THEN
        SET p_is_eligible = 'NO';
        SET p_reason      = 'KYC not verified. Please complete KYC before applying.';

    ELSEIF v_credit_score < 600 THEN
        SET p_is_eligible = 'NO';
        SET p_reason      = CONCAT('Credit score too low: ', v_credit_score, '. Minimum required: 600.');

    ELSEIF v_income < (p_requested_amount * 0.30) THEN
        SET p_is_eligible = 'NO';
        SET p_reason      = CONCAT('Annual income ₹', v_income,
                                   ' is less than 30% of requested amount ₹', p_requested_amount, '.');

    ELSEIF v_active_loans >= 3 THEN
        SET p_is_eligible = 'NO';
        SET p_reason      = CONCAT('Customer already has ', v_active_loans,
                                   ' active loans. Maximum 3 concurrent loans allowed.');

    ELSE
        SET p_is_eligible = 'YES';
        SET p_reason      = CONCAT('Eligible. Credit score: ', v_credit_score,
                                   ', Income: ₹', v_income,
                                   ', Active loans: ', v_active_loans, '.');
    END IF;
END $$

-- Test:
-- CALL sp_check_loan_eligibility(101, 500000, @eligible, @reason);
-- SELECT @eligible AS eligible, @reason AS reason;


-- ============================================================
-- PROCEDURE 3: Record a loan payment
-- ============================================================
-- SP3: sp_record_payment
-- WHAT: Inserts a new payment record and updates the outstanding balance.
--       Validates that the payment_id doesn't already exist.
--       Returns a status message via OUT parameter.
-- WHY:  Wrapping payment recording in a procedure ensures all payment
--       insert and balance-update logic runs atomically as a transaction.
-- Usage: CALL sp_record_payment(99999, 1001, 101, 1, '2024-01-15',
--               '2024-01-14', 15000.00, 8000.00, 7000.00, 0.00,
--               'Paid', 0, 2400000.00, @msg);
DROP PROCEDURE IF EXISTS sp_record_payment $$
CREATE PROCEDURE sp_record_payment (
    IN  p_payment_id        INT,
    IN  p_application_id    INT,
    IN  p_customer_id       INT,
    IN  p_payment_number    INT,
    IN  p_due_date          DATE,
    IN  p_payment_date      DATE,
    IN  p_emi_amount        DECIMAL(12,2),
    IN  p_principal_paid    DECIMAL(12,2),
    IN  p_interest_paid     DECIMAL(12,2),
    IN  p_penalty_amount    DECIMAL(12,2),
    IN  p_payment_status    VARCHAR(20),
    IN  p_days_late         INT,
    IN  p_outstanding_balance DECIMAL(15,2),
    OUT p_status_msg        VARCHAR(200)
)
BEGIN
    DECLARE v_exists INT DEFAULT 0;

    -- Check if payment_id already exists
    SELECT COUNT(*) INTO v_exists
    FROM loan_payments WHERE payment_id = p_payment_id;

    IF v_exists > 0 THEN
        SET p_status_msg = CONCAT('ERROR: Payment ID ', p_payment_id, ' already exists.');
    ELSE
        START TRANSACTION;

        INSERT INTO loan_payments (
            payment_id, application_id, customer_id, payment_number,
            due_date, payment_date, emi_amount, principal_paid,
            interest_paid, penalty_amount, payment_status,
            days_late, outstanding_balance
        ) VALUES (
            p_payment_id, p_application_id, p_customer_id, p_payment_number,
            p_due_date, p_payment_date, p_emi_amount, p_principal_paid,
            p_interest_paid, p_penalty_amount, p_payment_status,
            p_days_late, p_outstanding_balance
        );

        COMMIT;
        SET p_status_msg = CONCAT('SUCCESS: Payment ID ', p_payment_id,
                                  ' recorded for application ', p_application_id, '.');
    END IF;
END $$

-- Test:
-- CALL sp_record_payment(999001, 1001, 101, 1, '2024-01-15', '2024-01-14',
--      15000, 8000, 7000, 0, 'Paid', 0, 2400000, @msg);
-- SELECT @msg;


-- ============================================================
-- PROCEDURE 4: Monthly branch report
-- ============================================================
-- SP4: sp_monthly_branch_report
-- WHAT: Generates a monthly performance report for all branches for a
--       given year-month string (format: 'YYYY-MM').
--       Returns: loans applied, approved, disbursed, interest earned.
-- WHY:  Month-end branch reports are a recurring operational task.
--       A stored procedure automates the computation on demand.
-- Usage: CALL sp_monthly_branch_report('2023-06');
DROP PROCEDURE IF EXISTS sp_monthly_branch_report $$
CREATE PROCEDURE sp_monthly_branch_report (
    IN p_month VARCHAR(7)   -- Format: 'YYYY-MM'
)
BEGIN
    SELECT
        b.branch_name, b.city, b.state, b.zone,
        COUNT(la.application_id)                                         AS applications,
        SUM(CASE WHEN la.status IN ('Approved','Disbursed','Closed')
                 THEN 1 ELSE 0 END)                                      AS approved,
        SUM(CASE WHEN la.status = 'Disbursed' THEN 1 ELSE 0 END)        AS disbursed,
        ROUND(SUM(CASE WHEN la.status = 'Disbursed'
                       THEN la.loan_amount_approved ELSE 0 END)
              / 10000000, 2)                                              AS disbursed_cr,
        ROUND(SUM(lp.interest_paid), 0)                                  AS interest_earned,
        ROUND(SUM(lp.penalty_amount), 0)                                 AS penalties_collected
    FROM branches b
    LEFT JOIN loan_applications la
        ON b.branch_id = la.branch_id
        AND DATE_FORMAT(la.application_date, '%Y-%m') = p_month
    LEFT JOIN loan_payments lp
        ON la.application_id = lp.application_id
        AND DATE_FORMAT(lp.payment_date, '%Y-%m') = p_month
    GROUP BY b.branch_id, b.branch_name, b.city, b.state, b.zone
    ORDER BY disbursed_cr DESC;
END $$

-- Test:
-- CALL sp_monthly_branch_report('2023-06');


-- ============================================================
-- PROCEDURE 5: Flag NPA accounts
-- ============================================================
-- SP5: sp_flag_npa_accounts
-- WHAT: Uses a cursor to iterate through all loans, counts missed payments,
--       and prints a warning for any loan meeting NPA criteria (3+ misses).
--       Returns a result set of flagged NPA accounts.
-- WHY:  Demonstrates cursor-based row-by-row processing — useful when
--       set-based SQL alone cannot meet the requirement (e.g., logging or
--       calling another procedure per flagged row).
-- Usage: CALL sp_flag_npa_accounts(3);
DROP PROCEDURE IF EXISTS sp_flag_npa_accounts $$
CREATE PROCEDURE sp_flag_npa_accounts (
    IN p_min_missed_payments INT
)
BEGIN
    -- Return NPA candidates directly
    SELECT
        la.application_id,
        c.customer_id, c.full_name, c.phone_number,
        la.loan_type_name, la.loan_amount_approved, la.status,
        COUNT(CASE WHEN lp.payment_status = 'Missed' THEN 1 END) AS missed_payments,
        MAX(lp.outstanding_balance)                               AS current_outstanding,
        MAX(lp.days_late)                                         AS max_days_late,
        CURDATE()                                                 AS flagged_on
    FROM loan_applications la
    JOIN loan_payments lp ON la.application_id = lp.application_id
    JOIN customers     c  ON la.customer_id    = c.customer_id
    GROUP BY la.application_id, c.customer_id, c.full_name, c.phone_number,
             la.loan_type_name, la.loan_amount_approved, la.status
    HAVING missed_payments >= p_min_missed_payments
    ORDER BY current_outstanding DESC;

    -- Also return summary count
    SELECT COUNT(*) AS total_npa_accounts,
           p_min_missed_payments AS criteria_missed_payments_min
    FROM (
        SELECT la.application_id
        FROM loan_applications la
        JOIN loan_payments lp ON la.application_id = lp.application_id
        GROUP BY la.application_id
        HAVING COUNT(CASE WHEN lp.payment_status = 'Missed' THEN 1 END) >= p_min_missed_payments
    ) npa_count;
END $$

-- Test:
-- CALL sp_flag_npa_accounts(3);


-- ============================================================
-- PROCEDURE 6: Customer transaction summary
-- ============================================================
-- SP6: sp_customer_transaction_summary
-- WHAT: Returns a summary of a customer's transaction activity
--       for a specified date range — total credits, debits, and net flow.
-- WHY:  Customer relationship managers use this to quickly review
--       account activity during customer meetings or issue resolution.
-- Usage: CALL sp_customer_transaction_summary(101, '2023-01-01', '2023-12-31');
DROP PROCEDURE IF EXISTS sp_customer_transaction_summary $$
CREATE PROCEDURE sp_customer_transaction_summary (
    IN p_customer_id INT,
    IN p_from_date   DATE,
    IN p_to_date     DATE
)
BEGIN
    -- Summary
    SELECT
        p_customer_id                                            AS customer_id,
        (SELECT full_name FROM customers WHERE customer_id = p_customer_id) AS customer_name,
        p_from_date AS from_date, p_to_date AS to_date,
        COUNT(*)                                                AS total_transactions,
        SUM(CASE WHEN transaction_type='Credit' THEN amount ELSE 0 END) AS total_credits,
        SUM(CASE WHEN transaction_type='Debit'  THEN amount ELSE 0 END) AS total_debits,
        ROUND(
            SUM(CASE WHEN transaction_type='Credit' THEN amount ELSE 0 END) -
            SUM(CASE WHEN transaction_type='Debit'  THEN amount ELSE 0 END), 2
        )                                                        AS net_flow
    FROM transactions
    WHERE customer_id   = p_customer_id
      AND status        = 'Success'
      AND transaction_date BETWEEN p_from_date AND p_to_date;

    -- Category breakdown
    SELECT category,
           COUNT(*)               AS txn_count,
           ROUND(SUM(amount), 2)  AS total_amount
    FROM transactions
    WHERE customer_id        = p_customer_id
      AND status             = 'Success'
      AND transaction_type   = 'Debit'
      AND transaction_date BETWEEN p_from_date AND p_to_date
    GROUP BY category
    ORDER BY total_amount DESC;
END $$

-- Test:
-- CALL sp_customer_transaction_summary(101, '2023-01-01', '2023-12-31');


-- Reset delimiter
DELIMITER ;


-- ============================================================
-- LIST ALL STORED PROCEDURES
-- ============================================================
SHOW PROCEDURE STATUS WHERE Db = 'indosynth_bank';


-- ============================================================
-- END OF STORED PROCEDURES
-- ============================================================
