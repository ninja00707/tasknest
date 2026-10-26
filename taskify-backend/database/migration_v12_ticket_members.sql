-- Migration v12: Trello-style members on a task (project module)
-- One task can have many team members (instead of a single assignee).

CREATE TABLE IF NOT EXISTS ticket_members (
  id          SERIAL PRIMARY KEY,
  ticket_id   INT NOT NULL REFERENCES tickets(id) ON DELETE CASCADE,
  user_id     INT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  added_by_id INT REFERENCES users(id),
  created_at  TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(ticket_id, user_id)
);

CREATE INDEX IF NOT EXISTS idx_ticket_members_ticket ON ticket_members(ticket_id);
CREATE INDEX IF NOT EXISTS idx_ticket_members_user ON ticket_members(user_id);

-- Run: node database/run_migration.js database/migration_v12_ticket_members.sql
