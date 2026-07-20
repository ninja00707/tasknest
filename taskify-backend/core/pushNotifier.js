const webpush = require('web-push');
const subscriptionRepo = require('../modules/notification/subscription.repository');

// Retrieve VAPID keys from environment or generate them on the fly if not configured
let vapidPublicKey = process.env.VAPID_PUBLIC_KEY;
let vapidPrivateKey = process.env.VAPID_PRIVATE_KEY;

if (!vapidPublicKey || !vapidPrivateKey) {
  const keys = webpush.generateVAPIDKeys();
  vapidPublicKey = keys.publicKey;
  vapidPrivateKey = keys.privateKey;
}

webpush.setVapidDetails(
  process.env.WEB_PUSH_SUBJECT || 'mailto:admin@example.com',
  vapidPublicKey,
  vapidPrivateKey
);

async function sendPush(userId, payload) {
  try {
    const subscription = await subscriptionRepo.getByUserId(userId);
    if (!subscription) return;

    const pushPayload = JSON.stringify({
      title: payload.title || 'TaskNest Update',
      body: payload.message || payload.body || 'You have a new update.',
      icon: '/assets/icons/icon-192.png',
      badge: '/assets/icons/badge-72.png',
      data: {
        ticketId: payload.ticketId,
        url: `/ticket/${payload.ticketId}`
      }
    });

    await webpush.sendNotification(subscription, pushPayload);
  } catch (err) {
    if (err.statusCode === 410 || err.statusCode === 404) {
      console.log(`[PushNotifier] Subscription expired/invalid for user ${userId}. Deleting.`);
      await subscriptionRepo.delete(userId);
    } else {
      console.error(`[PushNotifier] Failed to send push to user ${userId}:`, err.message);
    }
  }
}

module.exports = {
  sendPush,
  getPublicKey: () => vapidPublicKey
};
