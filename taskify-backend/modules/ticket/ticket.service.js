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

  async syncParentTicketStatus(parentId, user) {
    try {
      const subTickets = await ticketRepo.getSubTicketsByParentId(parentId);
      if (subTickets.length === 0) return;

      const parent = await ticketRepo.getTicketDetails(parentId);
      if (!parent) return;

      let newStatus = 'open';
      const allClosed = subTickets.every(st => st.status === 'closed');
      const allCompletedOrClosed = subTickets.every(st => st.status === 'completed' || st.status === 'closed');
      const anyInProgressOrCompleted = subTickets.some(st => st.status === 'in_progress' || st.status === 'completed');

      if (allClosed) {
        newStatus = 'closed';
      } else if (allCompletedOrClosed) {
        newStatus = 'completed';
      } else if (anyInProgressOrCompleted) {
        newStatus = 'in_progress';
      } else {
        newStatus = 'open';
      }

      if (parent.status !== newStatus) {
        console.log(`[TicketService] Auto-syncing parent ticket ${parentId} status from ${parent.status} to ${newStatus}`);
        await ticketRepo.updateStatus(parentId, newStatus, user);
        await ticketRepo.logAction(
          parentId,
          user.id,
          'status_changed',
          parent.status,
          newStatus,
          `Parent ticket status automatically synced to ${newStatus} based on sub-tickets.`
        );

        // Notify creator of parent ticket
        const participants = await ticketRepo.getTicketParticipants(parentId);
        await this._dispatch(parentId, participants, `Parent Ticket #${parentId} status changed to ${newStatus}`, 'TICKET_STATUS_UPDATED', { ticket: await ticketRepo.getTicketDetails(parentId) });
      }
    } catch (err) {
      console.error('Error syncing parent ticket status:', err);
    }
  }

  async createTicket(data, user) {
    const { title, description, priority = 'medium', assignedDeptId, assignedDeptIds = [], dueDate } = data;

    // Ensure assignedToId is handled as a number or null
    const assignedToId = data.assignedToId != null ? Number(data.assignedToId) : null;

    if (!title || !description || title.trim() === '' || description.trim() === '') {
      throw { statusCode: 400, message: 'title and description are required' };
    }

    // Requirement: Every ticket is a 'subticket'
    const targetDepts = assignedDeptIds.length > 0 ? assignedDeptIds : [assignedDeptId];
    if (targetDepts.some(id => id == null)) throw { statusCode: 400, message: 'Valid department assignment required' };

    const ticket = await ticketRepo.createTicket({
      title,
      description,
      priority,
      assignedDeptId: targetDepts[0], // Primary department
      dueDate,
      createdBy: user,
      assignedToId,
      parentId: null,
      tag: 'subticket'
    });

    // Create department trail entries (Separate table tracking)
    await ticketRepo.createDepartmentAssignments(ticket.id, targetDepts);

    const logNote = `Sub-ticket created by ${user.name} with department trail: ${targetDepts.join(', ')}`;
    await ticketRepo.logAction(ticket.id, user.id, 'created', null, ticket.status, logNote);

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
    const isCeo = user.role === 'ceo';

    console.log(`[TicketService] Attempting to update ticket ${ticketId} status from ${ticket.status} to ${newStatus} by user ${user.id}`);

    // Only the resolver or CEO can mark a ticket as completed
    if (newStatus === 'completed') {
      if (!isResolver && !isCeo) {
        throw { statusCode: 403, message: 'Only the assigned resolver can mark this ticket as completed' };
      }
    }

    if (newStatus === 'closed') {
      // Workflow: Cannot close until all department heads have approved
      if (ticket.dept_assignments && ticket.dept_assignments.length > 0) {
        const allDone = ticket.dept_assignments.every(da => da.manager_approved === true);
        if (!allDone) {
          throw { statusCode: 400, message: 'Cannot close. All departments in the trail must be approved by their heads first.' };
        }
      }
      if (!isCreator && !isCeo) {
        throw { statusCode: 403, message: 'Only the creator can finalize and close this ticket' };
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

    // Real-time update for creator and assignee
    const participants = await ticketRepo.getTicketParticipants(ticketId);
    await this._dispatch(ticketId, participants, `Ticket #${ticketId} status changed to ${newStatus}`, 'TICKET_STATUS_UPDATED', { ticket: updated });

    if (updated.parent_id) {
      await this.syncParentTicketStatus(updated.parent_id, user);
    }

    return updated;
  }

  async markDepartmentTaskDone(ticketId, user) {
    // 1. Employee marks it done
    const assignment = await ticketRepo.updateDeptAssignment(ticketId, user.department_id, 'employee_done', true);
    await ticketRepo.logAction(ticketId, user.id, 'dept_task_done', 'false', 'true', `Employee ${user.name} marked department task as done.`);

    // Notify department managers to approve
    const managers = await ticketRepo.getManagersByDepartment(user.department_id);
    await this._dispatch(ticketId, managers, `Task in Ticket #${ticketId} needs manager approval for your department.`);
    return assignment;
  }

  async approveDepartmentTask(ticketId, deptId, user) {
    if (user.role !== 'manager') throw { statusCode: 403, message: 'Only managers can approve department completion.' };

    // 2. Department head approves
    const assignment = await ticketRepo.updateDeptAssignment(ticketId, deptId, 'manager_approved', true);
    await ticketRepo.logAction(ticketId, user.id, 'dept_task_approved', 'false', 'true', `Manager ${user.name} approved department completion.`);

    // 3. Notify Creator
    const ticket = await ticketRepo.getTicketDetails(ticketId);
    await this._dispatch(ticketId, [ticket.created_by_id], `Department ${deptId} has completed their assignment in Ticket #${ticketId}.`);
    return assignment;
  }
  async selfAssign(ticketId, user) {
    if (user.role === 'ceo') {
      throw { statusCode: 400, message: 'CEO does not self-assign' };
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

    if (updated.parent_id) {
      await this.syncParentTicketStatus(updated.parent_id, user);
    }

    return updated;
  }

  async assignToEmployee(ticketId, employeeId, user) {
    if (!['manager', 'ceo'].includes(user.role)) {
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

    if (updated.parent_id) {
      await this.syncParentTicketStatus(updated.parent_id, user);
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

    // Permission Check: CEO cannot transfer, and if assigned, only the resolver can transfer
    if (user.role === 'ceo') throw { statusCode: 403, message: 'CEO is not authorized to transfer tickets' };

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

    if (updated.parent_id) {
      await this.syncParentTicketStatus(updated.parent_id, user);
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

    if (updated.parent_id) {
      await this.syncParentTicketStatus(updated.parent_id, user);
    }

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
