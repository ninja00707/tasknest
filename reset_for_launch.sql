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

-- Reset all ticket-related sequences
ALTER SEQUENCE tickets_id_seq             RESTART WITH 1;
ALTER SEQUENCE ticket_logs_id_seq         RESTART WITH 1;
ALTER SEQUENCE ticket_comments_id_seq     RESTART WITH 1;
ALTER SEQUENCE notifications_id_seq       RESTART WITH 1;
ALTER SEQUENCE sub_ticket_departments_id_seq RESTART WITH 1;
ALTER SEQUENCE standard_ticket_departments_id_seq RESTART WITH 1;
ALTER SEQUENCE ticket_number_seq          RESTART WITH 1;

-- Force all users to reset password on next login (exclude dev account ADMIN001)
UPDATE users SET must_reset_password = TRUE WHERE code <> 'ADMIN001';

COMMIT;
