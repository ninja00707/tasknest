const service = require('./auth.service');

exports.register = async (req, res) => {
  try {
    const result = await service.register(req.body);

    const message = result.pendingApproval
      ? result.message
      : 'User registered successfully';

    return res.status(result.pendingApproval ? 201 : 201).json({
      success: true,
      message,
      data: result,
    });
  } catch (err) {
    console.error('Registration Error:', err);

    return res.status(err.statusCode || 500).json({
      success: false,
      message: err.message || 'An unexpected error occurred during registration',
      error: process.env.NODE_ENV === 'development' ? err.toString() : undefined,
    });
  }
};

exports.login = async (req, res) => {
  try {
    // Basic validation before passing to service
    if (!req.body.code || !req.body.password) {
      return res.status(400).json({
        success: false,
        message: 'Code and password are required',
      });
    }

    const result = await service.login(req.body);

    if (result.mustResetPassword) {
      return res.status(200).json({
        success: true,
        mustResetPassword: true,
        message: result.message,
        data: { userId: result.userId, email: result.email },
      });
    }

    return res.status(200).json({
      success: true,
      message: 'Login successful',
      data: result,
    });
  } catch (err) {
    console.error('Login Error:', err);

    // Check if it's an unauthorized error (e.g., wrong password)
    const statusCode = err.message === 'Invalid credentials' || err.statusCode === 401 ? 401 : (err.statusCode || 500);

    return res.status(statusCode).json({
      success: false,
      message: err.message || 'An unexpected error occurred during login',
      error: process.env.NODE_ENV === 'development' ? err.toString() : undefined,
    });
  }
};

exports.forgotPassword = async (req, res) => {
  try {
    const { email } = req.body;
    const result = await service.forgotPassword(email);

    return res.status(200).json({
      success: true,
      message: result.message,
      data: { resetToken: result.resetToken, expiresIn: result.expiresIn },
    });
  } catch (err) {
    console.error('Forgot Password Error:', err);
    return res.status(err.statusCode || 500).json({
      success: false,
      message: err.message || 'An unexpected error occurred',
      error: process.env.NODE_ENV === 'development' ? err.toString() : undefined,
    });
  }
};

exports.resetPassword = async (req, res) => {
  try {
    const { email, code, newPassword } = req.body;
    const result = await service.resetPassword({ email, code, newPassword });

    return res.status(200).json({
      success: true,
      message: result.message,
    });
  } catch (err) {
    console.error('Reset Password Error:', err);
    return res.status(err.statusCode || 500).json({
      success: false,
      message: err.message || 'An unexpected error occurred',
      error: process.env.NODE_ENV === 'development' ? err.toString() : undefined,
    });
  }
};

exports.firstLoginReset = async (req, res) => {
  try {
    const { userId, email, newPassword } = req.body;
    const result = await service.firstLoginReset({ userId, email, newPassword });

    return res.status(200).json({
      success: true,
      message: result.message,
      data: result,
    });
  } catch (err) {
    console.error('First Login Reset Error:', err);
    return res.status(err.statusCode || 500).json({
      success: false,
      message: err.message || 'An unexpected error occurred',
      error: process.env.NODE_ENV === 'development' ? err.toString() : undefined,
    });
  }
};