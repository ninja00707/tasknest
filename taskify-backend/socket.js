const { Server } = require('socket.io');
const jwt = require('jsonwebtoken');
const socketHelper = require('./core/socketHelper');
const outboxProcessor = require('./core/outboxProcessor');

const IDLE_TIMEOUT_MS = 30 * 60 * 1000;

async function setupSocketIO(server, isWorker = false) {
  const io = new Server(server, {
    cors: {
      origin: '*',
      methods: ['GET', 'POST', 'PATCH', 'DELETE'],
    },
    pingInterval: 25000,
    pingTimeout: 20000,
  });

  // ── Redis Adapter (cross-process socket.io) ─────────────────────────
  if (process.env.REDIS_URL || (process.env.REDIS_HOST && process.env.REDIS_PORT)) {
    const Redis = require('ioredis');
    const test = new Redis({
      host: process.env.REDIS_HOST || 'localhost',
      port: parseInt(process.env.REDIS_PORT) || 6379,
      retryStrategy: () => null,
      lazyConnect: true,
      enableReadyCheck: false,
    });
    test.on('error', () => {});
    const available = await test.connect().then(() => { test.quit(); return true; }).catch(() => false);
    if (available) {
      try {
        const { createAdapter } = require('@socket.io/redis-adapter');
        const pub = new Redis({ host: process.env.REDIS_HOST || 'localhost', port: parseInt(process.env.REDIS_PORT) || 6379, retryStrategy: () => null, enableReadyCheck: false });
        const sub = new Redis({ host: process.env.REDIS_HOST || 'localhost', port: parseInt(process.env.REDIS_PORT) || 6379, retryStrategy: () => null, enableReadyCheck: false });
        pub.on('error', () => {});
        sub.on('error', () => {});
        io.adapter(createAdapter(pub, sub));
        console.log('[Socket] Redis adapter enabled');
      } catch (err) {
        console.warn('[Socket] Redis adapter unavailable, using in-process:', err.message);
      }
    } else {
      console.log('[Socket] Redis not available, skipping adapter');
    }
  }

  if (isWorker) {
    const { createAdapter } = require('@socket.io/cluster-adapter');
    io.adapter(createAdapter());
  }

  io.use((socket, next) => {
    const token = socket.handshake.auth?.token || socket.handshake.query?.token;
    if (!token) return next(new Error('Authentication required'));
    try {
      const decoded = jwt.verify(token, process.env.JWT_SECRET);
      socket.userId = decoded.id;
      next();
    } catch {
      return next(new Error('Invalid token'));
    }
  });

  io.on('connection', (socket) => {
    const userId = socket.userId;
    console.log(`[Socket] User ${userId} connected`);

    socket.join(`user_${userId}`);

    if (socket.handshake.auth?.departmentId) {
      socket.join(`dept_${socket.handshake.auth.departmentId}`);
    }

    let idleTimer = null;
    function resetIdleTimer() {
      if (idleTimer) clearTimeout(idleTimer);
      idleTimer = setTimeout(() => {
        console.log(`[Socket] User ${userId} idle timeout, disconnecting`);
        socket.emit('IDLE_DISCONNECT', { reason: 'idle_timeout' });
        socket.disconnect(true);
      }, IDLE_TIMEOUT_MS);
    }
    resetIdleTimer();

    socket.onAny(() => resetIdleTimer());

    socket.on('disconnect', (reason) => {
      if (idleTimer) clearTimeout(idleTimer);
      console.log(`[Socket] User ${userId} disconnected: ${reason}`);
    });
  });

  socketHelper.init(io);

  // Start the outbox processor — picks up DB rows and emits enriched payloads
  outboxProcessor.start();

  return io;
}

module.exports = { setupSocketIO };
