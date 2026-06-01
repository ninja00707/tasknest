const pool = require('./db');

async function run() {
  try {
    console.log("Starting migration: Adding parent_id to tickets table...");
    await pool.query(`
      ALTER TABLE tickets 
      ADD COLUMN IF NOT EXISTS parent_id INT REFERENCES tickets(id) ON DELETE CASCADE;
    `);
    console.log("✅ Database schema migrated successfully!");
  } catch (err) {
    console.error("❌ Database schema migration failed:", err);
  } finally {
    await pool.end();
  }
}

run();
