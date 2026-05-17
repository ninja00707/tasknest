const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const repo = require('./auth.repository');

exports.register = async ({
  email,
  password,
  name,
  company_id,
  department_id,
  role,
}) => {

  if (
    !email ||
    !password ||
    !name ||
    !company_id ||
    !department_id ||
    !role
  ) {

    const error = new Error(
      'All fields are required'
    );

    error.statusCode = 400;

    throw error;
  }

  const existingUser =
    await repo.findUserByEmail(email);

  if (existingUser) {

    const error =
      new Error('User already exists');

    error.statusCode = 409;

    throw error;
  }

  const hashedPassword =
    await bcrypt.hash(password, 10);

  const user = await repo.createUser({
    email: email.toLowerCase(),
    password: hashedPassword,
    name,
    company_id,
    department_id,
    role,
  });

  delete user.password;

  return user;
};

exports.login = async ({ email, password }) => {
  if (!email || !password) {
    const error = new Error('Email and password are required');
    error.statusCode = 400;
    throw error;
  }

  const user = await repo.findUserByEmail(email.toLowerCase());
  if (!user) {
    const error = new Error('User not found');
    error.statusCode = 404;
    throw error;
  }

  const isValid = await bcrypt.compare(password, user.password);
  if (!isValid) {
    const error = new Error('Invalid credentials');
    error.statusCode = 401;
    throw error;
  }

  // Make sure to set JWT_SECRET in your .env file
  const token = jwt.sign(
    {
      id: user.id,
      email: user.email,
      role: user.role,
      company_id: user.company_id,
      department_id: user.department_id
    },
    process.env.JWT_SECRET || 'fallback_secret',
    { expiresIn: '7d' }
  );

  // Exclude password from the returned object
  const userWithoutPassword = { ...user };
  delete userWithoutPassword.password;

  return { token, user: userWithoutPassword };
};

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