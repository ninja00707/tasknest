const express = require('express');
const router = express.Router();
const controller = require('./ticket.controller');
const { authenticate, isManager, isCeo } = require('./Auth.middleware');

// All ticket routes require authentication
router.use(authenticate);

// ── Analytics (MUST be defined above /:id) ───────────────────
router.get('/analytics/by-department', isCeo, controller.getAnalyticsByDepartment);
router.get('/analytics/organization', isCeo, controller.getOrganizationAnalytics);
router.get('/analytics/department/:departmentId', isManager, controller.getDepartmentAnalytics);

// ── Stats & Departments ───────────────────────────────────────
router.get('/stats', controller.getStats);
router.get('/departments', controller.getDepartments);
router.get('/employees', isManager, controller.getEmployees);
router.get('/sent-tickets', controller.getSentTickets);

// ── CRUD ──────────────────────────────────────────────────────
router.get('/', controller.getTickets);
router.get('/:id', controller.getTicket);
router.post('/', controller.createTicket);

// ── Actions ───────────────────────────────────────────────────
router.patch('/:id/status', controller.updateStatus);
router.patch('/:id/self-assign', controller.selfAssign);
router.patch('/:id/assign', isManager, controller.assignToEmployee);
router.patch('/:id/transfer', controller.transferTicket);
router.patch('/:id/reopen', controller.reopenTicket);

// ── Comments & History ────────────────────────────────────────
router.get('/:id/comments', controller.getComments);
router.post('/:id/comments', controller.addComment);
router.get('/:id/logs', controller.getTicketLogs);

module.exports = router;
