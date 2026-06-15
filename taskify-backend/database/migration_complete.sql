-- ============================================================
--  Complete Migration — ALL changes since original schema.sql
--  Idempotent — safe to run multiple times on any state
-- ============================================================
BEGIN;

-- ── 1. New columns on users ─────────────────────────────────
ALTER TABLE users ADD COLUMN IF NOT EXISTS code VARCHAR(20);
ALTER TABLE users ADD COLUMN IF NOT EXISTS must_reset_password BOOLEAN DEFAULT FALSE;
ALTER TABLE users ADD COLUMN IF NOT EXISTS reset_token VARCHAR(10);
ALTER TABLE users ADD COLUMN IF NOT EXISTS reset_token_expires TIMESTAMPTZ;
ALTER TABLE users ADD COLUMN IF NOT EXISTS reports_to INT REFERENCES users(id);
ALTER TABLE users ADD COLUMN IF NOT EXISTS designation VARCHAR(200);

-- ── 2. New columns on tickets ───────────────────────────────
ALTER TABLE tickets ADD COLUMN IF NOT EXISTS ticket_number VARCHAR(50);
ALTER TABLE tickets ADD COLUMN IF NOT EXISTS is_standard_ticket BOOLEAN DEFAULT FALSE;
ALTER TABLE tickets ADD COLUMN IF NOT EXISTS is_multi_ticket BOOLEAN DEFAULT FALSE;
ALTER TABLE tickets ADD COLUMN IF NOT EXISTS closed_label TEXT;
ALTER TABLE tickets ADD COLUMN IF NOT EXISTS parent_ticket_id INT REFERENCES tickets(id);
ALTER TABLE tickets ADD COLUMN IF NOT EXISTS overall_progress INT DEFAULT 0;
ALTER TABLE tickets ADD COLUMN IF NOT EXISTS ticket_type VARCHAR(20) DEFAULT 'standard';

-- ── 3. ticket_number sequence ───────────────────────────────
CREATE SEQUENCE IF NOT EXISTS ticket_number_seq START 1;

-- ── 4. Developer role (id=3) ─────────────────────────────────
INSERT INTO roles (id, name) VALUES (3, 'developer') ON CONFLICT (id) DO NOTHING;

-- ── 5. Developer department ─────────────────────────────────
INSERT INTO departments (id, name, code, company_id, parent_id, tier)
VALUES (100, 'Developer', 'DEV', 0, NULL, 'upper')
ON CONFLICT (id) DO NOTHING;

-- ── 6. All 46 real departments ───────────────────────────────
INSERT INTO departments (id, name, code, company_id, parent_id, tier) VALUES
  (50, 'Administration [Combine Staff]',  'ADM_CS',  0, NULL, 'lower'),
  (51, 'Product Management [DXDX]',       'PM_DXDX',  0, NULL, 'lower'),
  (52, 'SMD [DXDX]',                      'SMD_DXDX', 0, NULL, 'lower'),
  (53, 'Supply Chain [DXDX]',             'SC_DXDX',  0, NULL, 'lower'),
  (54, 'Sales [DXDX]',                    'SAL_DXDX', 0, NULL, 'lower'),
  (55, 'Cash Management [FDFD]',          'CM_FDFD',  0, NULL, 'lower'),
  (56, 'Imports [FDFD]',                  'IMP_FDFD', 0, NULL, 'lower'),
  (57, 'Indenting [FDFD]',                'IND_FDFD', 0, NULL, 'lower'),
  (58, 'Marketing Support [FDFD]',        'MS_FDFD',  0, NULL, 'lower'),
  (59, 'Procurement [FDFD]',              'PRO_FDFD', 0, NULL, 'lower'),
  (60, 'SMD [FDFD]',                      'SMD_FDFD', 0, NULL, 'lower'),
  (61, 'Supply Chain [FDFD]',             'SC_FDFD',  0, NULL, 'lower'),
  (62, 'Warehouse [FDFD]',                'WH_FDFD',  0, NULL, 'lower'),
  (63, 'Marketing [FMAG]',                'MKT_FMAG', 0, NULL, 'lower'),
  (64, 'Sales and Distribution [FMAG]',   'SD_FMAG',  0, NULL, 'lower'),
  (65, 'Marketing [FMCG]',                'MKT_FMCG', 0, NULL, 'lower'),
  (66, 'Marketing Support [FMCG]',        'MS_FMCG',  0, NULL, 'lower'),
  (67, 'Sales and Distribution [FMCG]',   'SD_FMCG',  0, NULL, 'lower'),
  (68, 'Warehouse [FMCG]',                'WH_FMCG',  0, NULL, 'lower'),
  (69, 'Marketing [FMPG]',                'MKT_FMPG', 0, NULL, 'lower'),
  (70, 'Sales and Distribution [FMPG]',   'SD_FMPG',  0, NULL, 'lower'),
  (71, 'Vaccination Services [FMPG]',     'VAC_FMPG', 0, NULL, 'lower'),
  (72, 'Marketing [FMSG]',                'MKT_FMSG', 0, NULL, 'lower'),
  (73, 'Sales and Distribution [FMSG]',   'SD_FMSG',  0, NULL, 'lower'),
  (74, 'Accounts and Finance [HOCM]',     'AF_HOCM',  0, NULL, 'lower'),
  (75, 'Administration [HOCM]',           'ADM_HOCM', 0, NULL, 'lower'),
  (76, 'Compliance and Govt Affairs [HOCM]', 'CGA_HOCM', 0, NULL, 'lower'),
  (77, 'Human Resources [HOCM]',          'HR_HOCM',  0, NULL, 'lower'),
  (78, 'Imports [HOCM]',                  'IMP_HOCM', 0, NULL, 'lower'),
  (79, 'Information Technology [HOCM]',   'IT_HOCM',  0, NULL, 'lower'),
  (80, 'Planning [HOCM]',                 'PLN_HOCM', 0, NULL, 'lower'),
  (81, 'Procurement [HOCM]',              'PRO_HOCM', 0, NULL, 'lower'),
  (82, 'Production [HOCM]',               'PRD_HOCM', 0, NULL, 'lower'),
  (83, 'QA and Regulatory Affairs [HOCM]','QA_HOCM',  0, NULL, 'lower'),
  (84, 'R and D [HOCM]',                  'RD_HOCM',  0, NULL, 'lower'),
  (85, 'Secretarial [HOCM]',              'SEC_HOCM', 0, NULL, 'lower'),
  (86, 'Warehouse [HOCM]',                'WH_HOCM',  0, NULL, 'lower'),
  (87, 'Administration [HOCM Daily Wager]','ADM_HOCMDW', 0, NULL, 'lower'),
  (88, 'Production [HOCM Daily Wager]',   'PRD_HOCMDW', 0, NULL, 'lower'),
  (89, 'Warehouse [HOCM Daily Wager]',    'WH_HOCMDW', 0, NULL, 'lower'),
  (90, 'SMD [LAFM]',                      'SMD_LAFM', 0, NULL, 'lower'),
  (91, 'Warehouse [LAFM]',                'WH_LAFM',  0, NULL, 'lower'),
  (92, 'Product Management [LARA]',       'PM_LARA',  0, NULL, 'lower'),
  (93, 'SMD [LARA]',                      'SMD_LARA', 0, NULL, 'lower'),
  (94, 'Warehouse [LARA]',                'WH_LARA',  0, NULL, 'lower'),
  (95, 'SMD [LBFM]',                      'SMD_LBFM', 0, NULL, 'lower')
ON CONFLICT (id) DO NOTHING;

-- ── 7. Backfill ticket numbers for existing tickets ──────────
UPDATE tickets SET ticket_number = CONCAT('UMP-TKQ-', LPAD(id::text, 4, '0'))
WHERE ticket_number IS NULL AND parent_ticket_id IS NULL;

UPDATE tickets t SET ticket_number = CONCAT(
  (SELECT ticket_number FROM tickets WHERE id = t.parent_ticket_id),
  '-SUB-',
  LPAD((SELECT COUNT(*) FROM tickets WHERE parent_ticket_id = t.parent_ticket_id AND id <= t.id)::text, 4, '0')
) WHERE ticket_number IS NULL AND parent_ticket_id IS NOT NULL;

SELECT SETVAL('ticket_number_seq', GREATEST(COALESCE((SELECT MAX(CAST(SPLIT_PART(ticket_number, '-', 3) AS INTEGER)) FROM tickets WHERE parent_ticket_id IS NULL AND ticket_number ~ '^UMP-TKQ-\d{4}$'), 0), 1));

COMMIT;
