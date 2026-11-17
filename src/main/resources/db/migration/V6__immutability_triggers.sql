-- =====================================================================
-- V6: immutability triggers
-- =====================================================================
-- Makes the financial history tamper-resistant at the database level,
-- even if application code (or a person with a SQL client) tries to
-- change it.
--
--   ledger_entries  : no UPDATE, no DELETE   (append-only)
--   admin_audit_log : no UPDATE, no DELETE   (append-only)
--   transactions    : no DELETE              (status may still change,
--                                             e.g. SUCCESS -> REVERSED)
--
-- Corrections must be made with NEW rows (compensating transactions).
--
-- Each trigger body is a single SIGNAL statement, so no DELIMITER
-- handling is needed and Flyway can run this file as is.
--
-- Note for tests: DELETE on these tables is now blocked. To reset the
-- test database, drop and recreate the schema (payledger_test) and let
-- Flyway rebuild it, instead of deleting rows.
-- =====================================================================

CREATE TRIGGER trg_ledger_entries_no_update
    BEFORE UPDATE ON ledger_entries
    FOR EACH ROW
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'ledger_entries is append-only: UPDATE is not allowed';

CREATE TRIGGER trg_ledger_entries_no_delete
    BEFORE DELETE ON ledger_entries
    FOR EACH ROW
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'ledger_entries is append-only: DELETE is not allowed';

CREATE TRIGGER trg_admin_audit_log_no_update
    BEFORE UPDATE ON admin_audit_log
    FOR EACH ROW
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'admin_audit_log is append-only: UPDATE is not allowed';

CREATE TRIGGER trg_admin_audit_log_no_delete
    BEFORE DELETE ON admin_audit_log
    FOR EACH ROW
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'admin_audit_log is append-only: DELETE is not allowed';

CREATE TRIGGER trg_transactions_no_delete
    BEFORE DELETE ON transactions
    FOR EACH ROW
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'transactions cannot be deleted';