-- V2 Ticket Flow: Recursive sub-ticket chains, Standard/Multi types

ALTER TABLE tickets
  ADD COLUMN IF NOT EXISTS is_multi_ticket BOOLEAN DEFAULT FALSE,
  ADD COLUMN IF NOT EXISTS closed_label TEXT;

-- ticket_departments tracks multi-department assignments (renamed from standard_ticket_departments)
ALTER TABLE standard_ticket_departments RENAME TO ticket_departments;
ALTER INDEX idx_std_ticket_dept_ticket RENAME TO idx_ticket_depts_ticket;
ALTER INDEX idx_std_ticket_dept_dept RENAME TO idx_ticket_depts_dept;
DROP TRIGGER IF EXISTS standard_ticket_departments_updated_at ON ticket_departments;
CREATE TRIGGER ticket_departments_updated_at
  BEFORE UPDATE ON ticket_departments
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();
