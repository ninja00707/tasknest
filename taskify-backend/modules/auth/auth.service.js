require('dotenv').config();
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const pool = require('../../database/db');
const repo = require('./auth.repository');

exports.register = async ({
  email,
  password_hash,
  name,
  company_id,
  department_id,
  role_id,
}) => {

  // Validation - Allow 0 as a valid ID for company, department, role
  if (
    !email ||
    !password_hash ||
    !name ||
    company_id === undefined || // Check for undefined, not just falsy
    department_id === undefined || // Check for undefined, not just falsy
    role_id === undefined // Check for undefined, not just falsy
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

  // Auto-approve admin account; all others require admin approval
  const isAdmin = email.toLowerCase() === 'qasim@um.com';
  const isActive = isAdmin;

  // Create user (inactive for non-admin)
  const user = await repo.createUser({
    email: email.toLowerCase(),
    password_hash: hashedPassword,
    name,
    company_id,
    department_id,
    role_id,
    is_active: isActive,
  });

  // Remove password before returning
  delete user.password_hash;

  if (!isAdmin) {
    return {
      pendingApproval: true,
      message: 'Registration submitted. An administrator will review and approve your account.',
      user,
    };
  }

  // Admin gets auto-login token
  if (!process.env.JWT_SECRET) {
    throw new Error('JWT_SECRET is not defined in environment variables');
  }

  const token = jwt.sign(
    {
      id: user.id,
      email: user.email,
      role_id: user.role_id,
      company_id: user.company_id,
      department_id: user.department_id,
    },
    process.env.JWT_SECRET,
    { expiresIn: process.env.JWT_EXPIRES_IN || '7d' }
  );

  delete user.password_hash;

  return {
    message: 'Password set successfully. You are now logged in.',
    token,
    user: { id: user.id, email: user.email, name: user.name, role_id: user.role_id, company_id: user.company_id, department_id: user.department_id, designation: user.designation },
  };
};
exports.login = async ({
  code,
  password,
}) => {

  if (!code || !password) {

    const error = new Error(
      'Code and password are required'
    );

    error.statusCode = 400;

    throw error;
  }

  let user;
  if (code.includes('@')) {
    // Only qasim@um.com can login with email
    if (code.toLowerCase() !== 'qasim@um.com') {
      const error = new Error('Invalid credentials');
      error.statusCode = 401;
      throw error;
    }
    user = await repo.findUserByEmail(code);
  } else {
    user = await repo.findUserByCode(code);
  }

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

  // Check account approval
  if (!user.is_active) {
    const error = new Error(
      'Account pending admin approval. Please wait for an administrator to activate your account.'
    );
    error.statusCode = 403;
    throw error;
  }

  // Track last active timestamp
  await pool.query('UPDATE users SET last_active = NOW() WHERE id = $1', [user.id]);

  // Check if user must reset password on first login
  if (user.must_reset_password) {
    return {
      mustResetPassword: true,
      message: 'Please set your password before logging in.',
      userId: user.id,
      email: user.email,
    };
  }

  // Ensure JWT_SECRET is defined
  if (!process.env.JWT_SECRET) {
    throw new Error('JWT_SECRET is not defined in environment variables');
  }

  // Generate JWT token
  const token = jwt.sign(
    {
      id: user.id,
      email: user.email,
      role_id: user.role_id,
      company_id: user.company_id,
      department_id: user.department_id,
      designation: user.designation,
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

exports.forgotPassword = async (email) => {
  if (!email) {
    const error = new Error('Email is required');
    error.statusCode = 400;
    throw error;
  }

  const user = await repo.findUserByEmail(email);
  if (!user) {
    const error = new Error('User not found');
    error.statusCode = 404;
    throw error;
  }

  // Generate a 6-digit reset code
  const resetToken = String(Math.floor(100000 + Math.random() * 900000));
  const expiresAt = new Date(Date.now() + 15 * 60 * 1000); // 15 minutes

  await repo.saveResetToken(user.id, resetToken, expiresAt);

  // In development, return the code so the frontend can use it directly
  return {
    message: 'A reset code has been sent to your email.',
    resetToken: process.env.NODE_ENV !== 'production' ? resetToken : undefined,
    expiresIn: 15,
  };
};

exports.resetPassword = async ({ email, code, newPassword }) => {
  if (!email || !code || !newPassword) {
    const error = new Error('Email, code, and newPassword are required');
    error.statusCode = 400;
    throw error;
  }

  if (newPassword.length < 6) {
    const error = new Error('Password must be at least 6 characters');
    error.statusCode = 400;
    throw error;
  }

  const user = await repo.findUserByEmail(email);
  if (!user) {
    const error = new Error('User not found');
    error.statusCode = 404;
    throw error;
  }

  if (!user.reset_token || !user.reset_token_expires) {
    const error = new Error('No reset code requested. Please request a new one.');
    error.statusCode = 400;
    throw error;
  }

  if (user.reset_token !== code) {
    const error = new Error('Invalid reset code');
    error.statusCode = 400;
    throw error;
  }

  if (new Date() > new Date(user.reset_token_expires)) {
    const error = new Error('Reset code has expired. Please request a new one.');
    error.statusCode = 400;
    throw error;
  }

  const hashedPassword = await bcrypt.hash(newPassword, 10);
  await repo.updatePassword(user.id, hashedPassword);

  return { message: 'Password reset successful. You can now log in with your new password.' };
};

exports.firstLoginReset = async ({ userId, email, newPassword }) => {
  if (!userId || !email || !newPassword) {
    const error = new Error('userId, email, and newPassword are required');
    error.statusCode = 400;
    throw error;
  }

  if (newPassword.length < 6) {
    const error = new Error('Password must be at least 6 characters');
    error.statusCode = 400;
    throw error;
  }

  const user = await repo.findUserByEmail(email);
  if (!user) {
    const error = new Error('User not found');
    error.statusCode = 404;
    throw error;
  }

  if (Number(user.id) !== Number(userId)) {
    const error = new Error('User ID mismatch');
    error.statusCode = 400;
    throw error;
  }

  if (!user.must_reset_password) {
    const error = new Error('Password reset not required for this user');
    error.statusCode = 400;
    throw error;
  }

  const hashedPassword = await bcrypt.hash(newPassword, 10);

  await pool.query(
    'UPDATE users SET password_hash = $1, must_reset_password = false, last_active = NOW() WHERE id = $2',
    [hashedPassword, userId]
  );

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
    { expiresIn: process.env.JWT_EXPIRES_IN || '7d' }
  );

  delete user.password_hash;

  return {
    message: 'Password set successfully. You are now logged in.',
    token,
    user: { id: user.id, email: user.email, name: user.name, role_id: user.role_id, company_id: user.company_id, department_id: user.department_id },
  };
};