// Run: node database/clear_tickets.js
const pool = require('./db');

async function clearAll() {
    const client = await pool.connect();
    try {
        await client.query('BEGIN');

        await client.query('UPDATE tickets SET parent_ticket_id = NULL');
        await client.query('DELETE FROM ticket_logs');
        await client.query('DELETE FROM ticket_comments');
        await client.query('DELETE FROM sub_ticket_departments');
        await client.query('DELETE FROM notifications');
        await client.query('DELETE FROM tickets');

        // Reset sequences
        const seqs = ['tickets_id_seq', 'ticket_logs_id_seq', 'ticket_comments_id_seq',
            'sub_ticket_departments_id_seq', 'notifications_id_seq', 'ticket_number_seq'];
        for (const seq of seqs) {
            await client.query(`SELECT setval('${seq}', 1, false)`).catch(() => { });
        }

        await client.query('COMMIT');

        // Verify
        const r1 = await pool.query('SELECT COUNT(*) as cnt FROM tickets');
        const r2 = await pool.query('SELECT COUNT(*) as cnt FROM ticket_logs');
        const r3 = await pool.query('SELECT COUNT(*) as cnt FROM ticket_comments');
        const r4 = await pool.query('SELECT COUNT(*) as cnt FROM sub_ticket_departments');
        const r5 = await pool.query('SELECT COUNT(*) as cnt FROM notifications');
        console.log('✅ All ticket data cleared!');
        console.log('Tickets:', r1.rows[0].cnt, '| Logs:', r2.rows[0].cnt, '| Comments:', r3.rows[0].cnt,
            '| SubDepts:', r4.rows[0].cnt, '| Notifs:', r5.rows[0].cnt);
        process.exit(0);
    } catch (e) {
        await client.query('ROLLBACK');
        console.error('❌ Error:', e.message);
        process.exit(1);
    } finally {
        client.release();
    }
}

clearAll();

