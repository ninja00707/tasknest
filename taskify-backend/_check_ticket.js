const { Pool } = require('pg');
require('dotenv').config();
const pool = new Pool({
  host: process.env.DB_HOST,
  port: process.env.DB_PORT,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME
});

(async () => {
  const child = await pool.query("SELECT id, ticket_number, title, status, is_sub_ticket, parent_ticket_id, overall_progress, created_at, updated_at FROM tickets WHERE id = 121");
  console.log('CHILD:', JSON.stringify(child.rows[0], null, 2));

  try {
    const depts = await pool.query("SELECT * FROM sub_ticket_departments WHERE ticket_id = 121");
    console.log('\nDEPARTMENTS:', JSON.stringify(depts.rows, null, 2));
  } catch(e) {
    console.log('\nsub_ticket_departments error:', e.message);
  }

  // Check parent updated_at
  const parent = await pool.query("SELECT id, ticket_number, status, updated_at FROM tickets WHERE id = 120");
  console.log('\nPARENT:', JSON.stringify(parent.rows[0], null, 2));

  await pool.end();
})();
