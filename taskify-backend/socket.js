const { Server } = require('socket.io');
const jwt = require('jsonwebtoken');
const socketHelper = require('./core/socketHelper');

const IDLE_TIMEOUT_MS = 30 * 60 * 1000;

function setupSocketIO(server, isWorker = false) {
  const io = new Server(server, {
    cors: {
      origin: '*',
      methods: ['GET', 'POST', 'PATCH', 'DELETE'],
    },
    pingInterval: 25000,
    pingTimeout: 20000,
  });

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

  return io;
}

module.exports = { setupSocketIO };
