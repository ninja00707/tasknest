-- ============================================================
--  DB Reset + Dummy Tickets for Remote Server
--  Keeps: qasim@um.com, departments, roles, companies
--  Deletes: all other users, all tickets and related data
-- ============================================================
BEGIN;

-- 0. Add is_shared column (needed by new backend filtering)
ALTER TABLE departments ADD COLUMN IF NOT EXISTS is_shared BOOLEAN DEFAULT FALSE;

-- Mark Administration [Combine Staff] (50) and IT [HOCM] (79) as shared between companies
UPDATE departments SET is_shared = TRUE WHERE id IN (50, 79);

-- 1. Clear dependent tables (skip any that don't exist)
DO $$
DECLARE
    tbl TEXT;
BEGIN
    FOREACH tbl IN ARRAY ARRAY[
        'notifications','sub_ticket_departments','ticket_comments',
        'ticket_logs','ticket_departments','tickets'
    ]
    LOOP
        IF EXISTS (SELECT 1 FROM information_schema.tables
                   WHERE table_schema='public' AND table_name=tbl) THEN
            EXECUTE format('DELETE FROM %I', tbl);
        END IF;
    END LOOP;
END $$;

-- 2. Delete all users except qasim@um.com
DELETE FROM users WHERE email != 'qasim@um.com';

-- 3. Reset ticket sequence
SELECT setval('ticket_number_seq', 1, false);

-- 4. Create dummy tickets (skip if tickets already exist)
DO $$
DECLARE
    q_id INT;
    seq INT;
    tn TEXT;
    existing INT;
BEGIN
    SELECT COUNT(*) INTO existing FROM tickets;
    IF existing > 0 THEN
        RETURN;
    END IF;

    SELECT id INTO q_id FROM users WHERE email = 'qasim@um.com';

    -- Helper: get next sequence and format as UMP-TKQ-XXX
    seq := nextval('ticket_number_seq');
    tn := 'UMP-TKQ-' || LPAD(seq::text, 3, '0');

    -- Ticket 1: Open - IT issue (dept 79)
    INSERT INTO tickets (ticket_number, title, description, status, priority, created_by_id, assigned_dept_id, created_by_dept, created_at, updated_at)
    VALUES (tn, 'Server backup failed', 'The nightly backup for the main server failed with error code 0x80070005. Need immediate investigation.', 'open', 'urgent', q_id, 79, 100, NOW() - INTERVAL '5 days', NOW() - INTERVAL '5 days');

    seq := nextval('ticket_number_seq');
    tn := 'UMP-TKQ-' || LPAD(seq::text, 3, '0');
    -- Ticket 2: In Progress - HR request (dept 77)
    INSERT INTO tickets (ticket_number, title, description, status, priority, created_by_id, assigned_dept_id, created_by_dept, created_at, updated_at)
    VALUES (tn, 'New employee onboarding kit', 'Please arrange onboarding kit for 5 new hires joining next Monday. Includes laptop, badge, stationery.', 'in_progress', 'high', q_id, 77, 100, NOW() - INTERVAL '4 days', NOW() - INTERVAL '3 days');

    seq := nextval('ticket_number_seq');
    tn := 'UMP-TKQ-' || LPAD(seq::text, 3, '0');
    -- Ticket 3: Open - Finance (dept 74)
    INSERT INTO tickets (ticket_number, title, description, status, priority, created_by_id, assigned_dept_id, created_by_dept, created_at, updated_at)
    VALUES (tn, 'Q3 budget variance report', 'Need the Q3 budget vs actual variance report for the board meeting on Friday.', 'open', 'high', q_id, 74, 100, NOW() - INTERVAL '3 days', NOW() - INTERVAL '3 days');

    seq := nextval('ticket_number_seq');
    tn := 'UMP-TKQ-' || LPAD(seq::text, 3, '0');
    -- Ticket 4: completed - Administration [Combine Staff] (dept 50)
    INSERT INTO tickets (ticket_number, title, description, status, priority, created_by_id, assigned_dept_id, created_by_dept, created_at, updated_at)
    VALUES (tn, 'Office AC maintenance', 'The central AC on floor 3 is making noise and not cooling properly. Please schedule maintenance.', 'completed', 'medium', q_id, 50, 100, NOW() - INTERVAL '7 days', NOW() - INTERVAL '2 days');

    seq := nextval('ticket_number_seq');
    tn := 'UMP-TKQ-' || LPAD(seq::text, 3, '0');
    -- Ticket 5: Open - Compliance (dept 76)
    INSERT INTO tickets (ticket_number, title, description, status, priority, created_by_id, assigned_dept_id, created_by_dept, created_at, updated_at)
    VALUES (tn, 'Drug license renewal', 'The drug manufacturing license expires next month. Submit renewal application before deadline.', 'open', 'urgent', q_id, 76, 100, NOW() - INTERVAL '2 days', NOW() - INTERVAL '2 days');

    seq := nextval('ticket_number_seq');
    tn := 'UMP-TKQ-' || LPAD(seq::text, 3, '0');
    -- Ticket 6: In Progress - Procurement (dept 81)
    INSERT INTO tickets (ticket_number, title, description, status, priority, created_by_id, assigned_dept_id, created_by_dept, created_at, updated_at)
    VALUES (tn, 'Raw material purchase request', 'Need to procure 500kg of paracetamol powder from approved vendor. Urgent for next production cycle.', 'in_progress', 'urgent', q_id, 81, 100, NOW() - INTERVAL '6 days', NOW() - INTERVAL '4 days');

    seq := nextval('ticket_number_seq');
    tn := 'UMP-TKQ-' || LPAD(seq::text, 3, '0');
    -- Ticket 7: Closed - IT (dept 79)
    INSERT INTO tickets (ticket_number, title, description, status, priority, created_by_id, assigned_dept_id, created_by_dept, created_at, updated_at)
    VALUES (tn, 'Email server migration completed', 'Email server migration to new hosting is complete. All accounts have been transferred successfully.', 'closed', 'medium', q_id, 79, 100, NOW() - INTERVAL '10 days', NOW() - INTERVAL '8 days');

    seq := nextval('ticket_number_seq');
    tn := 'UMP-TKQ-' || LPAD(seq::text, 3, '0');
    -- Ticket 8: Open - Production (dept 82)
    INSERT INTO tickets (ticket_number, title, description, status, priority, created_by_id, assigned_dept_id, created_by_dept, created_at, updated_at)
    VALUES (tn, 'Batch 2435 quality check pending', 'Batch 2435 of paracetamol 500mg is pending final quality check before release to warehouse.', 'open', 'high', q_id, 82, 100, NOW() - INTERVAL '1 day', NOW() - INTERVAL '1 day');

    seq := nextval('ticket_number_seq');
    tn := 'UMP-TKQ-' || LPAD(seq::text, 3, '0');
    -- Ticket 9: In Progress - QA/Regulatory (dept 83)
    INSERT INTO tickets (ticket_number, title, description, status, priority, created_by_id, assigned_dept_id, created_by_dept, created_at, updated_at)
    VALUES (tn, 'FDA audit preparation', 'FDA audit scheduled for next month. Need all documentation ready including batch records, SOPs, and validation reports.', 'in_progress', 'urgent', q_id, 83, 100, NOW() - INTERVAL '8 days', NOW() - INTERVAL '5 days');

    seq := nextval('ticket_number_seq');
    tn := 'UMP-TKQ-' || LPAD(seq::text, 3, '0');
    -- Ticket 10: completed - Administration [Combine Staff] (dept 50)
    INSERT INTO tickets (ticket_number, title, description, status, priority, created_by_id, assigned_dept_id, created_by_dept, created_at, updated_at)
    VALUES (tn, 'Security guard shift schedule', 'New security guard shift schedule for October has been prepared and approved.', 'completed', 'low', q_id, 50, 100, NOW() - INTERVAL '4 days', NOW() - INTERVAL '1 day');

    seq := nextval('ticket_number_seq');
    tn := 'UMP-TKQ-' || LPAD(seq::text, 3, '0');
    -- Ticket 11: Open - Warehouse (dept 86)
    INSERT INTO tickets (ticket_number, title, description, status, priority, created_by_id, assigned_dept_id, created_by_dept, created_at, updated_at)
    VALUES (tn, 'Inventory discrepancy in Zone B', 'Physical count shows 50 units less than system record for product code PARA-500. Investigate.', 'open', 'high', q_id, 86, 100, NOW() - INTERVAL '12 hours', NOW() - INTERVAL '12 hours');

    seq := nextval('ticket_number_seq');
    tn := 'UMP-TKQ-' || LPAD(seq::text, 3, '0');
    -- Ticket 12: In Progress - R&D (dept 84)
    INSERT INTO tickets (ticket_number, title, description, status, priority, created_by_id, assigned_dept_id, created_by_dept, created_at, updated_at)
    VALUES (tn, 'New formulation stability study', 'Stability study for new paracetamol+ibuprofen combo formulation needs to start this week.', 'in_progress', 'medium', q_id, 84, 100, NOW() - INTERVAL '3 days', NOW() - INTERVAL '2 days');

    seq := nextval('ticket_number_seq');
    tn := 'UMP-TKQ-' || LPAD(seq::text, 3, '0');
    -- Ticket 13: Open - Planning (dept 80)
    INSERT INTO tickets (ticket_number, title, description, status, priority, created_by_id, assigned_dept_id, created_by_dept, created_at, updated_at)
    VALUES (tn, 'Production schedule for October', 'Need the production schedule for October based on sales forecast. Deadline is end of this week.', 'open', 'high', q_id, 80, 100, NOW() - INTERVAL '2 days', NOW() - INTERVAL '2 days');

    seq := nextval('ticket_number_seq');
    tn := 'UMP-TKQ-' || LPAD(seq::text, 3, '0');
    -- Ticket 14: completed - Imports (dept 78)
    INSERT INTO tickets (ticket_number, title, description, status, priority, created_by_id, assigned_dept_id, created_by_dept, created_at, updated_at)
    VALUES (tn, 'Customs clearance for shipment IMP-2024-09', 'Shipment containing raw materials held at customs. Documentation submitted and cleared.', 'completed', 'urgent', q_id, 78, 100, NOW() - INTERVAL '5 days', NOW() - INTERVAL '3 days');

    seq := nextval('ticket_number_seq');
    tn := 'UMP-TKQ-' || LPAD(seq::text, 3, '0');
    -- Ticket 15: Closed - IT (dept 79)
    INSERT INTO tickets (ticket_number, title, description, status, priority, created_by_id, assigned_dept_id, created_by_dept, created_at, updated_at)
    VALUES (tn, 'WiFi access point installation', 'New WiFi access points installed on floor 2 and 4. Coverage issues should be resolved now.', 'closed', 'medium', q_id, 79, 100, NOW() - INTERVAL '6 days', NOW() - INTERVAL '4 days');

    -- Log entries for ticket activities
    INSERT INTO ticket_logs (ticket_id, acted_by_id, action, old_value, new_value, created_at)
    SELECT id, q_id, 'created', NULL, 'open', created_at FROM tickets;

    INSERT INTO ticket_logs (ticket_id, acted_by_id, action, old_value, new_value, created_at)
    SELECT id, q_id, 'status_changed', NULL,
        CASE priority
            WHEN 'urgent' THEN 'Urgent'
            WHEN 'high' THEN 'High'
            WHEN 'medium' THEN 'Medium'
            ELSE 'Low'
        END,
        created_at + INTERVAL '1 hour'
    FROM tickets;

END $$;

COMMIT;
