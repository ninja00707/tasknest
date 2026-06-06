const notificationRepo = require('./notification.repository');

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
}

module.exports = new NotificationController();
