const pool = require('../../database/db');

class TicketRepository {
  async getTicketDetails(ticketId) {
    const result = await pool.query(`
      SELECT
        t.id, t.title, t.description, t.status, t.priority,
        t.assigned_dept_id, t.created_by_dept, t.assigned_to_id,
        t.transferred_from, t.transferred_at,
        t.due_date, t.created_at, t.updated_at,
        t.closed_at, t.reopened_at, t.reopen_count,

        creator.id   AS created_by_id,
        creator.name AS created_by_name,
        cd.code      AS created_by_dept_code,
        cd.name      AS created_by_dept_name,

        ad.id        AS assigned_dept_id,
        ad.code      AS assigned_dept_code,
        ad.name      AS assigned_dept_name,

        assignee.id   AS assigned_to_id,
        assignee.name AS assigned_to_name,

        tf.code AS transferred_from_code
      FROM tickets t
      LEFT JOIN users creator  ON creator.id = t.created_by_id
      LEFT JOIN departments cd ON cd.id = t.created_by_dept
      LEFT JOIN departments ad ON ad.id = t.assigned_dept_id
      LEFT JOIN users assignee ON assignee.id = t.assigned_to_id
      LEFT JOIN departments tf ON tf.id = t.transferred_from
      WHERE t.id = $1
    `, [ticketId]);

    return result.rows[0] || null;
  }

  // ── Get tickets visible to this user based on role ────────────────────────
  async getVisibleTickets(user, filters = {}) {
    const { status, priority, page = 1, limit = 20 } = filters;
    const offset = (Number(page) - 1) * Number(limit);
    const params = [];
    let whereClause = '';

    if (user.role === 'ceo') {
      // CEO sees everything
      whereClause = 'WHERE 1=1';
    } else {
      params.push(user.department_id);
      whereClause = `WHERE t.assigned_dept_id = $${params.length}`;
    }

    if (status) {
      params.push(status);
      whereClause += ` AND t.status = $${params.length}`;
    }
    if (priority) {
      params.push(priority);
      whereClause += ` AND t.priority = $${params.length}`;
    }

    params.push(Number(limit), offset);

    const query = `
      SELECT
        t.id, t.title, t.description, t.status, t.priority,
        t.assigned_dept_id, t.created_by_dept, t.assigned_to_id,
        t.transferred_from, t.transferred_at,
        t.due_date, t.created_at, t.updated_at,
        t.reopen_count, t.closed_at,

        creator.id   AS created_by_id,
        creator.name AS created_by_name,
        cd.code      AS created_by_dept_code,
        cd.name      AS created_by_dept_name,

        ad.id        AS assigned_dept_id,
        ad.code      AS assigned_dept_code,
        ad.name      AS assigned_dept_name,

        assignee.id   AS assigned_to_id,
        assignee.name AS assigned_to_name,

        tf.code AS transferred_from_code
      FROM tickets t
      LEFT JOIN users       creator  ON creator.id  = t.created_by_id
      LEFT JOIN departments cd       ON cd.id        = t.created_by_dept
      LEFT JOIN departments ad       ON ad.id        = t.assigned_dept_id
      LEFT JOIN users  assignee ON assignee.id  = t.assigned_to_id
      LEFT JOIN departments tf  ON tf.id        = t.transferred_from
      ${whereClause}
      ORDER BY
        CASE t.priority WHEN 'urgent' THEN 1 WHEN 'high' THEN 2 WHEN 'medium' THEN 3 ELSE 4 END,
        t.created_at DESC
      LIMIT $${params.length - 1} OFFSET $${params.length}
    `;

    const result = await pool.query(query, params);
    return result.rows;
  }

  // ── Dashboard stats for a user ────────────────────────────────────────────
  async getDashboardStats(user) {
    let whereClause = '';
    const params = [];

    if (user.role !== 'ceo') {
      params.push(user.department_id);
      whereClause = `WHERE assigned_dept_id = $1`;
    }

    const result = await pool.query(`
      SELECT
        COUNT(*)                                          AS total,
        COUNT(*) FILTER (WHERE status = 'open')          AS open,
        COUNT(*) FILTER (WHERE status = 'in_progress')   AS in_progress,
        COUNT(*) FILTER (WHERE status = 'completed')     AS completed,
        COUNT(*) FILTER (WHERE status = 'closed')        AS closed,
        COUNT(*) FILTER (WHERE priority = 'urgent')      AS urgent,
        COUNT(*) FILTER (WHERE priority = 'high')        AS high_priority,
        COUNT(*) FILTER (WHERE due_date < NOW() AND status NOT IN ('completed','closed')) AS overdue
      FROM tickets ${whereClause}
    `, params);

    return result.rows[0];
  }

  // ── Get single ticket (with permission check) ─────────────────────────────
  async getTicketById(ticketId, user) {
    const ticket = await this.getTicketDetails(ticketId);

    if (!ticket) return null;

    if (user.role === 'ceo') {
      return ticket;
    }

    const isAssignedDept = ticket.assigned_dept_id === user.department_id;
    const isTransferredFromUsersDept =
      ticket.transferred_at && ticket.created_by_dept === user.department_id;

    if (!isAssignedDept && !isTransferredFromUsersDept) {
      return { forbidden: true };
    }

    return ticket;
  }

  // ── Create ticket ─────────────────────────────────────────────────────────
  async createTicket({ title, description, priority, assignedDeptId, dueDate, createdBy, assignedToId }) {
    // Strict check for assignedToId to set correct status
    const status = (assignedToId != null) ? 'in_progress' : 'open';
    const result = await pool.query(`
      INSERT INTO tickets
        (title, description, priority, assigned_dept_id, due_date, created_by_id, created_by_dept, assigned_to_id, status)
      VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
      RETURNING id
    `, [title, description, priority, assignedDeptId, dueDate || null, createdBy.id, createdBy.department_id, assignedToId || null, status]);

    return await this.getTicketDetails(result.rows[0].id);
  }

  // ── Update ticket status ─────────────────────────────────────────────────
  async updateStatus(ticketId, status, user) {
    await pool.query(`
      UPDATE tickets SET status = $1,
        closed_by_id = CASE WHEN $1 = 'closed' THEN $2 ELSE closed_by_id END,
        closed_at    = CASE WHEN $1 = 'closed' THEN NOW() ELSE closed_at END
      WHERE id = $3
    `, [status, user.id, ticketId]);

    return await this.getTicketDetails(ticketId);
  }

  // ── Self-assign open ticket (employee only) ───────────────────────────────
  async selfAssign(ticketId, userId) {
    const result = await pool.query(`
      UPDATE tickets
      SET assigned_to_id = $1, status = 'in_progress'
      WHERE id = $2 AND status = 'open' AND assigned_to_id IS NULL
      RETURNING id
    `, [userId, ticketId]);

    if (result.rows.length === 0) return null;

    return await this.getTicketDetails(ticketId);
  }

  // ── Manager assigns ticket to employee ───────────────────────────────────
  async assignToEmployee(ticketId, employeeId, managerId) {
    // Verify employee is in same dept as manager
    const empCheck = await pool.query(
      `SELECT id FROM users WHERE id = $1 AND department_id = (
         SELECT department_id FROM users WHERE id = $2
       )`,
      [employeeId, managerId]
    );

    if (empCheck.rows.length === 0) {
      throw new Error('Employee not in same department');
    }

    const result = await pool.query(`
      UPDATE tickets
      SET assigned_to_id = $1, status = 'in_progress'
      WHERE id = $2
      RETURNING id
    `, [employeeId, ticketId]);

    if (result.rows.length === 0) return null;

    return await this.getTicketDetails(ticketId);
  }

  // ── Transfer ticket to another department ─────────────────────────────────
  async transferTicket(ticketId, targetDeptId, user) {
    const result = await pool.query(`
      UPDATE tickets
      SET assigned_dept_id   = $1,
          transferred_from   = assigned_dept_id,
          transferred_at     = NOW(),
          assigned_to_id     = NULL,
          status             = 'open'
      WHERE id = $2
      RETURNING id
    `, [targetDeptId, ticketId]);

    if (result.rows.length === 0) return null;

    return await this.getTicketDetails(ticketId);
  }

  // ── Reopen ticket (creator, within 48h, once only) ────────────────────────
  async reopenTicket(ticketId, userId) {
    const ticket = await pool.query(
      `SELECT * FROM tickets WHERE id = $1`, [ticketId]
    );
    if (ticket.rows.length === 0) throw new Error('Ticket not found');

    const t = ticket.rows[0];

    if (t.created_by_id !== userId) throw new Error('Only the creator can reopen this ticket');
    if (t.reopen_count >= 1) throw new Error('Ticket can only be reopened once');
    if (t.status !== 'closed' && t.status !== 'completed') throw new Error('Only closed/completed tickets can be reopened');

    const hoursSinceClosed = (Date.now() - new Date(t.closed_at).getTime()) / 36e5;
    if (hoursSinceClosed > 48) throw new Error('Reopen window of 48 hours has passed');

    const result = await pool.query(`
      UPDATE tickets
      SET status = 'open', reopened_at = NOW(), reopen_count = reopen_count + 1, closed_by_id = NULL, closed_at = NULL
      WHERE id = $1
      RETURNING id
    `, [ticketId]);

    if (result.rows.length === 0) return null;

    return await this.getTicketDetails(ticketId);
  }

  // ── Get ticket comments ───────────────────────────────────────────────────
  async getComments(ticketId) {
    const result = await pool.query(`
      SELECT tc.*, u.name AS user_name, d.code AS dept_code
      FROM ticket_comments tc
      JOIN users u       ON u.id = tc.user_id
      JOIN departments d ON d.id = u.department_id
      WHERE tc.ticket_id = $1
      ORDER BY tc.created_at ASC
    `, [ticketId]);

    return result.rows;
  }

  // ── Add comment ───────────────────────────────────────────────────────────
  async addComment(ticketId, userId, message) {
    const result = await pool.query(`
      INSERT INTO ticket_comments (ticket_id, user_id, message)
      VALUES ($1, $2, $3) RETURNING *
    `, [ticketId, userId, message]);

    return result.rows[0];
  }

  // ── Log action ───────────────────────────────────────────────────────────
  async logAction(ticketId, userId, action, oldValue, newValue, note) {
    await pool.query(`
      INSERT INTO ticket_logs (ticket_id, acted_by_id, action, old_value, new_value, note)
      VALUES ($1, $2, $3, $4, $5, $6)
    `, [ticketId, userId, action, oldValue, newValue, note]);
  }

  // ── Get departments list ──────────────────────────────────────────────────
  async getDepartments() {
    const result = await pool.query(
      `SELECT id, name, code, tier, parent_id FROM departments ORDER BY tier, name`
    );
    return result.rows;
  }

  // ── Get employees in a department ────────────────────────────────────────
  async getEmployeesByDepartment(departmentId) {
    const result = await pool.query(`
      SELECT
        u.id,
        u.name,
        u.email,
        u.department_id,
        u.company_id,
        u.is_active,
        r.name AS role,
        d.code AS dept_code,
        d.name AS dept_name
      FROM users u
      JOIN roles r ON r.id = u.role_id
      JOIN departments d ON d.id = u.department_id
      WHERE u.department_id = $1
        AND u.is_active = TRUE
        AND r.name = 'employee'
      ORDER BY u.name ASC
    `, [departmentId]);

    return result.rows;
  }

  // ── Tickets created by this department and transferred out ───────────────
  async getSentTicketsByDepartment(departmentId) {
    const result = await pool.query(`
      SELECT
        t.id, t.title, t.description, t.status, t.priority,
        t.assigned_dept_id, t.created_by_dept, t.assigned_to_id,
        t.transferred_from, t.transferred_at,
        t.due_date, t.created_at, t.updated_at,
        t.reopen_count, t.closed_at,

        creator.id   AS created_by_id,
        creator.name AS created_by_name,
        cd.code      AS created_by_dept_code,
        cd.name      AS created_by_dept_name,

        ad.id        AS assigned_dept_id,
        ad.code      AS assigned_dept_code,
        ad.name      AS assigned_dept_name,

        assignee.id   AS assigned_to_id,
        assignee.name AS assigned_to_name,

        tf.code AS transferred_from_code
      FROM tickets t
      LEFT JOIN users       creator  ON creator.id  = t.created_by_id
      LEFT JOIN departments cd       ON cd.id        = t.created_by_dept
      LEFT JOIN departments ad       ON ad.id        = t.assigned_dept_id
      LEFT JOIN users  assignee ON assignee.id  = t.assigned_to_id
      LEFT JOIN departments tf  ON tf.id        = t.transferred_from
      WHERE t.created_by_dept = $1
        AND t.assigned_dept_id <> $1
      ORDER BY t.transferred_at DESC, t.created_at DESC
    `, [departmentId]);

    return result.rows;
  }

  // ── Get ticket logs/history ─────────────────────────────────────────────
  async getTicketLogs(ticketId) {
    const result = await pool.query(`
      SELECT 
        tl.id, tl.ticket_id, tl.action, tl.old_value, tl.new_value, tl.note, tl.created_at,
        u.id AS acted_by_id,
        u.name AS acted_by_name,
        d.code AS dept_code
      FROM ticket_logs tl
      LEFT JOIN users u ON u.id = tl.acted_by_id
      LEFT JOIN departments d ON d.id = u.department_id
      WHERE tl.ticket_id = $1
      ORDER BY tl.created_at ASC
    `, [ticketId]);

    return result.rows;
  }

  // ── Get analytics grouped by department ──────────────────────────────────
  async getAnalyticsByDepartment() {
    const result = await pool.query(`
      SELECT
        d.id AS dept_id,
        d.code AS dept_code,
        d.name AS dept_name,
        COUNT(t.id)                                          AS total,
        COUNT(t.id) FILTER (WHERE t.status = 'open')        AS open,
        COUNT(t.id) FILTER (WHERE t.status = 'in_progress') AS in_progress,
        COUNT(t.id) FILTER (WHERE t.status = 'completed')   AS completed,
        COUNT(t.id) FILTER (WHERE t.status = 'closed')      AS closed,
        COUNT(t.id) FILTER (WHERE t.priority = 'urgent')    AS urgent,
        COUNT(t.id) FILTER (WHERE t.priority = 'high')      AS high_priority,
        COUNT(t.id) FILTER (WHERE t.due_date < NOW() AND t.status NOT IN ('completed','closed')) AS overdue,
        ROUND(AVG(EXTRACT(EPOCH FROM (COALESCE(t.closed_at, t.updated_at) - t.created_at)) / 3600)::numeric, 2) AS avg_resolution_hours
      FROM departments d
      LEFT JOIN tickets t ON t.assigned_dept_id = d.id
      GROUP BY d.id, d.code, d.name
      ORDER BY d.name ASC
    `);

    return result.rows;
  }
}

module.exports = new TicketRepository();
