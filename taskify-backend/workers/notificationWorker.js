const queueManager = require('../core/queue');
const ticketRepo = require('../modules/ticket/ticket.repository');
const pushNotifier = require('../core/pushNotifier');

async function init() {
  const queue = queueManager.get('notifications');

  queue.process('dispatch', async (job) => {
    const { ticketId, userIds, message, eventType, payload, skipUserIds } = job.data;

    const notifTarget = userIds.filter(id => !skipUserIds.includes(id));
    if (notifTarget.length > 0) {
      try {
        await ticketRepo.createNotifications(notifTarget, ticketId, message);
      } catch (err) {
        console.error(`[NotificationWorker] Failed to create notifications for ticket ${ticketId}:`, err.message);
        return;
      }
    }

    for (const userId of notifTarget) {
      pushNotifier.sendPush(userId, {
        title: message,
        body: `Ticket #${payload.ticketNumber || payload.ticket?.ticketNumber || ticketId} update.`,
        ticketId
      }).catch(err => {
        console.error(`[NotificationWorker] Push error for user ${userId}:`, err.message);
      });
    }
  });

  console.log('[NotificationWorker] Ready');
}

module.exports = { init };
