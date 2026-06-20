const router = require('express').Router();
const controller = require('./admin.controller');
const { authenticate } = require('../ticket/auth.middleware');

// ── Admin Guard ─────────────────────────────────────────────────────────
const isAdmin = (req, res, next) => {
  if (!['ceo', 'developer'].includes(req.user.role) && req.user.email !== 'qasim@um.com') {
    return res.status(403).json({ success: false, message: 'Admin access required' });
  }
  next();
};

router.use(authenticate, isAdmin);

// Stats
router.get('/stats', controller.getStats);

// Users
router.get('/users', controller.listUsers);
router.get('/users/pending', controller.listPendingUsers);
router.get('/users/activity', controller.getUserActivity);
router.get('/users/:id', controller.getUser);
router.post('/users', controller.createUser);
router.patch('/users/:id', controller.updateUser);
router.patch('/users/:id/approve', controller.approveUser);
router.delete('/users/:id', controller.deleteUser);

// Departments
router.get('/departments', controller.listDepartments);
router.get('/departments/:id', controller.getDepartment);
router.post('/departments', controller.createDepartment);
router.patch('/departments/:id', controller.updateDepartment);
router.delete('/departments/:id', controller.deleteDepartment);

// Tickets
router.get('/tickets', controller.listTickets);
router.get('/tickets/:id', controller.getTicket);
router.patch('/tickets/:id', controller.updateTicket);
router.delete('/tickets/:id', controller.deleteTicket);

module.exports = router;
