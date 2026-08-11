const { Client } = require('pg');
(async () => {
  const c = new Client({ host: 'localhost', user: 'postgres', password: 'Qasim@11', database: 'taskify' });
  await c.connect();
  const ids = [89, 90];
  await c.query(`DELETE FROM notifications WHERE ticket_id = ANY($1)`, [ids]);
  await c.query(`DELETE FROM event_outbox WHERE ticket_id = ANY($1)`, [ids]);
  await c.query(`DELETE FROM ticket_logs WHERE ticket_id = ANY($1)`, [ids]);
  await c.query(`DELETE FROM ticket_comments WHERE ticket_id = ANY($1)`, [ids]);
  await c.query(`DELETE FROM sub_ticket_departments WHERE ticket_id = ANY($1)`, [ids]);
  await c.query(`DELETE FROM tickets WHERE id = ANY($1)`, [ids]);
  const r = await c.query(`SELECT COUNT(*) AS cnt FROM tickets WHERE id = ANY($1)`, [ids]);
  console.log('Test tickets remaining:', r.rows[0].cnt);
  await c.end();
})().catch((e) => { console.error(e.message); process.exit(1); });
