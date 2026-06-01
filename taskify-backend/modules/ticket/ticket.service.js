const ticketRepo = require('./ticket.repository');

class TicketService {
  // ── Real-Time Notification Dispatcher ────────────────────────────────────
  async _dispatch(ticketId, userIds, message, eventType = 'NOTIFICATION', payload = {}) {
    for (const userId of userIds) {
      // 1. Persist to DB
      await ticketRepo.createNotification(userId, ticketId, message);

      // 2. Push Real-Time via Socket.io
      if (global.io) {
        global.io.to(`user_${userId}`).emit(eventType, {
          ticketId,
          message,
          ...payload
        });
      }
    }
  }

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

    // Automatically attach full history/logs whenever a ticket is viewed in detail
    ticket.history = await ticketRepo.getTicketLogs(ticketId);
    return ticket;
  }

  async createTicket(data, user) {
    const { title, description, priority = 'medium', assignedDeptId, assignedDeptIds, dueDate } = data;

    // Ensure assignedToId is handled as a number or null
    const assignedToId = data.assignedToId != null ? Number(data.assignedToId) : null;

    if (!title || !description || title.trim() === '' || description.trim() === '' || (assignedDeptId == null && (!assignedDeptIds || assignedDeptIds.length === 0))) {
      throw { statusCode: 400, message: 'title, description and target department(s) are required' };
    }

    // If multiple departments are provided, create a parent ticket and multiple sub-tickets
    if (assignedDeptIds && assignedDeptIds.length > 0) {
      const parentTicket = await ticketRepo.createTicket({
        title: `[MASTER] ${title}`,
        description,
        priority,
        assignedDeptId: user.department_id, // Rooted in creator's dept
        dueDate,
        createdBy: user,
        assignedToId: null,
      });

      for (const deptId of assignedDeptIds) {
        await ticketRepo.createTicket({
          title,
          description,
          priority,
          assignedDeptId: deptId,
          dueDate,
          createdBy: user,
          assignedToId: null,
          parentId: parentTicket.id
        });
        const managers = await ticketRepo.getManagersByDepartment(deptId);
        await this._dispatch(parentTicket.id, managers, `New Task for your department: ${title}`, 'TICKET_CREATED');
      }

      return parentTicket;
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

    const logNote = `Created by ${user.name}${assignedToId ? ` and assigned to ${ticket.assigned_to_name}` : ''}`;
    await ticketRepo.logAction(ticket.id, user.id, 'created', null, ticket.status, logNote);

    // Notify target department managers
    const managers = await ticketRepo.getManagersByDepartment(assignedDeptId);
    await this._dispatch(ticket.id, managers, `New Ticket Created: ${title}`, 'TICKET_CREATED', { ticket });

    // If auto-assigned, notify the employee
    if (assignedToId) {
      await this._dispatch(ticket.id, [assignedToId], `You have been assigned to Ticket #${ticket.id}`, 'TICKET_ASSIGNED');
    }

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

    const isResolver = ticket.assigned_to_id === user.id;
    const isCreator = ticket.created_by_id === user.id;
    const isDirector = user.role === 'directors';
    const isDeptManager = user.role === 'manager' && Number(user.department_id) === Number(ticket.assigned_dept_id);

    console.log(`[TicketService] Attempting to update ticket ${ticketId} status from ${ticket.status} to ${newStatus} by user ${user.id}`);

    // Only the resolver or a Director who created the ticket can mark it as completed
    if (newStatus === 'completed') {
      if (!isResolver && !(isDirector && isCreator)) {
        throw { statusCode: 403, message: 'Only the assigned resolver or the creator (if Director) can mark this ticket as completed' };
      }
    }

    // Only the creator or the department manager (approval) can mark a ticket as closed
    if (newStatus === 'closed') {
      if (!isCreator && !isDeptManager) {
        throw { statusCode: 403, message: 'Only the creator or department manager can approve/finalize this ticket' };
      }
    }

    // If ticket is completed, it can only be closed or reopened (reopen via different method)
    if (ticket.status === 'completed' && newStatus !== 'closed') {
      throw { statusCode: 400, message: 'Ticket is already completed. It can only be finalized and closed or reopened.' };
    }

    if (ticket.status === 'closed') {
      throw { statusCode: 400, message: 'Ticket is already closed. It must be reopened first.' };
    }

    const oldStatus = ticket.status;
    console.log(`[TicketService] Calling ticketRepo.updateStatus with ticketId: ${ticketId}, newStatus: ${newStatus}, userId: ${user.id}`);
    const updated = await ticketRepo.updateStatus(ticketId, newStatus, user);
    await ticketRepo.logAction(ticketId, user.id, 'status_changed', oldStatus, newStatus, `Status updated to ${newStatus} by ${user.name}`);

    // Hierarchy Logic: If a sub-ticket is closed (Approved), check if parent should be marked as 100% complete
    if (updated.parent_id && newStatus === 'closed') {
      const siblings = await ticketRepo.getSubTickets(updated.parent_id);
      const allClosed = siblings.every(s => s.status === 'closed');

      if (allClosed) {
        const parentTicket = await ticketRepo.getTicketById(updated.parent_id, { role: 'directors' });
        if (parentTicket && parentTicket.status !== 'completed') {
          // Automatically mark parent as completed once all departments are approved
          await ticketRepo.updateStatus(parentTicket.id, 'completed', { id: user.id, name: 'System (Auto)' });
          await ticketRepo.logAction(parentTicket.id, user.id, 'status_changed', parentTicket.status, 'completed', 'All departmental tasks approved. Ticket is 100% completed.');

          // Notify HR (original creator)
          await this._dispatch(parentTicket.id, [parentTicket.created_by_id], `Master Ticket #${parentTicket.id} is now 100% completed.`, 'TICKET_STATUS_UPDATED');
        }
      } else {
        // Notify HR (creator) that one department has finished their task
        const creatorId = (await ticketRepo.getTicketById(updated.parent_id, { role: 'directors' })).created_by_id;
        await this._dispatch(updated.parent_id, [creatorId], `Department ${updated.assigned_dept_name} has approved completion of their task for Ticket #${updated.parent_id}`, 'TICKET_UPDATED');
      }
    }

    const participants = await ticketRepo.getTicketParticipants(ticketId);
    await this._dispatch(ticketId, participants, `Ticket #${ticketId} status changed to ${newStatus}`, 'TICKET_STATUS_UPDATED', { ticket: updated });

    return updated;
  }

  async selfAssign(ticketId, user) {
    if (user.role === 'directors') {
      throw { statusCode: 400, message: 'Directors do not self-assign' };
    }

    const ticketBeforeUpdate = await ticketRepo.getTicketById(ticketId, user);
    if (!ticketBeforeUpdate) throw { statusCode: 404, message: 'Ticket not found' };
    if (ticketBeforeUpdate.forbidden) throw { statusCode: 403, message: 'Access denied' };
    if (ticketBeforeUpdate.status !== 'open') {
      throw { statusCode: 400, message: 'Only OPEN tickets can be self-assigned' };
    }

    const updated = await ticketRepo.selfAssign(ticketId, user.id);
    if (!updated) throw { statusCode: 400, message: 'Ticket already assigned' };

    // Log the assignment
    await ticketRepo.logAction(
      ticketId,
      user.id,
      'assigned',
      'Unassigned',
      user.name,
      'Self-assigned'
    );

    // Log the automatic status change to in_progress
    await ticketRepo.logAction(ticketId, user.id, 'status_changed', 'open', 'in_progress', 'Status changed via self-assignment');

    return updated;
  }

  async assignToEmployee(ticketId, employeeId, user) {
    if (!['manager', 'directors'].includes(user.role)) {
      throw { statusCode: 403, message: 'Only managers can assign tickets to employees' };
    }

    const ticketBeforeUpdate = await ticketRepo.getTicketById(ticketId, user);
    if (!ticketBeforeUpdate) throw { statusCode: 404, message: 'Ticket not found' };
    if (ticketBeforeUpdate.forbidden) throw { statusCode: 403, message: 'Access denied' };

    // Actions are disabled for completed or closed tickets
    if (ticketBeforeUpdate.status === 'completed' || ticketBeforeUpdate.status === 'closed') {
      throw { statusCode: 400, message: 'Cannot assign a ticket that is already completed or closed' };
    }

    const updated = await ticketRepo.assignToEmployee(ticketId, employeeId, user.id);
    if (!updated) throw { statusCode: 400, message: 'Unable to assign ticket' };

    const assignedEmployee = await ticketRepo.getUserById(employeeId);
    const assignedEmployeeName = assignedEmployee ? assignedEmployee.name : `Unknown Employee (ID: ${employeeId})`;

    await ticketRepo.logAction(
      ticketId,
      user.id,
      'assigned',
      ticketBeforeUpdate.assigned_to_name || 'Unassigned',
      assignedEmployeeName,
      `Manager ${user.name} assigned the ticket.`
    );

    // Notify employee
    await this._dispatch(ticketId, [employeeId], `Manager ${user.name} assigned you to Ticket #${ticketId}`, 'TICKET_ASSIGNED');

    // Log status change if it went from 'open' to 'in_progress'
    if (ticketBeforeUpdate.status === 'open' && updated.status === 'in_progress') {
      await ticketRepo.logAction(
        ticketId,
        user.id,
        'status_changed',
        ticketBeforeUpdate.status,
        updated.status,
        'Status changed due to assignment'
      );
    }

    return updated;
  }

  async transferTicket(ticketId, targetDeptId, user) {
    const ticketBeforeUpdate = await ticketRepo.getTicketById(ticketId, user);
    if (!ticketBeforeUpdate) throw { statusCode: 404, message: 'Ticket not found' };
    if (ticketBeforeUpdate.forbidden) throw { statusCode: 403, message: 'Access denied' };

    // Actions are disabled for completed or closed tickets
    if (ticketBeforeUpdate.status === 'completed' || ticketBeforeUpdate.status === 'closed') {
      throw { statusCode: 400, message: 'Cannot transfer a ticket that is already completed or closed' };
    }

    // Permission Check: Directors cannot transfer, and if assigned, only the resolver can transfer
    if (user.role === 'directors') throw { statusCode: 403, message: 'Directors are not authorized to transfer tickets' };

    if (ticketBeforeUpdate.assigned_to_id && ticketBeforeUpdate.assigned_to_id !== user.id) {
      throw { statusCode: 403, message: 'Only the assigned resolver can transfer this ticket' };
    }
    if (Number(ticketBeforeUpdate.assigned_dept_id) === Number(targetDeptId)) {
      throw { statusCode: 400, message: 'Ticket is already in that department' };
    }

    const updated = await ticketRepo.transferTicket(ticketId, targetDeptId, user);
    if (!updated) throw { statusCode: 400, message: 'Unable to transfer ticket' };

    // Log department transfer
    await ticketRepo.logAction(
      ticketId,
      user.id,
      'transferred',
      ticketBeforeUpdate.assigned_dept_name,
      updated.assigned_dept_name, // Use the name of the new department
      `Transferred from ${ticketBeforeUpdate.assigned_dept_name} to ${updated.assigned_dept_name}.`
    );

    // Notify new department managers
    const newManagers = await ticketRepo.getManagersByDepartment(targetDeptId);
    await this._dispatch(ticketId, newManagers, `Ticket #${ticketId} transferred to your department`, 'TICKET_TRANSFERRED');
    await this._dispatch(ticketId, [ticketBeforeUpdate.created_by_id], `Your ticket was transferred to ${updated.assigned_dept_name}`, 'TICKET_UPDATED');

    // Log unassignment if it happened
    if (ticketBeforeUpdate.assigned_to_id !== null) {
      await ticketRepo.logAction(
        ticketId,
        user.id,
        'assigned',
        ticketBeforeUpdate.assigned_to_name,
        'Unassigned',
        'Unassigned due to transfer'
      );
    }

    // Log status change to 'open'
    if (ticketBeforeUpdate.status !== 'open') {
      await ticketRepo.logAction(
        ticketId,
        user.id,
        'status_changed',
        ticketBeforeUpdate.status,
        updated.status, // 'open'
        'Status changed to open due to transfer'
      );
    }
    return updated;
  }

  async reopenTicket(ticketId, user) {
    const ticket = await ticketRepo.getTicketById(ticketId, user);
    if (!ticket) throw { statusCode: 404, message: 'Ticket not found' };
    if (ticket.forbidden) throw { statusCode: 403, message: 'Access denied' };

    const oldStatus = ticket.status;

    const updated = await ticketRepo.reopenTicket(ticketId, user.id);
    if (!updated) throw { statusCode: 400, message: 'Unable to reopen ticket' };

    await ticketRepo.logAction(ticketId, user.id, 'reopened', oldStatus, 'in_progress', `Ticket reopened by creator (${user.name}) and returned to "In Progress" status.`);

    // Notify participants (Creator and Resolver) that the ticket is active again
    const participants = await ticketRepo.getTicketParticipants(ticketId);
    await this._dispatch(ticketId, participants, `Ticket #${ticketId} has been reopened and is now In Progress.`, 'TICKET_REOPENED', { ticket: updated });

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
    const comment = await ticketRepo.addComment(ticketId, user.id, message);

    await ticketRepo.logAction(
      ticketId,
      user.id,
      'comment_added',
      null,
      message.substring(0, 100), // Log first 100 chars of comment
      `Comment added by ${user.name}`
    );

    // Notify participants
    const participants = (await ticketRepo.getTicketParticipants(ticketId)).filter(id => id !== user.id);
    await this._dispatch(ticketId, participants, `${user.name} commented on Ticket #${ticketId}`, 'COMMENT_ADDED');

    return comment;
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

  async getMyTickets(user, filters) {
    return await ticketRepo.getMyTickets(user.id, filters);
  }

  async getSentTickets(user) {
    return await ticketRepo.getSentTicketsByDepartment(user.department_id);
  }

  async getDepartmentAnalytics(departmentId) {
    return await ticketRepo.getDashboardStats({
      role: 'manager',
      department_id: Number(departmentId)
    });
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

  async getOrganizationAnalytics() {
    return await ticketRepo.getAnalyticsByDepartment(); // Reusing the existing repo method for now
  }
}

module.exports = new TicketService();
