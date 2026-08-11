-- Catch-up: bring a server DB created from schema.sql up to current schema.
-- Safe & idempotent (IF NOT EXISTS / existence guards). Safe to re-run.

-- ── 1. users columns added by later migrations ────────────────────────────
ALTER TABLE users ADD COLUMN IF NOT EXISTS reset_token VARCHAR(10);
ALTER TABLE users ADD COLUMN IF NOT EXISTS reset_token_expires TIMESTAMPTZ;
ALTER TABLE users ADD COLUMN IF NOT EXISTS must_reset_password BOOLEAN DEFAULT FALSE;
ALTER TABLE users ADD COLUMN IF NOT EXISTS code VARCHAR(20) UNIQUE;
ALTER TABLE users ADD COLUMN IF NOT EXISTS last_active TIMESTAMPTZ;
ALTER TABLE users ADD COLUMN IF NOT EXISTS reports_to INT REFERENCES users(id);
ALTER TABLE users ADD COLUMN IF NOT EXISTS designation VARCHAR(200);
ALTER TABLE users ADD COLUMN IF NOT EXISTS see_all_companies BOOLEAN DEFAULT FALSE;

-- ── 2. tickets columns ────────────────────────────────────────────────────
ALTER TABLE tickets ADD COLUMN IF NOT EXISTS ticket_number VARCHAR(50);
ALTER TABLE tickets ADD COLUMN IF NOT EXISTS version BIGINT;

-- ── 3. version backfill for tickets (batched) ─────────────────────────────
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM pg_attribute WHERE attrelid = 'tickets'::regclass AND attname = 'version') THEN
    UPDATE tickets SET version = 1 WHERE version IS NULL;
  END IF;
END $$;

-- ── 4. sub_ticket_departments version column (guarded) ────────────────────
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'sub_ticket_departments') THEN
    EXECUTE 'ALTER TABLE sub_ticket_departments ADD COLUMN IF NOT EXISTS version BIGINT';
    EXECUTE 'UPDATE sub_ticket_departments SET version = 1 WHERE version IS NULL';
  END IF;
END $$;

-- ── 5. event_outbox table (v7) ────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS event_outbox (
  id BIGSERIAL PRIMARY KEY,
  event_type VARCHAR(100) NOT NULL,
  ticket_id INT NOT NULL REFERENCES tickets(id) ON DELETE CASCADE,
  parent_ticket_id INT REFERENCES tickets(id) ON DELETE CASCADE,
  payload JSONB NOT NULL DEFAULT '{}',
  version BIGINT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT now(),
  processed_at TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS idx_event_outbox_unprocessed
  ON event_outbox (created_at)
  WHERE processed_at IS NULL;

-- ── 6. ticket_disputes + dispute_activities tables (v8) ──────────────────
CREATE TABLE IF NOT EXISTS ticket_disputes (
  id BIGSERIAL PRIMARY KEY,
  ticket_id INT NOT NULL REFERENCES tickets(id) ON DELETE CASCADE,
  raised_by_id INT NOT NULL REFERENCES users(id),
  reason VARCHAR(50) NOT NULL,
  description TEXT NOT NULL,
  status VARCHAR(30) NOT NULL DEFAULT 'open',
  assigned_reviewer_id INT REFERENCES users(id),
  resolution_notes TEXT,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now(),
  resolved_at TIMESTAMPTZ
);

CREATE UNIQUE INDEX IF NOT EXISTS idx_ticket_disputes_ticket
  ON ticket_disputes(ticket_id);
CREATE INDEX IF NOT EXISTS idx_ticket_disputes_status
  ON ticket_disputes(status, created_at DESC);

CREATE TABLE IF NOT EXISTS dispute_activities (
  id BIGSERIAL PRIMARY KEY,
  dispute_id INT NOT NULL REFERENCES ticket_disputes(id) ON DELETE CASCADE,
  action VARCHAR(50) NOT NULL,
  actor_id INT NOT NULL REFERENCES users(id),
  actor_name VARCHAR(200),
  note TEXT,
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_dispute_activities_dispute
  ON dispute_activities(dispute_id, created_at DESC);
