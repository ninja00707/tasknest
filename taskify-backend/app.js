const express = require('express');
const cors = require('cors');
const compression = require('compression');
const rateLimit = require('express-rate-limit');
require('dotenv').config();

const authRoutes = require('./modules/auth/auth.routes');
const ticketRoutes = require('./modules/ticket/ticket.routes');
const notificationRoutes = require('./modules/notification/notification.routes');

const app = express();

// ── Compression ──────────────────────────────────────────────────────────
app.use(compression());

// ── Rate Limiting ────────────────────────────────────────────────────────
const limiter = rateLimit({
  windowMs: 1 * 60 * 1000, // 1 minute
  max: parseInt(process.env.RATE_LIMIT_MAX) || 300, // 300 requests/min per IP
  standardHeaders: true,
  legacyHeaders: false,
  message: { success: false, message: 'Too many requests, please try again later.' },
});
app.use('/api/', limiter);

// Login/register can be more restrictive
const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 20, // 20 attempts per 15 min
  message: { success: false, message: 'Too many auth attempts, please try again later.' },
});
app.use('/api/auth/login', authLimiter);
app.use('/api/auth/register', authLimiter);

// ── Body Parsing & CORS ──────────────────────────────────────────────────
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// ── Routes ───────────────────────────────────────────────────────────────
app.use('/api/auth', authRoutes);
app.use('/api/tickets', ticketRoutes);
app.use('/api/notifications', notificationRoutes);

// ── 404 Handler ──────────────────────────────────────────────────────────
app.use((req, res, next) => {
  res.status(404).json({
    success: false,
    message: `Route ${req.originalUrl} not found`
  });
});

// ── Global Error Handler ─────────────────────────────────────────────────
app.use((err, req, res, next) => {
  console.error('Global Error Handler:', err);
  const statusCode = err.statusCode || 500;
  res.status(statusCode).json({
    success: false,
    message: err.message || 'An unexpected internal server error occurred',
    error: process.env.NODE_ENV === 'development' ? err.toString() : undefined
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
