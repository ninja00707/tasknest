const pool = require('../../database/db');

exports.createUser = async ({
  email,
  password_hash,
  name,
  company_id,
  department_id,
  role_id,
}) => {

  try {

    const query = `
      INSERT INTO users
      (
        email,
        password_hash,
        name,
        company_id,
        department_id,
        role_id
      )
      VALUES ($1, $2, $3, $4, $5, $6)
      RETURNING *
    `;

    const values = [
      email,
      password_hash,
      name,
      company_id,
      department_id,
      role_id,
    ];

    const result = await pool.query(
      query,
      values
    );

    return result.rows[0];

  } catch (error) {

    console.error(
      'Database Error (createUser):',
      error
    );

    const customError = new Error(
      'Database error while creating user'
    );

    customError.statusCode = 500;

    throw customError;
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