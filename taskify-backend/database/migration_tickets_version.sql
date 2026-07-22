-- ── Add version column to tickets for optimistic concurrency & realtime ordering ──
-- Additive only: nullable, defaults to NULL (treated as version 1 by app code).

ALTER TABLE tickets ADD COLUMN IF NOT EXISTS version BIGINT;

-- Batched backfill: run in a transaction-safe loop so we never lock the table
-- for more than ~1000 rows at a time.
DO $$
DECLARE
  batch_size INT := 1000;
  rows_updated INT := 1;
BEGIN
  WHILE rows_updated > 0 LOOP
    UPDATE tickets
    SET version = 1
    WHERE id IN (
      SELECT id FROM tickets
      WHERE version IS NULL
      LIMIT batch_size
    );
    GET DIAGNOSTICS rows_updated = ROW_COUNT;
    RAISE NOTICE 'Backfilled % tickets', rows_updated;
  END LOOP;
END $$;
