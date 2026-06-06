const ticketRepo = require('./ticket.repository');

class TicketService {
  // ── Real-Time Notification Dispatcher ────────────────────────────────────
  async _dispatch(ticketId, userIds, message, eventType = 'NOTIFICATION', payload = {}, skipUserIds = []) {
    for (const userId of userIds) {
      const skipNotif = skipUserIds.includes(userId);
      let notif = null;
      if (!skipNotif) {
        notif = await ticketRepo.createNotification(userId, ticketId, message);
      }
      if (global.io) {
        global.io.to(`user_${userId}`).emit(eventType, {
          ticketId,
          message,
          notificationId: notif?.id || null,
          createdAt: notif?.created_at || new Date().toISOString(),
          ...payload
        });
      }
    }
    // Emit unread count only for users who received notifications
    if (global.io && userIds.length > 0) {
      const notifUsers = userIds.filter(id => !skipUserIds.includes(id));
      const uniqueUsers = [...new Set(notifUsers)];
      for (const userId of uniqueUsers) {
        const count = await ticketRepo.getUnreadCount(userId);
        global.io.to(`user_${userId}`).emit('NOTIFICATION_COUNT', { count });
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
    const { title, description, priority = 'medium', assignedDeptId, dueDate, parentTicketId = null, selfAssign = false } = data;
    const departmentIds = data.departmentIds;

    const subTitle = data.subTitle || data.sub_title;
    const subDescription = data.subDescription || data.sub_description;

    let assignedToId = data.assignedToId != null ? Number(data.assignedToId) : null;
    if (selfAssign) {
      assignedToId = user.id;
    }

    if (!title || !description || title.trim() === '' || description.trim() === '') {
      throw { statusCode: 400, message: 'title and description are required' };
    }

    // Multi-department mode: create master + sub-ticket for each department
    if (!parentTicketId && Array.isArray(departmentIds) && departmentIds.length > 0) {
      const uniqueDepts = [...new Set(departmentIds.map(Number))];
      if (uniqueDepts.length === 0) throw { statusCode: 400, message: 'At least one department is required' };

      if (uniqueDepts.length > 1) {
        // Multi: create master and sub-tickets for all selected departments
        const masterTicket = await ticketRepo.createTicket({
          title: `Project: ${title}`,
          description: `Master oversight for: ${description}`,
          priority,
          assignedDeptId: user.department_id,
          dueDate,
          createdBy: user,
          assignedToId: user.id,
          parentTicketId: null,
          ticketType: 'multi_task'
        });

        await ticketRepo.logAction(masterTicket.id, user.id, 'created', null, 'open', `Project Master created for multi-department task`);

        for (const deptId of uniqueDepts) {
          const isOwnDept = Number(deptId) === Number(user.department_id);
          // Use per-department title/description if provided, otherwise fallback
          let deptTitle, deptDesc;
          if (Array.isArray(data.deptTickets)) {
            const dt = data.deptTickets.find(d => Number(d.department_id) === Number(deptId));
            if (dt) {
              deptTitle = dt.title;
              deptDesc = dt.description;
            }
          }
          const effectiveTitle = deptTitle || (isOwnDept ? title : (subTitle || title));
          const effectiveDesc = deptDesc || (isOwnDept ? description : (subDescription || description));
          await this.createTicket({
            ...data,
            title: effectiveTitle,
            description: effectiveDesc,
            parentTicketId: masterTicket.id,
            assignedDeptId: deptId,
            assignedToId: null,
            selfAssign: false
          }, user);
        }

        return masterTicket;
      }

      // Single department: fall through to existing logic with this dept
      data.assignedDeptId = uniqueDepts[0];
    }

    const effectiveDeptId = data.assignedDeptId ?? assignedDeptId;
    if (effectiveDeptId == null) {
      throw { statusCode: 400, message: 'assignedDeptId is required' };
    }

    // Cross-department: Create master in creator's dept + sub in target dept
    if (!parentTicketId && Number(effectiveDeptId) !== Number(user.department_id)) {
      const effectiveSubTitle = (subTitle && String(subTitle).trim())
        ? String(subTitle).trim()
        : title;
      const effectiveSubDesc = (subDescription && String(subDescription).trim())
        ? String(subDescription).trim()
        : description;

      const masterTicket = await ticketRepo.createTicket({
        title: `Project: ${title}`,
        description: `Master oversight for: ${description}`,
        priority,
        assignedDeptId: user.department_id,
        dueDate,
        createdBy: user,
        assignedToId: user.id,
        parentTicketId: null,
        ticketType: 'standard'
      });

      await ticketRepo.logAction(masterTicket.id, user.id, 'created', null, 'open', `Project Master created for department oversight`);

      return await this.createTicket({
        ...data,
        title: effectiveSubTitle,
        description: effectiveSubDesc,
        parentTicketId: masterTicket.id,
        assignedToId: null,
        selfAssign: false
      }, user);
    }

    const ticket = await ticketRepo.createTicket({
      title,
      description,
      priority,
      assignedDeptId: effectiveDeptId,
      dueDate,
      createdBy: user,
      assignedToId,
      parentTicketId: parentTicketId ? Number(parentTicketId) : null,
      ticketType: 'standard'
    });

    const logNote = `Created by ${user.name}${assignedToId ? ` and assigned to ${ticket.assigned_to_name}` : ''}${parentTicketId ? ` as a sub-ticket of #${parentTicketId}` : ''}`;
    await ticketRepo.logAction(ticket.id, user.id, 'created', null, ticket.status, logNote);

    if (parentTicketId) {
      await ticketRepo.logAction(parentTicketId, user.id, 'sub_ticket_created', null, String(ticket.id), `Sub-ticket #${ticket.id} created by ${user.name}`);
    }

    // Notify ALL participants across the entire ticket chain
    const allParticipants = await ticketRepo.getTicketParticipants(ticket.id);
    await this._dispatch(ticket.id, allParticipants, `New Ticket Created: ${title}`, 'TICKET_CREATED', { ticket });

    // If auto-assigned, also notify the employee directly
    if (assignedToId) {
      await this._dispatch(ticket.id, [assignedToId], `You have been assigned to Ticket #${ticket.id}`, 'TICKET_ASSIGNED');
    }

    return ticket;
  }

  async createSubTicket(data, user) {
    if (user.role !== 'manager' && user.role !== 'ceo') {
      throw { statusCode: 403, message: 'Only managers or CEO can create multi-task tickets' };
    }

    const { title, description, priority = 'medium', dueDate, departments, parentTicketId = null } = data;

    if (!title || !description || title.trim() === '' || description.trim() === '') {
      throw { statusCode: 400, message: 'title and description are required' };
    }

    if (!Array.isArray(departments) || departments.length < 2) {
      throw { statusCode: 400, message: 'Multi-task tickets require at least 2 departments with task descriptions' };
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
      parentTicketId: parentTicketId ? Number(parentTicketId) : null,
    });

    const deptNames = ticket.sub_departments.map(d => d.department_name).join(', ');
    await ticketRepo.logAction(
      ticket.id, user.id, 'created', null, 'multi_task',
      `Multi-task ticket created by ${user.name} for departments: ${deptNames}${parentTicketId ? ` as a sub-ticket of #${parentTicketId}` : ''}`
    );
    await ticketRepo.logAction(
      ticket.id, user.id, 'assigned', 'Unassigned', user.name,
      `Multi-task ticket auto-assigned to creator (${user.name})`
    );

    if (parentTicketId) {
      await ticketRepo.logAction(parentTicketId, user.id, 'sub_ticket_created', null, String(ticket.id), `Multi-task sub-ticket #${ticket.id} created by ${user.name}`);
    }

    // Collect all users to notify: department managers + parent ticket participants if any
    const allSubDeptManagers = [];
    for (const dept of ticket.sub_departments) {
      const managers = await ticketRepo.getManagersByDepartment(dept.department_id);
      allSubDeptManagers.push(...managers);
    }
    let allUsers = [...new Set(allSubDeptManagers)];
    if (parentTicketId) {
      const parentParticipants = await ticketRepo.getTicketParticipants(parentTicketId);
      allUsers = [...new Set([...allUsers, ...parentParticipants])];
    }
    await this._dispatch(
      ticket.id, allUsers,
      `New Multi-Task Ticket #${ticket.id} created ${parentTicketId ? `as sub-ticket of #${parentTicketId}` : ''}`,
      'SUB_TICKET_CREATED', { ticket }
    );

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
      ticketId, participants,
      `Sub-Ticket #${ticketId}: ${deptName} progress updated (${updated.overall_progress}% complete)`,
      'SUB_TICKET_PROGRESS', { ticket: updated }, [user.id]
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

    const participants = await ticketRepo.getTicketParticipants(ticketId);
    await this._dispatch(
      ticketId, participants,
      `${user.name} self-assigned to ${deptRow.department_name || `Dept ${departmentId}`} task for Ticket #${ticketId}`,
      'SUB_TICKET_ASSIGNED', {}, [user.id]
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
      const participants = await ticketRepo.getTicketParticipants(ticketId);
      await this._dispatch(
        ticketId, participants,
        `${user.name} assigned ${assignedEmployee.name} to ${deptRow?.department_name || departmentId} work for Ticket #${ticketId}`,
        'SUB_TICKET_ASSIGNED', {}, [user.id]
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
      ticketId, participants,
      `Sub-Ticket #${ticketId} has been completed by the creator`,
      'SUB_TICKET_COMPLETED', { ticket: updated }, [user.id]
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
      ticketId, participants,
      `Sub-Ticket #${ticketId}: ${deptName} reopened by creator`,
      'SUB_TICKET_REOPENED', { ticket: updated }, [user.id]
    );

    return updated;
  }

  async updateStatus(ticketId, newStatus, user, remark, isSystemUpdate = false) {
    const ticket = await ticketRepo.getTicketById(ticketId, user, isSystemUpdate);
    if (!ticket) throw { statusCode: 404, message: 'Ticket not found' };
    if (ticket.forbidden) throw { statusCode: 403, message: 'Access denied' };

    const allowedStatuses = ['open', 'in_progress', 'completed', 'closed'];
    if (!allowedStatuses.includes(newStatus)) {
      throw { statusCode: 400, message: 'Invalid status' };
    }

    // Rule 4: Block completion if active children exist
    if (!isSystemUpdate && newStatus === 'completed') {
      const hasActive = await ticketRepo.hasActiveChildren(ticketId);
      if (hasActive) {
        throw {
          statusCode: 400,
          message: `Cannot mark as completed while sub-tickets are still active.`
        };
      }
    }

    // Block closed if any sub-tickets are not finalized
    if (!isSystemUpdate && newStatus === 'closed') {
      const hasUnfinalized = await ticketRepo.hasUnfinalizedSubTickets(ticketId);
      if (hasUnfinalized) {
        throw {
          statusCode: 400,
          message: `Rule Violation: Cannot mark as ${newStatus} while sub-tasks are still active.`
        };
      }
    }

    const isResolver = ticket.assigned_to_id === user.id;
    const isCreator = ticket.created_by_id === user.id;
    const isEmployee = user.role === 'employee';
    const isAssignedDeptManager = user.role === 'manager' && user.department_id === ticket.assigned_dept_id;
    const isCeo = user.role === 'ceo';

    if (!isSystemUpdate) {
      console.log(`[TicketService] Status update: ${ticket.status} -> ${newStatus} by ${user.name} (ID: ${user.id})`);
    }

    // Only the assigned resolver can mark a ticket as completed
    if (!isSystemUpdate && newStatus === 'completed') {
      if (ticket.status === 'open') throw { statusCode: 400, message: 'Ticket must be assigned first.' };

      if (!isResolver) {
        throw { statusCode: 403, message: 'Only the assigned resolver can mark this ticket as done.' };
      }
      if (!remark || String(remark).trim() === '') {
        throw { statusCode: 400, message: 'Completion remark is required when marking done' };
      }
    }

    // Only the resolver or creator (or CEO) can close a ticket
    if (newStatus === 'closed') {
      if (!isSystemUpdate) {
        if (ticket.is_sub_ticket) {
          if (!isResolver) {
            throw { statusCode: 403, message: 'Only the assigned resolver can close this sub-ticket.' };
          }
        } else if (!isResolver && !isCreator && !isCeo) {
          throw { statusCode: 403, message: 'Only the creator can finalize and close this ticket' };
        }
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
      `Status updated to ${newStatus} by ${user.name}${isSystemUpdate ? ' (System Action)' : ''}${remark ? `. Remark: ${remark}` : ''}`
    );

    // Log parent notification when child completes (no auto-complete)
    if (newStatus === 'completed' && ticket.parent_ticket_id) {
      const chain = await ticketRepo.getParentChain(ticketId);
      const allParents = [ticket.parent_ticket_id, ...chain];
      for (const parentId of allParents) {
        const allDone = await ticketRepo.allChildrenCompleted(parentId);
        if (allDone) {
          await ticketRepo.logAction(
            parentId, user.id, 'all_children_completed', null, null,
            `All sub-tickets completed via #${ticketId}`
          );
        } else {
          break;
        }
      }
    }

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
    await this._dispatch(ticketId, participants, `Ticket #${ticketId} status changed to ${newStatus}`, 'TICKET_STATUS_UPDATED', { ticket: updated }, [user.id]);

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

    // Notify all participants
    const participants = await ticketRepo.getTicketParticipants(ticketId);
    await this._dispatch(
      ticketId, participants,
      `Ticket #${ticketId} self-assigned by ${user.name}`,
      'TICKET_ASSIGNED', { ticket: updated }, [user.id]
    );

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

  async transferTicket(ticketId, targetDeptId, user, title, description) {
    const parentTicket = await ticketRepo.getTicketById(ticketId, user);
    if (!parentTicket) throw { statusCode: 404, message: 'Parent ticket not found' };
    if (parentTicket.forbidden) throw { statusCode: 403, message: 'Access denied' };

    // Rule: Open ticket must be assigned before sub-ticket creation
    if (parentTicket.status === 'open') {
      throw { statusCode: 400, message: 'Ticket must be assigned first before creating a sub-ticket.' };
    }

    // Rule 3: Mandatory Title and Description for Sub-Tickets
    if (!title?.trim() || !description?.trim()) {
      throw { statusCode: 400, message: 'A new Title and Description are mandatory for sub-tickets.' };
    }

    // Rule 3: Prevent duplicate departments in the project tree
    const isUsed = await ticketRepo.isDepartmentUsedInTree(ticketId, Number(targetDeptId));
    if (isUsed) {
      throw { statusCode: 400, message: 'This department is already part of the project lineage.' };
    }

    // Actions are disabled for closed tickets
    if (parentTicket.status === 'closed') {
      throw { statusCode: 400, message: 'Cannot create sub-ticket for a closed ticket' };
    }

    // Permission Check: CEO cannot create sub-tickets via transfer, and if assigned, only the resolver can create sub-ticket
    if (user.role === 'ceo') throw { statusCode: 403, message: 'CEO is not authorized to create sub-tickets' };

    if (parentTicket.assigned_to_id && parentTicket.assigned_to_id !== user.id && user.role !== 'manager') {
      throw { statusCode: 403, message: 'Only the assigned resolver or a manager can create a sub-ticket' };
    }

    // Create a new ticket as a sub-ticket (starts open, unassigned)
    const subTicket = await ticketRepo.createTicket({
      title: title?.trim() || `Sub: ${parentTicket.title}`,
      description: description?.trim() || parentTicket.description,
      priority: parentTicket.priority,
      assignedDeptId: targetDeptId,
      dueDate: parentTicket.due_date,
      createdBy: user,
      assignedToId: null,
      parentTicketId: ticketId,
      ticketType: 'standard'
    });

    // Log the sub-ticket creation on the parent ticket
    await ticketRepo.logAction(
      ticketId,
      user.id,
      'sub_ticket_created',
      null,
      String(subTicket.id),
      `Sub-ticket #${subTicket.id} created for department ${subTicket.assigned_dept_name} (formerly Transfer)`
    );

    // Log creation on the sub-ticket itself
    await ticketRepo.logAction(
      subTicket.id,
      user.id,
      'created',
      null,
      subTicket.status,
      `Created as a sub-ticket of #${ticketId}`
    );

    // Notify parent participants + new department managers
    const parentParticipants = await ticketRepo.getTicketParticipants(ticketId);
    const newManagers = await ticketRepo.getManagersByDepartment(targetDeptId);
    const allUsers = [...new Set([...parentParticipants, ...newManagers])];
    await this._dispatch(subTicket.id, allUsers, `New Sub-Ticket #${subTicket.id} created from #${ticketId}`, 'SUB_TICKET_CREATED', { ticket: subTicket });

    return subTicket;
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
    await this._dispatch(ticketId, participants, `Ticket #${ticketId} has been reopened and is now In Progress.`, 'TICKET_REOPENED', { ticket: updated }, [user.id]);

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
    const participants = await ticketRepo.getTicketParticipants(ticketId);
    await this._dispatch(ticketId, participants, `${user.name} commented on Ticket #${ticketId}`, 'COMMENT_ADDED', {}, [user.id]);

    return comment;
  }

  // ── Update ticket details (title, description, priority, due_date) ──────
  async updateTicket(ticketId, user, fields) {
    const ticket = await ticketRepo.getTicketById(ticketId, user);
    if (!ticket) throw { statusCode: 404, message: 'Ticket not found' };
    if (ticket.forbidden) throw { statusCode: 403, message: 'Access denied' };

    const updated = await ticketRepo.updateTicketField(ticketId, user.id, fields);
    if (!updated) throw { statusCode: 400, message: 'No valid fields to update' };

    const participants = await ticketRepo.getTicketParticipants(ticketId);
    const changed = Object.keys(fields).join(', ');
    await this._dispatch(
      ticketId,
      participants,
      `${user.name} updated ${changed} on Ticket #${ticketId}`,
      'TICKET_UPDATED',
      { ticketNumber: updated.ticket_number },
      [user.id]
    );

    return updated;
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
