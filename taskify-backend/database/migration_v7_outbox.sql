-- Phase 1: Realtime Outbox + Versioning
-- Safe, additive migration. No existing columns touched.

-- 1. Event outbox table (new table only)
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

-- 2. Version column on tickets (nullable, backward-compatible)
ALTER TABLE tickets ADD COLUMN IF NOT EXISTS version BIGINT;

-- 3. Version column on sub_ticket_departments (nullable, backward-compatible)
ALTER TABLE sub_ticket_departments ADD COLUMN IF NOT EXISTS version BIGINT;

-- 4. Safe batched backfill for tickets (1000 rows at a time)
-- Application treats NULL as version 1 until backfill completes.
-- Run this AFTER deploying the code that handles NULL version.
DO $$
DECLARE
  batch_size INT := 1000;
  max_id INT;
  current_start INT := 0;
BEGIN
  SELECT COALESCE(MAX(id), 0) INTO max_id FROM tickets;
  WHILE current_start <= max_id LOOP
    UPDATE tickets SET version = 1
    WHERE version IS NULL AND id > current_start AND id <= current_start + batch_size;
    current_start := current_start + batch_size;
  END LOOP;
END $$;

-- 5. Safe batched backfill for sub_ticket_departments
DO $$
DECLARE
  batch_size INT := 1000;
  max_id INT;
  current_start INT := 0;
BEGIN
  SELECT COALESCE(MAX(id), 0) INTO max_id FROM sub_ticket_departments;
  WHILE current_start <= max_id LOOP
    UPDATE sub_ticket_departments SET version = 1
    WHERE version IS NULL AND id > current_start AND id <= current_start + batch_size;
    current_start := current_start + batch_size;
  END LOOP;
END $$;
