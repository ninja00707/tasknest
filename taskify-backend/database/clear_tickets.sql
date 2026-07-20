-- ============================================================
-- Tasknest: Clear ALL Ticket Data (Keep Structure)
-- Run: psql -U postgres -d taskify -f clear_tickets.sql
-- ============================================================
-- Clears: tickets, ticket_logs, ticket_comments, 
--         sub_ticket_departments, notifications
-- Resets all sequences for clean start
-- Tables structure remains intact
-- ============================================================

BEGIN;

-- Break self-referencing FK on tickets (parent-child)
UPDATE tickets SET parent_ticket_id = NULL;

-- Delete in order of dependencies
DELETE FROM ticket_logs;
DELETE FROM ticket_comments;
DELETE FROM sub_ticket_departments;
DELETE FROM notifications;
DELETE FROM tickets;

-- Reset all ticket-related sequences to start fresh
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
  IF EXISTS (SELECT 1 FROM pg_class WHERE relname = 'ticket_number_seq' AND relkind = 'S') THEN
    PERFORM setval('ticket_number_seq', 1, false);
  END IF;
END $$;

COMMIT;

-- Verify everything is cleared
SELECT 'tickets' as table_name, COUNT(*) as remaining FROM tickets
UNION ALL
SELECT 'ticket_logs', COUNT(*) FROM ticket_logs
UNION ALL
SELECT 'ticket_comments', COUNT(*) FROM ticket_comments
UNION ALL
SELECT 'sub_ticket_departments', COUNT(*) FROM sub_ticket_departments
UNION ALL
SELECT 'notifications', COUNT(*) FROM notifications;

