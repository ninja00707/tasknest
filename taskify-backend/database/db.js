const { Pool } = require('pg');
require('dotenv').config();

const poolConfig = process.env.DATABASE_URL
  ? {
      connectionString: process.env.DATABASE_URL,
      ssl: { rejectUnauthorized: false },
    }
  : {
      user: process.env.DB_USER,
      host: process.env.DB_HOST,
      database: process.env.DB_NAME,
      password: process.env.DB_PASSWORD,
      port: process.env.DB_PORT,
    };

const pool = new Pool({
  ...poolConfig,
  max: parseInt(process.env.DB_POOL_MAX) || 50,
  idleTimeoutMillis: parseInt(process.env.DB_IDLE_TIMEOUT) || 30000,
  connectionTimeoutMillis: parseInt(process.env.DB_CONN_TIMEOUT) || 5000,
  allowExitOnIdle: true,
});

pool.on('connect', () => { /* connected */ });
pool.on('acquire', () => { /* acquired */ });
pool.on('remove', () => { /* removed */ });
pool.on('error', (err) => console.error('❌ PostgreSQL error:', err));

module.exports = pool;
