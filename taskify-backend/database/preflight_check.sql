-- ── Pre-deploy schema preflight (READ-ONLY) ────────────────────────────────
-- Answers: "which migrations are still missing on this database?"
-- Safe to run on a live database: no writes, no locks beyond catalog reads.
--
-- Run:  psql "$DATABASE_URL" -f database/preflight_check.sql
--  or:  node database/check_schema.js
--
-- MISSING rows tell you which migration file to apply (see run_migration.js).
-- ───────────────────────────────────────────────────────────────────────────

WITH expected_tables(tbl, needed_by) AS (
  VALUES
    ('companies',              'schema.sql'),
    ('departments',            'schema.sql'),
    ('roles',                  'schema.sql'),
    ('users',                  'schema.sql'),
    ('tickets',                'schema.sql'),
    ('sub_ticket_departments', 'schema.sql'),
    ('ticket_comments',        'schema.sql'),
    ('ticket_logs',            'schema.sql'),
    ('notifications',          'schema.sql'),
    ('event_outbox',           'migration_v7_outbox.sql'),
    ('ticket_disputes',        'migration_v8_disputes.sql'),
    ('dispute_activities',     'migration_v8_disputes.sql'),
    ('projects',               'migration_v10_projects.sql'),
    ('project_departments',    'migration_v10_projects.sql'),
    ('project_members',        'migration_v10_projects.sql'),
    ('project_observers',      'migration_v10_projects.sql'),
    ('project_tasks',          'migration_v10_projects.sql'),
    ('project_task_comments',  'migration_v10_projects.sql'),
    ('project_task_logs',      'migration_v10_projects.sql'),
    ('ticket_members',         'migration_v12_ticket_members.sql')
),
expected_columns(tbl, col, needed_by) AS (
  VALUES
    -- users
    ('users', 'code',                'migration_v5_must_reset_password.sql'),
    ('users', 'reset_token',         'migration_v4_reset_token.sql'),
    ('users', 'reset_token_expires', 'migration_v4_reset_token.sql'),
    ('users', 'must_reset_password', 'migration_v5_must_reset_password.sql'),
    ('users', 'last_active',         'migration_v9_server_catchup.sql'),
    ('users', 'reports_to',          'migration_v9_server_catchup.sql'),
    ('users', 'designation',         'migration_v9_server_catchup.sql'),
    ('users', 'see_all_companies',   'migration_v9_server_catchup.sql'),
    -- tickets
    ('tickets', 'ticket_number',     'migration_v3_ticket_number.sql'),
    ('tickets', 'version',           'migration_v7_outbox.sql'),
    ('tickets', 'project_id',        'migration_v11_project_tickets.sql'),
    ('tickets', 'archived_at',       'migration_v13_ticket_archived.sql'),
    ('tickets', 'is_sub_ticket',     'schema.sql'),
    ('tickets', 'parent_ticket_id',  'schema.sql'),
    ('tickets', 'ticket_type',       'schema.sql'),
    ('tickets', 'overall_progress',  'schema.sql'),
    ('tickets', 'assigned_to_id',    'schema.sql'),
    ('tickets', 'due_date',          'schema.sql'),
    ('tickets', 'closed_at',         'schema.sql'),
    ('tickets', 'reopen_count',      'schema.sql'),
    -- sub tickets
    ('sub_ticket_departments', 'version', 'migration_v7_outbox.sql'),
    -- project tasks
    ('project_tasks', 'version',          'migration_v10_projects.sql'),
    ('project_tasks', 'assigned_dept_id', 'migration_v10_projects.sql'),
    ('project_tasks', 'progress',         'migration_v10_projects.sql'),
    ('project_tasks', 'due_date',         'migration_v10_projects.sql'),
    -- project task logs (last-mover / timeline feature)
    ('project_task_logs', 'action',    'migration_v10_projects.sql'),
    ('project_task_logs', 'old_value', 'migration_v10_projects.sql'),
    ('project_task_logs', 'new_value', 'migration_v10_projects.sql'),
    ('project_task_logs', 'note',      'migration_v10_projects.sql')
),
expected_sequences(seq, needed_by) AS (
  VALUES
    ('ticket_number_seq', 'migration_v3_ticket_number.sql'),
    ('task_number_seq',   'migration_v14_task_number_sequence_only.sql')
),
expected_indexes(idx, needed_by) AS (
  VALUES
    ('idx_event_outbox_unprocessed', 'migration_v7_outbox.sql'),
    ('idx_ticket_disputes_ticket',   'migration_v8_disputes.sql'),
    ('idx_proj_logs_task',           'migration_v10_projects.sql'),
    ('idx_tickets_project_id',       'migration_v11_project_tickets.sql'),
    ('idx_ticket_members_ticket',    'migration_v12_ticket_members.sql'),
    ('idx_tickets_archived',         'migration_v13_ticket_archived.sql')
)
SELECT * FROM (
  SELECT 'table' AS kind, tbl AS object_name, needed_by,
         CASE WHEN to_regclass('public.' || tbl) IS NULL THEN 'MISSING' ELSE 'OK' END AS status
  FROM expected_tables
  UNION ALL
  SELECT 'column', tbl || '.' || col, needed_by,
         CASE WHEN EXISTS (
           SELECT 1 FROM information_schema.columns c
           WHERE c.table_schema = 'public' AND c.table_name = tbl AND c.column_name = col
         ) THEN 'OK' ELSE 'MISSING' END
  FROM expected_columns
  UNION ALL
  SELECT 'sequence', seq, needed_by,
         CASE WHEN to_regclass('public.' || seq) IS NULL THEN 'MISSING' ELSE 'OK' END
  FROM expected_sequences
  UNION ALL
  SELECT 'index', idx, needed_by,
         CASE WHEN to_regclass('public.' || idx) IS NULL THEN 'MISSING' ELSE 'OK' END
  FROM expected_indexes
) checks
ORDER BY (status = 'MISSING') DESC, needed_by, kind, object_name;
