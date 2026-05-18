const pool = require('../../database/db');

class TicketRepository {

  // ── Get tickets visible to this user based on role ────────────────────────
  async getVisibleTickets(user, filters = {}) {
    const { status, priority, page = 1, limit = 20 } = filters;
    const offset = (page - 1) * limit;
    const params = [];
    let whereClause = '';

    if (user.role === 'ceo') {
      // CEO sees everything
      whereClause = 'WHERE 1=1';
    } else if (user.role === 'manager') {
      // Manager sees all tickets assigned to their department
      params.push(user.department_id);
      whereClause = `WHERE t.assigned_dept_id = $${params.length}`;
    } else {
      // Employee sees only tickets assigned to their department
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

    params.push(limit, offset);

    const query = `
      SELECT
        t.id, t.title, t.description, t.status, t.priority,
        t.due_date, t.created_at, t.updated_at,
        t.reopen_count, t.closed_at, t.transferred_at,

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
      JOIN users       creator  ON creator.id  = t.created_by_id
      JOIN departments cd       ON cd.id        = t.created_by_dept
      JOIN departments ad       ON ad.id        = t.assigned_dept_id
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
    const result = await pool.query(`
      SELECT t.*,
        creator.name  AS created_by_name,
        cd.code       AS created_by_dept_code,
        ad.code       AS assigned_dept_code,
        ad.name       AS assigned_dept_name,
        assignee.name AS assigned_to_name
      FROM tickets t
      JOIN users       creator  ON creator.id = t.created_by_id
      JOIN departments cd       ON cd.id      = t.created_by_dept
      JOIN departments ad       ON ad.id      = t.assigned_dept_id
      LEFT JOIN users  assignee ON assignee.id = t.assigned_to_id
      WHERE t.id = $1
    `, [ticketId]);

    if (result.rows.length === 0) return null;

    const ticket = result.rows[0];

    // Visibility check
    if (user.role !== 'ceo' && ticket.assigned_dept_id !== user.department_id) {
      return { forbidden: true };
    }

    return ticket;
  }

  // ── Create ticket ─────────────────────────────────────────────────────────
  async createTicket({ title, description, priority, assignedDeptId, dueDate, createdBy }) {
    const result = await pool.query(`
      INSERT INTO tickets
        (title, description, priority, assigned_dept_id, due_date, created_by_id, created_by_dept, status)
      VALUES ($1, $2, $3, $4, $5, $6, $7, 'open')
      RETURNING *
    `, [title, description, priority, assignedDeptId, dueDate || null, createdBy.id, createdBy.department_id]);

    return result.rows[0];
  }

  // ── Update ticket status ─────────────────────────────────────────────────
  async updateStatus(ticketId, status, user) {
    const result = await pool.query(`
      UPDATE tickets SET status = $1,
        closed_by_id = CASE WHEN $1 = 'closed' THEN $2 ELSE closed_by_id END,
        closed_at    = CASE WHEN $1 = 'closed' THEN NOW() ELSE closed_at END
      WHERE id = $3
      RETURNING *
    `, [status, user.id, ticketId]);

    return result.rows[0];
  }

  // ── Self-assign open ticket (employee only) ───────────────────────────────
  async selfAssign(ticketId, userId) {
    const result = await pool.query(`
      UPDATE tickets
      SET assigned_to_id = $1, status = 'in_progress'
      WHERE id = $2 AND status = 'open' AND assigned_to_id IS NULL
      RETURNING *
    `, [userId, ticketId]);

    return result.rows[0];
  }

  // ── Manager assigns ticket to employee ───────────────────────────────────
  async assignToEmployee(ticketId, employeeId, managerId) {
    // Verify employee is in same dept as manager
    const empCheck = await pool.query(
      `SELECT id FROM users WHERE id = $1 AND department_id = (
         SELECT department_id FROM users WHERE id = $2
       )`, [employeeId, managerId]
    );
    if (empCheck.rows.length === 0) {
      throw new Error('Employee not in same department');
    }

    const result = await pool.query(`
      UPDATE tickets SET assigned_to_id = $1, status = 'in_progress'
      WHERE id = $2 RETURNING *
    `, [employeeId, ticketId]);

    return result.rows[0];
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
      RETURNING *
    `, [targetDeptId, ticketId]);

    return result.rows[0];
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
      RETURNING *
    `, [ticketId]);

    return result.rows[0];
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
}

module.exports = new TicketRepository();