-- ============================================================
--  Full Data Reset — Departments + Qasim + 15 Dummy Tickets
--  Run AFTER schema.sql (keeps companies, roles intact)
-- ============================================================
BEGIN;

-- ── Add columns if missing (from migration_complete) ──────────
ALTER TABLE users ADD COLUMN IF NOT EXISTS code VARCHAR(20);
ALTER TABLE users ADD COLUMN IF NOT EXISTS must_reset_password BOOLEAN DEFAULT FALSE;
ALTER TABLE users ADD COLUMN IF NOT EXISTS reset_token VARCHAR(10);
ALTER TABLE users ADD COLUMN IF NOT EXISTS reset_token_expires TIMESTAMPTZ;
ALTER TABLE users ADD COLUMN IF NOT EXISTS reports_to INT REFERENCES users(id);
ALTER TABLE users ADD COLUMN IF NOT EXISTS designation VARCHAR(200);

ALTER TABLE tickets ADD COLUMN IF NOT EXISTS ticket_number VARCHAR(50);
ALTER TABLE tickets ADD COLUMN IF NOT EXISTS is_standard_ticket BOOLEAN DEFAULT FALSE;
ALTER TABLE tickets ADD COLUMN IF NOT EXISTS is_multi_ticket BOOLEAN DEFAULT FALSE;
ALTER TABLE tickets ADD COLUMN IF NOT EXISTS closed_label TEXT;
ALTER TABLE tickets ADD COLUMN IF NOT EXISTS parent_ticket_id INT REFERENCES tickets(id);
ALTER TABLE tickets ADD COLUMN IF NOT EXISTS overall_progress INT DEFAULT 0;
ALTER TABLE tickets ADD COLUMN IF NOT EXISTS ticket_type VARCHAR(20) DEFAULT 'standard';

CREATE SEQUENCE IF NOT EXISTS ticket_number_seq START 1;

ALTER TABLE departments ADD COLUMN IF NOT EXISTS is_shared BOOLEAN DEFAULT FALSE;

INSERT INTO roles (id, name) VALUES (3, 'developer') ON CONFLICT (id) DO NOTHING;

-- ── All 47 UM departments (from migration_complete) ───────────
INSERT INTO departments (id, name, code, company_id, parent_id, tier, is_shared) VALUES
  (50, 'Administration [Combine Staff]',  'ADM_CS',  0, NULL, 'lower', TRUE),
  (51, 'Product Management [DXDX]',       'PM_DXDX',  0, NULL, 'lower', FALSE),
  (52, 'SMD [DXDX]',                      'SMD_DXDX', 0, NULL, 'lower', FALSE),
  (53, 'Supply Chain [DXDX]',             'SC_DXDX',  0, NULL, 'lower', FALSE),
  (54, 'Sales [DXDX]',                    'SAL_DXDX', 0, NULL, 'lower', FALSE),
  (55, 'Cash Management [FDFD]',          'CM_FDFD',  0, NULL, 'lower', FALSE),
  (56, 'Imports [FDFD]',                  'IMP_FDFD', 0, NULL, 'lower', FALSE),
  (57, 'Indenting [FDFD]',                'IND_FDFD', 0, NULL, 'lower', FALSE),
  (58, 'Marketing Support [FDFD]',        'MS_FDFD',  0, NULL, 'lower', FALSE),
  (59, 'Procurement [FDFD]',              'PRO_FDFD', 0, NULL, 'lower', FALSE),
  (60, 'SMD [FDFD]',                      'SMD_FDFD', 0, NULL, 'lower', FALSE),
  (61, 'Supply Chain [FDFD]',             'SC_FDFD',  0, NULL, 'lower', FALSE),
  (62, 'Warehouse [FDFD]',                'WH_FDFD',  0, NULL, 'lower', FALSE),
  (63, 'Marketing [FMAG]',                'MKT_FMAG', 0, NULL, 'lower', FALSE),
  (64, 'Sales and Distribution [FMAG]',   'SD_FMAG',  0, NULL, 'lower', FALSE),
  (65, 'Marketing [FMCG]',                'MKT_FMCG', 0, NULL, 'lower', FALSE),
  (66, 'Marketing Support [FMCG]',        'MS_FMCG',  0, NULL, 'lower', FALSE),
  (67, 'Sales and Distribution [FMCG]',   'SD_FMCG',  0, NULL, 'lower', FALSE),
  (68, 'Warehouse [FMCG]',                'WH_FMCG',  0, NULL, 'lower', FALSE),
  (69, 'Marketing [FMPG]',                'MKT_FMPG', 0, NULL, 'lower', FALSE),
  (70, 'Sales and Distribution [FMPG]',   'SD_FMPG',  0, NULL, 'lower', FALSE),
  (71, 'Vaccination Services [FMPG]',     'VAC_FMPG', 0, NULL, 'lower', FALSE),
  (72, 'Marketing [FMSG]',                'MKT_FMSG', 0, NULL, 'lower', FALSE),
  (73, 'Sales and Distribution [FMSG]',   'SD_FMSG',  0, NULL, 'lower', FALSE),
  (74, 'Accounts and Finance [HOCM]',     'AF_HOCM',  0, NULL, 'lower', FALSE),
  (75, 'Administration [HOCM]',           'ADM_HOCM', 0, NULL, 'lower', FALSE),
  (76, 'Compliance and Govt Affairs [HOCM]', 'CGA_HOCM', 0, NULL, 'lower', FALSE),
  (77, 'Human Resources [HOCM]',          'HR_HOCM',  0, NULL, 'lower', FALSE),
  (78, 'Imports [HOCM]',                  'IMP_HOCM', 0, NULL, 'lower', FALSE),
  (79, 'Information Technology [HOCM]',   'IT_HOCM',  0, NULL, 'lower', TRUE),
  (80, 'Planning [HOCM]',                 'PLN_HOCM', 0, NULL, 'lower', FALSE),
  (81, 'Procurement [HOCM]',              'PRO_HOCM', 0, NULL, 'lower', FALSE),
  (82, 'Production [HOCM]',               'PRD_HOCM', 0, NULL, 'lower', FALSE),
  (83, 'QA and Regulatory Affairs [HOCM]','QA_HOCM',  0, NULL, 'lower', FALSE),
  (84, 'R and D [HOCM]',                  'RD_HOCM',  0, NULL, 'lower', FALSE),
  (85, 'Secretarial [HOCM]',              'SEC_HOCM', 0, NULL, 'lower', FALSE),
  (86, 'Warehouse [HOCM]',                'WH_HOCM',  0, NULL, 'lower', FALSE),
  (87, 'Administration [HOCM Daily Wager]','ADM_HOCMDW', 0, NULL, 'lower', FALSE),
  (88, 'Production [HOCM Daily Wager]',   'PRD_HOCMDW', 0, NULL, 'lower', FALSE),
  (89, 'Warehouse [HOCM Daily Wager]',    'WH_HOCMDW', 0, NULL, 'lower', FALSE),
  (90, 'SMD [LAFM]',                      'SMD_LAFM', 0, NULL, 'lower', FALSE),
  (91, 'Warehouse [LAFM]',                'WH_LAFM',  0, NULL, 'lower', FALSE),
  (92, 'Product Management [LARA]',       'PM_LARA',  0, NULL, 'lower', FALSE),
  (93, 'SMD [LARA]',                      'SMD_LARA', 0, NULL, 'lower', FALSE),
  (94, 'Warehouse [LARA]',                'WH_LARA',  0, NULL, 'lower', FALSE),
  (95, 'SMD [LBFM]',                      'SMD_LBFM', 0, NULL, 'lower', FALSE),
  (100,'Developer',                       'DEV',      0, NULL, 'upper', FALSE)
ON CONFLICT (id) DO NOTHING;

-- ── Qasim (developer) ─────────────────────────────────────────
INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Qasim', 'qasim@um.com', 'ADMIN001', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 3, 100, 0, TRUE, FALSE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'qasim@um.com');

-- ── Dummy tickets ─────────────────────────────────────────────
DO $$
DECLARE
    q_id INT;
    existing INT;
BEGIN
    SELECT COUNT(*) INTO existing FROM tickets;
    IF existing > 0 THEN RETURN; END IF;

    SELECT id INTO q_id FROM users WHERE email = 'qasim@um.com';

    INSERT INTO tickets (ticket_number, title, description, status, priority, created_by_id, assigned_dept_id, created_by_dept, created_at, updated_at)
    VALUES ('UMP-TKQ-001', 'Server backup failed', 'The nightly backup for the main server failed with error code 0x80070005. Need immediate investigation.', 'open', 'urgent', q_id, 79, 100, NOW() - INTERVAL '5 days', NOW() - INTERVAL '5 days');

    INSERT INTO tickets (ticket_number, title, description, status, priority, created_by_id, assigned_dept_id, created_by_dept, created_at, updated_at)
    VALUES ('UMP-TKQ-002', 'New employee onboarding kit', 'Please arrange onboarding kit for 5 new hires joining next Monday. Includes laptop, badge, stationery.', 'in_progress', 'high', q_id, 77, 100, NOW() - INTERVAL '4 days', NOW() - INTERVAL '3 days');

    INSERT INTO tickets (ticket_number, title, description, status, priority, created_by_id, assigned_dept_id, created_by_dept, created_at, updated_at)
    VALUES ('UMP-TKQ-003', 'Q3 budget variance report', 'Need the Q3 budget vs actual variance report for the board meeting on Friday.', 'open', 'high', q_id, 74, 100, NOW() - INTERVAL '3 days', NOW() - INTERVAL '3 days');

    INSERT INTO tickets (ticket_number, title, description, status, priority, created_by_id, assigned_dept_id, created_by_dept, created_at, updated_at)
    VALUES ('UMP-TKQ-004', 'Office AC maintenance', 'The central AC on floor 3 is making noise and not cooling properly.', 'completed', 'medium', q_id, 50, 100, NOW() - INTERVAL '7 days', NOW() - INTERVAL '2 days');

    INSERT INTO tickets (ticket_number, title, description, status, priority, created_by_id, assigned_dept_id, created_by_dept, created_at, updated_at)
    VALUES ('UMP-TKQ-005', 'Drug license renewal', 'The drug manufacturing license expires next month. Submit renewal application before deadline.', 'open', 'urgent', q_id, 76, 100, NOW() - INTERVAL '2 days', NOW() - INTERVAL '2 days');

    INSERT INTO tickets (ticket_number, title, description, status, priority, created_by_id, assigned_dept_id, created_by_dept, created_at, updated_at)
    VALUES ('UMP-TKQ-006', 'Raw material purchase request', 'Need to procure 500kg of paracetamol powder from approved vendor. Urgent for next production cycle.', 'in_progress', 'urgent', q_id, 81, 100, NOW() - INTERVAL '6 days', NOW() - INTERVAL '4 days');

    INSERT INTO tickets (ticket_number, title, description, status, priority, created_by_id, assigned_dept_id, created_by_dept, created_at, updated_at)
    VALUES ('UMP-TKQ-007', 'Email server migration completed', 'Email server migration to new hosting is complete. All accounts transferred successfully.', 'closed', 'medium', q_id, 79, 100, NOW() - INTERVAL '10 days', NOW() - INTERVAL '8 days');

    INSERT INTO tickets (ticket_number, title, description, status, priority, created_by_id, assigned_dept_id, created_by_dept, created_at, updated_at)
    VALUES ('UMP-TKQ-008', 'Batch 2435 quality check pending', 'Batch 2435 of paracetamol 500mg is pending final quality check before release.', 'open', 'high', q_id, 82, 100, NOW() - INTERVAL '1 day', NOW() - INTERVAL '1 day');

    INSERT INTO tickets (ticket_number, title, description, status, priority, created_by_id, assigned_dept_id, created_by_dept, created_at, updated_at)
    VALUES ('UMP-TKQ-009', 'FDA audit preparation', 'FDA audit scheduled for next month. Need all documentation ready including batch records, SOPs, and validation reports.', 'in_progress', 'urgent', q_id, 83, 100, NOW() - INTERVAL '8 days', NOW() - INTERVAL '5 days');

    INSERT INTO tickets (ticket_number, title, description, status, priority, created_by_id, assigned_dept_id, created_by_dept, created_at, updated_at)
    VALUES ('UMP-TKQ-010', 'Security guard shift schedule', 'New security guard shift schedule for October has been prepared and approved.', 'completed', 'low', q_id, 50, 100, NOW() - INTERVAL '4 days', NOW() - INTERVAL '1 day');

    INSERT INTO tickets (ticket_number, title, description, status, priority, created_by_id, assigned_dept_id, created_by_dept, created_at, updated_at)
    VALUES ('UMP-TKQ-011', 'Inventory discrepancy in Zone B', 'Physical count shows 50 units less than system record for product code PARA-500. Investigate.', 'open', 'high', q_id, 86, 100, NOW() - INTERVAL '12 hours', NOW() - INTERVAL '12 hours');

    INSERT INTO tickets (ticket_number, title, description, status, priority, created_by_id, assigned_dept_id, created_by_dept, created_at, updated_at)
    VALUES ('UMP-TKQ-012', 'New formulation stability study', 'Stability study for new paracetamol+ibuprofen combo formulation needs to start this week.', 'in_progress', 'medium', q_id, 84, 100, NOW() - INTERVAL '3 days', NOW() - INTERVAL '2 days');

    INSERT INTO tickets (ticket_number, title, description, status, priority, created_by_id, assigned_dept_id, created_by_dept, created_at, updated_at)
    VALUES ('UMP-TKQ-013', 'Production schedule for October', 'Need the production schedule for October based on sales forecast.', 'open', 'high', q_id, 80, 100, NOW() - INTERVAL '2 days', NOW() - INTERVAL '2 days');

    INSERT INTO tickets (ticket_number, title, description, status, priority, created_by_id, assigned_dept_id, created_by_dept, created_at, updated_at)
    VALUES ('UMP-TKQ-014', 'Customs clearance for shipment IMP-2024-09', 'Shipment containing raw materials held at customs. Documentation cleared.', 'completed', 'urgent', q_id, 78, 100, NOW() - INTERVAL '5 days', NOW() - INTERVAL '3 days');

    INSERT INTO tickets (ticket_number, title, description, status, priority, created_by_id, assigned_dept_id, created_by_dept, created_at, updated_at)
    VALUES ('UMP-TKQ-015', 'WiFi access point installation', 'New WiFi access points installed on floor 2 and 4. Coverage issues resolved.', 'closed', 'medium', q_id, 79, 100, NOW() - INTERVAL '6 days', NOW() - INTERVAL '4 days');

    -- Ticket logs
    INSERT INTO ticket_logs (ticket_id, acted_by_id, action, old_value, new_value, created_at)
    SELECT id, q_id, 'created', NULL, 'open', created_at FROM tickets;

    INSERT INTO ticket_logs (ticket_id, acted_by_id, action, old_value, new_value, created_at)
    SELECT id, q_id, 'status_changed', NULL,
        CASE priority WHEN 'urgent' THEN 'Urgent' WHEN 'high' THEN 'High' WHEN 'medium' THEN 'Medium' ELSE 'Low' END,
        created_at + INTERVAL '1 hour'
    FROM tickets;

    -- Sync sequence past 15
    PERFORM setval('ticket_number_seq', 16, false);
END $$;

COMMIT;
