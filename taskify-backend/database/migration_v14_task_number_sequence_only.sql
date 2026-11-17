-- Migration v14 (live-safe variant): task-number SEQUENCE ONLY.
--
-- Use this instead of migration_v14_task_number.sql on a live database.
--
-- What it does:
--   1. Creates `task_number_seq`, which the API needs when creating a new
--      project task (ticket.repository.js -> NEXTVAL('task_number_seq')).
--   2. Moves the sequence past the highest existing UMP-TA-### value so new
--      project tasks cannot reuse a number.
--
-- What it deliberately does NOT do:
--   * No UPDATE of tickets.ticket_number.
--   * No renumbering of existing project-linked tickets.
--   Existing numbers stay exactly as they are.
--
-- Safe to re-run. Read-only with respect to ticket rows.
--
-- Run: node database/run_migration.js database/migration_v14_task_number_sequence_only.sql

CREATE SEQUENCE IF NOT EXISTS task_number_seq START 0 MINVALUE 0;

DO $$
DECLARE
  max_no BIGINT;
BEGIN
  SELECT MAX(SUBSTRING(ticket_number FROM '^UMP-TA-([0-9]+)$')::BIGINT)
    INTO max_no
  FROM tickets
  WHERE ticket_number ~ '^UMP-TA-[0-9]+$';

  IF max_no IS NULL THEN
    -- No UMP-TA numbers yet: next NEXTVAL must be 0 (UMP-TA-000).
    PERFORM setval('task_number_seq', 0, false);
  ELSE
    -- Continue after the highest existing number.
    PERFORM setval('task_number_seq', max_no, true);
  END IF;
END $$;
