const { Server } = require('socket.io');
const jwt = require('jsonwebtoken');

let io = null;

// ── Track connected users: userId → Set<socketId> ───────────────────────
const connectedUsers = new Map();

function setupSocket(server) {
  io = new Server(server, {
    cors: { origin: '*', methods: ['GET', 'POST'] },
    path: '/socket.io',
    pingInterval: 25000,
    pingTimeout: 20000,
  });

  // ── Redis adapter (for multi-instance scaling) ────────────────────────
  _attachRedisAdapter(io);

  // ── Auth middleware ─────────────────────────────────────────────────
  io.use((socket, next) => {
    const token = socket.handshake.auth?.token || socket.handshake.query?.token;
    if (!token) return next(new Error('Authentication required'));
    try {
      const decoded = jwt.verify(token, process.env.JWT_SECRET);
      socket.user = decoded;
      next();
    } catch {
      next(new Error('Invalid token'));
    }
  });

  io.on('connection', (socket) => {
    const userId = socket.user.id;

    // Track this socket
    if (!connectedUsers.has(userId)) connectedUsers.set(userId, new Set());
    connectedUsers.get(userId).add(socket.id);

    // Auto-join dashboard room
    socket.join('dashboard');

    // ── Join/leave ticket detail rooms ──────────────────────────────
    socket.on('ticket:join_details', (ticketId) => {
      socket.join(`ticket:${ticketId}`);
    });

    socket.on('ticket:leave_details', (ticketId) => {
      socket.leave(`ticket:${ticketId}`);
    });

    // ── ticket:action — multiplexed client action handler ───────────
    // NOTE: broadcast() calls have been removed from here.
    // All realtime emission now goes through the event outbox processor,
    // which runs after the service-layer transaction commits.
    socket.on('ticket:action', async (data, ack) => {
      const ticketService = require('../modules/ticket/ticket.service');
      try {
        const { action, ticketId, ...params } = data;
        let result;

        const user = {
          id: socket.user.id,
          name: socket.user.name,
          role: socket.user.role,
          department_id: socket.user.department_id,
          company_id: socket.user.company_id,
        };

        switch (action) {
          case 'self_assign':
            result = await ticketService.selfAssign(ticketId, user);
            break;

          case 'assign_employee':
            result = await ticketService.assignToEmployee(ticketId, params.employeeId, user);
            break;

          case 'update_status':
            result = await ticketService.updateStatus(
              ticketId, params.status, user, params.remark,
            );
            break;

          case 'transfer':
            result = await ticketService.transferTicket(
              ticketId, params.targetDeptId, user, params.title, params.description,
            );
            break;

          case 'reopen':
            result = await ticketService.reopenTicket(ticketId, user);
            break;

          case 'add_comment':
            result = await ticketService.addComment(ticketId, params.message, user);
            break;

          case 'update_sub_dept_progress':
            result = await ticketService.updateSubDeptProgress(
              ticketId, params.departmentId, { status: params.status, note: params.note }, user,
            );
            break;

          case 'self_assign_sub_dept':
            result = await ticketService.selfAssignSubDept(ticketId, params.departmentId, user);
            break;

          case 'assign_sub_dept_employee':
            result = await ticketService.assignSubDeptToEmployee(
              ticketId, params.departmentId, params.employeeId, user,
            );
            break;

          case 'complete_sub_ticket':
            result = await ticketService.completeSubTicket(ticketId, user);
            break;

          case 'reopen_sub_dept':
            result = await ticketService.reopenSubDept(ticketId, params.departmentId, user);
            break;

          case 'update_ticket':
            result = await ticketService.updateTicket(ticketId, user, params.fields);
            break;

          default:
            if (ack) ack({ success: false, message: `Unknown action: ${action}` });
            return;
        }

        // No broadcast() here — the outbox processor handles emission
        if (ack) ack({ success: true, ticket: result });
      } catch (err) {
        const message = err.message || 'Action failed';
        if (ack) ack({ success: false, message });
      }
    });

    socket.on('disconnect', () => {
      const sockets = connectedUsers.get(userId);
      if (sockets) {
        sockets.delete(socket.id);
        if (sockets.size === 0) connectedUsers.delete(userId);
      }
    });
  });

  return io;
}

// ── Redis adapter for multi-instance scaling ──────────────────────────────
async function _attachRedisAdapter(ioServer) {
  if (!process.env.REDIS_URL && !(process.env.REDIS_HOST && process.env.REDIS_PORT)) {
    console.log('[Socket] Redis adapter skipped (no REDIS_URL / REDIS_HOST+PORT)');
    return;
  }
  try {
    const { createAdapter } = require('@socket.io/redis-adapter');
    const { createClient } = require('redis');

    const pubClient = createClient({
      url: process.env.REDIS_URL || `redis://${process.env.REDIS_HOST}:${process.env.REDIS_PORT}`,
    });
    const subClient = pubClient.duplicate();

    await Promise.all([pubClient.connect(), subClient.connect()]);
    ioServer.adapter(createAdapter(pubClient, subClient));
    console.log('[Socket] Redis adapter attached');
  } catch (err) {
    console.warn('[Socket] Redis adapter failed, falling back to in-memory:', err.message);
  }
}

// ── Broadcast helpers ────────────────────────────────────────────────────

/**
 * Broadcast a ticket event to all relevant rooms.
 *
 * @param {string} eventName       - Socket event name (ticket:created | ticket:updated)
 * @param {object} data            - Either a ticket object (legacy) or a full enriched payload
 *                                    { ticket, ticketId, type, version, updatedAt, ... }
 * @param {number} ticketId        - Ticket ID (used for room routing)
 * @param {number} excludeUserId   - Actor's user ID (excluded from detail rooms)
 */
function broadcast(eventName, data, ticketId, excludeUserId) {
  if (!io) return;

  // Build the payload — support both legacy (ticket object) and new (enriched) formats
  let payload;
  if (data && data.ticket !== undefined && data.ticketId !== undefined) {
    // New enriched format from outbox processor: { ticket, ticketId, type, version, ... }
    payload = data;
  } else {
    // Legacy format: data IS the ticket object
    payload = { ticket: data, ticketId: data.id || ticketId };
  }

  const resolvedTicketId = payload.ticketId || ticketId;
  const parentTicketId = payload.parentTicketId || payload.ticket?.parent_ticket_id || null;

  // Get the acting user's socket IDs to exclude from detail rooms
  const excludeSockets = excludeUserId
    ? connectedUsers.get(excludeUserId) || new Set()
    : new Set();

  // Emit to dashboard room — EVERYONE including acting user
  emitToRoom('dashboard', eventName, payload);

  // Emit to specific ticket room (skip acting user — they get ack from REST)
  if (resolvedTicketId) {
    emitExcept(`ticket:${resolvedTicketId}`, eventName, payload, excludeSockets);
  }

  // If this is a sub-ticket, also emit to the parent ticket room
  if (parentTicketId) {
    emitExcept(`ticket:${parentTicketId}`, eventName, payload, excludeSockets);
  }
}

function emitToRoom(room, event, data) {
  if (!io) return;
  io.to(room).emit(event, data);
}

function emitExcept(room, event, data, excludeSockets) {
  if (!io) return;
  const roomSockets = io.sockets.adapter.rooms.get(room);
  if (!roomSockets) return;

  for (const socketId of roomSockets) {
    if (!excludeSockets.has(socketId)) {
      io.to(socketId).emit(event, data);
    }
  }
}

function broadcastNotification(userId, notification) {
  if (!io) return;
  const sockets = connectedUsers.get(userId);
  if (!sockets) return;
  for (const socketId of sockets) {
    io.to(socketId).emit('notification:new', notification);
  }
}

function getIO() { return io; }
function getConnectedUsers() { return connectedUsers; }

module.exports = {
  setupSocket,
  getIO,
  getConnectedUsers,
  broadcast,
  broadcastNotification,
};
