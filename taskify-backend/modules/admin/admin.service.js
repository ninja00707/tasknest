const repo = require('./admin.repository');
const bcrypt = require('bcrypt');
const pool = require('../../database/db');

exports.getStats = async () => {
  return repo.getStats();
};

exports.listUsers = async () => {
  return repo.findAllUsers();
};

exports.listPendingUsers = async () => {
  return repo.findPendingUsers();
};

exports.approveUser = async (id) => {
  const user = await repo.findUserById(id);
  if (!user) { const e = new Error('User not found'); e.statusCode = 404; throw e; }
  if (user.is_active) { const e = new Error('User is already active'); e.statusCode = 400; throw e; }
  return repo.updateUser(id, { is_active: true });
};

exports.getUser = async (id) => {
  const user = await repo.findUserById(id);
  if (!user) { const e = new Error('User not found'); e.statusCode = 404; throw e; }
  return user;
};

exports.createUser = async (body) => {
  const { name, email, code, designation, password, roleId, departmentId, companyId, reportsTo, seeAllCompanies } = body;
  if (!name || !email || !password) {
    const e = new Error('Name, email and password are required');
    e.statusCode = 400; throw e;
  }
  const existing = await repo.findUserByEmail(email);
  if (existing) { const e = new Error('Email already in use'); e.statusCode = 409; throw e; }
  if (code) {
    const existingCode = await pool.query('SELECT id FROM users WHERE code = $1', [code]);
    if (existingCode.rows.length) { const e = new Error('Code already in use'); e.statusCode = 409; throw e; }
  }
  const hash = await bcrypt.hash(password, 10);
  return repo.createUser({ name, email, code, designation, passwordHash: hash, roleId, departmentId, companyId, reportsTo, seeAllCompanies });
};

exports.updateUser = async (id, body) => {
  const user = await repo.findUserById(id);
  if (!user) { const e = new Error('User not found'); e.statusCode = 404; throw e; }
  const { name, email, roleId, departmentId, companyId, isActive, designation, reportsTo, seeAllCompanies } = body;
  const updates = {};
  if (name !== undefined) updates.name = name;
  if (email !== undefined) updates.email = email;
  if (roleId !== undefined) updates.role_id = roleId;
  if (departmentId !== undefined) updates.department_id = departmentId;
  if (companyId !== undefined) updates.company_id = companyId;
  if (isActive !== undefined) updates.is_active = isActive;
  if (designation !== undefined) updates.designation = designation;
  if (reportsTo !== undefined) updates.reports_to = reportsTo;
  if (seeAllCompanies !== undefined) updates.see_all_companies = seeAllCompanies;
  if (body.mustResetPassword !== undefined) updates.must_reset_password = body.mustResetPassword;
  if (body.password) {
    updates.password_hash = await bcrypt.hash(body.password, 10);
  }
  if (Object.keys(updates).length === 0) return user;
  return repo.updateUser(id, updates);
};

exports.deleteUser = async (id) => {
  const user = await repo.findUserById(id);
  if (!user) { const e = new Error('User not found'); e.statusCode = 404; throw e; }
  await repo.deleteUser(id);
};

exports.listDepartments = async () => {
  return repo.findAllDepartments();
};

exports.getDepartment = async (id) => {
  const dept = await repo.findDepartmentById(id);
  if (!dept) { const e = new Error('Department not found'); e.statusCode = 404; throw e; }
  return dept;
};

exports.createDepartment = async (body) => {
  const { name, code, companyId, tier, parentId, isShared } = body;
  if (!name || !code || companyId === undefined) {
    const e = new Error('Name, code and companyId are required');
    e.statusCode = 400; throw e;
  }
  if (parentId != null) {
    const parent = await repo.findDepartmentById(parentId);
    if (!parent) {
      const e = new Error(`Parent department with ID ${parentId} does not exist`);
      e.statusCode = 400; throw e;
    }
  }
  return repo.createDepartment({ name, code, companyId, tier, parentId, isShared });
};

exports.updateDepartment = async (id, body) => {
  const dept = await repo.findDepartmentById(id);
  if (!dept) { const e = new Error('Department not found'); e.statusCode = 404; throw e; }
  const updates = {};
  if (body.name !== undefined) updates.name = body.name;
  if (body.code !== undefined) updates.code = body.code;
  if (body.companyId !== undefined) updates.company_id = body.companyId;
  if (body.tier !== undefined) updates.tier = body.tier;
  if (body.parentId !== undefined) updates.parent_id = body.parentId;
  if (body.isShared !== undefined) updates.is_shared = body.isShared;
  if (Object.keys(updates).length === 0) return dept;
  return repo.updateDepartment(id, updates);
};

exports.deleteDepartment = async (id) => {
  const dept = await repo.findDepartmentById(id);
  if (!dept) { const e = new Error('Department not found'); e.statusCode = 404; throw e; }
  await repo.deleteDepartment(id);
};

exports.listTickets = async (query) => {
  return repo.findAllTickets(query);
};

exports.getTicket = async (id) => {
  const ticket = await repo.findTicketById(id);
  if (!ticket) { const e = new Error('Ticket not found'); e.statusCode = 404; throw e; }
  return ticket;
};

exports.getSubTickets = async (parentId) => {
  const parent = await repo.findTicketById(parentId);
  if (!parent) { const e = new Error('Ticket not found'); e.statusCode = 404; throw e; }
  return repo.findSubTickets(parentId);
};

exports.updateTicket = async (id, body) => {
  const ticket = await repo.findTicketById(id);
  if (!ticket) { const e = new Error('Ticket not found'); e.statusCode = 404; throw e; }
  const allowed = ['title', 'description', 'status', 'priority', 'assigned_to_id', 'assigned_dept_id', 'due_date'];
  const updates = {};
  for (const key of allowed) {
    if (body[key] !== undefined) updates[key] = body[key];
  }
  if (Object.keys(updates).length === 0) return ticket;
  return repo.updateTicket(id, updates);
};

exports.getUserActivity = async () => {
  return repo.findUserActivity();
};

exports.deleteTicket = async (id) => {
  const ticket = await repo.findTicketById(id);
  if (!ticket) { const e = new Error('Ticket not found'); e.statusCode = 404; throw e; }
  await repo.deleteTicket(id);
};
