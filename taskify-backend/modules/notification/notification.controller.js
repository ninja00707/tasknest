const notificationRepo = require('./notification.repository');
const subscriptionRepo = require('./subscription.repository');
const pushNotifier = require('../../core/pushNotifier');

class NotificationController {
  async getAll(req, res, next) {
    try {
      const notifications = await notificationRepo.findByUser(req.user.id);
      const unreadCount = await notificationRepo.getUnreadCount(req.user.id);
      res.json({ success: true, data: { notifications, unreadCount } });
    } catch (err) {
      next(err);
    }
  }

  async getUnreadCount(req, res, next) {
    try {
      const count = await notificationRepo.getUnreadCount(req.user.id);
      res.json({ success: true, data: { count } });
    } catch (err) {
      next(err);
    }
  }

  async markAsRead(req, res, next) {
    try {
      const { ids } = req.body;
      await notificationRepo.markAsRead(req.user.id, ids);
      const unreadCount = await notificationRepo.getUnreadCount(req.user.id);
      res.json({ success: true, data: { unreadCount } });
    } catch (err) {
      next(err);
    }
  }

  async getVapidPublicKey(req, res, next) {
    try {
      res.json({ success: true, data: { publicKey: pushNotifier.getPublicKey() } });
    } catch (err) {
      next(err);
    }
  }

  async subscribe(req, res, next) {
    try {
      const { subscription } = req.body;
      if (!subscription) {
        return res.status(400).json({ success: false, message: 'Subscription object required' });
      }
      await subscriptionRepo.upsert(req.user.id, subscription);
      res.json({ success: true, message: 'Subscribed successfully' });
    } catch (err) {
      next(err);
    }
  }

  async unsubscribe(req, res, next) {
    try {
      await subscriptionRepo.delete(req.user.id);
      res.json({ success: true, message: 'Unsubscribed successfully' });
    } catch (err) {
      next(err);
    }
  }
}

module.exports = new NotificationController();
