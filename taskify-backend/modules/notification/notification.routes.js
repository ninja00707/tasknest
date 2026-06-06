const express = require('express');
const router = express.Router();
const { authenticate } = require('../ticket/Auth.middleware');
const controller = require('./notification.controller');

router.get('/', authenticate, controller.getAll);
router.get('/unread-count', authenticate, controller.getUnreadCount);
router.patch('/read', authenticate, controller.markAsRead);

module.exports = router;
