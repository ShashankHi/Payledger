-- =====================================================================
-- V4: admin_audit_log
-- =====================================================================
-- One row for every admin action (approve, reject, suspend, freeze,
-- tier change, reversal, ...). Rows are never updated or deleted
-- (enforced by triggers in V6).
--
-- reason is mandatory. For actions that do not naturally need one
-- (e.g. approving a registration) the service writes a default text
-- such as 'Registration approved'.
-- =====================================================================

CREATE TABLE admin_audit_log (
    id          BIGINT       NOT NULL AUTO_INCREMENT,
    admin_id    BIGINT       NOT NULL,
    action      VARCHAR(50)  NOT NULL,        -- e.g. APPROVE_USER, FREEZE_ACCOUNT
    target_type VARCHAR(30)  NOT NULL,        -- USER, ACCOUNT, TRANSACTION
    target_id   BIGINT       NULL,
    reason      VARCHAR(500) NOT NULL,
    created_at  DATETIME(6)  NOT NULL DEFAULT CURRENT_TIMESTAMP(6),

    PRIMARY KEY (id),
    CONSTRAINT fk_audit_admin    FOREIGN KEY (admin_id) REFERENCES users (id),
    CONSTRAINT chk_audit_reason  CHECK (CHAR_LENGTH(TRIM(reason)) > 0)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4;

CREATE INDEX idx_audit_admin_created ON admin_audit_log (admin_id, created_at);
CREATE INDEX idx_audit_target        ON admin_audit_log (target_type, target_id);
CREATE INDEX idx_audit_created       ON admin_audit_log (created_at);