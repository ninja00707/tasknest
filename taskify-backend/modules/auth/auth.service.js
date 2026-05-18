const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const repo = require('./auth.repository');

exports.register = async ({
  email,
  password_hash,
  name,
  company_id,
  department_id,
  role_id,
}) => {

  // Validation
  if (
    !email ||
    !password_hash ||
    !name ||
    !company_id ||
    !department_id ||
    !role_id
  ) {

    const error = new Error(
      'All fields are required'
    );

    error.statusCode = 400;

    throw error;
  }

  // Check existing user
  const existingUser =
    await repo.findUserByEmail(email);

  if (existingUser) {

    const error =
      new Error('User already exists');

    error.statusCode = 409;

    throw error;
  }

  // Hash password
  const hashedPassword =
    await bcrypt.hash(password_hash, 10);

  // Create user
  const user = await repo.createUser({
    email: email.toLowerCase(),
    password_hash: hashedPassword,
    name,
    company_id,
    department_id,
    role_id,
  });

  // Remove password before returning
  delete user.password_hash;

  return user;
};
exports.login = async ({
  email,
  password,
}) => {

  if (!email || !password) {

    const error = new Error(
      'Email and password are required'
    );

    error.statusCode = 400;

    throw error;
  }

  const user =
    await repo.findUserByEmail(email);

  if (!user) {

    const error = new Error(
      'Invalid credentials'
    );

    error.statusCode = 401;

    throw error;
  }

  const isPasswordValid =
    await bcrypt.compare(
      password,
      user.password_hash
    );

  if (!isPasswordValid) {

    const error = new Error(
      'Invalid credentials'
    );

    error.statusCode = 401;

    throw error;
  }

  // Generate JWT token
  const token = jwt.sign(
    {
      id: user.id,
      email: user.email,
      role_id: user.role_id,
      company_id: user.company_id,
      department_id: user.department_id,
    },
    process.env.JWT_SECRET,
    {
      expiresIn: process.env.JWT_EXPIRES_IN || '7d',
    }
  );

  // Remove password hash
  delete user.password_hash;

  return {
    token,
    user,
  };
};
// exports.login = async ({
//   email,
//   password,
// }) => {

//   if (!email || !password) {

//     const error = new Error(
//       'Email and password are required'
//     );

//     error.statusCode = 400;

//     throw error;
//   }

//   const user =
//     await repo.findUserByEmail(email);

//   if (!user) {

//     const error = new Error(
//       'Invalid credentials'
//     );

//     error.statusCode = 401;

//     throw error;
//   }

//   // IMPORTANT FIX HERE
//   const isPasswordValid =
//     await bcrypt.compare(
//       password,
//       user.password_hash
//     );

//   if (!isPasswordValid) {

//     const error = new Error(
//       'Invalid credentials'
//     );

//     error.statusCode = 401;

//     throw error;
//   }

//   // Remove password before returning
//   delete user.password_hash;

//   return user;
// };



exports.forgotPassword = async (email) => {
  if (!email) {
    const error = new Error('Email is required');
    error.statusCode = 400;
    throw error;
  }

  const user = await repo.findUserByEmail(email);
  if (!user) {
    // For security reasons, we might not want to reveal if the email exists,
    // but returning a clear error helps the frontend display the right message.
    const error = new Error('User not found');
    error.statusCode = 404;
    throw error;
  }

  // TODO: Implement actual email sending logic with a reset token here.
  // For now, return a success message indicating the email would be sent.

  return { message: 'If an account exists with this email, a reset link has been sent.' };
};