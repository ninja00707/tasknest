const service = require('./auth.service');

exports.register = async (req, res) => {
  try {
    const user = await service.register(req.body);

    return res.status(201).json({
      success: true,
      message: 'User registered successfully',
      data: user,
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
    if (!req.body.email || !req.body.password) {
      return res.status(400).json({
        success: false,
        message: 'Email and password are required',
      });
    }

    const result = await service.login(req.body);

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
    });
  } catch (err) {
    console.error('Forgot Password Error:', err);
    
    return res.status(err.statusCode || 500).json({
      success: false,
      message: err.message || 'An unexpected error occurred during password reset',
      error: process.env.NODE_ENV === 'development' ? err.toString() : undefined,
    });
  }
};