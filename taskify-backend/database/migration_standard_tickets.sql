-- Standard Tickets: multi-department assignment + parent-child hierarchy

ALTER TABLE tickets
  ADD COLUMN IF NOT EXISTS parent_ticket_id INT REFERENCES tickets(id),
  ADD COLUMN IF NOT EXISTS is_standard_ticket BOOLEAN DEFAULT FALSE;

CREATE TABLE IF NOT EXISTS standard_ticket_departments (
  id                SERIAL PRIMARY KEY,
  ticket_id         INT           NOT NULL REFERENCES tickets(id) ON DELETE CASCADE,
  department_id     INT           NOT NULL REFERENCES departments(id),
  status            VARCHAR(20)   NOT NULL DEFAULT 'assigned'
                    CHECK (status IN ('assigned', 'in_progress', 'completed', 'closed')),
  created_at        TIMESTAMPTZ   DEFAULT NOW(),
  updated_at        TIMESTAMPTZ   DEFAULT NOW(),
  UNIQUE(ticket_id, department_id)
);

CREATE INDEX IF NOT EXISTS idx_tickets_parent ON tickets(parent_ticket_id);
CREATE INDEX IF NOT EXISTS idx_tickets_standard ON tickets(is_standard_ticket);
CREATE INDEX IF NOT EXISTS idx_std_ticket_dept_ticket ON standard_ticket_departments(ticket_id);
CREATE INDEX IF NOT EXISTS idx_std_ticket_dept_dept ON standard_ticket_departments(department_id);

DROP TRIGGER IF EXISTS standard_ticket_departments_updated_at ON standard_ticket_departments;
CREATE TRIGGER standard_ticket_departments_updated_at
  BEFORE UPDATE ON standard_ticket_departments
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();
