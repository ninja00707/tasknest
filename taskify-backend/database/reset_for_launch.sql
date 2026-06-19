-- ============================================================
-- Tasknest: Full Data Reset for Live Launch
-- Run: psql -U postgres -d taskify -f reset_for_launch.sql
-- ============================================================
-- 1. Clears all tickets, notifications, logs, comments
-- 2. Resets all ticket-related sequences to start fresh
-- 3. Forces all users to reset password on next login
-- ============================================================

BEGIN;

-- Break self-referencing FK on tickets (parent-child relationships)
UPDATE tickets SET parent_ticket_id = NULL;

-- Delete notifications manually (no ON DELETE CASCADE)
DELETE FROM notifications;

-- Delete tickets (cascades to ticket_logs, ticket_comments,
-- ticket_departments, sub_ticket_departments)
DELETE FROM tickets;

-- Reset all ticket-related sequences (gracefully skip missing ones)
DO $$ BEGIN
  IF EXISTS (SELECT 1 FROM pg_class WHERE relname = 'tickets_id_seq' AND relkind = 'S') THEN
    PERFORM setval('tickets_id_seq', 1, false);
  END IF;
END $$;

DO $$ BEGIN
  IF EXISTS (SELECT 1 FROM pg_class WHERE relname = 'ticket_logs_id_seq' AND relkind = 'S') THEN
    PERFORM setval('ticket_logs_id_seq', 1, false);
  END IF;
END $$;

DO $$ BEGIN
  IF EXISTS (SELECT 1 FROM pg_class WHERE relname = 'ticket_comments_id_seq' AND relkind = 'S') THEN
    PERFORM setval('ticket_comments_id_seq', 1, false);
  END IF;
END $$;

DO $$ BEGIN
  IF EXISTS (SELECT 1 FROM pg_class WHERE relname = 'notifications_id_seq' AND relkind = 'S') THEN
    PERFORM setval('notifications_id_seq', 1, false);
  END IF;
END $$;

DO $$ BEGIN
  IF EXISTS (SELECT 1 FROM pg_class WHERE relname = 'sub_ticket_departments_id_seq' AND relkind = 'S') THEN
    PERFORM setval('sub_ticket_departments_id_seq', 1, false);
  END IF;
END $$;

DO $$ BEGIN
  IF EXISTS (SELECT 1 FROM pg_class WHERE relname = 'standard_ticket_departments_id_seq' AND relkind = 'S') THEN
    PERFORM setval('standard_ticket_departments_id_seq', 1, false);
  END IF;
END $$;

DO $$ BEGIN
  IF EXISTS (SELECT 1 FROM pg_class WHERE relname = 'ticket_number_seq' AND relkind = 'S') THEN
    PERFORM setval('ticket_number_seq', 1, false);
  END IF;
END $$;

-- Force all users to reset password on next login (exclude dev account ADMIN001)
UPDATE users SET must_reset_password = TRUE WHERE code <> 'ADMIN001';

COMMIT;
