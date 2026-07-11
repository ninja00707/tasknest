const ticketRepo = require('../modules/ticket/ticket.repository');
const eventBus = require('./eventBus');

let io = null;

function init(ioInstance) {
  io = ioInstance;

  eventBus.on('ticket:*', async ({ eventType, ticketId, data }) => {
    if (!io) return;
    const involved = data._involvedUserIds || [];
    const skipUserIds = data._skipUserIds || [];
    const notifyUserIds = data._notifyUserIds || null;

    if (involved.length === 0) return;

    const notifTarget = (notifyUserIds ?? involved).filter(id => !skipUserIds.includes(id));
    let notifications = [];
    if (notifTarget.length > 0) {
      try {
        notifications = await ticketRepo.createNotifications(notifTarget, ticketId, data._message || '');
      } catch (err) {
        console.error(`[EventHandler] Failed to create notifications for ticket ${ticketId}:`, err.message);
      }
    }

    const notifMap = {};
    for (const n of notifications) notifMap[n.user_id] = n;

    for (const userId of involved) {
      const notif = notifMap[userId];
      io.to(`user_${userId}`).emit(data._eventType || eventType, {
        event: eventType,
        ticketId,
        ticketNumber: data.ticketNumber,
        newStatus: data.newStatus,
        newPriority: data.newPriority,
        oldStatus: data.oldStatus,
        assignedTo: data.assignedTo,
        assignedDept: data.assignedDept,
        notificationId: notif?.id || null,
        createdAt: notif?.created_at || new Date().toISOString(),
        message: data._message || '',
      });
    }

    if (notifTarget.length > 0) {
      const uniqueUsers = [...new Set(notifTarget)];
      try {
        const counts = await Promise.all(uniqueUsers.map(id => ticketRepo.getUnreadCount(id)));
        for (let i = 0; i < uniqueUsers.length; i++) {
          io.to(`user_${uniqueUsers[i]}`).emit('NOTIFICATION_COUNT', { count: counts[i] });
        }
      } catch (err) {
        console.error(`[EventHandler] Failed to get unread counts:`, err.message);
      }
    }
  });
}

module.exports = { init };
