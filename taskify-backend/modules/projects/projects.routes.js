const express = require('express');
const router = express.Router();
const controller = require('./projects.controller');
const { authenticate, isManager } = require('../ticket/Auth.middleware');

// All project routes require authentication
router.use(authenticate);

// ── Project CRUD ────────────────────────────────────────────────────
router.post('/', isManager, controller.createProject);
router.get('/', controller.listProjects);
router.get('/:id', controller.getProjectDetail);
router.patch('/:id', controller.updateProject);
router.delete('/:id', controller.deleteProject);

// ── Project team management ─────────────────────────────────────────
router.post('/:id/members', controller.addMembers);
router.delete('/:id/members/:userId', controller.removeMember);
router.post('/:id/observers', controller.addObservers);
router.delete('/:id/observers/:userId', controller.removeObserver);
router.post('/:id/departments', controller.addDepartments);
router.delete('/:id/departments/:deptId', controller.removeDepartment);

// ── Tasks ───────────────────────────────────────────────────────────
router.post('/:id/tasks', controller.addTask);
router.patch('/:id/tasks/:taskId', controller.updateTask);
router.delete('/:id/tasks/:taskId', controller.deleteTask);
router.get('/:id/tasks/:taskId/comments', controller.getComments);
router.post('/:id/tasks/:taskId/comments', controller.addComment);
router.get('/:id/tasks/:taskId/logs', controller.getLogs);

module.exports = router;
