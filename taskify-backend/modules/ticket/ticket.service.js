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
    const tickets = await ticketRepo.getVisibleTickets(user, filters);
    return await ticketRepo.enrichTicketsWithSubData(tickets);
  }

  async getTicket(ticketId, user) {
    if (!user) throw { statusCode: 401, message: 'Unauthorized' };
    const ticket = await ticketRepo.getTicketById(ticketId, user);
    if (!ticket) throw { statusCode: 404, message: 'Ticket not found' };
    if (ticket.forbidden) throw { statusCode: 403, message: 'Access denied to this ticket' };

    await ticketRepo.enrichTicketWithSubData(ticket);
    ticket.history = await ticketRepo.getTicketLogs(ticketId);
    return ticket;
  }

  async createTicket(data, user) {
    const { title, description, priority = 'medium', assignedDeptId, dueDate } = data;

    // Ensure assignedToId is handled as a number or null
    const assignedToId = data.assignedToId != null ? Number(data.assignedToId) : null;

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

  async createSubTicket(data, user) {
    if (user.role !== 'manager') {
      throw { statusCode: 403, message: 'Only department managers can create sub-tickets' };
    }

    const { title, description, priority = 'medium', dueDate, departments } = data;

    if (!title || !description || title.trim() === '' || description.trim() === '') {
      throw { statusCode: 400, message: 'title and description are required' };
    }

    if (!Array.isArray(departments) || departments.length < 2) {
      throw { statusCode: 400, message: 'Sub-tickets require at least 2 departments with task descriptions' };
    }

    const normalizedDepts = departments.map((d) => ({
      departmentId: d.departmentId ?? d.department_id,
      taskDescription: String(d.taskDescription ?? d.task_description ?? '').trim(),
    }));

    for (const dept of normalizedDepts) {
      const deptId = dept.departmentId;
      const hasValidId =
        deptId !== null &&
        deptId !== undefined &&
        deptId !== '' &&
        !Number.isNaN(Number(deptId));

      if (!hasValidId || !dept.taskDescription) {
        throw { statusCode: 400, message: 'Each department must have a departmentId and taskDescription' };
      }
    }

    const deptIds = normalizedDepts.map((d) => Number(d.departmentId));
    if (new Set(deptIds).size !== deptIds.length) {
      throw { statusCode: 400, message: 'Duplicate departments are not allowed' };
    }

    const ticket = await ticketRepo.createSubTicket({
      title: title.trim(),
      description: description.trim(),
      priority,
      dueDate,
      createdBy: user,
      departments: normalizedDepts.map((d) => ({
        departmentId: Number(d.departmentId),
        taskDescription: d.taskDescription,
      })),
    });

    const deptNames = ticket.sub_departments.map(d => d.department_name).join(', ');
    await ticketRepo.logAction(
      ticket.id, user.id, 'created', null, 'sub_ticket',
      `Sub-ticket created by ${user.name} for departments: ${deptNames}`
    );
    await ticketRepo.logAction(
      ticket.id, user.id, 'assigned', 'Unassigned', user.name,
      `Sub-ticket auto-assigned to creator (${user.name})`
    );

    for (const dept of ticket.sub_departments) {
      const managers = await ticketRepo.getManagersByDepartment(dept.department_id);
      await this._dispatch(
        ticket.id, managers,
        `New Sub-Ticket #${ticket.id} assigned to your department (${dept.department_name})`,
        'SUB_TICKET_CREATED', { ticket }
      );
    }

    return ticket;
  }

  async updateSubDeptProgress(ticketId, departmentId, data, user) {
    const ticket = await ticketRepo.getTicketById(ticketId, user);
    if (!ticket) throw { statusCode: 404, message: 'Ticket not found' };
    if (ticket.forbidden) throw { statusCode: 403, message: 'Access denied' };
    if (!ticket.is_sub_ticket) {
      throw { statusCode: 400, message: 'This is not a sub-ticket' };
    }

    const isCreatorDept = Number(ticket.created_by_dept) === Number(user.department_id);
    const isTargetDept = Number(departmentId) === Number(user.department_id);
    const isCeo = user.role === 'ceo';
    const isManager = user.role === 'manager';

    if (!isCeo && !isCreatorDept && !isTargetDept) {
      throw { statusCode: 403, message: 'You can only update progress for your own department' };
    }

    const deptRow = ticket.sub_departments.find(d => Number(d.department_id) === Number(departmentId));
    if (!deptRow) throw { statusCode: 404, message: 'Department task not found in this sub-ticket' };

    const { status, note } = data;
    if (!['open', 'in_progress', 'pending_approval', 'approved', 'completed'].includes(status)) {
      throw { statusCode: 400, message: 'Status must be open, in_progress, pending_approval, approved, or completed' };
    }

    const isAssignedEmployee = Number(deptRow.assigned_to_id) === Number(user.id);

    // RULES for status transitions:
    // in_progress -> pending_approval: only assigned employee (mark done)
    if (status === 'pending_approval') {
      if (!isAssignedEmployee && !isCeo) {
        throw { statusCode: 403, message: 'Only the assigned employee can mark this task as done' };
      }
      if (!note || String(note).trim() === '') {
        throw { statusCode: 400, message: 'A completion remark is required when marking as done' };
      }
    }
    // pending_approval -> approved: only the department's manager or CEO
    if (status === 'approved') {
      if (!isManager && !isCeo) {
        throw { statusCode: 403, message: 'Only a manager can approve completed work' };
      }
      if (!isTargetDept && !isCeo) {
        throw { statusCode: 403, message: 'You can only approve work for your own department' };
      }
    }
    // completed: only CEO override (normal flow uses pending_approval -> approved -> creator completes)
    if (status === 'completed' && !isCeo) {
      throw { statusCode: 403, message: 'Only CEO can directly complete a department task' };
    }
    // completed -> open: only ceo (reopen)
    if (status === 'open' && deptRow.status === 'completed' && !isCeo) {
      throw { statusCode: 403, message: 'Only CEO can reopen a completed department task' };
    }

    const updated = await ticketRepo.updateSubDeptProgress(
      ticketId,
      Number(departmentId),
      { status }
    );

    const deptName = deptRow.department_name || `Dept ${departmentId}`;

    // Log the progress change
    const progressLog = status === 'pending_approval'
      ? `${user.name} submitted ${deptName} work as done${note ? `. Remark: ${note}` : ''}`
      : status === 'approved'
      ? `${user.name} approved ${deptName} work`
      : status === 'completed'
      ? `${user.name} marked ${deptName} as completed`
      : `${user.name} changed ${deptName} status from ${deptRow.status} to ${status}${note ? `. Remark: ${note}` : ''}`;

    await ticketRepo.logAction(
      ticketId, user.id, 'status_changed',
      deptRow.status,
      `${deptName}: ${updated.overall_progress}% overall`,
      progressLog
    );

    // Transparency: add note as a formal comment
    if (note && note.trim()) {
      let commentMsg;
      if (status === 'pending_approval') {
        commentMsg = `[DEPT COMPLETION - ${deptName}]: ${note.trim()}`;
      } else if (status === 'approved') {
        commentMsg = `[DEPT APPROVED - ${deptName}]: Approved by ${user.name}`;
      } else if (status === 'completed') {
        commentMsg = `[DEPT COMPLETED - ${deptName}]: Finalized by ${user.name}`;
      } else {
        commentMsg = `[DEPT PROGRESS - ${deptName}]: ${note.trim()}`;
      }
      await ticketRepo.addComment(ticketId, user.id, commentMsg);
      await ticketRepo.logAction(
        ticketId, user.id, 'comment_added', null,
        commentMsg.substring(0, 100),
        status === 'approved'
          ? `Manager ${user.name} approved ${deptName} work`
          : status === 'completed'
          ? `CEO ${user.name} finalized ${deptName}`
          : `Note added by ${user.name} for ${deptName}`
      );
    }

    const participants = await ticketRepo.getTicketParticipants(ticketId);
    await this._dispatch(
      ticketId, participants.filter(id => id !== user.id),
      `Sub-Ticket #${ticketId}: ${deptName} progress updated (${updated.overall_progress}% complete)`,
      'SUB_TICKET_PROGRESS', { ticket: updated }
    );

    return updated;
  }

  async selfAssignSubDept(ticketId, departmentId, user) {
    const ticket = await ticketRepo.getTicketById(ticketId, user);
    if (!ticket) throw { statusCode: 404, message: 'Ticket not found' };
    if (ticket.forbidden) throw { statusCode: 403, message: 'Access denied' };
    if (!ticket.is_sub_ticket) throw { statusCode: 400, message: 'This is not a sub-ticket' };

    const deptRow = ticket.sub_departments.find(d => Number(d.department_id) === Number(departmentId));
    if (!deptRow) throw { statusCode: 404, message: 'Department task not found in this sub-ticket' };
    if (deptRow.assigned_to_id) throw { statusCode: 400, message: 'This department task already has an assigned employee' };
    if (deptRow.status !== 'open') throw { statusCode: 400, message: 'Only open department tasks can be self-assigned' };

    const updated = await ticketRepo.assignSubDeptToEmployee(
      Number(ticketId),
      Number(departmentId),
      user.id,
      user.id
    );

    await ticketRepo.logAction(
      ticketId, user.id, 'assigned',
      'Unassigned', user.name,
      `Employee ${user.name} self-assigned to ${deptRow.department_name || `Dept ${departmentId}`}`
    );
    await ticketRepo.logAction(
      ticketId, user.id, 'status_changed',
      'open', 'in_progress',
      `Status auto-changed to in_progress due to self-assignment by ${user.name}`
    );

    await this._dispatch(
      ticketId, [user.id],
      `You have been assigned to ${deptRow.department_name || `Dept ${departmentId}`} task for Ticket #${ticketId}`,
      'SUB_TICKET_ASSIGNED'
    );

    return updated;
  }

  async assignSubDeptToEmployee(ticketId, departmentId, employeeId, user) {
    const ticket = await ticketRepo.getTicketById(ticketId, user);
    if (!ticket) throw { statusCode: 404, message: 'Ticket not found' };
    if (ticket.forbidden) throw { statusCode: 403, message: 'Access denied' };
    if (!ticket.is_sub_ticket) throw { statusCode: 400, message: 'This is not a sub-ticket' };
    if (!['manager', 'ceo'].includes(user.role)) {
      throw { statusCode: 403, message: 'Only managers can assign sub-ticket work' };
    }

    const updated = await ticketRepo.assignSubDeptToEmployee(
      Number(ticketId),
      Number(departmentId),
      Number(employeeId),
      user.id
    );

    const assignedEmployee = await ticketRepo.getUserById(Number(employeeId));
    const deptRow = updated.sub_departments.find(d => Number(d.department_id) === Number(departmentId));
    await ticketRepo.logAction(
      ticketId,
      user.id,
      'assigned',
      deptRow?.assigned_to_name || 'Unassigned',
      assignedEmployee?.name || `Employee ${employeeId}`,
      `Department manager ${user.name} assigned ${deptRow?.department_name || departmentId} work`
    );
    await ticketRepo.logAction(
      ticketId, user.id, 'status_changed',
      'open', 'in_progress',
      `Status auto-changed to in_progress due to assignment by ${user.name}`
    );

    if (assignedEmployee?.id) {
      await this._dispatch(
        ticketId,
        [assignedEmployee.id],
        `You have been assigned sub-ticket work for Ticket #${ticketId}`,
        'SUB_TICKET_ASSIGNED'
      );
    }

    return updated;
  }

  async completeSubTicket(ticketId, user) {
    const ticket = await ticketRepo.getTicketById(ticketId, user);
    if (!ticket) throw { statusCode: 404, message: 'Ticket not found' };
    if (ticket.forbidden) throw { statusCode: 403, message: 'Access denied' };
    if (!ticket.is_sub_ticket) throw { statusCode: 400, message: 'This is not a sub-ticket' };

    const isCreator = Number(ticket.created_by_id) === Number(user.id);
    if (!isCreator && user.role !== 'ceo') {
      throw { statusCode: 403, message: 'Only the ticket creator can mark the overall ticket as done' };
    }

    const allApprovedOrCompleted = ticket.sub_departments.every(
      d => d.status === 'approved' || d.status === 'completed'
    );
    if (!allApprovedOrCompleted) {
      throw { statusCode: 400, message: 'All departments must be approved before completing the ticket' };
    }

    const updated = await ticketRepo.completeSubTicket(ticketId, user.id);

    const doneDepts = ticket.sub_departments.map(d => d.department_name || `Dept ${d.department_id}`).join(', ');
    await ticketRepo.logAction(
      ticketId, user.id, 'status_changed',
      'in_progress', 'completed',
      `Creator ${user.name} marked the sub-ticket as completed. Departments: ${doneDepts}`
    );

    const participants = await ticketRepo.getTicketParticipants(ticketId);
    await this._dispatch(
      ticketId, participants.filter(id => id !== user.id),
      `Sub-Ticket #${ticketId} has been completed by the creator`,
      'SUB_TICKET_COMPLETED', { ticket: updated }
    );

    return updated;
  }

  async reopenSubDept(ticketId, departmentId, user) {
    const ticket = await ticketRepo.getTicketById(ticketId, user);
    if (!ticket) throw { statusCode: 404, message: 'Ticket not found' };
    if (ticket.forbidden) throw { statusCode: 403, message: 'Access denied' };
    if (!ticket.is_sub_ticket) throw { statusCode: 400, message: 'This is not a sub-ticket' };

    const isCreator = Number(ticket.created_by_id) === Number(user.id);
    if (!isCreator && user.role !== 'ceo') {
      throw { statusCode: 403, message: 'Only the ticket creator can reopen a department task' };
    }

    const deptRow = ticket.sub_departments.find(d => Number(d.department_id) === Number(departmentId));
    if (!deptRow) throw { statusCode: 404, message: 'Department task not found in this sub-ticket' };

    if (deptRow.status !== 'approved' && deptRow.status !== 'completed') {
      throw { statusCode: 400, message: 'Only approved or completed department tasks can be reopened' };
    }

    // Check 48-hour window
    const completedTime = deptRow.completed_at || deptRow.updated_at;
    if (!completedTime) {
      throw { statusCode: 400, message: 'Cannot determine when this task was completed' };
    }
    const hoursSince = (Date.now() - new Date(completedTime).getTime()) / 36e5;
    if (hoursSince > 48) {
      throw { statusCode: 400, message: 'Reopen window of 48 hours has passed' };
    }

    // Check if already reopened once
    const logs = await ticketRepo.getTicketLogs(ticketId);
    const reopenedBefore = logs.some(
      l => l.action === 'sub_dept_reopened' && String(l.old_value) === String(departmentId)
    );
    if (reopenedBefore) {
      throw { statusCode: 400, message: 'This department task can only be reopened once' };
    }

    const updated = await ticketRepo.reopenSubDept(ticketId, Number(departmentId));

    const deptName = deptRow.department_name || `Dept ${departmentId}`;
    await ticketRepo.logAction(
      ticketId, user.id, 'sub_dept_reopened',
      String(departmentId), 'in_progress',
      `Creator ${user.name} reopened ${deptName} work`
    );
    await ticketRepo.logAction(
      ticketId, user.id, 'status_changed',
      deptRow.status, 'in_progress',
      `${deptName} status changed to in_progress (reopened by creator ${user.name})`
    );

    const participants = await ticketRepo.getTicketParticipants(ticketId);
    await this._dispatch(
      ticketId, participants.filter(id => id !== user.id),
      `Sub-Ticket #${ticketId}: ${deptName} reopened by creator`,
      'SUB_TICKET_REOPENED', { ticket: updated }
    );

    return updated;
  }

  async updateStatus(ticketId, newStatus, user, remark) {
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

    console.log(`[TicketService] Status update: ${ticket.status} -> ${newStatus} by ${user.name} (ID: ${user.id})`);

    // Only the resolver or CEO can mark a ticket as completed
    if (newStatus === 'completed') {
      if (!isResolver && !isCeo) {
        throw { statusCode: 403, message: 'Only the assigned resolver can mark this ticket as completed' };
      }
      if (!remark || String(remark).trim() === '') {
        throw { statusCode: 400, message: 'Completion remark is required when marking done' };
      }
    }

    // Only the creator or CEO can mark a ticket as closed (finalize and close)
    if (newStatus === 'closed') {
      if (!isCreator && !isCeo) {
        throw { statusCode: 403, message: 'Only the creator can finalize and close this ticket' };
      }
      if (!remark || String(remark).trim() === '') {
        throw { statusCode: 400, message: 'Closing remark is required when closing ticket' };
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
    await ticketRepo.logAction(
      ticketId,
      user.id,
      'status_changed',
      oldStatus,
      newStatus,
      `Status updated to ${newStatus} by ${user.name}${remark ? `. Final Remark: ${remark}` : ''}`
    );

    // Transparency: Add the closing/completion remark as a formal comment so it is visible in the thread
    if ((newStatus === 'completed' || newStatus === 'closed') && remark) {
      const commentMsg = `[${newStatus.toUpperCase()} REMARK]: ${remark}`;
      await ticketRepo.addComment(ticketId, user.id, commentMsg);
      await ticketRepo.logAction(
        ticketId, user.id, 'comment_added', null,
        commentMsg.substring(0, 100),
        `${newStatus.charAt(0).toUpperCase() + newStatus.slice(1)} remark added by ${user.name}`
      );
    }

    // Real-time update for creator and assignee
    const participants = await ticketRepo.getTicketParticipants(ticketId);
    await this._dispatch(ticketId, participants, `Ticket #${ticketId} status changed to ${newStatus}`, 'TICKET_STATUS_UPDATED', { ticket: updated });

    return updated;
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

    return updated;
  }

  async transferTicket(ticketId, targetDeptId, user) {
    const ticketBeforeUpdate = await ticketRepo.getTicketById(ticketId, user);
    if (!ticketBeforeUpdate) throw { statusCode: 404, message: 'Ticket not found' };
    if (ticketBeforeUpdate.forbidden) throw { statusCode: 403, message: 'Access denied' };

    if (ticketBeforeUpdate.is_sub_ticket) {
      throw { statusCode: 400, message: 'Sub-tickets cannot be transferred. Update department progress instead.' };
    }

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
    const tickets = await ticketRepo.getSentTicketsByDepartment(user.department_id);
    return await ticketRepo.enrichTicketsWithSubData(tickets);
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
