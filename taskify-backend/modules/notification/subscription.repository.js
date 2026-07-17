const pool = require('../../database/db');

class SubscriptionRepository {
  constructor() {
    this.initTable();
  }

  async initTable() {
    try {
      await pool.query(`
        CREATE TABLE IF NOT EXISTS user_push_subscriptions (
          user_id INT PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
          subscription JSONB NOT NULL,
          created_at TIMESTAMPTZ DEFAULT NOW()
        );
      `);
    } catch (err) {
      console.error('[SubscriptionRepository] Failed to create user_push_subscriptions table:', err.message);
    }
  }

  async getByUserId(userId) {
    const result = await pool.query(
      'SELECT subscription FROM user_push_subscriptions WHERE user_id = $1',
      [userId]
    );
    return result.rows[0]?.subscription || null;
  }

  async upsert(userId, subscription) {
    await pool.query(`
      INSERT INTO user_push_subscriptions (user_id, subscription, created_at)
      VALUES ($1, $2, NOW())
      ON CONFLICT (user_id) DO UPDATE
      SET subscription = EXCLUDED.subscription, created_at = NOW()
    `, [userId, JSON.stringify(subscription)]);
  }

  async delete(userId) {
    await pool.query('DELETE FROM user_push_subscriptions WHERE user_id = $1', [userId]);
  }
}

module.exports = new SubscriptionRepository();
