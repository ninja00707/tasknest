const projectService = require('./projects.service');

const handler = (fn) => (req, res, next) => {
  Promise.resolve(fn(req, res, next)).catch(next);
};

class ProjectController {
  createProject = handler(async (req, res) => {
    const project = await projectService.createProject(req.user, req.body);
    res.status(201).json({ success: true, data: project });
  });

  listProjects = handler(async (req, res) => {
    const projects = await projectService.listProjects(req.user, req.query);
    res.json({ success: true, data: projects });
  });

  getProjectDetail = handler(async (req, res) => {
    const project = await projectService.getProjectDetail(req.user, Number(req.params.id), req.query);
    res.json({ success: true, data: project });
  });

  updateProject = handler(async (req, res) => {
    const project = await projectService.updateProject(req.user, Number(req.params.id), req.body);
    res.json({ success: true, data: project });
  });

  deleteProject = handler(async (req, res) => {
    const result = await projectService.deleteProject(req.user, Number(req.params.id));
    res.json({ success: true, data: result });
  });

  addMembers = handler(async (req, res) => {
    const result = await projectService.addMembers(req.user, Number(req.params.id), req.body);
    res.json({ success: true, data: result });
  });

  removeMember = handler(async (req, res) => {
    const result = await projectService.removeMember(req.user, Number(req.params.id), Number(req.params.userId));
    res.json({ success: true, data: result });
  });

  addObservers = handler(async (req, res) => {
    const result = await projectService.addObservers(req.user, Number(req.params.id), req.body);
    res.json({ success: true, data: result });
  });

  removeObserver = handler(async (req, res) => {
    const result = await projectService.removeObserver(req.user, Number(req.params.id), Number(req.params.userId));
    res.json({ success: true, data: result });
  });

  addDepartments = handler(async (req, res) => {
    const result = await projectService.addDepartments(req.user, Number(req.params.id), req.body);
    res.json({ success: true, data: result });
  });

  removeDepartment = handler(async (req, res) => {
    const result = await projectService.removeDepartment(req.user, Number(req.params.id), Number(req.params.deptId));
    res.json({ success: true, data: result });
  });

  addTask = handler(async (req, res) => {
    const task = await projectService.addTask(req.user, Number(req.params.id), req.body);
    res.status(201).json({ success: true, data: task });
  });

  updateTask = handler(async (req, res) => {
    const task = await projectService.updateTask(req.user, Number(req.params.id), Number(req.params.taskId), req.body);
    res.json({ success: true, data: task });
  });

  deleteTask = handler(async (req, res) => {
    const result = await projectService.deleteTask(req.user, Number(req.params.id), Number(req.params.taskId));
    res.json({ success: true, data: result });
  });

  addComment = handler(async (req, res) => {
    const comment = await projectService.addComment(req.user, Number(req.params.id), Number(req.params.taskId), req.body);
    res.status(201).json({ success: true, data: comment });
  });

  getComments = handler(async (req, res) => {
    const comments = await projectService.getComments(req.user, Number(req.params.id), Number(req.params.taskId));
    res.json({ success: true, data: comments });
  });

  getLogs = handler(async (req, res) => {
    const logs = await projectService.getLogs(req.user, Number(req.params.id), Number(req.params.taskId));
    res.json({ success: true, data: logs });
  });
}

module.exports = new ProjectController();
