-- =====================================================================
-- V3: idempotency_keys
-- =====================================================================
-- Stores each Idempotency-Key a client sends, a hash of the request body,
-- and (once finished) the response, so a retry gets the SAME response
-- instead of moving money twice.
--
-- Flow:
--   1. Insert a row with IN_PROGRESS. If the (user_id, key) pair
--      already exists, the unique constraint rejects it:
--        - same request_hash + COMPLETED   -> return the stored response
--        - same request_hash + IN_PROGRESS -> tell the client to retry shortly
--        - different request_hash          -> 422 (key reused with a different payload)
--   2. Run the operation.
--   3. Update the row to COMPLETED with the response.
--
-- The column is named idempotency_key because KEY is a reserved word in MySQL.
-- =====================================================================

CREATE TABLE idempotency_keys (
        id              BIGINT         NOT NULL AUTO_INCREMENT,
        user_id         BIGINT         NOT NULL,
        idempotency_key VARCHAR(100)   NOT NULL,
        request_hash    VARCHAR(64)    NOT NULL,      -- SHA-256 hex of the request body
        status          VARCHAR(20)    NOT NULL DEFAULT 'IN_PROGRESS',
        response_status INT            NULL,          -- HTTP status of the stored response
        response_body   VARCHAR(4000)  NULL,          -- JSON of the stored response
        transaction_id  BIGINT         NULL,
        created_at      DATETIME(6)    NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
        expires_at      DATETIME(6)    NOT NULL,

        PRIMARY KEY (id),
        CONSTRAINT uq_idem_user_key   UNIQUE (user_id, idempotency_key),
        CONSTRAINT fk_idem_user       FOREIGN KEY (user_id)        REFERENCES users (id),
        CONSTRAINT fk_idem_txn        FOREIGN KEY (transaction_id) REFERENCES transactions (id),
        CONSTRAINT chk_idem_status    CHECK (status IN ('IN_PROGRESS', 'COMPLETED'))
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4;

-- For cleaning up expired keys
CREATE INDEX idx_idem_expires ON idempotency_keys (expires_at);