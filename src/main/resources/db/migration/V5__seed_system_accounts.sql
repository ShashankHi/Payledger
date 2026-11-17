-- =====================================================================
-- V5: seed system accounts
-- =====================================================================
-- EXTERNAL_FUNDING : the "outside world". Deposits debit it, withdrawals
--                    credit it. Its balance goes negative as money enters
--                    the system, which is expected.
-- FEE_COLLECTION   : receives transfer fees.
--
-- These rows are required for the ledger to work, so they are created by
-- a migration (not by application code). Both have no user_id.
-- =====================================================================

INSERT INTO accounts (account_number, name, type, currency, balance, status)
VALUES ('SYS-EXTERNAL-FUNDING', 'EXTERNAL_FUNDING', 'SYSTEM', 'INR', 0.0000, 'ACTIVE'),
       ('SYS-FEE-COLLECTION',   'FEE_COLLECTION',   'SYSTEM', 'INR', 0.0000, 'ACTIVE');