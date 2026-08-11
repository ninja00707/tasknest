-- ── Link tickets to projects ────────────────────────────────────
ALTER TABLE tickets
  ADD COLUMN IF NOT EXISTS project_id INT REFERENCES projects(id) ON DELETE SET NULL;

CREATE INDEX IF NOT EXISTS idx_tickets_project_id ON tickets(project_id);
