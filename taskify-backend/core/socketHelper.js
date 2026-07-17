const queueManager = require('./queue');

class SocketHelper {
  constructor() {
    this.io = null;
  }

  init(io) {
    this.io = io;
  }

  async emit(eventType, ticketId, userIds, message, payload = {}, skipUserIds = []) {
    if (!this.io) return;

    // 1. Emit live update event immediately with notificationId: null so client can update UI instantly.
    for (const userId of userIds) {
      this.io.to(`user_${userId}`).emit(eventType, {
        ticketId,
        ticketNumber: payload.ticketNumber || payload.ticket?.ticketNumber || null,
        newStatus: payload.newStatus || payload.ticket?.status || null,
        oldStatus: payload.oldStatus || null,
        assignedTo: payload.assignedTo || payload.ticket?.assigned_to_name || null,
        assignedDept: payload.assignedDept || payload.ticket?.assigned_dept_code || null,
        message,
        notificationId: null,
        createdAt: new Date().toISOString(),
        event: eventType,
      });
    }

    // 1b. Also broadcast immediately to department rooms for real-time UI updates across the departments.
    const deptIds = new Set();
    if (payload.ticket?.assigned_dept_id) deptIds.add(payload.ticket.assigned_dept_id);
    if (payload.ticket?.created_by_dept) deptIds.add(payload.ticket.created_by_dept);
    if (payload.assignedDept) deptIds.add(payload.assignedDept);
    if (payload.ticket?.sub_departments && Array.isArray(payload.ticket.sub_departments)) {
      for (const sd of payload.ticket.sub_departments) {
        if (sd.department_id) deptIds.add(sd.department_id);
      }
    }
    for (const deptId of deptIds) {
      this.io.to(`dept_${deptId}`).emit(eventType, {
        ticketId,
        ticketNumber: payload.ticketNumber || payload.ticket?.ticketNumber || null,
        newStatus: payload.newStatus || payload.ticket?.status || null,
        oldStatus: payload.oldStatus || null,
        assignedTo: payload.assignedTo || payload.ticket?.assigned_to_name || null,
        assignedDept: payload.assignedDept || payload.ticket?.assigned_dept_code || null,
        message,
        notificationId: null,
        createdAt: new Date().toISOString(),
        event: eventType,
      });
    }

    // 2. Offload DB creation & push notifications to queue.
    const notifTarget = userIds.filter(id => !skipUserIds.includes(id));
    if (notifTarget.length > 0) {
      const q = queueManager.get('notifications');
      q.add('dispatch', {
        ticketId,
        userIds,
        message,
        eventType,
        payload,
        skipUserIds
      }).catch(err => {
        console.error(`[SocketHelper] Failed to enqueue notification job:`, err.message);
      });
    }
  }

  async create(ticketId, userIds, message, payload = {}, skipUserIds = []) {
    await this.emit('TICKET_CREATED', ticketId, userIds, message, payload, skipUserIds);
  }

  async read(ticketId, userIds, message, payload = {}, skipUserIds = []) {
    await this.emit('TICKET_VIEWED', ticketId, userIds, message, payload, skipUserIds);
  }

  async update(ticketId, userIds, message, payload = {}, skipUserIds = []) {
    await this.emit('TICKET_STATUS_UPDATED', ticketId, userIds, message, payload, skipUserIds);
  }

  async delete(ticketId, userIds, message, payload = {}, skipUserIds = []) {
    await this.emit('TICKET_CLOSED', ticketId, userIds, message, payload, skipUserIds);
  }

  async assign(ticketId, userIds, message, payload = {}, skipUserIds = []) {
    await this.emit('TICKET_ASSIGNED', ticketId, userIds, message, payload, skipUserIds);
  }

  async comment(ticketId, userIds, message, payload = {}, skipUserIds = []) {
    await this.emit('COMMENT_ADDED', ticketId, userIds, message, payload, skipUserIds);
  }

  async reopen(ticketId, userIds, message, payload = {}, skipUserIds = []) {
    await this.emit('TICKET_REOPENED', ticketId, userIds, message, payload, skipUserIds);
  }

  async complete(ticketId, userIds, message, payload = {}, skipUserIds = []) {
    await this.emit('SUB_TICKET_COMPLETED', ticketId, userIds, message, payload, skipUserIds);
  }

  async subCreate(ticketId, userIds, message, payload = {}, skipUserIds = []) {
    await this.emit('SUB_TICKET_CREATED', ticketId, userIds, message, payload, skipUserIds);
  }

  async subAssign(ticketId, userIds, message, payload = {}, skipUserIds = []) {
    await this.emit('SUB_TICKET_ASSIGNED', ticketId, userIds, message, payload, skipUserIds);
  }

  async subProgress(ticketId, userIds, message, payload = {}, skipUserIds = []) {
    await this.emit('SUB_TICKET_PROGRESS', ticketId, userIds, message, payload, skipUserIds);
  }

  async subReopen(ticketId, userIds, message, payload = {}, skipUserIds = []) {
    await this.emit('SUB_TICKET_REOPENED', ticketId, userIds, message, payload, skipUserIds);
  }

  async fieldUpdate(ticketId, userIds, message, payload = {}, skipUserIds = []) {
    await this.emit('TICKET_UPDATED', ticketId, userIds, message, payload, skipUserIds);
  }
}

module.exports = new SocketHelper();
