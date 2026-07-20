#!/usr/bin/env node

const cluster = require('cluster');
const os = require('os');
require('dotenv').config();

const isPrimary = cluster.isPrimary !== undefined ? cluster.isPrimary : cluster.isMaster;

if (isPrimary) {
  // ── Master / Primary Process ──────────────────────────────────────

  const numWorkers = parseInt(process.env.WORKERS) || os.cpus().length;

  console.log('═══════════════════════════════════════════════');
  console.log(`  TaskNest Server (Cluster Mode)`);
  console.log(`  Master PID: ${process.pid}`);
  console.log(`  Workers:    ${numWorkers}`);
  console.log(`  Port:       ${process.env.PORT || 5050}`);
  console.log('═══════════════════════════════════════════════');
  console.log('');

  for (let i = 0; i < numWorkers; i++) {
    cluster.fork();
  }

  cluster.on('exit', (worker, code, signal) => {
    console.log(`[Master] Worker ${worker.process.pid} exited (code=${code}, signal=${signal}). Restarting...`);
    cluster.fork();
  });

  cluster.on('online', (worker) => {
    console.log(`[Master] Worker ${worker.process.pid} is online`);
  });

  // ── Graceful Shutdown ─────────────────────────────────────────────
  const shutdown = () => {
    console.log('\n[Master] Shutting down...');
    for (const id in cluster.workers) {
      cluster.workers[id].kill('SIGTERM');
    }
    process.exit(0);
  };

  process.on('SIGTERM', shutdown);
  process.on('SIGINT', shutdown);
  process.on('SIGHUP', shutdown);

} else {
  // ── Worker Process ────────────────────────────────────────────────
  process.env.CLUSTER_WORKER = 'true';
  require('./bin/www');
}
