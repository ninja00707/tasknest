// ── Standalone Background Worker ──────────────────────────────────────────
// Runs as a separate process (PM2 fork mode) to handle queued jobs.
// Starts queue consumers without an HTTP server.

require('../core/env');
const queueManager = require('../core/queue');
const notificationWorker = require('./notificationWorker');

if (require.main === module) {
  (async () => {
    console.log(`[Worker] PID ${process.pid} starting...`);

    await queueManager.init();

    await notificationWorker.init(null);

    console.log(`[Worker] PID ${process.pid} ready, waiting for jobs...`);

    process.on('SIGTERM', async () => {
      console.log('[Worker] Shutting down...');
      await queueManager.closeAll();
      process.exit(0);
    });

    process.on('SIGINT', async () => {
      console.log('[Worker] Shutting down...');
      await queueManager.closeAll();
      process.exit(0);
    });
  })();
}
