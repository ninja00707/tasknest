const express = require('express');
const router = express.Router();
const controller = require('./ticket.controller');
const { authenticate, isManager, isCeo, isDepManager } = require('./Auth.middleware');

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

// ── Sub-Tickets (MUST be above /:id) ─────────────────────────
router.post('/sub-tickets', isDepManager, controller.createSubTicket);
router.patch('/:id/sub-departments/:deptId', controller.updateSubDeptProgress);
router.patch('/:id/sub-departments/:deptId/assign', isManager, controller.assignSubDeptToEmployee);
router.patch('/:id/sub-departments/:deptId/self-assign', controller.selfAssignSubDept);
router.post('/:id/complete', controller.completeSubTicket);
router.patch('/:id/sub-departments/:deptId/reopen', controller.reopenSubDept);

// ── Standard & Multi Tickets (MUST be above /:id) ─────────────
router.post('/standard-tickets', controller.createStandardTicket);
router.get('/standard-tickets', controller.getStandardTickets);
router.post('/multi-tickets', controller.createMultiTicket);

// ── V2 Flow Actions ───────────────────────────────────────────
router.patch('/:id/mark-complete', controller.markComplete);
router.patch('/:id/close', controller.closeTicket);
router.post('/:id/sub-tickets', controller.createSubTicketV2);
router.get('/:id/descendants', controller.getDescendants);
router.get('/:id/children', controller.getChildren);

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

// ── Child tickets & Hierarchy ─────────────────────────────────
router.post('/:id/child-tickets', controller.createChildTicket);
router.get('/:id/children', controller.getChildTickets);

// ── Comments & History ────────────────────────────────────────
router.get('/:id/comments', controller.getComments);
router.post('/:id/comments', controller.addComment);
router.get('/:id/logs', controller.getTicketLogs);

module.exports = router;
