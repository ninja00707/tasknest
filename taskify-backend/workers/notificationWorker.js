// ── Background Notification Dispatcher ─────────────────────────────────────
// Offloads notification creation and socket emission from the HTTP request
// path so the API stays fast. Runs as a queue consumer.

const queueManager = require('../core/queue');
const ticketRepo = require('../modules/ticket/ticket.repository');
const pushNotifier = require('../core/pushNotifier');

async function init(io) {
  const queue = queueManager.get('notifications');

  queue.process('dispatch', async (job) => {
    const { ticketId, userIds, message, eventType, payload, skipUserIds } = job.data;

    const notifTarget = userIds.filter(id => !skipUserIds.includes(id));
    let notifications = [];
    if (notifTarget.length > 0) {
      try {
        notifications = await ticketRepo.createNotifications(notifTarget, ticketId, message);
      } catch (err) {
        console.error(`[NotificationWorker] Failed to create notifications for ticket ${ticketId}:`, err.message);
        return;
      }
    }

    // Send Chrome Push Notifications in parallel
    for (const userId of notifTarget) {
      pushNotifier.sendPush(userId, {
        title: message,
        body: `Ticket #${payload.ticketNumber || payload.ticket?.ticketNumber || ticketId} update.`,
        ticketId
      }).catch(err => {
        console.error(`[NotificationWorker] Push error for user ${userId}:`, err.message);
      });
    }

    if (!io) return;

    const notifMap = {};
    for (const n of notifications) notifMap[n.user_id] = n;

    // Send socket update WITH notificationId so client can display notification toast
    for (const userId of userIds) {
      const notif = notifMap[userId];
      if (notif) {
        io.to(`user_${userId}`).emit(eventType, {
          ticketId,
          ticketNumber: payload.ticketNumber || payload.ticket?.ticketNumber || null,
          newStatus: payload.newStatus || payload.ticket?.status || null,
          oldStatus: payload.oldStatus || null,
          assignedTo: payload.assignedTo || payload.ticket?.assigned_to_name || null,
          assignedDept: payload.assignedDept || payload.ticket?.assigned_dept_code || null,
          message,
          notificationId: notif.id,
          createdAt: notif.created_at,
          event: eventType,
        });
      }
    }

    if (notifTarget.length > 0) {
      const uniqueUsers = [...new Set(notifTarget)];
      try {
        const counts = await ticketRepo.getUnreadCounts(uniqueUsers);
        for (const userId of uniqueUsers) {
          io.to(`user_${userId}`).emit('NOTIFICATION_COUNT', { count: counts[userId] ?? 0 });
        }
      } catch (err) {
        console.error(`[NotificationWorker] Failed to get unread counts:`, err.message);
      }
    }
  });

  console.log('[NotificationWorker] Ready');
}

module.exports = { init };
