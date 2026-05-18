const express = require('express');
const router = express.Router();
const controller = require('./ticket.controller');
const { authenticate, isManager } = require('./Auth.middleware');

// All ticket routes require authentication
router.use(authenticate);

// ── Stats & Departments ───────────────────────────────────────
router.get('/stats', controller.getStats);
router.get('/departments', controller.getDepartments);

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

// ── Comments ──────────────────────────────────────────────────
router.get('/:id/comments', controller.getComments);
router.post('/:id/comments', controller.addComment);

module.exports = router;