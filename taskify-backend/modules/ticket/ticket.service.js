const ticketRepo = require('./ticket.repository');
const cache = require('../../core/cache');

class TicketService {
  // ── Recursively propagate status up the parent chain ────────────────────
  // in_progress: push every ancestor to in_progress.
  // closed: auto-close the root master once every descendant sub-ticket is
  //         closed (sub-tickets themselves are closed by their assignee).
  async _propagateUpward(childTicket, newStatus, user) {
    if (!childTicket.parent_ticket_id) return [];

    if (newStatus === 'in_progress') {
      return await ticketRepo.updateParentChain(childTicket.id, 'in_progress');
    }

    if (newStatus === 'closed') {
      return await this._autoCloseParents(childTicket, user);
    }

    return [];
  }

  // ── Auto-close the root master once every descendant sub-ticket closes ──
  // Each sub-ticket (including intermediate ones) is closed by its own
  // assignee — never auto-closed here — so only the root master is ever
  // closed by this helper. We still walk past intermediate sub-tickets to
  // check the master whenever a descendant closes.
  async _autoCloseParents(childTicket, user) {
    if (!childTicket.parent_ticket_id) return [];

    const chain = await ticketRepo.getParentChain(childTicket.id);
    const closedParents = [];
    for (const p of chain) {
      if (p.isSubTicket) {
        // Intermediate sub-ticket: its assignee closes it explicitly.
        continue;
      }
      const closed = await ticketRepo.closeTicketIfAllChildrenClosed(p.parentId, user.id);
      if (closed) {
        closedParents.push({ parentId: p.parentId });
      } else {
        // The master can only close once every sub-ticket is closed.
        break;
      }
    }
    return closedParents;
  }

  _invalidateStats(...userIds) {
    for (const id of userIds) {
      if (id) cache.del(`dash:stats:${id}`);
    }
  }

  async _emitParentChain(ticketId, updatedParents, actingUserId) {
    if (!updatedParents || updatedParents.length === 0) return;

    const pool = require('../../database/db');
    const client = await pool.connect();
    try {
      await client.query('BEGIN');
      for (const p of updatedParents) {
        const parentTicket = await ticketRepo.getTicketById(p.parentId, null, true);
        if (parentTicket && !parentTicket.forbidden) {
          await ticketRepo.insertOutbox({
            eventType: 'TICKET_STATUS_UPDATED',
            ticketId: p.parentId,
            parentTicketId: parentTicket.parent_ticket_id || null,
            payload: { ticket: parentTicket },
            version: parentTicket.version || 1,
            actingUserId,
          }, client);
        }
      }
      await client.query('COMMIT');
    } catch (err) {
      try { await client.query('ROLLBACK'); } catch (_) {}
      console.error(`[TicketService] Failed to emit parent chain for ticket ${ticketId}:`, err.message);
    } finally {
      client.release();
    }
  }

  async getDashboardStats(user) {
    if (!user) throw { statusCode: 401, message: 'Unauthorized' };
    const cacheKey = `dash:stats:${user.id}`;
    const ttl = parseInt(process.env.CACHE_STATS_TTL) || 120;
    return await cache.remember(cacheKey, ttl, () => ticketRepo.getDashboardStats(user));
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
    const { title, description, priority = 'medium', assignedDeptId, dueDate, parentTicketId = null, selfAssign = false, projectId } = data;
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
          title,
          description,
          priority,
          assignedDeptId: user.department_id,
          dueDate,
          createdBy: user,
          assignedToId: user.id,
          parentTicketId: null,
          ticketType: 'multi_task',
          projectId: projectId != null ? Number(projectId) : null
        });

        await ticketRepo.logAction(masterTicket.id, user.id, 'created', null, 'open', 'Project Master created for multi-department task');

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
        title,
        description,
        priority,
        assignedDeptId: user.department_id,
        dueDate,
        createdBy: user,
        assignedToId: user.id,
        parentTicketId: null,
        ticketType: 'standard',
        projectId: projectId != null ? Number(projectId) : null
      });

      await ticketRepo.logAction(masterTicket.id, user.id, 'created', null, 'open', 'Project Master created for department oversight');

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
      ticketType: 'standard',
      projectId: projectId != null ? Number(projectId) : null
    });
    this._invalidateStats(user.id, assignedToId);

    const logNote = `Created by ${user.name}${assignedToId ? ` and assigned to ${ticket.assigned_to_name}` : ''}${parentTicketId ? ` as a sub-ticket of #${parentTicketId}` : ''}`;
    await ticketRepo.logAction(ticket.id, user.id, 'created', null, ticket.status, logNote);

    if (parentTicketId) {
      await ticketRepo.logAction(parentTicketId, user.id, 'sub_ticket_created', null, String(ticket.id), `Sub-ticket #${ticket.id} created by ${user.name}`);
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
    this._invalidateStats(user.id);

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
    if (!['open', 'in_progress', 'pending_approval', 'approved'].includes(status)) {
      throw { statusCode: 400, message: 'Status must be open, in_progress, pending_approval, or approved' };
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


    const updated = await ticketRepo.updateSubDeptProgress(
      ticketId,
      Number(departmentId),
      { status }
    );
    this._invalidateStats(user.id);

    const deptName = deptRow.department_name || `Dept ${departmentId}`;

    // Log the progress change
    const progressLog = status === 'pending_approval'
      ? `${user.name} submitted ${deptName} work as done${note ? `. Remark: ${note}` : ''}`
      : status === 'approved'
        ? `${user.name} approved ${deptName} work`

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
      } else {
        commentMsg = `[DEPT PROGRESS - ${deptName}]: ${note.trim()}`;
      }
      await ticketRepo.addComment(ticketId, user.id, commentMsg);
      await ticketRepo.logAction(
        ticketId, user.id, 'comment_added', null,
        commentMsg.substring(0, 100),
        status === 'approved'
          ? `Manager ${user.name} approved ${deptName} work`
          : `Note added by ${user.name} for ${deptName}`
      );
    }

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
      d => d.status === 'approved'
    );
    if (!allApprovedOrCompleted) {
      throw { statusCode: 400, message: 'All departments must be approved before completing the ticket' };
    }

    const updated = await ticketRepo.completeSubTicket(ticketId, user.id);

    const doneDepts = ticket.sub_departments.map(d => d.department_name || `Dept ${d.department_id}`).join(', ');
    await ticketRepo.logAction(
      ticketId, user.id, 'status_changed',
      'in_progress', 'closed',
      `Creator ${user.name} marked the sub-ticket as closed. Departments: ${doneDepts}`
    );

    // Auto-close the master (and any intermediate parents) once all their
    // direct sub-tickets are closed — no further creator action required.
    const closedParents = await this._autoCloseParents(ticket, user);
    if (closedParents.length > 0) {
      await this._emitParentChain(ticketId, closedParents, user.id);
    }

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

    if (deptRow.status !== 'approved') {
      throw { statusCode: 400, message: 'Only approved department tasks can be reopened' };
    }

    // Determine cascade order (sub_departments is already ordered by d.name ASC)
    const currentIndex = ticket.sub_departments.findIndex(d => Number(d.department_id) === Number(departmentId));
    const prevDept = currentIndex > 0 ? ticket.sub_departments[currentIndex - 1] : null;
    const isCascadeReopen = prevDept && prevDept.status === 'in_progress';

    // For cascade reopens (previous department already in_progress), skip the
    // reopen-count restrictions so the chain can continue down.
    if (!isCascadeReopen) {
      // Check if already reopened once
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

    const updated = await ticketRepo.reopenSubDept(ticketId, Number(departmentId), nextDeptId);

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

    return updated;
  }

  async updateStatus(ticketId, newStatus, user, remark, isSystemUpdate = false) {
    const ticket = await ticketRepo.getTicketById(ticketId, user, isSystemUpdate);
    if (!ticket) throw { statusCode: 404, message: 'Ticket not found' };
    if (ticket.forbidden) throw { statusCode: 403, message: 'Access denied' };

    const allowedStatuses = ['open', 'in_progress', 'closed'];
    if (!allowedStatuses.includes(newStatus)) {
      throw { statusCode: 400, message: 'Invalid status' };
    }

    // Only the master waits for ALL its sub-tickets to close. A sub-ticket
    // can always be closed by its own assignee once its work is done,
    // regardless of how many sub-tickets exist.
    if (!isSystemUpdate && newStatus === 'closed' && !ticket.is_sub_ticket) {
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

    // Finalize and close permission
    if (newStatus === 'closed') {
      if (!isSystemUpdate) {
        if (ticket.is_sub_ticket) {
          // Sub-tickets: only the assigned resolver
          if (!isResolver) {
            throw { statusCode: 403, message: 'Only the assigned resolver can finalize and close this sub-ticket' };
          }
        } else {
          // Master tickets: only the creator
          if (!isCreator) {
            throw { statusCode: 403, message: 'Only the creator can finalize and close this master ticket' };
          }
        }
      }
      if (!remark || String(remark).trim() === '') {
        throw { statusCode: 400, message: 'Closing remark is required when closing ticket' };
      }
    }

if (ticket.status === 'closed') {
  throw { statusCode: 400, message: 'Ticket is already closed. It must be reopened first.' };
}

const oldStatus = ticket.status;
const updated = await ticketRepo.updateStatus(ticketId, newStatus, user);
this._invalidateStats(user.id);
await ticketRepo.logAction(
  ticketId,
  user.id,
  'status_changed',
  oldStatus,
  newStatus,
  `Status updated to ${newStatus} by ${user.name}${isSystemUpdate ? ' (System Action)' : ''}${remark ? `. Remark: ${remark}` : ''}`
);

// ── Recursively propagate status up the parent chain ──────────────
const updatedParents = await this._propagateUpward(ticket, newStatus, user);
await this._emitParentChain(ticketId, updatedParents, user.id);

// Transparency: Add the closing/completion remark as a formal comment so it is visible in the thread
if (newStatus === 'closed' && remark) {
  const commentMsg = `[${newStatus.toUpperCase()} REMARK]: ${remark}`;
  await ticketRepo.addComment(ticketId, user.id, commentMsg);
  await ticketRepo.logAction(
    ticketId, user.id, 'comment_added', null,
    commentMsg.substring(0, 100),
    `${newStatus.charAt(0).toUpperCase() + newStatus.slice(1)} remark added by ${user.name}`
  );
}

return updated;
  }

  // ── Dispute & close a ticket (managers only, solid argument required) ───
  async dispute(ticketId, user, argument) {
    if (user.role !== 'manager') {
      throw { statusCode: 403, message: 'Only managers can dispute a ticket' };
    }
    if (!argument || String(argument).trim().length < 20) {
      throw { statusCode: 400, message: 'A solid argument statement is required before closing the ticket (min 20 characters)' };
    }

    const ticket = await ticketRepo.getTicketById(ticketId, user);
    if (!ticket) throw { statusCode: 404, message: 'Ticket not found' };
    if (ticket.forbidden) throw { statusCode: 403, message: 'Access denied' };
    if (ticket.status === 'closed') {
      throw { statusCode: 400, message: 'Ticket is already closed' };
    }
    if (ticket.is_sub_ticket) {
      throw { statusCode: 400, message: 'Only master tickets can be disputed' };
    }

    const oldStatus = ticket.status;

    // Dispute closes the whole tree: first force-close every sub-ticket,
    // then the master goes straight to Closed.
    if (!ticket.is_sub_ticket) {
      await ticketRepo.closeAllSubTickets(ticketId, user.id);
    }

    const updated = await ticketRepo.updateStatus(ticketId, 'closed', user);
    this._invalidateStats(user.id);

    await ticketRepo.logAction(
      ticketId, user.id, 'disputed', oldStatus, 'closed',
      String(argument).trim()
    );

    const commentMsg = `[DISPUTE]: ${String(argument).trim()}`;
    await ticketRepo.addComment(ticketId, user.id, commentMsg);
    await ticketRepo.logAction(
      ticketId, user.id, 'comment_added', null,
      commentMsg.substring(0, 100),
      `Dispute comment added by ${user.name}`
    );

    if (ticket.parent_ticket_id) {
      const updatedParents = await this._propagateUpward(ticket, 'closed', user);
      await this._emitParentChain(ticketId, updatedParents, user.id);
    }

    const enriched = await ticketRepo.getTicketById(ticketId, user);
    await this._emitDisputeOutbox(ticketId, {
      id: -ticketId,
      ticket_id: ticketId,
      ticket_title: ticket.title,
      ticket_number: ticket.ticket_number,
      ticket_status: 'closed',
      raised_by_id: user.id,
      raised_by_name: user.name,
      reason: 'other',
      description: String(argument).trim(),
      status: 'disputed',
      created_at: new Date().toISOString(),
    }, user.id);

    return enriched || updated;
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
  this._invalidateStats(user.id);

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

  if (ticketBeforeUpdate.parent_ticket_id) {
    const updatedParents = await this._propagateUpward(ticketBeforeUpdate, 'in_progress', user);
    await this._emitParentChain(ticketId, updatedParents, user.id);
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

  // Actions are disabled for closed tickets
  if (ticketBeforeUpdate.status === 'closed') {
    throw { statusCode: 400, message: 'Cannot assign a ticket that is already closed' };
  }

  const updated = await ticketRepo.assignToEmployee(ticketId, employeeId, user.id);
  if (!updated) throw { statusCode: 400, message: 'Unable to assign ticket' };
  this._invalidateStats(user.id, employeeId);

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

  if (ticketBeforeUpdate.parent_ticket_id && (ticketBeforeUpdate.status === 'open' || updated.status === 'in_progress')) {
    const updatedParents = await this._propagateUpward(ticketBeforeUpdate, 'in_progress', user);
    await this._emitParentChain(ticketId, updatedParents, user.id);
  }

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

  return subTicket;
}

  async reopenTicket(ticketId, user) {
  const ticket = await ticketRepo.getTicketById(ticketId, user);
  if (!ticket) throw { statusCode: 404, message: 'Ticket not found' };
  if (ticket.forbidden) throw { statusCode: 403, message: 'Access denied' };

  const oldStatus = ticket.status;

  const updated = await ticketRepo.reopenTicket(ticketId, user.id);
  if (!updated) throw { statusCode: 400, message: 'Unable to reopen ticket' };
  this._invalidateStats(user.id);

  await ticketRepo.logAction(ticketId, user.id, 'reopened', oldStatus, 'in_progress', `Ticket reopened by creator (${user.name}) and returned to "In Progress" status.`);

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
  this._invalidateStats(user.id);

  await ticketRepo.logAction(
    ticketId,
    user.id,
    'comment_added',
    null,
    message.substring(0, 100),
    `Comment added by ${user.name}`
  );

  return comment;
}

  // ── Update ticket details (title, description, priority, due_date) ──────
  async updateTicket(ticketId, user, fields) {
  const ticket = await ticketRepo.getTicketById(ticketId, user);
  if (!ticket) throw { statusCode: 404, message: 'Ticket not found' };
  if (ticket.forbidden) throw { statusCode: 403, message: 'Access denied' };

  // Description is editable only by the ticket creator while the ticket is
  // still OPEN (before it moves to in_progress).
  if (fields && Object.prototype.hasOwnProperty.call(fields, 'description')) {
    if (Number(ticket.created_by_id) !== Number(user.id)) {
      throw { statusCode: 403, message: 'Only the ticket creator can edit the description' };
    }
    if (ticket.status !== 'open') {
      throw { statusCode: 400, message: 'Description can only be edited while the ticket is open' };
    }
  }

  const updated = await ticketRepo.updateTicketField(ticketId, user.id, fields);
  if (!updated) throw { statusCode: 400, message: 'No valid fields to update' };
  this._invalidateStats(user.id);

  return updated;
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

  // ── Ticket Disputes (review workflow) ────────────────────────────────────
  _isTicketParticipant(ticket, user) {
    return Number(ticket.created_by_id) === Number(user.id) ||
      Number(ticket.assigned_to_id) === Number(user.id) ||
      Number(ticket.assigned_dept_id) === Number(user.department_id);
  }

  _canReviewDispute(ticket, user) {
    if (['ceo', 'developer'].includes(user.role)) return true;
    return user.role === 'manager' &&
      Number(ticket.assigned_dept_id) === Number(user.department_id);
  }

  _disputeClosed(status) {
    return ['resolved', 'rejected', 'escalated', 'withdrawn'].includes(status);
  }

  async _emitDisputeOutbox(ticketId, dispute, userId) {
    try {
      let ticket = null;
      try { ticket = await ticketRepo.getTicketById(ticketId, null, true); } catch (_) {}
      const version = dispute?.updated_at
        ? new Date(dispute.updated_at).getTime()
        : Date.now();
      await ticketRepo.insertOutbox({
        eventType: 'DISPUTE_UPDATED',
        ticketId,
        parentTicketId: null,
        payload: { dispute, ticket },
        version,
        actingUserId: userId,
      });
    } catch (err) {
      console.error('[Dispute] Outbox emit failed:', err.message);
    }
  }

  async getDisputeByTicket(ticketId, user) {
    const ticket = await ticketRepo.getTicketById(ticketId, user);
    if (!ticket) throw { statusCode: 404, message: 'Ticket not found' };
    if (ticket.forbidden) throw { statusCode: 403, message: 'Access denied' };
    return await ticketRepo.getDisputeByTicket(ticketId);
  }

  async listDisputes(user) {
    return await ticketRepo.listDisputes(user);
  }

  async raiseDispute(ticketId, user, reason, description) {
    const allowedReasons = ['wrong_resolution', 'sla_breach', 'wrong_assignment', 'quality_issue', 'other'];
    if (!allowedReasons.includes(reason)) {
      throw { statusCode: 400, message: 'Invalid dispute reason' };
    }
    if (!description || String(description).trim().length < 10) {
      throw { statusCode: 400, message: 'Please describe the dispute (min 10 characters)' };
    }

    const ticket = await ticketRepo.getTicketById(ticketId, user);
    if (!ticket) throw { statusCode: 404, message: 'Ticket not found' };
    if (ticket.forbidden) throw { statusCode: 403, message: 'Access denied' };
    if (!this._isTicketParticipant(ticket, user)) {
      throw { statusCode: 403, message: 'Only ticket participants can raise a dispute' };
    }
    const existing = await ticketRepo.getDisputeByTicket(ticketId);
    if (existing) throw { statusCode: 400, message: 'A dispute already exists for this ticket' };

    const dispute = await ticketRepo.createDispute({
      ticketId,
      raisedById: user.id,
      reason,
      description: String(description).trim(),
    });
    await this._emitDisputeOutbox(ticketId, dispute, user.id);
    return dispute;
  }

  async addDisputeComment(disputeId, user, note) {
    if (!note || String(note).trim() === '') {
      throw { statusCode: 400, message: 'Comment is required' };
    }
    const dispute = await ticketRepo.getDisputeById(disputeId);
    if (!dispute) throw { statusCode: 404, message: 'Dispute not found' };
    const ticket = await ticketRepo.getTicketById(dispute.ticket_id, user);
    if (!ticket || ticket.forbidden) throw { statusCode: 403, message: 'Access denied' };

    const canComment = Number(dispute.raised_by_id) === Number(user.id) ||
      this._isTicketParticipant(ticket, user) ||
      this._canReviewDispute(ticket, user);
    if (!canComment) throw { statusCode: 403, message: 'You cannot comment on this dispute' };
    if (this._disputeClosed(dispute.status)) {
      throw { statusCode: 400, message: 'This dispute is already closed' };
    }

    await ticketRepo.addDisputeActivity(
      dispute.id, 'commented', user.id, user.name, String(note).trim()
    );
    await ticketRepo.updateDispute(dispute.id, {});
    const updated = await ticketRepo.getDisputeById(dispute.id);
    await this._emitDisputeOutbox(updated.ticket_id, updated, user.id);
    return updated;
  }

  async updateDisputeStatus(disputeId, user, status, note, reviewerId) {
    const allowed = ['under_review', 'resolved', 'rejected', 'escalated'];
    if (!allowed.includes(status)) {
      throw { statusCode: 400, message: 'Invalid dispute status' };
    }

    const dispute = await ticketRepo.getDisputeById(disputeId);
    if (!dispute) throw { statusCode: 404, message: 'Dispute not found' };
    const ticket = await ticketRepo.getTicketById(dispute.ticket_id, user);
    if (!ticket || ticket.forbidden) throw { statusCode: 403, message: 'Access denied' };
    if (!this._canReviewDispute(ticket, user)) {
      throw { statusCode: 403, message: 'Only the department head or an admin can update this dispute' };
    }
    if (this._disputeClosed(dispute.status)) {
      throw { statusCode: 400, message: 'This dispute is already closed' };
    }
    if ((status === 'resolved' || status === 'rejected') &&
        (!note || String(note).trim().length < 10)) {
      throw { statusCode: 400, message: 'A resolution note is required (min 10 characters)' };
    }

    const updates = {
      status,
      resolutionNotes: note ? String(note).trim() : undefined,
    };
    let action = 'status_changed';
    if (status === 'resolved') action = 'resolved';
    if (status === 'rejected') action = 'rejected';
    if (status === 'escalated') action = 'escalated';

    if (status === 'under_review') {
      const reviewer = reviewerId || user.id;
      updates.assignedReviewerId = reviewer;
      if (Number(dispute.assigned_reviewer_id) !== Number(reviewer)) {
        await ticketRepo.addDisputeActivity(
          dispute.id, 'reviewer_assigned', user.id, user.name, `Reviewer assigned`
        );
      }
    }

    await ticketRepo.updateDispute(dispute.id, updates);
    await ticketRepo.addDisputeActivity(
      dispute.id, action, user.id, user.name, note ? String(note).trim() : null
    );
    const updated = await ticketRepo.getDisputeById(dispute.id);
    await this._emitDisputeOutbox(updated.ticket_id, updated, user.id);
    return updated;
  }

  async withdrawDispute(disputeId, user) {
    const dispute = await ticketRepo.getDisputeById(disputeId);
    if (!dispute) throw { statusCode: 404, message: 'Dispute not found' };
    if (Number(dispute.raised_by_id) !== Number(user.id)) {
      throw { statusCode: 403, message: 'Only the raiser can withdraw this dispute' };
    }
    if (this._disputeClosed(dispute.status)) {
      throw { statusCode: 400, message: 'This dispute is already closed' };
    }

    await ticketRepo.updateDispute(dispute.id, { status: 'withdrawn' });
    await ticketRepo.addDisputeActivity(
      dispute.id, 'withdrawn', user.id, user.name, 'Dispute withdrawn by the raiser'
    );
    const updated = await ticketRepo.getDisputeById(dispute.id);
    await this._emitDisputeOutbox(updated.ticket_id, updated, user.id);
    return updated;
  }
}

module.exports = new TicketService();
