-- =====================================================================
-- V2: transactions and ledger_entries
-- =====================================================================
-- transactions   : one row per business operation (deposit, withdrawal,
--                  transfer, reversal). Status moves PENDING -> SUCCESS,
--                  and SUCCESS -> REVERSED when it is reversed.
-- ledger_entries : the append-only double-entry records. Every transaction
--                  has 2 entries (no fee) or 4 entries (with fee):
--                    DEBIT  sender            amount
--                    CREDIT receiver          amount
--                    DEBIT  sender            fee      (only if fee > 0)
--                    CREDIT FEE_COLLECTION    fee      (only if fee > 0)
--                  Total DEBITs always equal total CREDITs.
--
-- Deposits and withdrawals use the EXTERNAL_FUNDING system account as the
-- other side, so from_account_id and to_account_id are always present.
-- =====================================================================

CREATE TABLE transactions (
        id               BIGINT        NOT NULL AUTO_INCREMENT,
        type             VARCHAR(20)   NOT NULL,
        status           VARCHAR(20)   NOT NULL DEFAULT 'PENDING',
        amount           DECIMAL(19,4) NOT NULL,
        fee              DECIMAL(19,4) NOT NULL DEFAULT 0.0000,
        currency         VARCHAR(3)    NOT NULL DEFAULT 'INR',
        from_account_id  BIGINT        NOT NULL,
        to_account_id    BIGINT        NOT NULL,
        initiated_by     BIGINT        NOT NULL,     -- user (or admin, for admin reversals)
        reference_txn_id BIGINT        NULL,         -- for REVERSAL: the original transaction
        idempotency_key  VARCHAR(100)  NULL,
        note             VARCHAR(500)  NULL,
        created_at       DATETIME(6)   NOT NULL DEFAULT CURRENT_TIMESTAMP(6),

        PRIMARY KEY (id),
        CONSTRAINT fk_txn_from        FOREIGN KEY (from_account_id)  REFERENCES accounts (id),
        CONSTRAINT fk_txn_to          FOREIGN KEY (to_account_id)    REFERENCES accounts (id),
        CONSTRAINT fk_txn_initiated   FOREIGN KEY (initiated_by)     REFERENCES users (id),
        CONSTRAINT fk_txn_reference   FOREIGN KEY (reference_txn_id) REFERENCES transactions (id),

    -- Same idempotency key from the same user can only create one transaction.
    -- This unique constraint is what stops two simultaneous duplicate requests.
        CONSTRAINT uq_txn_idempotency UNIQUE (initiated_by, idempotency_key),
    -- A transaction can be reversed at most once (database-level guard).
        CONSTRAINT uq_txn_reference   UNIQUE (reference_txn_id),

        CONSTRAINT chk_txn_type       CHECK (type IN ('DEPOSIT', 'WITHDRAWAL', 'TRANSFER', 'REVERSAL')),
        CONSTRAINT chk_txn_status     CHECK (status IN ('PENDING', 'SUCCESS', 'FAILED', 'REVERSED')),
        CONSTRAINT chk_txn_amount     CHECK (amount > 0),
        CONSTRAINT chk_txn_fee        CHECK (fee >= 0),
        CONSTRAINT chk_txn_accounts   CHECK (from_account_id <> to_account_id)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4;

-- Transaction history queries (own transactions, filtered and sorted by date)
CREATE INDEX idx_txn_from_created ON transactions (from_account_id, created_at);
CREATE INDEX idx_txn_to_created   ON transactions (to_account_id, created_at);
CREATE INDEX idx_txn_status_type  ON transactions (status, type);
CREATE INDEX idx_txn_created      ON transactions (created_at);


CREATE TABLE ledger_entries (
        id             BIGINT        NOT NULL AUTO_INCREMENT,
        transaction_id BIGINT        NOT NULL,
        account_id     BIGINT        NOT NULL,
        direction      VARCHAR(10)   NOT NULL,
        amount         DECIMAL(19,4) NOT NULL,
        balance_after  DECIMAL(19,4) NOT NULL,       -- account balance right after this entry
        created_at     DATETIME(6)   NOT NULL DEFAULT CURRENT_TIMESTAMP(6),

        PRIMARY KEY (id),
        CONSTRAINT fk_ledger_txn       FOREIGN KEY (transaction_id) REFERENCES transactions (id),
        CONSTRAINT fk_ledger_account   FOREIGN KEY (account_id)     REFERENCES accounts (id),
        CONSTRAINT chk_ledger_dir      CHECK (direction IN ('DEBIT', 'CREDIT')),
        CONSTRAINT chk_ledger_amount   CHECK (amount > 0)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4;

-- Per-account history and reconciliation (sum of entries per account)
CREATE INDEX idx_ledger_account_created ON ledger_entries (account_id, created_at);
CREATE INDEX idx_ledger_transaction     ON ledger_entries (transaction_id);