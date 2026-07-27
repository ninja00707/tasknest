const pool = require('../../database/db');

exports.getStats = async () => {
  const results = await Promise.all([
    pool.query('SELECT COUNT(*)::int AS total FROM users'),
    pool.query('SELECT COUNT(*)::int AS total FROM departments'),
    pool.query('SELECT COUNT(*)::int AS total FROM tickets'),
    pool.query(`SELECT COUNT(*)::int AS total FROM tickets WHERE status = 'open'`),
    pool.query(`SELECT COUNT(*)::int AS total FROM tickets WHERE status = 'in_progress'`),
    pool.query(`SELECT COUNT(*)::int AS total FROM tickets WHERE status = 'completed'`),
    pool.query(`SELECT COUNT(*)::int AS total FROM tickets WHERE status = 'closed'`),
    pool.query('SELECT COUNT(*)::int AS total FROM companies'),
    pool.query(`SELECT COUNT(*)::int AS total FROM tickets WHERE due_date < NOW() AND status NOT IN ('completed','closed')`),
    pool.query(`SELECT COUNT(*)::int AS total FROM tickets WHERE priority = 'urgent' AND status NOT IN ('completed','closed')`),
    pool.query(`SELECT COUNT(*)::int AS total FROM tickets WHERE is_sub_ticket = TRUE`),
    pool.query('SELECT COUNT(*)::int AS total FROM sub_ticket_departments'),
  ]);
  return {
    totalUsers: results[0].rows[0].total,
    totalDepartments: results[1].rows[0].total,
    totalTickets: results[2].rows[0].total,
    openTickets: results[3].rows[0].total,
    inProgressTickets: results[4].rows[0].total,
    completedTickets: results[5].rows[0].total,
    closedTickets: results[6].rows[0].total,
    totalCompanies: results[7].rows[0].total,
    overdueTickets: results[8].rows[0].total,
    urgentTickets: results[9].rows[0].total,
    subTicketCount: results[10].rows[0].total,
    totalSubTicketDepartments: results[11].rows[0].total,
  };
};

exports.findAllUsers = async () => {
  const result = await pool.query(
    `SELECT u.id, u.name, u.email, u.code, u.designation, u.role_id, u.department_id, u.company_id,
            u.is_active, u.created_at, u.reports_to, u.see_all_companies,
            r.name AS role_name,
            d.name AS department_name,
            d.code AS department_code,
            c.name AS company_name,
            reporter.name AS reports_to_name
     FROM users u
     JOIN roles r ON r.id = u.role_id
     LEFT JOIN departments d ON d.id = u.department_id
     LEFT JOIN companies c ON c.id = u.company_id
     LEFT JOIN users reporter ON reporter.id = u.reports_to
     ORDER BY u.created_at DESC`
  );
  return result.rows;
};

exports.findPendingUsers = async () => {
  const result = await pool.query(
    `SELECT u.id, u.name, u.email, u.code, u.designation, u.role_id, u.department_id, u.company_id,
            u.is_active, u.created_at, u.reports_to, u.see_all_companies,
            r.name AS role_name,
            d.name AS department_name,
            d.code AS department_code,
            c.name AS company_name,
            reporter.name AS reports_to_name
     FROM users u
     JOIN roles r ON r.id = u.role_id
     LEFT JOIN departments d ON d.id = u.department_id
     LEFT JOIN companies c ON c.id = u.company_id
     LEFT JOIN users reporter ON reporter.id = u.reports_to
     WHERE u.is_active = FALSE
     ORDER BY u.created_at DESC`
  );
  return result.rows;
};

exports.findUserById = async (id) => {
  const result = await pool.query(
    `SELECT u.*, r.name AS role_name
     FROM users u
     JOIN roles r ON r.id = u.role_id
     WHERE u.id = $1`,
    [id]
  );
  return result.rows[0] || null;
};

exports.findUserByEmail = async (email) => {
  const result = await pool.query('SELECT * FROM users WHERE email = $1', [email]);
  return result.rows[0] || null;
};

exports.createUser = async ({ name, email, code, designation, passwordHash, roleId, departmentId, companyId, reportsTo, seeAllCompanies }) => {
  const result = await pool.query(
    `INSERT INTO users (name, email, code, designation, password_hash, role_id, department_id, company_id, reports_to, see_all_companies)
     VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)
     RETURNING id, name, email, code, designation, role_id, department_id, company_id, is_active, created_at, reports_to, see_all_companies`,
    [name, email, code || null, designation || null, passwordHash, roleId ?? 2, departmentId ?? null, companyId ?? 0, reportsTo ?? null, seeAllCompanies ?? false]
  );
  return result.rows[0];
};

exports.updateUser = async (id, updates) => {
  const setClauses = [];
  const values = [];
  let idx = 1;
  for (const [col, val] of Object.entries(updates)) {
    setClauses.push(`${col} = $${idx}`);
    values.push(val);
    idx++;
  }
  values.push(id);
  const result = await pool.query(
    `UPDATE users SET ${setClauses.join(', ')} WHERE id = $${idx}
     RETURNING id, name, email, role_id, department_id, company_id, is_active, created_at`,
    values
  );
  return result.rows[0];
};

exports.deleteUser = async (id) => {
  await pool.query('UPDATE users SET is_active = FALSE WHERE id = $1', [id]);
};

exports.findAllDepartments = async () => {
  const result = await pool.query(
    `SELECT d.*, p.name AS parent_name, c.name AS company_name
     FROM departments d
     LEFT JOIN departments p ON p.id = d.parent_id
     LEFT JOIN companies c ON c.id = d.company_id
     ORDER BY d.id`
  );
  return result.rows;
};

exports.findDepartmentById = async (id) => {
  const result = await pool.query('SELECT * FROM departments WHERE id = $1', [id]);
  return result.rows[0] || null;
};

exports.createDepartment = async ({ name, code, companyId, tier, parentId, isShared }) => {
  const idResult = await pool.query('SELECT COALESCE(MAX(id), -1) + 1 AS next_id FROM departments');
  const nextId = idResult.rows[0].next_id;
  const result = await pool.query(
    `INSERT INTO departments (id, name, code, company_id, tier, parent_id, is_shared)
     VALUES ($1, $2, $3, $4, $5, $6, $7)
     RETURNING *`,
    [nextId, name, code, companyId, tier ?? 'upper', parentId ?? null, isShared ?? false]
  );
  return result.rows[0];
};

exports.updateDepartment = async (id, updates) => {
  const setClauses = [];
  const values = [];
  let idx = 1;
  for (const [col, val] of Object.entries(updates)) {
    setClauses.push(`${col} = $${idx}`);
    values.push(val);
    idx++;
  }
  values.push(id);
  const result = await pool.query(
    `UPDATE departments SET ${setClauses.join(', ')} WHERE id = $${idx}
     RETURNING *`,
    values
  );
  return result.rows[0];
};

exports.deleteDepartment = async (id) => {
  await pool.query('DELETE FROM departments WHERE id = $1', [id]);
};

exports.findAllTickets = async (query = {}) => {
  const page = parseInt(query.page) || 1;
  const limit = parseInt(query.limit) || 20;
  const offset = (page - 1) * limit;
  const conditions = [];
  const values = [];
  let idx = 1;

  if (query.status) {
    conditions.push(`t.status = $${idx++}`);
    values.push(query.status);
  }
  if (query.priority) {
    conditions.push(`t.priority = $${idx++}`);
    values.push(query.priority);
  }
  if (query.search) {
    conditions.push(`(t.ticket_number ILIKE $${idx} OR t.title ILIKE $${idx})`);
    values.push(`%${query.search}%`);
    idx++;
  }

  const where = conditions.length > 0 ? 'WHERE ' + conditions.join(' AND ') : '';

  const countResult = await pool.query(
    `SELECT COUNT(*)::int AS total FROM tickets t ${where}`,
    values
  );
  const total = countResult.rows[0].total;
  const totalPages = Math.ceil(total / limit);

  const result = await pool.query(
    `SELECT t.*,
            u.name AS created_by_name,
            u.email AS created_by_email,
            d.name AS assigned_dept_name,
            d.code AS assigned_dept_code,
            a.name AS assigned_to_name,
            ll.action AS last_action,
            ll.acted_by_name AS last_acted_by_name,
            ll.acted_by_dept_name AS last_acted_by_dept_name,
            ll.acted_at AS last_action_at,
            (SELECT COUNT(*)::int FROM tickets c WHERE c.parent_ticket_id = t.id) AS immediate_child_count
     FROM tickets t
     LEFT JOIN users u ON u.id = t.created_by_id
     LEFT JOIN departments d ON d.id = t.assigned_dept_id
     LEFT JOIN users a ON a.id = t.assigned_to_id
     LEFT JOIN LATERAL (
       SELECT tl.action,
              actor.name AS acted_by_name,
              dept.name AS acted_by_dept_name,
              tl.created_at AS acted_at
       FROM ticket_logs tl
       LEFT JOIN users actor ON actor.id = tl.acted_by_id
       LEFT JOIN departments dept ON dept.id = actor.department_id
       WHERE tl.ticket_id = t.id
       ORDER BY tl.created_at DESC
       LIMIT 1
     ) ll ON TRUE
     ${where}
     ORDER BY t.created_at DESC
     LIMIT $${idx++} OFFSET $${idx}`,
    [...values, limit, offset]
  );

  return { tickets: result.rows, total, page, totalPages };
};

exports.findTicketById = async (id) => {
  const result = await pool.query(
    `SELECT t.*,
            u.name AS created_by_name,
            d.name AS assigned_dept_name,
            d.code AS assigned_dept_code,
            a.name AS assigned_to_name,
            ll.action AS last_action,
            ll.acted_by_name AS last_acted_by_name,
            ll.acted_by_dept_name AS last_acted_by_dept_name,
            ll.acted_at AS last_action_at,
            (SELECT COUNT(*)::int FROM tickets c WHERE c.parent_ticket_id = t.id) AS immediate_child_count
     FROM tickets t
     LEFT JOIN users u ON u.id = t.created_by_id
     LEFT JOIN departments d ON d.id = t.assigned_dept_id
     LEFT JOIN users a ON a.id = t.assigned_to_id
     LEFT JOIN LATERAL (
       SELECT tl.action,
              actor.name AS acted_by_name,
              dept.name AS acted_by_dept_name,
              tl.created_at AS acted_at
       FROM ticket_logs tl
       LEFT JOIN users actor ON actor.id = tl.acted_by_id
       LEFT JOIN departments dept ON dept.id = actor.department_id
       WHERE tl.ticket_id = t.id
       ORDER BY tl.created_at DESC
       LIMIT 1
     ) ll ON TRUE
     WHERE t.id = $1`,
    [id]
  );
  return result.rows[0] || null;
};

exports.findSubTickets = async (parentId) => {
  const result = await pool.query(
    `SELECT t.*,
            u.name AS created_by_name,
            d.name AS assigned_dept_name,
            d.code AS assigned_dept_code,
            a.name AS assigned_to_name,
            ll.action AS last_action,
            ll.acted_by_name AS last_acted_by_name,
            ll.acted_by_dept_name AS last_acted_by_dept_name,
            ll.acted_at AS last_action_at,
            (SELECT COUNT(*)::int FROM tickets c WHERE c.parent_ticket_id = t.id) AS immediate_child_count
     FROM tickets t
     LEFT JOIN users u ON u.id = t.created_by_id
     LEFT JOIN departments d ON d.id = t.assigned_dept_id
     LEFT JOIN users a ON a.id = t.assigned_to_id
     LEFT JOIN LATERAL (
       SELECT tl.action,
              actor.name AS acted_by_name,
              dept.name AS acted_by_dept_name,
              tl.created_at AS acted_at
       FROM ticket_logs tl
       LEFT JOIN users actor ON actor.id = tl.acted_by_id
       LEFT JOIN departments dept ON dept.id = actor.department_id
       WHERE tl.ticket_id = t.id
       ORDER BY tl.created_at DESC
       LIMIT 1
     ) ll ON TRUE
     WHERE t.parent_ticket_id = $1
     ORDER BY t.created_at ASC`,
    [parentId]
  );
  return result.rows;
};

exports.updateTicket = async (id, updates) => {
  const setClauses = [];
  const values = [];
  let idx = 1;
  for (const [col, val] of Object.entries(updates)) {
    setClauses.push(`${col} = $${idx}`);
    values.push(val);
    idx++;
  }
  values.push(id);
  const result = await pool.query(
    `UPDATE tickets SET ${setClauses.join(', ')}, updated_at = NOW() WHERE id = $${idx}
     RETURNING *`,
    values
  );
  return result.rows[0];
};

exports.deleteTicket = async (id) => {
  await Promise.all([
    pool.query('DELETE FROM ticket_comments WHERE ticket_id = $1', [id]),
    pool.query('DELETE FROM ticket_logs WHERE ticket_id = $1', [id]),
    pool.query('DELETE FROM notifications WHERE ticket_id = $1', [id]),
    pool.query('DELETE FROM sub_ticket_departments WHERE ticket_id = $1', [id]),
    pool.query('DELETE FROM tickets WHERE id = $1', [id]),
  ]);
};

exports.findUserActivity = async () => {
  const result = await pool.query(
    `SELECT u.id, u.name, u.email, u.code, u.designation, u.is_active, u.last_active,
            u.created_at, u.must_reset_password,
            r.name AS role_name,
            d.name AS department_name,
            c.name AS company_name
     FROM users u
     JOIN roles r ON r.id = u.role_id
     LEFT JOIN departments d ON d.id = u.department_id
     LEFT JOIN companies c ON c.id = u.company_id
     ORDER BY u.last_active DESC NULLS LAST, u.name`
  );
  return result.rows;
};
