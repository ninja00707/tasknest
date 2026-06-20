-- ============================================================
-- Tasknest: Safe migration (no data loss)
-- Run: psql -U postgres -d taskify -f migrate.sql
-- Only adds last_active column if missing — no resets
-- ============================================================
DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='users' AND column_name='last_active') THEN
    ALTER TABLE users ADD COLUMN last_active TIMESTAMP WITH TIME ZONE;
  END IF;
END $$;
