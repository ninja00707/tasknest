const { Server } = require('socket.io');
const jwt = require('jsonwebtoken');

function setupSocketIO(server, isWorker = false) {
  const io = new Server(server, {
    cors: {
      origin: '*',
      methods: ['GET', 'POST', 'PATCH', 'DELETE'],
    },
  });

  // ── Cluster adapter (cross-worker event propagation) ─────────────
  if (isWorker) {
    const { createAdapter } = require('@socket.io/cluster-adapter');
    io.adapter(createAdapter());
  }

  // ── Authentication middleware ──────────────────────────────────
  io.use((socket, next) => {
    const token = socket.handshake.auth?.token || socket.handshake.query?.token;
    if (!token) {
      return next(new Error('Authentication required'));
    }
    try {
      const decoded = jwt.verify(token, process.env.JWT_SECRET);
      socket.userId = decoded.id;
      next();
    } catch {
      return next(new Error('Invalid token'));
    }
  });

  // ── Connection handler ─────────────────────────────────────────
  io.on('connection', (socket) => {
    const userId = socket.userId;

    // Join user-specific room
    socket.join(`user_${userId}`);

    // Join department room if available
    if (socket.handshake.auth?.departmentId) {
      socket.join(`dept_${socket.handshake.auth.departmentId}`);
    }

    socket.on('disconnect', () => {
      // cleanup if needed
    });
  });

  global.io = io;
  return io;
}

module.exports = { setupSocketIO };
