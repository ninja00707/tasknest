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

exports.saveResetToken = async (userId, token, expiresAt) => {
  try {
    await pool.query(
      'UPDATE users SET reset_token = $1, reset_token_expires = $2 WHERE id = $3',
      [token, expiresAt, userId]
    );
  } catch (error) {
    console.error('Database Error (saveResetToken):', error);
    const err = new Error('Database error while saving reset token');
    err.statusCode = 500;
    throw err;
  }
};

exports.updatePassword = async (userId, newHash) => {
  try {
    await pool.query(
      'UPDATE users SET password_hash = $1, reset_token = NULL, reset_token_expires = NULL WHERE id = $2',
      [newHash, userId]
    );
  } catch (error) {
    console.error('Database Error (updatePassword):', error);
    const err = new Error('Database error while updating password');
    err.statusCode = 500;
    throw err;
  }
};