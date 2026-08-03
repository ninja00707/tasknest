-- Phase: Ticket Disputes
-- Safe, additive migration. No existing columns touched.

-- 1. Dispute table (one active dispute per ticket)
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

-- 2. Dispute activity timeline
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
