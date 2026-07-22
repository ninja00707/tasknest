const ticketRepo = require('./ticket.repository');

class TicketService {
  // ── Recursively propagate in_progress up the parent chain ────────────
  // For completed/closed: just collect parent chain for outbox notification
  async _propagateUpward(childTicket, newStatus, user, client) {
    if (!childTicket.parent_ticket_id) return [];

    if (newStatus === 'in_progress') {
      const updatedParents = await ticketRepo.updateParentChain(childTicket.parent_ticket_id, 'in_progress', client);
      if (updatedParents && updatedParents.length > 0) {
        for (const parent of updatedParents) {
          const parentTicket = await ticketRepo.getTicketDetails(parent.id, client);
          if (parentTicket) {
            const version = await ticketRepo.bumpVersion(client, parent.id);
            await ticketRepo.insertOutboxRow(client, {
              eventType: 'ticket:updated',
              ticketId: parent.id,
              parentTicketId: parentTicket.parent_ticket_id,
              payload: parentTicket,
              actorId: user.id,
              version,
            });
          }
        }
      }
      return updatedParents;
    }

    if (newStatus === 'completed' || newStatus === 'closed') {
      const parents = await ticketRepo.getParentChain(childTicket.parent_ticket_id);
      if (parents && parents.length > 0) {
        for (const parent of parents) {
          const parentId = parent.parentId || parent.id;
          const parentTicket = await ticketRepo.getTicketDetails(parentId, client);
          if (parentTicket) {
            const version = await ticketRepo.bumpVersion(client, parentId);
            await ticketRepo.insertOutboxRow(client, {
              eventType: 'ticket:updated',
              ticketId: parentId,
              parentTicketId: parentTicket.parent_ticket_id,
              payload: parentTicket,
              actorId: user.id,
              version,
            });
          }
        }
      }
      return parents;
    }

    return [];
  }


  async getDashboardStats(user) {
    if (!user) throw { statusCode: 401, message: 'Unauthorized' };
    return await ticketRepo.getDashboardStats(user);
  }

  async getTickets(user, filters) {
    if (!user) throw { statusCode: 401, message: 'Unauthorized' };
    const { tickets, total } = await ticketRepo.getVisibleTickets(user, filters);
    const enriched = await ticketRepo.enrichTicketsWithSubData(tickets);
    return { tickets: enriched, total };
  }

  async getTicket(ticketId, user) {
    if (!user) throw { statusCode: 401, message: 'Unauthorized' };
    const ticket = await ticketRepo.getTicketById(ticketId, user);
    if (!ticket) throw { statusCode: 404, message: 'Ticket not found' };
    if (ticket.forbidden) throw { statusCode: 403, message: 'Access denied to this ticket' };

    await ticketRepo.enrichTicketWithSubData(ticket);
    ticket.history = await ticketRepo.getTicketLogs(ticketId);

    // If ticket has sub-tickets (children), check if user's department has a child
    // and use that child's assignment for the current user
    if (Array.isArray(ticket.children) && ticket.children.length > 0) {
      const myDeptChild = ticket.children.find(c => Number(c.assigned_dept_id) === Number(user.department_id));
      if (myDeptChild) {
        ticket.my_assigned_to_id = myDeptChild.assigned_to_id;
        ticket.my_assigned_to_name = myDeptChild.assignee_name;
      }
    }

    ticket.can_comment =
      Number(ticket.created_by_id) === Number(user.id) ||
      (ticket.my_assigned_to_id != null && Number(ticket.my_assigned_to_id) === Number(user.id)) ||
      (ticket.assigned_to_id != null && Number(ticket.assigned_to_id) === Number(user.id)) ||
      (Array.isArray(ticket.sub_departments) && ticket.sub_departments.some(sd => Number(sd.assigned_to_id) === Number(user.id)));
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
        const masterTicket = await ticketRepo.withTransaction(async (client) => {
          const ticket = await ticketRepo.createTicket({
            title,
            description,
            priority,
            assignedDeptId: user.department_id,
            dueDate,
            createdBy: user,
            assignedToId: user.id,
            parentTicketId: null,
            ticketType: 'multi_task'
          }, client);

          await ticketRepo.logAction(ticket.id, user.id, 'created', null, 'open', 'Project Master created for multi-department task', client);

          const version = await ticketRepo.bumpVersion(client, ticket.id);
          await ticketRepo.insertOutboxRow(client, {
            eventType: 'ticket:created',
            ticketId: ticket.id,
            payload: ticket,
            actorId: user.id,
            version,
          });

          return ticket;
        });

        for (const deptId of uniqueDepts) {
          const isOwnDept = Number(deptId) === Number(user.department_id);
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

      const masterTicket = await ticketRepo.withTransaction(async (client) => {
        const ticket = await ticketRepo.createTicket({
          title,
          description,
          priority,
          assignedDeptId: user.department_id,
          dueDate,
          createdBy: user,
          assignedToId: user.id,
          parentTicketId: null,
          ticketType: 'standard'
        }, client);

        await ticketRepo.logAction(ticket.id, user.id, 'created', null, 'open', 'Project Master created for department oversight', client);

        const version = await ticketRepo.bumpVersion(client, ticket.id);
        await ticketRepo.insertOutboxRow(client, {
          eventType: 'ticket:created',
          ticketId: ticket.id,
          payload: ticket,
          actorId: user.id,
          version,
        });

        return ticket;
      });

      return await this.createTicket({
        ...data,
        title: effectiveSubTitle,
        description: effectiveSubDesc,
        parentTicketId: masterTicket.id,
        assignedToId: null,
        selfAssign: false
      }, user);
    }

    return await ticketRepo.withTransaction(async (client) => {
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
      }, client);

      const logNote = `Created by ${user.name}${assignedToId ? ` and assigned to ${ticket.assigned_to_name}` : ''}${parentTicketId ? ` as a sub-ticket of #${parentTicketId}` : ''}`;
      await ticketRepo.logAction(ticket.id, user.id, 'created', null, ticket.status, logNote, client);

      if (parentTicketId) {
        await ticketRepo.logAction(parentTicketId, user.id, 'sub_ticket_created', null, String(ticket.id), `Sub-ticket #${ticket.id} created by ${user.name}`, client);
      }

      const version = await ticketRepo.bumpVersion(client, ticket.id);
      await ticketRepo.insertOutboxRow(client, {
        eventType: 'ticket:created',
        ticketId: ticket.id,
        parentTicketId: ticket.parent_ticket_id,
        payload: ticket,
        actorId: user.id,
        version,
      });

      return ticket;
    });
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

    return await ticketRepo.withTransaction(async (client) => {
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
      }, client);

      const deptNames = ticket.sub_departments.map(d => d.department_name).join(', ');
      await ticketRepo.logAction(
        ticket.id, user.id, 'created', null, 'multi_task',
        `Multi-task ticket created by ${user.name} for departments: ${deptNames}${parentTicketId ? ` as a sub-ticket of #${parentTicketId}` : ''}`,
        client
      );
      await ticketRepo.logAction(
        ticket.id, user.id, 'assigned', 'Unassigned', user.name,
        `Multi-task ticket auto-assigned to creator (${user.name})`,
        client
      );

      if (parentTicketId) {
        await ticketRepo.logAction(parentTicketId, user.id, 'sub_ticket_created', null, String(ticket.id), `Multi-task sub-ticket #${ticket.id} created by ${user.name}`, client);
      }

      const version = await ticketRepo.bumpVersion(client, ticket.id);
      await ticketRepo.insertOutboxRow(client, {
        eventType: 'ticket:created',
        ticketId: ticket.id,
        parentTicketId: ticket.parent_ticket_id,
        payload: ticket,
        actorId: user.id,
        version,
      });

      return ticket;
    });
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
    if (status === 'pending_approval') {
      if (!isAssignedEmployee && !isCeo) {
        throw { statusCode: 403, message: 'Only the assigned employee can mark this task as done' };
      }
      if (!note || String(note).trim() === '') {
        throw { statusCode: 400, message: 'A completion remark is required when marking as done' };
      }
    }
    if (status === 'approved') {
      if (!isManager && !isCeo) {
        throw { statusCode: 403, message: 'Only a manager can approve completed work' };
      }
      if (!isTargetDept && !isCeo) {
        throw { statusCode: 403, message: 'You can only approve work for your own department' };
      }
    }
    if (status === 'completed' && !isCeo) {
      throw { statusCode: 403, message: 'Only CEO can directly complete a department task' };
    }
    if (status === 'open' && deptRow.status === 'completed' && !isCeo) {
      throw { statusCode: 403, message: 'Only CEO can reopen a completed department task' };
    }

    return await ticketRepo.withTransaction(async (client) => {
      const updated = await ticketRepo.updateSubDeptProgress(
        ticketId,
        Number(departmentId),
        { status },
        client
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
        progressLog,
        client
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
        await ticketRepo.addComment(ticketId, user.id, commentMsg, client);
        await ticketRepo.logAction(
          ticketId, user.id, 'comment_added', null,
          commentMsg.substring(0, 100),
          status === 'approved'
            ? `Manager ${user.name} approved ${deptName} work`
            : status === 'completed'
              ? `CEO ${user.name} finalized ${deptName}`
              : `Note added by ${user.name} for ${deptName}`,
          client
        );
      }

      const version = await ticketRepo.bumpVersion(client, ticketId);
      await ticketRepo.insertOutboxRow(client, {
        eventType: 'ticket:updated',
        ticketId,
        parentTicketId: updated.parent_ticket_id,
        payload: updated,
        actorId: user.id,
        version,
      });

      return updated;
    });
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

    return await ticketRepo.withTransaction(async (client) => {
      const updated = await ticketRepo.assignSubDeptToEmployee(
        Number(ticketId),
        Number(departmentId),
        user.id,
        user.id,
        client
      );

      await ticketRepo.logAction(
        ticketId, user.id, 'assigned',
        'Unassigned', user.name,
        `Employee ${user.name} self-assigned to ${deptRow.department_name || `Dept ${departmentId}`}`,
        client
      );
      await ticketRepo.logAction(
        ticketId, user.id, 'status_changed',
        'open', 'in_progress',
        `Status auto-changed to in_progress due to self-assignment by ${user.name}`,
        client
      );

      const version = await ticketRepo.bumpVersion(client, ticketId);
      await ticketRepo.insertOutboxRow(client, {
        eventType: 'ticket:updated',
        ticketId,
        parentTicketId: updated.parent_ticket_id,
        payload: updated,
        actorId: user.id,
        version,
      });

      return updated;
    });
  }

  async assignSubDeptToEmployee(ticketId, departmentId, employeeId, user) {
    const ticket = await ticketRepo.getTicketById(ticketId, user);
    if (!ticket) throw { statusCode: 404, message: 'Ticket not found' };
    if (ticket.forbidden) throw { statusCode: 403, message: 'Access denied' };
    if (!ticket.is_sub_ticket) throw { statusCode: 400, message: 'This is not a sub-ticket' };
    if (!['manager', 'ceo'].includes(user.role)) {
      throw { statusCode: 403, message: 'Only managers can assign sub-ticket work' };
    }

    return await ticketRepo.withTransaction(async (client) => {
      const updated = await ticketRepo.assignSubDeptToEmployee(
        Number(ticketId),
        Number(departmentId),
        Number(employeeId),
        user.id,
        client
      );

      const assignedEmployee = await ticketRepo.getUserById(Number(employeeId));
      const deptRow = updated.sub_departments.find(d => Number(d.department_id) === Number(departmentId));
      await ticketRepo.logAction(
        ticketId,
        user.id,
        'assigned',
        deptRow?.assigned_to_name || 'Unassigned',
        assignedEmployee?.name || `Employee ${employeeId}`,
        `Department manager ${user.name} assigned ${deptRow?.department_name || departmentId} work`,
        client
      );
      await ticketRepo.logAction(
        ticketId, user.id, 'status_changed',
        'open', 'in_progress',
        `Status auto-changed to in_progress due to assignment by ${user.name}`,
        client
      );

      const version = await ticketRepo.bumpVersion(client, ticketId);
      await ticketRepo.insertOutboxRow(client, {
        eventType: 'ticket:updated',
        ticketId,
        parentTicketId: updated.parent_ticket_id,
        payload: updated,
        actorId: user.id,
        version,
      });

      return updated;
    });
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

    return await ticketRepo.withTransaction(async (client) => {
      const updated = await ticketRepo.completeSubTicket(ticketId, user.id, client);

      const doneDepts = ticket.sub_departments.map(d => d.department_name || `Dept ${d.department_id}`).join(', ');
      await ticketRepo.logAction(
        ticketId, user.id, 'status_changed',
        'in_progress', 'completed',
        `Creator ${user.name} marked the sub-ticket as completed. Departments: ${doneDepts}`,
        client
      );

      const version = await ticketRepo.bumpVersion(client, ticketId);
      await ticketRepo.insertOutboxRow(client, {
        eventType: 'ticket:updated',
        ticketId,
        parentTicketId: updated.parent_ticket_id,
        payload: updated,
        actorId: user.id,
        version,
      });

      return updated;
    });
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

    // Determine cascade order
    const currentIndex = ticket.sub_departments.findIndex(d => Number(d.department_id) === Number(departmentId));
    const prevDept = currentIndex > 0 ? ticket.sub_departments[currentIndex - 1] : null;
    const isCascadeReopen = prevDept && prevDept.status === 'in_progress';

    if (!isCascadeReopen) {
      const completedTime = deptRow.completed_at || deptRow.updated_at;
      if (!completedTime) {
        throw { statusCode: 400, message: 'Cannot determine when this task was completed' };
      }
      const hoursSince = (Date.now() - new Date(completedTime).getTime()) / 36e5;
      if (hoursSince > 48) {
        throw { statusCode: 400, message: 'Reopen window of 48 hours has passed' };
      }

      const logs = await ticketRepo.getTicketLogs(ticketId);
      const reopenedBefore = logs.some(
        l => l.action === 'sub_dept_reopened' && String(l.old_value) === String(departmentId)
      );
      if (reopenedBefore) {
        throw { statusCode: 400, message: 'This department task can only be reopened once' };
      }
    }

    // Find next department for cascade unlock
    const nextDept = currentIndex >= 0 && currentIndex < ticket.sub_departments.length - 1
      ? ticket.sub_departments[currentIndex + 1]
      : null;
    const nextDeptId = nextDept ? Number(nextDept.department_id) : null;

    return await ticketRepo.withTransaction(async (client) => {
      const updated = await ticketRepo.reopenSubDept(ticketId, Number(departmentId), nextDeptId, client);

      const deptName = deptRow.department_name || `Dept ${departmentId}`;
      await ticketRepo.logAction(
        ticketId, user.id, 'sub_dept_reopened',
        String(departmentId), 'in_progress',
        `Creator ${user.name} reopened ${deptName} work`,
        client
      );
      await ticketRepo.logAction(
        ticketId, user.id, 'status_changed',
        deptRow.status, 'in_progress',
        `${deptName} status changed to in_progress (reopened by creator ${user.name})`,
        client
      );

      const version = await ticketRepo.bumpVersion(client, ticketId);
      await ticketRepo.insertOutboxRow(client, {
        eventType: 'ticket:updated',
        ticketId,
        parentTicketId: updated.parent_ticket_id,
        payload: updated,
        actorId: user.id,
        version,
      });

      return updated;
    });
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

    // Only the assigned resolver can mark a ticket as completed
    if (!isSystemUpdate && newStatus === 'completed') {
      if (ticket.status === 'open') throw { statusCode: 400, message: 'Ticket must be assigned first.' };

      if (!isResolver) {
        console.log(`DEBUG: Completion failed. Ticket ID: ${ticketId}, Ticket AssignedTo: ${ticket.assigned_to_id}, User ID: ${user.id}`);
        throw { statusCode: 403, message: 'Only the assigned resolver can mark this ticket as done.' };
      }
      if (!remark || String(remark).trim() === '') {
        throw { statusCode: 400, message: 'Completion remark is required when marking done' };
      }
    }

    // Only the creator or CEO can close a main ticket (not the resolver)
    if (newStatus === 'closed') {
      if (!isSystemUpdate) {
        if (ticket.is_sub_ticket) {
          if (!isResolver) {
            throw { statusCode: 403, message: 'Only the assigned resolver can close this sub-ticket.' };
          }
        } else if (!isCreator && !isCeo) {
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

    return await ticketRepo.withTransaction(async (client) => {
      const oldStatus = ticket.status;
      await ticketRepo.updateStatus(ticketId, newStatus, user, client);

      const updated = await ticketRepo.getTicketDetails(ticketId, client);
      await ticketRepo.logAction(
        ticketId,
        user.id,
        'status_changed',
        oldStatus,
        newStatus,
        `Status updated to ${newStatus} by ${user.name}${isSystemUpdate ? ' (System Action)' : ''}${remark ? `. Remark: ${remark}` : ''}`,
        client
      );

      // ── Recursively propagate status up the parent chain ──────────────
      await this._propagateUpward(ticket, newStatus, user, client);

      // Transparency: Add the closing/completion remark as a formal comment
      if ((newStatus === 'completed' || newStatus === 'closed') && remark) {
        const commentMsg = `[${newStatus.toUpperCase()} REMARK]: ${remark}`;
        await ticketRepo.addComment(ticketId, user.id, commentMsg, client);
        await ticketRepo.logAction(
          ticketId, user.id, 'comment_added', null,
          commentMsg.substring(0, 100),
          `${newStatus.charAt(0).toUpperCase() + newStatus.slice(1)} remark added by ${user.name}`,
          client
        );
      }

      const version = await ticketRepo.bumpVersion(client, ticketId);
      await ticketRepo.insertOutboxRow(client, {
        eventType: 'ticket:updated',
        ticketId,
        parentTicketId: updated.parent_ticket_id,
        payload: updated,
        actorId: user.id,
        version,
      });

      return updated;
    });
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

    return await ticketRepo.withTransaction(async (client) => {
      const updated = await ticketRepo.selfAssign(ticketId, user.id, client);
      if (!updated) throw { statusCode: 400, message: 'Ticket already assigned' };

      // Log the assignment
      await ticketRepo.logAction(
        ticketId,
        user.id,
        'assigned',
        'Unassigned',
        user.name,
        'Self-assigned',
        client
      );

      // Log the automatic status change to in_progress
      await ticketRepo.logAction(ticketId, user.id, 'status_changed', 'open', 'in_progress', 'Status changed via self-assignment', client);

      const version = await ticketRepo.bumpVersion(client, ticketId);
      await ticketRepo.insertOutboxRow(client, {
        eventType: 'ticket:updated',
        ticketId,
        parentTicketId: updated.parent_ticket_id,
        payload: updated,
        actorId: user.id,
        version,
      });

      return updated;
    });
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

    const assignedEmployee = await ticketRepo.getUserById(employeeId);
    const assignedEmployeeName = assignedEmployee ? assignedEmployee.name : `Unknown Employee (ID: ${employeeId})`;

    return await ticketRepo.withTransaction(async (client) => {
      const updated = await ticketRepo.assignToEmployee(ticketId, employeeId, user.id, client);
      if (!updated) throw { statusCode: 400, message: 'Unable to assign ticket' };

      await ticketRepo.logAction(
        ticketId,
        user.id,
        'assigned',
        ticketBeforeUpdate.assigned_to_name || 'Unassigned',
        assignedEmployeeName,
        `Manager ${user.name} assigned the ticket.`,
        client
      );

      // Log status change if it went from 'open' to 'in_progress'
      if (ticketBeforeUpdate.status === 'open' && updated.status === 'in_progress') {
        await ticketRepo.logAction(
          ticketId,
          user.id,
          'status_changed',
          ticketBeforeUpdate.status,
          updated.status,
          'Status changed due to assignment',
          client
        );
      }

      const version = await ticketRepo.bumpVersion(client, ticketId);
      await ticketRepo.insertOutboxRow(client, {
        eventType: 'ticket:updated',
        ticketId,
        parentTicketId: updated.parent_ticket_id,
        payload: updated,
        actorId: user.id,
        version,
      });

      return updated;
    });
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

    // Permission Check
    if (user.role === 'ceo') throw { statusCode: 403, message: 'CEO is not authorized to create sub-tickets' };

    if (parentTicket.assigned_to_id && parentTicket.assigned_to_id !== user.id && user.role !== 'manager') {
      throw { statusCode: 403, message: 'Only the assigned resolver or a manager can create a sub-ticket' };
    }

    return await ticketRepo.withTransaction(async (client) => {
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
      }, client);

      // Log the sub-ticket creation on the parent ticket
      await ticketRepo.logAction(
        ticketId,
        user.id,
        'sub_ticket_created',
        null,
        String(subTicket.id),
        `Sub-ticket #${subTicket.id} created for department ${subTicket.assigned_dept_name} (formerly Transfer)`,
        client
      );

      // Log creation on the sub-ticket itself
      await ticketRepo.logAction(
        subTicket.id,
        user.id,
        'created',
        null,
        subTicket.status,
        `Created as a sub-ticket of #${ticketId}`,
        client
      );

      const version = await ticketRepo.bumpVersion(client, subTicket.id);
      await ticketRepo.insertOutboxRow(client, {
        eventType: 'ticket:created',
        ticketId: subTicket.id,
        parentTicketId: subTicket.parent_ticket_id,
        payload: subTicket,
        actorId: user.id,
        version,
      });

      return subTicket;
    });
  }

  async reopenTicket(ticketId, user) {
    const ticket = await ticketRepo.getTicketById(ticketId, user);
    if (!ticket) throw { statusCode: 404, message: 'Ticket not found' };
    if (ticket.forbidden) throw { statusCode: 403, message: 'Access denied' };

    const oldStatus = ticket.status;

    return await ticketRepo.withTransaction(async (client) => {
      const updated = await ticketRepo.reopenTicket(ticketId, user.id, client);
      if (!updated) throw { statusCode: 400, message: 'Unable to reopen ticket' };

      await ticketRepo.logAction(ticketId, user.id, 'reopened', oldStatus, 'in_progress', `Ticket reopened by creator (${user.name}) and returned to "In Progress" status.`, client);

      const version = await ticketRepo.bumpVersion(client, ticketId);
      await ticketRepo.insertOutboxRow(client, {
        eventType: 'ticket:updated',
        ticketId,
        parentTicketId: updated.parent_ticket_id,
        payload: updated,
        actorId: user.id,
        version,
      });

      return updated;
    });
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

    return await ticketRepo.withTransaction(async (client) => {
      const comment = await ticketRepo.addComment(ticketId, user.id, message, client);

      await ticketRepo.logAction(
        ticketId,
        user.id,
        'comment_added',
        null,
        message.substring(0, 100),
        `Comment added by ${user.name}`,
        client
      );

      const version = await ticketRepo.bumpVersion(client, ticketId);
      await ticketRepo.insertOutboxRow(client, {
        eventType: 'ticket:updated',
        ticketId,
        parentTicketId: ticket.parent_ticket_id,
        payload: comment,
        actorId: user.id,
        version,
      });

      return comment;
    });
  }

  // ── Update ticket details (title, description, priority, due_date) ──────
  async updateTicket(ticketId, user, fields) {
    const ticket = await ticketRepo.getTicketById(ticketId, user);
    if (!ticket) throw { statusCode: 404, message: 'Ticket not found' };
    if (ticket.forbidden) throw { statusCode: 403, message: 'Access denied' };

    return await ticketRepo.withTransaction(async (client) => {
      const updated = await ticketRepo.updateTicketField(ticketId, user.id, fields, client);
      if (!updated) throw { statusCode: 400, message: 'No valid fields to update' };

      const version = await ticketRepo.bumpVersion(client, ticketId);
      await ticketRepo.insertOutboxRow(client, {
        eventType: 'ticket:updated',
        ticketId,
        parentTicketId: updated.parent_ticket_id,
        payload: updated,
        actorId: user.id,
        version,
      });

      return updated;
    });
  }

  async getDepartments(user) {
    return await ticketRepo.getDepartments(user.company_id);
  }

  async getEmployees(user, departmentId) {
    if (departmentId) {
      return await ticketRepo.getEmployeesByDepartment(Number(departmentId));
    }
    return await ticketRepo.getEmployeesByCompany(user.company_id);
  }

  async getMyTickets(user, filters) {
    return await ticketRepo.getMyTickets(user.id, filters);
  }

  async getSentTickets(user) {
    const tickets = await ticketRepo.getSentTicketsByDepartment(user.department_id);
    return await ticketRepo.enrichTicketsWithSubData(tickets);
  }

  async getDepartmentAnalytics(departmentId, user) {
    return await ticketRepo.getDashboardStats({
      role: 'manager',
      department_id: Number(departmentId),
      company_id: user.company_id
    });
  }

  async getTicketLogs(ticketId, user) {
    const ticket = await ticketRepo.getTicketById(ticketId, user);
    if (!ticket) throw { statusCode: 404, message: 'Ticket not found' };
    if (ticket.forbidden) throw { statusCode: 403, message: 'Access denied' };
    return await ticketRepo.getTicketLogs(ticketId);
  }

  async getAnalyticsByDepartment(user) {
    return await ticketRepo.getAnalyticsByDepartment(user);
  }

  async getOrganizationAnalytics(user) {
    return await ticketRepo.getAnalyticsByDepartment(user); // Reusing the existing repo method for now
  }
}

module.exports = new TicketService();
