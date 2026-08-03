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

// ── CRUD ──────────────────────────────────────────────────────
router.get('/disputes', controller.listDisputes);
router.get('/', controller.getTickets);
router.get('/:id', controller.getTicket);
router.post('/', controller.createTicket);
router.patch('/:id', controller.updateTicket);

// ── Actions ───────────────────────────────────────────────────
router.patch('/:id/status', controller.updateStatus);
router.patch('/:id/dispute', isManager, controller.dispute);
router.patch('/:id/self-assign', controller.selfAssign);
router.patch('/:id/assign', isManager, controller.assignToEmployee);
router.patch('/:id/transfer', controller.transferTicket);
router.patch('/:id/reopen', controller.reopenTicket);

// ── Disputes (review workflow) ────────────────────────────────
router.get('/:id/dispute', controller.getDisputeByTicket);
router.post('/:id/dispute', controller.raiseDispute);
router.post('/disputes/:disputeId/comments', controller.addDisputeComment);
router.patch('/disputes/:disputeId/status', controller.updateDisputeStatus);
router.post('/disputes/:disputeId/withdraw', controller.withdrawDispute);

// ── Comments & History ────────────────────────────────────────
router.get('/:id/comments', controller.getComments);
router.post('/:id/comments', controller.addComment);
router.get('/:id/logs', controller.getTicketLogs);

module.exports = router;
