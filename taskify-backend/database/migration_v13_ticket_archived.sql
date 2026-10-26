-- Migration v13: Trello-style archiving for project tasks
-- Archived tasks disappear from the project board (soft delete).

ALTER TABLE tickets ADD COLUMN IF NOT EXISTS archived_at TIMESTAMPTZ;

CREATE INDEX IF NOT EXISTS idx_tickets_archived
  ON tickets(project_id) WHERE archived_at IS NOT NULL;

-- Run: node database/run_migration.js database/migration_v13_ticket_archived.sql
