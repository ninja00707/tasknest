-- Migration v14: Trello-style task number series (UMP-TA-000 onwards)
-- Project tasks get their own global sequence; regular tickets keep
-- UMP-TKQ on ticket_number_seq.

CREATE SEQUENCE IF NOT EXISTS task_number_seq START 0 MINVALUE 0;

-- Backfill: every existing project task joins the UMP-TA series in id order
-- (already-converted tasks are skipped, so this migration is re-runnable).
DO $$
DECLARE
  r RECORD;
  n BIGINT;
BEGIN
  FOR r IN
    SELECT id FROM tickets
    WHERE project_id IS NOT NULL
      AND (ticket_number IS NULL OR ticket_number !~ '^UMP-TA-')
    ORDER BY id
  LOOP
    SELECT NEXTVAL('task_number_seq') INTO n;
    UPDATE tickets
    SET ticket_number = 'UMP-TA-' || LPAD(n::text, 3, '0')
    WHERE id = r.id;
  END LOOP;
END $$;

-- Run: node database/run_migration.js database/migration_v14_task_number.sql
