const ticketRepo = require('./ticket.repository');

class TicketService {

  // ── Dashboard stats ───────────────────────────────────────────────────────
  async getDashboardStats(user) {
    return await ticketRepo.getDashboardStats(user);
  }

  // ── Get tickets (role-filtered) ───────────────────────────────────────────
  async getTickets(user, filters) {
    return await ticketRepo.getVisibleTickets(user, filters);
  }

  // ── Get single ticket ─────────────────────────────────────────────────────
  async getTicket(ticketId, user) {
    const ticket = await ticketRepo.getTicketById(ticketId, user);
    if (!ticket) throw { statusCode: 404, message: 'Ticket not found' };
    if (ticket.forbidden) throw { statusCode: 403, message: 'Access denied to this ticket' };
    return ticket;
  }

  // ── Create ticket ─────────────────────────────────────────────────────────
  // All roles can create tickets
  async createTicket(data, user) {
    const { title, description, priority = 'medium', assignedDeptId, dueDate } = data;

    if (!title || !description || !assignedDeptId) {
      throw { statusCode: 400, message: 'title, description and assignedDeptId are required' };
    }

    const ticket = await ticketRepo.createTicket({
      title, description, priority, assignedDeptId, dueDate, createdBy: user,
    });

    await ticketRepo.logAction(ticket.id, user.id, 'created', null, 'open', `Created by ${user.name}`);
    return ticket;
  }

  // ── Update status ─────────────────────────────────────────────────────────
  // Manager can update any status in their dept
  // Employee can update statuses on their own self-assigned ticket
  // Only the resolver (assigned_to) or manager can close
  async updateStatus(ticketId, newStatus, user) {
    const ticket = await ticketRepo.getTicketById(ticketId, user);
    if (!ticket) throw { statusCode: 404, message: 'Ticket not found' };
    if (ticket.forbidden) throw { statusCode: 403, message: 'Access denied' };

    const allowedStatuses = ['open', 'in_progress', 'completed', 'closed'];
    if (!allowedStatuses.includes(newStatus)) {
      throw { statusCode: 400, message: 'Invalid status' };
    }

    // Only resolver or manager can close
    if (newStatus === 'closed') {
      const canClose = user.role === 'ceo' ||
        user.role === 'manager' ||
        ticket.assigned_to_id === user.id;
      if (!canClose) throw { statusCode: 403, message: 'Only the resolver or manager can close a ticket' };
    }

    const oldStatus = ticket.status;
    const updated = await ticketRepo.updateStatus(ticketId, newStatus, user);
    await ticketRepo.logAction(ticketId, user.id, 'status_changed', oldStatus, newStatus, null);
    return updated;
  }

  // ── Self-assign (employee only on open tickets) ───────────────────────────
  async selfAssign(ticketId, user) {
    if (user.role === 'ceo') throw { statusCode: 400, message: 'CEO does not self-assign' };

    const ticket = await ticketRepo.getTicketById(ticketId, user);
    if (!ticket) throw { statusCode: 404, message: 'Ticket not found' };
    if (ticket.forbidden) throw { statusCode: 403, message: 'Access denied' };
    if (ticket.status !== 'open') throw { statusCode: 400, message: 'Only OPEN tickets can be self-assigned' };

    const updated = await ticketRepo.selfAssign(ticketId, user.id);
    if (!updated) throw { statusCode: 400, message: 'Ticket already assigned' };

    await ticketRepo.logAction(ticketId, user.id, 'assigned', null, user.name, 'Self-assigned');
    return updated;
  }

  // ── Manager assigns to employee ───────────────────────────────────────────
  async assignToEmployee(ticketId, employeeId, user) {
    if (!['manager', 'ceo'].includes(user.role)) {
      throw { statusCode: 403, message: 'Only managers can assign tickets to employees' };
    }

    const ticket = await ticketRepo.getTicketById(ticketId, user);
    if (!ticket) throw { statusCode: 404, message: 'Ticket not found' };
    if (ticket.forbidden) throw { statusCode: 403, message: 'Access denied' };

    const updated = await ticketRepo.assignToEmployee(ticketId, employeeId, user.id);
    await ticketRepo.logAction(ticketId, user.id, 'assigned', null, `employee:${employeeId}`, 'Manager assigned');
    return updated;
  }

  // ── Transfer to another department ────────────────────────────────────────
  async transferTicket(ticketId, targetDeptId, user) {
    const ticket = await ticketRepo.getTicketById(ticketId, user);
    if (!ticket) throw { statusCode: 404, message: 'Ticket not found' };
    if (ticket.forbidden) throw { statusCode: 403, message: 'Access denied' };

    if (ticket.assigned_dept_id === targetDeptId) {
      throw { statusCode: 400, message: 'Ticket is already in that department' };
    }

    const oldDept = ticket.assigned_dept_code;
    const updated = await ticketRepo.transferTicket(ticketId, targetDeptId, user);
    await ticketRepo.logAction(ticketId, user.id, 'transferred', oldDept, `dept:${targetDeptId}`, 'Department transfer');
    return updated;
  }

  // ── Reopen ticket ─────────────────────────────────────────────────────────
  async reopenTicket(ticketId, user) {
    const updated = await ticketRepo.reopenTicket(ticketId, user.id);
    await ticketRepo.logAction(ticketId, user.id, 'reopened', 'closed', 'open', 'Creator reopened');
    return updated;
  }

  // ── Comments ──────────────────────────────────────────────────────────────
  async getComments(ticketId, user) {
    const ticket = await ticketRepo.getTicketById(ticketId, user);
    if (!ticket) throw { statusCode: 404, message: 'Ticket not found' };
    if (ticket.forbidden) throw { statusCode: 403, message: 'Access denied' };
    return await ticketRepo.getComments(ticketId);
  }

  async addComment(ticketId, message, user) {
    const ticket = await ticketRepo.getTicketById(ticketId, user);
    if (!ticket) throw { statusCode: 404, message: 'Ticket not found' };
    if (ticket.forbidden) throw { statusCode: 403, message: 'Access denied' };
    return await ticketRepo.addComment(ticketId, user.id, message);
  }

  // ── Departments list ──────────────────────────────────────────────────────
  async getDepartments() {
    return await ticketRepo.getDepartments();
  }
}

module.exports = new TicketService();