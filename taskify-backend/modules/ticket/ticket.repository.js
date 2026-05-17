const pool = require('../../database/db');

exports.createTicket = async ({ title, description, creator_id, target_department_id, company_id }) => {
  const result = await pool.query(
    `INSERT INTO tickets (title, description, creator_id, target_department_id, company_id, status)
     VALUES ($1, $2, $3, $4, $5, 'open') RETURNING *`,
    [title, description, creator_id, target_department_id, company_id]
  );
  return result.rows[0];
};

exports.getTicketById = async (ticketId) => {
  const result = await pool.query(
    'SELECT * FROM tickets WHERE id = $1',
    [ticketId]
  );
  return result.rows[0];
};

exports.getTicketsByCompany = async (company_id) => {
  const result = await pool.query(
    'SELECT * FROM tickets WHERE company_id = $1 ORDER BY created_at DESC',
    [company_id]
  );
  return result.rows;
};

exports.getTicketsByDepartmentAndCreator = async (department_id, creator_id) => {
  const result = await pool.query(
    `SELECT * FROM tickets 
     WHERE target_department_id = $1 OR creator_id = $2 
     ORDER BY created_at DESC`,
    [department_id, creator_id]
  );
  return result.rows;
};

exports.updateTicketAssignee = async (ticketId, assignee_id) => {
  const result = await pool.query(
    `UPDATE tickets 
     SET assignee_id = $1, status = 'in_progress', updated_at = CURRENT_TIMESTAMP
     WHERE id = $2 RETURNING *`,
    [assignee_id, ticketId]
  );
  return result.rows[0];
};

exports.closeTicket = async (ticketId) => {
  const result = await pool.query(
    `UPDATE tickets 
     SET status = 'closed', closed_at = CURRENT_TIMESTAMP, updated_at = CURRENT_TIMESTAMP
     WHERE id = $1 RETURNING *`,
    [ticketId]
  );
  return result.rows[0];
};

exports.reopenTicket = async (ticketId, reopen_count) => {
  const result = await pool.query(
    `UPDATE tickets 
     SET status = 'open', 
         reopen_count = $1, 
         closed_at = NULL, 
         updated_at = CURRENT_TIMESTAMP
     WHERE id = $2 RETURNING *`,
    [reopen_count, ticketId]
  );
  return result.rows[0];
};
