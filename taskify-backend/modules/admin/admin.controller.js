const service = require('./admin.service');

const ok = (res, data, message) =>
  res.status(200).json({ success: true, data, message });

const created = (res, data, message) =>
  res.status(201).json({ success: true, data, message });

const handler = (fn) => async (req, res) => {
  try { await fn(req, res); } catch (err) {
    console.error('Admin Error:', err);
    res.status(err.statusCode || 500).json({
      success: false,
      message: err.message || 'Internal server error',
      error: process.env.NODE_ENV === 'development' ? err.toString() : undefined,
    });
  }
};

exports.getStats = handler(async (req, res) => {
  const stats = await service.getStats();
  ok(res, stats);
});

// ── Users ───────────────────────────────────────────────────────────────
exports.listUsers = handler(async (req, res) => {
  const users = await service.listUsers();
  ok(res, users);
});

exports.listPendingUsers = handler(async (req, res) => {
  const users = await service.listPendingUsers();
  ok(res, users);
});

exports.getUser = handler(async (req, res) => {
  const user = await service.getUser(parseInt(req.params.id));
  ok(res, user);
});

exports.createUser = handler(async (req, res) => {
  const user = await service.createUser(req.body);
  created(res, user, 'User created successfully');
});

exports.updateUser = handler(async (req, res) => {
  const user = await service.updateUser(parseInt(req.params.id), req.body);
  ok(res, user, 'User updated successfully');
});

exports.approveUser = handler(async (req, res) => {
  const user = await service.approveUser(parseInt(req.params.id));
  ok(res, user, 'User approved successfully');
});

exports.deleteUser = handler(async (req, res) => {
  await service.deleteUser(parseInt(req.params.id));
  ok(res, null, 'User deactivated successfully');
});

// ── Departments ─────────────────────────────────────────────────────────
exports.listDepartments = handler(async (req, res) => {
  const departments = await service.listDepartments();
  ok(res, departments);
});

exports.getDepartment = handler(async (req, res) => {
  const dept = await service.getDepartment(parseInt(req.params.id));
  ok(res, dept);
});

exports.createDepartment = handler(async (req, res) => {
  const dept = await service.createDepartment(req.body);
  created(res, dept, 'Department created successfully');
});

exports.updateDepartment = handler(async (req, res) => {
  const dept = await service.updateDepartment(parseInt(req.params.id), req.body);
  ok(res, dept, 'Department updated successfully');
});

exports.deleteDepartment = handler(async (req, res) => {
  await service.deleteDepartment(parseInt(req.params.id));
  ok(res, null, 'Department deleted successfully');
});

// ── Tickets ─────────────────────────────────────────────────────────────
exports.listTickets = handler(async (req, res) => {
  const result = await service.listTickets(req.query);
  res.status(200).json({
    success: true,
    data: result.tickets,
    pagination: { total: result.total, page: result.page, totalPages: result.totalPages },
  });
});

exports.getTicket = handler(async (req, res) => {
  const ticket = await service.getTicket(parseInt(req.params.id));
  ok(res, ticket);
});

exports.updateTicket = handler(async (req, res) => {
  const ticket = await service.updateTicket(parseInt(req.params.id), req.body);
  ok(res, ticket, 'Ticket updated successfully');
});

exports.deleteTicket = handler(async (req, res) => {
  await service.deleteTicket(parseInt(req.params.id));
  ok(res, null, 'Ticket deleted successfully');
});
