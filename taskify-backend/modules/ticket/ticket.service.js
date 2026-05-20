const ticketRepo = require('./ticket.repository');

class TicketService {
  async getDashboardStats(user) {
    if (!user) throw { statusCode: 401, message: 'Unauthorized' };
    return await ticketRepo.getDashboardStats(user);
  }

  async getTickets(user, filters) {
    if (!user) throw { statusCode: 401, message: 'Unauthorized' };
    return await ticketRepo.getVisibleTickets(user, filters);
  }

  async getTicket(ticketId, user) {
    if (!user) throw { statusCode: 401, message: 'Unauthorized' };
    const ticket = await ticketRepo.getTicketById(ticketId, user);
    if (!ticket) throw { statusCode: 404, message: 'Ticket not found' };
    if (ticket.forbidden) throw { statusCode: 403, message: 'Access denied to this ticket' };
    return ticket;
  }

  async createTicket(data, user) {
    const { title, description, priority = 'medium', assignedDeptId, dueDate, assignedToId } = data;

    if (!title || !description || title.trim() === '' || description.trim() === '' || assignedDeptId == null) {
      throw { statusCode: 400, message: 'title, description and assignedDeptId are required' };
    }

    const ticket = await ticketRepo.createTicket({
      title,
      description,
      priority,
      assignedDeptId,
      dueDate,
      createdBy: user,
      assignedToId,
    });

    await ticketRepo.logAction(
      ticket.id,
      user.id,
      'created',
      null,
      ticket.status,
      `Created by ${user.name}${assignedToId ? ` and assigned to employee ID ${assignedToId}` : ''}`
    );

    return ticket;
  }

  async updateStatus(ticketId, newStatus, user) {
    const ticket = await ticketRepo.getTicketById(ticketId, user);
    if (!ticket) throw { statusCode: 404, message: 'Ticket not found' };
    if (ticket.forbidden) throw { statusCode: 403, message: 'Access denied' };

    const allowedStatuses = ['open', 'in_progress', 'completed', 'closed'];
    if (!allowedStatuses.includes(newStatus)) {
      throw { statusCode: 400, message: 'Invalid status' };
    }

    if (newStatus === 'closed') {
      // Only the resolver (assigned_to_id) can close the ticket
      const isResolver = ticket.assigned_to_id === user.id;
      const isCeo = user.role === 'ceo';
      
      if (!isResolver && !isCeo) {
        throw {
          statusCode: 403,
          message: 'Only the person assigned to this ticket can close it',
        };
      }
    }

    const oldStatus = ticket.status;
    const updated = await ticketRepo.updateStatus(ticketId, newStatus, user);
    await ticketRepo.logAction(ticketId, user.id, 'status_changed', oldStatus, newStatus, null);
    return updated;
  }

  async selfAssign(ticketId, user) {
    if (user.role === 'ceo') {
      throw { statusCode: 400, message: 'CEO does not self-assign' };
    }

    const ticket = await ticketRepo.getTicketById(ticketId, user);
    if (!ticket) throw { statusCode: 404, message: 'Ticket not found' };
    if (ticket.forbidden) throw { statusCode: 403, message: 'Access denied' };
    if (ticket.status !== 'open') {
      throw { statusCode: 400, message: 'Only OPEN tickets can be self-assigned' };
    }

    const updated = await ticketRepo.selfAssign(ticketId, user.id);
    if (!updated) throw { statusCode: 400, message: 'Ticket already assigned' };

    await ticketRepo.logAction(ticketId, user.id, 'assigned', null, user.name, 'Self-assigned');
    return updated;
  }

  async assignToEmployee(ticketId, employeeId, user) {
    if (!['manager', 'ceo'].includes(user.role)) {
      throw { statusCode: 403, message: 'Only managers can assign tickets to employees' };
    }

    const ticket = await ticketRepo.getTicketById(ticketId, user);
    if (!ticket) throw { statusCode: 404, message: 'Ticket not found' };
    if (ticket.forbidden) throw { statusCode: 403, message: 'Access denied' };

    const updated = await ticketRepo.assignToEmployee(ticketId, employeeId, user.id);
    if (!updated) throw { statusCode: 400, message: 'Unable to assign ticket' };

    await ticketRepo.logAction(
      ticketId,
      user.id,
      'assigned',
      null,
      `employee:${employeeId}`,
      'Manager assigned'
    );

    return updated;
  }

  async transferTicket(ticketId, targetDeptId, user) {
    const ticket = await ticketRepo.getTicketById(ticketId, user);
    if (!ticket) throw { statusCode: 404, message: 'Ticket not found' };
    if (ticket.forbidden) throw { statusCode: 403, message: 'Access denied' };

    // Prevent transferring open tickets
    if (ticket.status === 'open') {
      throw { statusCode: 400, message: 'Cannot transfer open tickets. Assign the ticket first.' };
    }

    if (Number(ticket.assigned_dept_id) === Number(targetDeptId)) {
      throw { statusCode: 400, message: 'Ticket is already in that department' };
    }

    const updated = await ticketRepo.transferTicket(ticketId, targetDeptId, user);
    if (!updated) throw { statusCode: 400, message: 'Unable to transfer ticket' };

    await ticketRepo.logAction(
      ticketId,
      user.id,
      'transferred',
      ticket.assigned_dept_code,
      `dept:${targetDeptId}`,
      'Department transfer'
    );

    return updated;
  }

  async reopenTicket(ticketId, user) {
    const updated = await ticketRepo.reopenTicket(ticketId, user.id);
    if (!updated) throw { statusCode: 400, message: 'Unable to reopen ticket' };

    await ticketRepo.logAction(ticketId, user.id, 'reopened', 'closed', 'open', 'Creator reopened');
    return updated;
  }

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

  async getDepartments() {
    return await ticketRepo.getDepartments();
  }

  async getEmployees(user, departmentId) {
    const deptId = departmentId ? Number(departmentId) : Number(user.department_id);
    if (deptId === undefined || isNaN(deptId)) {
      throw { statusCode: 400, message: 'Department ID is required' };
    }
    return await ticketRepo.getEmployeesByDepartment(deptId);
  }

  async getSentTickets(user) {
    return await ticketRepo.getSentTicketsByDepartment(user.department_id);
  }

  async getTicketLogs(ticketId, user) {
    const ticket = await ticketRepo.getTicketById(ticketId, user);
    if (!ticket) throw { statusCode: 404, message: 'Ticket not found' };
    if (ticket.forbidden) throw { statusCode: 403, message: 'Access denied' };
    return await ticketRepo.getTicketLogs(ticketId);
  }

  async getAnalyticsByDepartment() {
    return await ticketRepo.getAnalyticsByDepartment();
  }
}

module.exports = new TicketService();
