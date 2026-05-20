const jwt = require('jsonwebtoken');
require('dotenv').config();
const pool = require('../../database/db');

// ── Verify JWT ────────────────────────────────────────────────────────────────
const authenticate = async (req, res, next) => {
    try {
        const authHeader = req.headers.authorization;
        if (!authHeader || !authHeader.startsWith('Bearer ')) {
            return res.status(401).json({ success: false, message: 'No token provided' });
        }

        const token = authHeader.split(' ')[1];
        const decoded = jwt.verify(token, process.env.JWT_SECRET);

        // Attach full user from DB (so we always have fresh role/dept)
        // Use LEFT JOIN for departments to handle cases where department_id is NULL
        const result = await pool.query(
            `SELECT u.id, u.name, u.email, u.department_id, u.company_id,
              r.name AS role, COALESCE(d.code, '') AS dept_code, COALESCE(d.tier, '0') AS dept_tier,
              COALESCE(d.parent_id, NULL) AS dept_parent_id
       FROM users u
       JOIN roles r ON r.id = u.role_id
       LEFT JOIN departments d ON d.id = u.department_id
       WHERE u.id = $1 AND u.is_active = TRUE`,
            [decoded.id]
        );

        if (result.rows.length === 0) {
            return res.status(401).json({ success: false, message: 'User not found or inactive' });
        }

        req.user = result.rows[0];
        next();
    } catch (err) {
        console.error('JWT Verification Error:', err.message);
        return res.status(401).json({ success: false, message: 'Invalid or expired token' });
    }
};

// ── Role Guards ───────────────────────────────────────────────────────────────
const isCeo = (req, res, next) => {
    if (req.user.role !== 'ceo') {
        return res.status(403).json({ success: false, message: 'CEO access required' });
    }
    next();
};

const isManager = (req, res, next) => {
    if (!['ceo', 'manager'].includes(req.user.role)) {
        return res.status(403).json({ success: false, message: 'Manager access required' });
    }
    next();
};

const isEmployee = (req, res, next) => {
    if (!['ceo', 'manager', 'employee'].includes(req.user.role)) {
        return res.status(403).json({ success: false, message: 'Access denied' });
    }
    next();
};

module.exports = { authenticate, isCeo, isManager, isEmployee };