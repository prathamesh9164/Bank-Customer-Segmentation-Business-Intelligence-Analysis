-- ============================================================
-- 🏦 IndoSynth Gramin Bank — 10: Triggers
-- ============================================================
-- Creates BEFORE and AFTER triggers on key tables to enforce
-- business rules, maintain audit logs, auto-compute derived
-- columns, and prevent invalid data modifications.
-- Run after 01_Database_Setup.sql
-- ============================================================

USE indosynth_bank;

DELIMITER $$


-- ============================================================
-- SECTION 0: AUDIT LOG TABLE (used by multiple triggers)
-- ============================================================

-- Create a generic audit log table to record all data changes
CREATE TABLE IF NOT EXISTS audit_log (
    log_id         INT AUTO_INCREMENT PRIMARY KEY,
    table_name     VARCHAR(50)  NOT NULL,
    operation      VARCHAR(10)  NOT NULL,   -- INSERT / UPDATE / DELETE
    record_id      INT,
    changed_column VARCHAR(60),
    old_value      VARCHAR(200),
    new_value      VARCHAR(200),
    changed_by     VARCHAR(100) DEFAULT USER(),
    changed_at     DATETIME     DEFAULT CURRENT_TIMESTAMP
);


-- ============================================================
-- TRIGGER 1: BEFORE INSERT on loan_applications
-- Enforce business rules before a loan application is created
-- ============================================================
-- TRG1: trg_before_loan_application_insert
-- WHAT: Validates loan amount against loan_types limits and ensures
--       application_date is not a future date before inserting.
-- WHY:  Prevents invalid data from entering the database at source,
--       regardless of which application or user is performing the insert.
DROP TRIGGER IF EXISTS trg_before_loan_application_insert $$
CREATE TRIGGER trg_before_loan_application_insert
BEFORE INSERT ON loan_applications
FOR EACH ROW
BEGIN
    DECLARE v_min_amount DECIMAL(15,2);
    DECLARE v_max_amount DECIMAL(15,2);

    -- Get loan type limits
    SELECT min_amount, max_amount
    INTO   v_min_amount, v_max_amount
    FROM   loan_types
    WHERE  loan_type_id = NEW.loan_type_id;

    -- Rule 1: Requested amount must be within product limits
    IF NEW.loan_amount_requested < v_min_amount THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Loan amount is below the minimum allowed for this product.';
    END IF;

    IF NEW.loan_amount_requested > v_max_amount THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Loan amount exceeds the maximum allowed for this product.';
    END IF;

    -- Rule 2: Application date cannot be in the future
    IF NEW.application_date > CURDATE() THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Application date cannot be a future date.';
    END IF;

    -- Rule 3: Approved amount cannot exceed requested amount
    IF NEW.loan_amount_approved IS NOT NULL
       AND NEW.loan_amount_approved > NEW.loan_amount_requested THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Approved amount cannot exceed requested amount.';
    END IF;
END $$


-- ============================================================
-- TRIGGER 2: AFTER INSERT on loan_applications
-- Log new application creation
-- ============================================================
-- TRG2: trg_after_loan_application_insert
-- WHAT: After a new loan application is inserted, writes an audit
--       log entry recording who created it and when.
-- WHY:  Audit trails are mandatory under financial regulations.
--       Every loan application creation must be traceable.
DROP TRIGGER IF EXISTS trg_after_loan_application_insert $$
CREATE TRIGGER trg_after_loan_application_insert
AFTER INSERT ON loan_applications
FOR EACH ROW
BEGIN
    INSERT INTO audit_log (table_name, operation, record_id, new_value)
    VALUES (
        'loan_applications', 'INSERT', NEW.application_id,
        CONCAT('customer_id=', NEW.customer_id,
               ', loan_type=', NEW.loan_type_name,
               ', amount=', NEW.loan_amount_requested,
               ', status=', NEW.status)
    );
END $$


-- ============================================================
-- TRIGGER 3: BEFORE UPDATE on loan_applications
-- Prevent invalid status transitions
-- ============================================================
-- TRG3: trg_before_loan_status_update
-- WHAT: Enforces valid loan status transition rules:
--       - 'Closed' loans cannot be reopened.
--       - 'Disbursed' loans cannot move directly to 'Pending'.
-- WHY:  Status fields are only meaningful if transitions follow
--       business rules. A trigger enforces this at the DB layer.
DROP TRIGGER IF EXISTS trg_before_loan_status_update $$
CREATE TRIGGER trg_before_loan_status_update
BEFORE UPDATE ON loan_applications
FOR EACH ROW
BEGIN
    -- A closed loan cannot change status
    IF OLD.status = 'Closed' AND NEW.status <> 'Closed' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'A Closed loan application cannot be reopened or changed.';
    END IF;

    -- A disbursed loan cannot revert to Pending
    IF OLD.status = 'Disbursed' AND NEW.status = 'Pending' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'A Disbursed loan cannot revert to Pending status.';
    END IF;
END $$


-- ============================================================
-- TRIGGER 4: AFTER UPDATE on loan_applications
-- Audit log for status changes
-- ============================================================
-- TRG4: trg_after_loan_status_update
-- WHAT: Records the old and new status whenever a loan application's
--       status changes, capturing who made the change and when.
-- WHY:  Status change history is required for regulatory compliance
--       and dispute resolution (e.g., "When was this loan approved?").
DROP TRIGGER IF EXISTS trg_after_loan_status_update $$
CREATE TRIGGER trg_after_loan_status_update
AFTER UPDATE ON loan_applications
FOR EACH ROW
BEGIN
    IF OLD.status <> NEW.status THEN
        INSERT INTO audit_log (
            table_name, operation, record_id,
            changed_column, old_value, new_value
        )
        VALUES (
            'loan_applications', 'UPDATE', NEW.application_id,
            'status', OLD.status, NEW.status
        );
    END IF;

    -- Also log disbursement date change
    IF OLD.disbursement_date IS NULL AND NEW.disbursement_date IS NOT NULL THEN
        INSERT INTO audit_log (
            table_name, operation, record_id,
            changed_column, old_value, new_value
        )
        VALUES (
            'loan_applications', 'UPDATE', NEW.application_id,
            'disbursement_date', 'NULL', CAST(NEW.disbursement_date AS CHAR)
        );
    END IF;
END $$


-- ============================================================
-- TRIGGER 5: BEFORE INSERT on loan_payments
-- Enforce payment business rules
-- ============================================================
-- TRG5: trg_before_payment_insert
-- WHAT: Validates that:
--       (a) EMI amount is positive.
--       (b) Payment date is not in the future.
--       (c) Days_late is correctly computed if payment_date is provided.
-- WHY:  Data integrity at insert time prevents downstream analytics
--       from being skewed by negative or future-dated payment records.
DROP TRIGGER IF EXISTS trg_before_payment_insert $$
CREATE TRIGGER trg_before_payment_insert
BEFORE INSERT ON loan_payments
FOR EACH ROW
BEGIN
    -- EMI must be positive
    IF NEW.emi_amount <= 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'EMI amount must be greater than zero.';
    END IF;

    -- Payment date cannot be in the future
    IF NEW.payment_date IS NOT NULL AND NEW.payment_date > CURDATE() THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Payment date cannot be a future date.';
    END IF;

    -- Auto-compute days_late if payment_date and due_date are both set
    IF NEW.payment_date IS NOT NULL AND NEW.due_date IS NOT NULL THEN
        IF NEW.payment_date > NEW.due_date THEN
            SET NEW.days_late = DATEDIFF(NEW.payment_date, NEW.due_date);
        ELSE
            SET NEW.days_late = 0;
        END IF;
    END IF;
END $$


-- ============================================================
-- TRIGGER 6: AFTER INSERT on loan_payments
-- Auto-update payment_status based on days_late
-- ============================================================
-- TRG6: trg_after_payment_insert
-- WHAT: After a payment is inserted, logs it to the audit table.
--       Also acts as a hook for future automated escalation logic.
-- WHY:  Centralises post-payment actions so business rules evolve
--       without changing application code.
DROP TRIGGER IF EXISTS trg_after_payment_insert $$
CREATE TRIGGER trg_after_payment_insert
AFTER INSERT ON loan_payments
FOR EACH ROW
BEGIN
    INSERT INTO audit_log (table_name, operation, record_id, new_value)
    VALUES (
        'loan_payments', 'INSERT', NEW.payment_id,
        CONCAT('application_id=', NEW.application_id,
               ', status=', NEW.payment_status,
               ', days_late=', COALESCE(NEW.days_late, 0),
               ', penalty=', COALESCE(NEW.penalty_amount, 0))
    );
END $$


-- ============================================================
-- TRIGGER 7: BEFORE DELETE on customers
-- Prevent deletion of customers with active loans
-- ============================================================
-- TRG7: trg_before_customer_delete
-- WHAT: Blocks deletion of any customer who has active (Disbursed) loans.
-- WHY:  Deleting a customer with an outstanding loan would orphan critical
--       financial records — this is a hard business rule.
DROP TRIGGER IF EXISTS trg_before_customer_delete $$
CREATE TRIGGER trg_before_customer_delete
BEFORE DELETE ON customers
FOR EACH ROW
BEGIN
    DECLARE v_active_loans INT DEFAULT 0;

    SELECT COUNT(*) INTO v_active_loans
    FROM loan_applications
    WHERE customer_id = OLD.customer_id
      AND status = 'Disbursed';

    IF v_active_loans > 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Cannot delete customer: they have active disbursed loans.';
    END IF;
END $$


-- ============================================================
-- TRIGGER 8: BEFORE UPDATE on customers
-- Auto-recalculate age when date_of_birth is updated
-- ============================================================
-- TRG8: trg_before_customer_dob_update
-- WHAT: Automatically recalculates and updates the age column whenever
--       date_of_birth is changed, keeping derived data consistent.
-- WHY:  Stored derived columns (like age) go stale. A trigger ensures
--       age is always in sync with date_of_birth without application code.
DROP TRIGGER IF EXISTS trg_before_customer_dob_update $$
CREATE TRIGGER trg_before_customer_dob_update
BEFORE UPDATE ON customers
FOR EACH ROW
BEGIN
    IF NEW.date_of_birth <> OLD.date_of_birth OR OLD.date_of_birth IS NULL THEN
        SET NEW.age = TIMESTAMPDIFF(YEAR, NEW.date_of_birth, CURDATE());
    END IF;
END $$


DELIMITER ;


-- ============================================================
-- LIST ALL TRIGGERS
-- ============================================================
SHOW TRIGGERS FROM indosynth_bank;


-- ============================================================
-- VIEW AUDIT LOG (after running any INSERT/UPDATE)
-- ============================================================
SELECT * FROM audit_log ORDER BY changed_at DESC LIMIT 20;


-- ============================================================
-- END OF TRIGGERS
-- ============================================================
