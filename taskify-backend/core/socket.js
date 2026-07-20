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
    socket.on('ticket:action', async (data, ack) => {
      const ticketService = require('../modules/ticket/ticket.service');
      try {
        const { action, ticketId, ...params } = data;
        let result;
        let eventName = 'ticket:updated';

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
            eventName = 'ticket:created';
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

        // Broadcast the result to all relevant rooms (skip the acting user — they get the ack)
        if (result) {
          broadcast(eventName, result, ticketId, userId);
        }

        if (ack) ack({ success: true, ticket: result });
      } catch (err) {
        const message = err.message || err.message || 'Action failed';
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

// ── Broadcast helpers ────────────────────────────────────────────────────

function broadcast(eventName, ticket, ticketId, excludeUserId) {
  if (!io) return;

  const payload = { ticket, ticketId: ticket.id || ticketId };

  // Get the acting user's socket IDs to exclude from detail rooms
  const excludeSockets = excludeUserId
    ? connectedUsers.get(excludeUserId) || new Set()
    : new Set();

  // Emit to dashboard room — EVERYONE including acting user
  // (acting user's DashboardBloc needs the update from socket,
  //  since REST response only updates TicketBloc)
  emitToRoom('dashboard', eventName, payload);

  // Emit to specific ticket room (skip acting user — they get ack from REST)
  if (ticketId) {
    emitExcept(`ticket:${ticketId}`, eventName, payload, excludeSockets);
  }

  // If this is a sub-ticket, also emit to the parent ticket room
  if (ticket.parent_ticket_id) {
    emitExcept(`ticket:${ticket.parent_ticket_id}`, eventName, payload, excludeSockets);
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
