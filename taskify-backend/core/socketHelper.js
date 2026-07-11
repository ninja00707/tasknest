const ticketRepo = require('../modules/ticket/ticket.repository');

class SocketHelper {
  constructor() {
    this.io = null;
  }

  init(io) {
    this.io = io;
  }

  async emit(eventType, ticketId, userIds, message, payload = {}, skipUserIds = []) {
    if (!this.io) return;

    const notifTarget = userIds.filter(id => !skipUserIds.includes(id));
    let notifications = [];
    if (notifTarget.length > 0) {
      try {
        notifications = await ticketRepo.createNotifications(notifTarget, ticketId, message);
      } catch (err) {
        console.error(`[SocketHelper] Failed to create notifications for ticket ${ticketId}:`, err.message);
      }
    }

    const notifMap = {};
    for (const n of notifications) notifMap[n.user_id] = n;

    for (const userId of userIds) {
      const notif = notifMap[userId];
      this.io.to(`user_${userId}`).emit(eventType, {
        ticketId,
        ticketNumber: payload.ticketNumber || payload.ticket?.ticketNumber || null,
        newStatus: payload.newStatus || payload.ticket?.status || null,
        oldStatus: payload.oldStatus || null,
        assignedTo: payload.assignedTo || payload.ticket?.assigned_to_name || null,
        assignedDept: payload.assignedDept || payload.ticket?.assigned_dept_code || null,
        message,
        notificationId: notif?.id || null,
        createdAt: notif?.created_at || new Date().toISOString(),
        event: eventType,
      });
    }

    if (notifTarget.length > 0) {
      const uniqueUsers = [...new Set(notifTarget)];
      try {
        const counts = await ticketRepo.getUnreadCounts(uniqueUsers);
        for (const userId of uniqueUsers) {
          this.io.to(`user_${userId}`).emit('NOTIFICATION_COUNT', { count: counts[userId] ?? 0 });
        }
      } catch (err) {
        console.error(`[SocketHelper] Failed to get unread counts:`, err.message);
      }
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
