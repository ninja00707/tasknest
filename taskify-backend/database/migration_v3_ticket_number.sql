-- Add ticket_number column and sequence for auto-numbering
CREATE SEQUENCE IF NOT EXISTS ticket_number_seq START 1;

ALTER TABLE tickets ADD COLUMN IF NOT EXISTS ticket_number VARCHAR(50);

-- Backfill existing tickets with ticket numbers based on their id
UPDATE tickets SET ticket_number = CONCAT('UMP-TKQ-', LPAD(id::text, 4, '0')) WHERE ticket_number IS NULL AND parent_ticket_id IS NULL;

UPDATE tickets t SET ticket_number = CONCAT(
  (SELECT ticket_number FROM tickets WHERE id = t.parent_ticket_id),
  '-SUB-',
  LPAD((SELECT COUNT(*) FROM tickets WHERE parent_ticket_id = t.parent_ticket_id AND id <= t.id)::text, 4, '0')
) WHERE ticket_number IS NULL AND parent_ticket_id IS NOT NULL;

-- Skip SETVAL if no masters exist (defaults to 1)
SELECT SETVAL('ticket_number_seq', GREATEST(COALESCE((SELECT MAX(CAST(SPLIT_PART(ticket_number, '-', 3) AS INTEGER)) FROM tickets WHERE parent_ticket_id IS NULL AND ticket_number ~ '^UMP-TKQ-\d{4}$'), 0), 1));
