const ticketRepo = require('../modules/ticket/ticket.repository');

class SocketHelper {
  constructor() {
    this.io = null;
  }

  init(io) {
    this.io = io;
  }

  async emit(eventType, ticketId, userIds, message, payload = {}, skipUserIds = [], parentChain = []) {
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

    const payloadData = {
      ticketId,
      parentTicketId: payload.parentTicketId ?? payload.ticket?.parent_ticket_id ?? null,
      parentChain,
      ticketNumber: payload.ticketNumber || payload.ticket?.ticketNumber || payload.ticket?.ticket_number || null,
      newStatus: payload.newStatus || payload.ticket?.status || null,
      oldStatus: payload.oldStatus || null,
      assignedTo: payload.assignedTo || payload.ticket?.assigned_to_name || null,
      assignedDept: payload.assignedDept || payload.ticket?.assigned_dept_code || null,
      dispute: payload.dispute || null,
      message,
      event: eventType,
      createdAt: new Date().toISOString(),
    };

    const notifMap = {};
    for (const n of notifications) notifMap[n.user_id] = n;

    for (const userId of userIds) {
      const notif = notifMap[userId];
      this.io.to(`user_${userId}`).emit(eventType, {
        ...payloadData,
        notificationId: notif?.id || null,
        createdAt: notif?.created_at || new Date().toISOString(),
      });
    }

    // Also broadcast to the assigned department room for live dashboard updates
    const assignedDeptId = payload.ticket?.assigned_dept_id || payload.assignedDeptId;
    if (assignedDeptId) {
      this.io.to(`dept_${assignedDeptId}`).emit(eventType, payloadData);
    }

    // Broadcast to the creator's department room as well
    const creatorDeptId = payload.ticket?.created_by_dept || payload.createdByDept;
    if (creatorDeptId && Number(creatorDeptId) !== Number(assignedDeptId)) {
      this.io.to(`dept_${creatorDeptId}`).emit(eventType, payloadData);
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

}

module.exports = new SocketHelper();
