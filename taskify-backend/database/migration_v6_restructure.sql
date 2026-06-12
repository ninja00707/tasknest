-- ============================================================
--  Migration v6: Developer role + department restructure + full import
--  Adds developer role (above CEO), 46 real departments, 246 employees
-- ============================================================

BEGIN;

-- ── 1. Add developer role ────────────────────────────────────
INSERT INTO roles (id, name) VALUES (3, 'developer') ON CONFLICT DO NOTHING;

-- ── 2. Create Developer department for Qasim ─────────────────
INSERT INTO departments (id, name, code, company_id, parent_id, tier)
VALUES (100, 'Developer', 'DEV', 0, NULL, 'upper')
ON CONFLICT DO NOTHING;

-- ── 3. Create all 46 real departments (flat, [Group] suffix) ─
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

-- ── 4. Update Qasim to Developer ────────────────────────────
UPDATE users SET role_id = 3, department_id = 100
WHERE email = 'qasim@um.com';

COMMIT;
