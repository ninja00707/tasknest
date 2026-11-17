// Read-only schema preflight. Prints every expected table/column/sequence/index
// as OK or MISSING so you know which migrations still need to run.
//
// Run from taskify-backend/:  node database/check_schema.js
// Exit code: 0 = schema complete, 1 = missing objects, 2 = connection error.

const fs = require('fs');
const path = require('path');
const pool = require('./db');

(async () => {
  try {
    const sql = fs.readFileSync(path.join(__dirname, 'preflight_check.sql'), 'utf8');
    const { rows } = await pool.query(sql);
    const missing = rows.filter((r) => r.status === 'MISSING');

    for (const r of rows) {
      console.log(`${r.status.padEnd(8)} ${r.kind.padEnd(9)} ${r.object_name.padEnd(38)} ${r.needed_by}`);
    }

    console.log('');
    if (missing.length === 0) {
      console.log(`✓ Schema complete (${rows.length} objects checked).`);
    } else {
      const files = [...new Set(missing.map((r) => r.needed_by))];
      console.log(`✗ ${missing.length} missing object(s). Run these migrations, in order:`);
      files.forEach((f) => console.log(`   node database/run_migration.js database/${f}`));
      process.exitCode = 1;
    }
  } catch (err) {
    console.error('Schema check failed:', err.message);
    process.exitCode = 2;
  } finally {
    await pool.end();
  }
})();
