const router = require('express').Router();
const ticketController = require('./ticket.controller');

// Create a new ticket
router.post('/', ticketController.createTicket);

// Get tickets based on user role and department
router.get('/', ticketController.getTickets);

// Manager assigns a ticket to a user (or a user auto-assigns themselves)
router.put('/:id/assign', ticketController.assignTicket);

// Resolver closes a ticket
router.put('/:id/close', ticketController.closeTicket);

// Creator reopens a ticket
router.put('/:id/reopen', ticketController.reopenTicket);

module.exports = router;
