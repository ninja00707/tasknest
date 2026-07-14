const express = require('express');
const cors = require('cors');
const compression = require('compression');
const rateLimit = require('express-rate-limit');
const cache = require('./core/cache');
const queueManager = require('./core/queue');

require('dotenv').config();

const authRoutes = require('./modules/auth/auth.routes');
const ticketRoutes = require('./modules/ticket/ticket.routes');
const notificationRoutes = require('./modules/notification/notification.routes');
const adminRoutes = require('./modules/admin/admin.routes');

const app = express();

// ── Initialize infrastructure (non-blocking) ────────────────────────────────
cache.init().catch(err => console.warn('[App] Cache init warning:', err.message));
queueManager.init().catch(err => console.warn('[App] Queue init warning:', err.message));

// ── Compression ──────────────────────────────────────────────────────────
app.use(compression({ threshold: 512, level: 6 }));

// ── Rate Limiting ────────────────────────────────────────────────────────
const limiter = rateLimit({
  windowMs: 1 * 60 * 1000,
  max: parseInt(process.env.RATE_LIMIT_MAX) || 300,
  standardHeaders: true,
  legacyHeaders: false,
  message: { success: false, message: 'Too many requests, please try again later.' },
});
app.use('/api/', limiter);

const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 20,
  message: { success: false, message: 'Too many auth attempts, please try again later.' },
});
app.use('/api/auth/login', authLimiter);
app.use('/api/auth/register', authLimiter);

// ── Body Parsing & CORS ──────────────────────────────────────────────────
app.use(cors());
app.use(express.json({ limit: '1mb' }));
app.use(express.urlencoded({ extended: true, limit: '1mb' }));

// ── Health check ─────────────────────────────────────────────────────────
app.get('/health', (req, res) => res.json({ status: 'ok', pid: process.pid }));
app.get('/api/health', (req, res) => res.json({ status: 'ok', pid: process.pid }));

// ── Cache-backed endpoints (example: cached stats) ───────────────────────
app.get('/api/cache/stats', async (req, res) => {
  const stats = await cache.remember('app:cache_stats', parseInt(process.env.CACHE_STATS_TTL) || 120, async () => ({
    uptime: process.uptime(),
    pid: process.pid,
    memory: process.memoryUsage(),
    timestamp: new Date().toISOString(),
  }));
  res.json({ success: true, data: stats });
});

// ── Routes ───────────────────────────────────────────────────────────────
app.use('/api/auth', authRoutes);
app.use('/api/tickets', ticketRoutes);
app.use('/api/notifications', notificationRoutes);
app.use('/api/admin', adminRoutes);

// ── 404 Handler ──────────────────────────────────────────────────────────
app.use((req, res, next) => {
  res.status(404).json({ success: false, message: `Route ${req.originalUrl} not found` });
});

// ── Global Error Handler ─────────────────────────────────────────────────
app.use((err, req, res, next) => {
  console.error('Global Error Handler:', err);
  const statusCode = err.statusCode || 500;
  res.status(statusCode).json({
    success: false,
    message: err.message || 'An unexpected internal server error occurred',
    error: process.env.NODE_ENV === 'development' ? err.toString() : undefined,
  });
});

// ── Auto-start when run directly (node app.js) ────────────────────────
if (require.main === module) {
  const cluster = require('cluster');
  const os = require('os');
  const { startServer } = require('./server');

  const isPrimary = cluster.isPrimary !== undefined ? cluster.isPrimary : cluster.isMaster;
  const useCluster = process.argv.includes('--cluster');

  if (useCluster && isPrimary) {
    const { setupPrimary } = require('@socket.io/cluster-adapter');
    setupPrimary();

    const numWorkers = parseInt(process.env.WORKERS) || os.cpus().length;
    console.log(`🚀 Cluster mode: ${numWorkers} workers`);
    for (let i = 0; i < numWorkers; i++) cluster.fork();

    cluster.on('exit', () => { cluster.fork(); });

    process.on('SIGTERM', () => { for (const id in cluster.workers) cluster.workers[id].kill(); process.exit(0); });
    process.on('SIGINT', () => { for (const id in cluster.workers) cluster.workers[id].kill(); process.exit(0); });
  } else if (useCluster) {
    process.env.CLUSTER_WORKER = 'true';
    startServer(app);
  } else {
    startServer(app);
  }
}

module.exports = app;
