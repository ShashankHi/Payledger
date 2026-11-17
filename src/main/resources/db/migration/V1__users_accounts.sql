-- =====================================================================
-- V1: users and accounts
-- =====================================================================
-- users    : everyone who can log in (USER or ADMIN)
-- accounts : wallets. One per approved USER, plus SYSTEM accounts
--            (created in V5) that sit on the other side of deposits,
--            withdrawals and fees so every transaction can be double-entry.
--
-- Notes:
--  * Strings are VARCHAR (not CHAR) so Hibernate's ddl-auto=validate
--    accepts them for plain Java String fields.
--  * Enum-like columns are VARCHAR with CHECK constraints. The Java enums
--    (Step 3) must use exactly these values and @Enumerated(EnumType.STRING).
--  * Money is DECIMAL(19,4), never FLOAT/DOUBLE.
-- =====================================================================

CREATE TABLE users (
        id               BIGINT       NOT NULL AUTO_INCREMENT,
        name             VARCHAR(100) NOT NULL,
        email            VARCHAR(150) NOT NULL,
        password_hash    VARCHAR(255) NOT NULL,
        role             VARCHAR(20)  NOT NULL DEFAULT 'USER',
        status           VARCHAR(30)  NOT NULL DEFAULT 'PENDING_APPROVAL',
        kyc_level        VARCHAR(20)  NOT NULL DEFAULT 'BASIC',
        approved_by      BIGINT       NULL,          -- admin who approved
        approved_at      DATETIME(6)  NULL,
        rejection_reason VARCHAR(500) NULL,
        created_at       DATETIME(6)  NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
        updated_at       DATETIME(6)  NOT NULL DEFAULT CURRENT_TIMESTAMP(6)
                   ON UPDATE CURRENT_TIMESTAMP(6),

        PRIMARY KEY (id),
        CONSTRAINT uq_users_email         UNIQUE (email),
        CONSTRAINT fk_users_approved_by   FOREIGN KEY (approved_by) REFERENCES users (id),
        CONSTRAINT chk_users_role         CHECK (role IN ('USER', 'ADMIN')),
        CONSTRAINT chk_users_status       CHECK (status IN ('PENDING_APPROVAL', 'ACTIVE', 'REJECTED', 'SUSPENDED')),
        CONSTRAINT chk_users_kyc_level    CHECK (kyc_level IN ('BASIC', 'VERIFIED'))
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4;

-- Admin "pending approvals" screen filters on status
CREATE INDEX idx_users_status ON users (status);


CREATE TABLE accounts (
        id             BIGINT        NOT NULL AUTO_INCREMENT,
        user_id        BIGINT        NULL,           -- NULL for SYSTEM accounts
        account_number VARCHAR(30)   NOT NULL,       -- shown to users, used to find a receiver
        name           VARCHAR(100)  NULL,           -- only used by SYSTEM accounts
        type           VARCHAR(20)   NOT NULL,
        currency       VARCHAR(3)    NOT NULL DEFAULT 'INR',
        balance        DECIMAL(19,4) NOT NULL DEFAULT 0.0000,   -- cached; the ledger is the truth
        version        BIGINT        NOT NULL DEFAULT 0,        -- JPA @Version (optimistic lock)
        status         VARCHAR(20)   NOT NULL DEFAULT 'ACTIVE',
        created_at     DATETIME(6)   NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
        updated_at     DATETIME(6)   NOT NULL DEFAULT CURRENT_TIMESTAMP(6)
               ON UPDATE CURRENT_TIMESTAMP(6),

        PRIMARY KEY (id),
        CONSTRAINT uq_accounts_number  UNIQUE (account_number),
        CONSTRAINT uq_accounts_user    UNIQUE (user_id),     -- one wallet per user (NULLs allowed many times)
        CONSTRAINT uq_accounts_name    UNIQUE (name),
        CONSTRAINT fk_accounts_user    FOREIGN KEY (user_id) REFERENCES users (id),
        CONSTRAINT chk_accounts_type   CHECK (type IN ('USER', 'SYSTEM')),
        CONSTRAINT chk_accounts_status CHECK (status IN ('ACTIVE', 'FROZEN')),
    -- USER accounts must belong to a user; SYSTEM accounts must not
        CONSTRAINT chk_accounts_owner  CHECK (
            (type = 'USER' AND user_id IS NOT NULL) OR (type = 'SYSTEM' AND user_id IS NULL)
            ),
    -- User wallets can never go negative. System accounts can
    -- (EXTERNAL_FUNDING goes negative as money is deposited into the system).
        CONSTRAINT chk_accounts_balance CHECK (type = 'SYSTEM' OR balance >= 0)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4;