const fs = require('fs');
const path = require('path');
const pool = require('./db');

async function runMigration() {
  try {
    const sqlPath = path.join(__dirname, 'migration_standard_tickets.sql');
    const sql = fs.readFileSync(sqlPath, 'utf8');
    console.log('Running standard_tickets migration...');
    await pool.query(sql);
    console.log('Standard tickets migration completed!');
  } catch (error) {
    console.error('Migration error:', error);
  } finally {
    pool.end();
  }
}

runMigration();
