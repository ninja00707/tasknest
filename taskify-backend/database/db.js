const { Pool } = require('pg');
require('dotenv').config();

const pool = new Pool({
  user: process.env.DB_USER,
  host: process.env.DB_HOST,
  database: process.env.DB_NAME,
  password: process.env.DB_PASSWORD,
  port: process.env.DB_PORT,

  // ── Connection Pool Tuning for 700+ concurrent users ────────────
  max: parseInt(process.env.DB_POOL_MAX) || 50,          // Max concurrent connections
  idleTimeoutMillis: parseInt(process.env.DB_IDLE_TIMEOUT) || 30000, // 30s idle timeout
  connectionTimeoutMillis: parseInt(process.env.DB_CONN_TIMEOUT) || 5000, // 5s connection timeout
  allowExitOnIdle: true,                                  // Allow pool to exit when idle
});

pool.on('connect', () => { /* connected */ });
pool.on('acquire', () => { /* acquired */ });
pool.on('remove', () => { /* removed */ });
pool.on('error', (err) => console.error('❌ PostgreSQL error:', err));

module.exports = pool;
