const repo = require('./ticket.repository');

exports.createTicket = async (ticketData) => {
  if (!ticketData.title || !ticketData.creator_id || !ticketData.target_department_id || !ticketData.company_id) {
    const error = new Error('Missing required fields for ticket creation');
    error.statusCode = 400;
    throw error;
  }
  return await repo.createTicket(ticketData);
};

exports.getTickets = async (user) => {
  // CEO sees all tickets in their company
  if (user.role === 'ceo') {
    return await repo.getTicketsByCompany(user.company_id);
  }
  
  // Managers and Users see tickets assigned to their department, OR tickets they created
  return await repo.getTicketsByDepartmentAndCreator(user.department_id, user.id);
};

exports.assignTicket = async (ticketId, user, assignee_id) => {
  const ticket = await repo.getTicketById(ticketId);
  
  if (!ticket) {
    const error = new Error('Ticket not found');
    error.statusCode = 404;
    throw error;
  }

  // A manager can assign tickets to anyone in their department
  // A user can only assign a ticket to themselves
  if (user.role === 'manager') {
    if (!assignee_id) {
      const error = new Error('Assignee ID is required for a manager');
      error.statusCode = 400;
      throw error;
    }
  } else if (user.role === 'user') {
    // Force auto-assignment to self
    assignee_id = user.id;
  } else {
    // CEO generally shouldn't be assigning tickets, or maybe they can. We'll allow CEO if assignee_id is provided.
    if (!assignee_id) {
      const error = new Error('Assignee ID is required');
      error.statusCode = 400;
      throw error;
    }
  }

  return await repo.updateTicketAssignee(ticketId, assignee_id);
};

exports.closeTicket = async (ticketId, user) => {
  const ticket = await repo.getTicketById(ticketId);
  
  if (!ticket) {
    const error = new Error('Ticket not found');
    error.statusCode = 404;
    throw error;
  }

  // ONLY resolver (assignee) can close the ticket
  if (ticket.assignee_id !== user.id && user.role !== 'ceo') { // Giving CEO override just in case, but strictly rule says only resolver
    if (ticket.assignee_id !== user.id) {
      const error = new Error('Only the assigned resolver can close this ticket');
      error.statusCode = 403;
      throw error;
    }
  }

  return await repo.closeTicket(ticketId);
};

exports.reopenTicket = async (ticketId, user) => {
  const ticket = await repo.getTicketById(ticketId);
  
  if (!ticket) {
    const error = new Error('Ticket not found');
    error.statusCode = 404;
    throw error;
  }

  // Only the creator can reopen
  if (ticket.creator_id !== user.id) {
    const error = new Error('Only the creator of the ticket can reopen it');
    error.statusCode = 403;
    throw error;
  }

  if (ticket.status !== 'closed') {
    const error = new Error('Ticket is not closed');
    error.statusCode = 400;
    throw error;
  }

  // Can only be reopened once
  if (ticket.reopen_count >= 1) {
    const error = new Error('Ticket has already been reopened the maximum number of times (1)');
    error.statusCode = 400;
    throw error;
  }

  // Must be reopened within 48 hours of being closed
  const closedAt = new Date(ticket.closed_at);
  const now = new Date();
  const diffHours = Math.abs(now - closedAt) / 36e5; // Convert ms to hours

  if (diffHours > 48) {
    const error = new Error('Ticket can only be reopened within 48 hours of being closed');
    error.statusCode = 400;
    throw error;
  }

  return await repo.reopenTicket(ticketId, ticket.reopen_count + 1);
};
