require('../core/env');
const { Pool } = require('pg');
const pool = new Pool();
(async () => {
  try {
    const r = await pool.query(`SELECT count(1)::int AS active FROM pg_stat_activity WHERE state = 'active'`);
    console.log('Active queries:', r.rows[0].active);
    const r2 = await pool.query(`SELECT count(1)::int AS total FROM pg_stat_activity`);
    console.log('Total connections:', r2.rows[0].total);
    const r3 = await pool.query(`SELECT pid, query, state, wait_event FROM pg_stat_activity WHERE state = 'active' AND query NOT LIKE '%pg_stat%' LIMIT 10`);
    console.log('Running queries:', JSON.stringify(r3.rows, null, 2));
  } catch(e) { console.error('DB error:', e.message); }
  await pool.end();
})();
