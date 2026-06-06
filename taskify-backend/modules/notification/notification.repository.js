const pool = require('../../database/db');

class NotificationRepository {
  async findByUser(userId, limit = 50) {
    const result = await pool.query(`
      SELECT n.id, n.user_id, n.ticket_id, n.message, n.is_read, n.created_at,
             t.ticket_number
      FROM notifications n
      LEFT JOIN tickets t ON t.id = n.ticket_id
      WHERE n.user_id = $1
      ORDER BY n.created_at DESC
      LIMIT $2
    `, [userId, limit]);
    return result.rows;
  }

  async getUnreadCount(userId) {
    const result = await pool.query(`
      SELECT COUNT(*) AS count FROM notifications
      WHERE user_id = $1 AND is_read = FALSE
    `, [userId]);
    return parseInt(result.rows[0].count, 10);
  }

  async markAsRead(userId, ids) {
    if (ids && ids.length > 0) {
      const placeholders = ids.map((_, i) => `$${i + 2}`).join(',');
      await pool.query(`
        UPDATE notifications SET is_read = TRUE
        WHERE user_id = $1 AND id IN (${placeholders})
      `, [userId, ...ids]);
    } else {
      await pool.query(`
        UPDATE notifications SET is_read = TRUE
        WHERE user_id = $1
      `, [userId]);
    }
  }
}

module.exports = new NotificationRepository();
