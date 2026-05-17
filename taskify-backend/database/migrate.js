const fs = require('fs');
const path = require('path');
const pool = require('./db');

async function runMigration() {
  try {
    const schemaPath = path.join(__dirname, 'schema.sql');
    const schemaSql = fs.readFileSync(schemaPath, 'utf8');

    console.log('Running database migration...');
    await pool.query(schemaSql);
    console.log('Migration completed successfully!');
  } catch (error) {
    console.error('Error running migration:', error);
  } finally {
    pool.end();
  }
}

runMigration();
