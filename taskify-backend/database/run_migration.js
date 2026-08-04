const fs = require('fs');
const path = require('path');
const pool = require('./db');

(async () => {
  const file = process.argv[2];
  if (!file) {
    console.error('Usage: node database/run_migration.js database/<migration_file>.sql');
    process.exit(1);
  }
  const sql = fs.readFileSync(path.resolve(file), 'utf8');
  console.log(`Running migration: ${file}`);
  try {
    await pool.query(sql);
    console.log('Migration applied successfully.');
  } catch (err) {
    console.error('Migration FAILED:', err.message);
    process.exitCode = 1;
  } finally {
    await pool.end();
  }
})();
