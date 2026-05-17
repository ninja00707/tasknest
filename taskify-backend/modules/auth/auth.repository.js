const pool = require('../../database/db');

exports.createUser = async ({ email, password, name, company_id, department_id, role }) => {
  try {
    const result = await pool.query(
      `INSERT INTO users (email, password, name, company_id, department_id, role) 
       VALUES ($1, $2, $3, $4, $5, $6) RETURNING *`,
      [email, password, name, company_id, department_id, role || 'user']
    );
    return result.rows[0];
  } catch (error) {
    console.error('Database Error (createUser):', error);
    // Check for PostgreSQL unique constraint violation (duplicate email)
    if (error.code === '23505') {
      const err = new Error('User with this email already exists');
      err.statusCode = 409;
      throw err;
    }

    // For other DB errors, throw a generic 500 error
    const err = new Error('Database error while creating user');
    err.statusCode = 500;
    throw err;
  }
};

exports.findUserByEmail = async (email) => {
  try {
    const result = await pool.query(
      'SELECT * FROM users WHERE email = $1',
      [email]
    );
    return result.rows[0] || null;
  } catch (error) {
    console.error('Database Error (findUserByEmail):', error);
    const err = new Error('Database error while fetching user');
    err.statusCode = 500;
    throw err;
  }
};