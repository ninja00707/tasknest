const projectRepo = require('./projects.repository');
const ProjectRules = require('./projects.rules');
const socketHelper = require('../../core/socketHelper');

class ProjectService {
  _throw(statusCode, message) {
    const err = new Error(message);
    err.statusCode = statusCode;
    throw err;
  }

  // ── Access helpers ──────────────────────────────────────────────────────
  async _getAccess(projectId, user) {
    const project = await projectRepo.getProjectAccess(projectId, user);
    if (!project) this._throw(404, 'Project not found');

    const role = ProjectRules.resolveRole(user, project);

    // Anyone with a role can view (access is already filtered by list query)
    const canView = true;
    if (!canView) this._throw(403, 'Access denied');

    return { project, role };
  }

  async _emit(projectId, event, payload) {
    try {
      const userIds = await projectRepo.getProjectUsers(projectId);
      if (!socketHelper.io) return;
      const data = { ...payload, projectId, event, createdAt: new Date().toISOString() };
      for (const userId of userIds) {
        socketHelper.io.to(`user_${userId}`).emit(event, data);
      }
      socketHelper.io.emit('PROJECT_EVENTS', data);
    } catch (err) {
      console.error(`[Projects] Realtime emit failed:`, err.message);
    }
  }

  // ══════════════════════════════════════════════════════════════════════
  // RULE 2: Only managers can create projects
  // ══════════════════════════════════════════════════════════════════════
  async createProject(user, body) {
    if (!ProjectRules.canCreateProject(user)) {
      this._throw(403, 'Only managers can create projects');
    }

    const { name, description, priority, startDate, endDate, departmentIds, memberIds, observerIds } = body;
    if (!name || !name.trim()) this._throw(400, 'Project name is required');
    if (!description || !description.trim()) this._throw(400, 'Project description is required');

    const project = await projectRepo.createProject({
      name: name.trim(),
      description: description.trim(),
      priority,
      startDate,
      endDate,
      createdBy: user,
      deptIds: departmentIds || [],
      memberIds: memberIds || [],
      observerIds: observerIds || [],
    });

    await this._emit(project.id, 'PROJECT_CREATED', { project, actor: { id: user.id, name: user.name } });
    return project;
  }

  async listProjects(user, query) {
    const scope = query.scope || 'all';
    const filters = { status: query.status };
    const projects = await projectRepo.listProjects(user, scope, filters);
    return projects;
  }

  async getProjectDetail(user, projectId, query = {}) {
    const { project, role } = await this._getAccess(projectId, user);
    const includeTasks = query.includeTasks !== 'false';
    const [departments, members, observers, tasks, tickets] = await Promise.all([
      projectRepo.getProjectDepartments(projectId),
      projectRepo.getProjectMembers(projectId),
      projectRepo.getProjectObservers(projectId),
      includeTasks ? projectRepo.getProjectTasks(projectId) : Promise.resolve([]),
      projectRepo.getProjectTickets(projectId),
    ]);
    return {
      ...project,
      viewerRole: role,
      isObserver: role === ProjectRules.ROLES.OBSERVER,
      canManage: ProjectRules.canManageMembers(role, user, project),
      canEdit: ProjectRules.canEditProject(role, user, project),
      canManageObservers: ProjectRules.canManageObservers(role, user, project),
      departments,
      members,
      observers,
      tasks,
      tickets,
    };
  }

  // ══════════════════════════════════════════════════════════════════════
  // RULE 3: Only the manager who created the project can edit
  // ══════════════════════════════════════════════════════════════════════
  async updateProject(user, projectId, body) {
    const { project, role } = await this._getAccess(projectId, user);
    if (!ProjectRules.canEditProject(role, user, project)) {
      this._throw(403, 'Only the manager who created this project can edit it');
    }
    if (project.status === 'completed' && body.status && body.status !== 'completed') {
      // allow reopening explicitly
    }
    const updated = await projectRepo.updateProject(projectId, {
      name: body.name,
      description: body.description,
      status: body.status,
      priority: body.priority,
      start_date: body.startDate,
      end_date: body.endDate,
    });
    await this._emit(projectId, 'PROJECT_UPDATED', { project: updated, actor: { id: user.id, name: user.name } });
    return updated;
  }

  async deleteProject(user, projectId) {
    const { project, role } = await this._getAccess(projectId, user);
    if (!ProjectRules.canDeleteProject(role, user, project)) {
      this._throw(403, 'Only the project creator or CEO can delete this project');
    }
    await projectRepo.deleteProject(projectId);
    await this._emit(projectId, 'PROJECT_DELETED', { id: projectId, actor: { id: user.id, name: user.name } });
    return { id: projectId, deleted: true };
  }

  // ══════════════════════════════════════════════════════════════════════
  // RULE 1: Members can be CRUD
  // ══════════════════════════════════════════════════════════════════════
  async addMembers(user, projectId, body) {
    const { project, role } = await this._getAccess(projectId, user);
    if (!ProjectRules.canManageMembers(role, user, project)) {
      this._throw(403, 'Only project members can add members');
    }
    if (!Array.isArray(body.userIds) || body.userIds.length === 0) this._throw(400, 'userIds is required');
    await projectRepo.addMembers(projectId, body.userIds, body.role || 'member');
    await this._emit(projectId, 'PROJECT_UPDATED', { message: 'Project members updated', actor: { id: user.id, name: user.name } });
    return { ok: true };
  }

  async removeMember(user, projectId, userId) {
    const { project, role } = await this._getAccess(projectId, user);
    if (!ProjectRules.canManageMembers(role, user, project)) {
      this._throw(403, 'Only project members can remove members');
    }
    if (Number(userId) === Number(user.id)) this._throw(400, 'You cannot remove yourself');
    await projectRepo.removeMember(projectId, userId);
    await this._emit(projectId, 'PROJECT_UPDATED', { message: 'Project member removed', actor: { id: user.id, name: user.name } });
    return { ok: true };
  }

  // ══════════════════════════════════════════════════════════════════════
  // RULE 4: Observers can be editable
  // ══════════════════════════════════════════════════════════════════════
  async addObservers(user, projectId, body) {
    const { project, role } = await this._getAccess(projectId, user);
    if (!ProjectRules.canManageObservers(role, user, project)) {
      this._throw(403, 'Only the project creator or lead can add observers');
    }
    if (!Array.isArray(body.userIds) || body.userIds.length === 0) this._throw(400, 'userIds is required');
    await projectRepo.addObservers(projectId, body.userIds);
    await this._emit(projectId, 'PROJECT_UPDATED', { message: 'Project observers updated', actor: { id: user.id, name: user.name } });
    return { ok: true };
  }

  async removeObserver(user, projectId, userId) {
    const { project, role } = await this._getAccess(projectId, user);
    if (!ProjectRules.canManageObservers(role, user, project)) {
      this._throw(403, 'Only the project creator or lead can remove observers');
    }
    await projectRepo.removeObserver(projectId, userId);
    await this._emit(projectId, 'PROJECT_UPDATED', { message: 'Project observer removed', actor: { id: user.id, name: user.name } });
    return { ok: true };
  }

  async addDepartments(user, projectId, body) {
    const { project, role } = await this._getAccess(projectId, user);
    if (!ProjectRules.canManageMembers(role, user, project)) {
      this._throw(403, 'Only project members can add departments');
    }
    if (!Array.isArray(body.departmentIds) || body.departmentIds.length === 0) this._throw(400, 'departmentIds is required');
    await projectRepo.addDepartments(projectId, body.departmentIds);
    await this._emit(projectId, 'PROJECT_UPDATED', { message: 'Project departments updated', actor: { id: user.id, name: user.name } });
    return { ok: true };
  }

  async removeDepartment(user, projectId, deptId) {
    const { project, role } = await this._getAccess(projectId, user);
    if (!ProjectRules.canManageMembers(role, user, project)) {
      this._throw(403, 'Only project members can remove departments');
    }
    await projectRepo.removeDepartment(projectId, deptId);
    await this._emit(projectId, 'PROJECT_UPDATED', { message: 'Project department removed', actor: { id: user.id, name: user.name } });
    return { ok: true };
  }

  // ══════════════════════════════════════════════════════════════════════
  // RULE 5: Tasks work like tickets
  // ══════════════════════════════════════════════════════════════════════
  async addTask(user, projectId, body) {
    const { project, role } = await this._getAccess(projectId, user);
    if (!ProjectRules.canCreateTask(role)) {
      this._throw(403, 'Only project members can add tasks');
    }
    if (!body.title || !body.title.trim()) this._throw(400, 'Task title is required');
    const task = await projectRepo.createTask(projectId, {
      title: body.title.trim(),
      description: body.description || '',
      priority: body.priority,
      assignedToId: body.assignedToId,
      assignedDeptId: body.assignedDeptId,
      dueDate: body.dueDate,
      createdById: user.id,
    });
    await this._emit(projectId, 'PROJECT_TASK_UPDATED', { task, actor: { id: user.id, name: user.name }, message: `New task added to ${project.name}` });
    return task;
  }

  async updateTask(user, projectId, taskId, body) {
    const { project, role } = await this._getAccess(projectId, user);
    const task = await projectRepo.getTask(taskId);
    if (!task || Number(task.project_id) !== Number(projectId)) this._throw(404, 'Task not found');

    if (!ProjectRules.canUpdateTask(role, task, user)) {
      this._throw(403, 'You do not have permission to update this task');
    }

    const updated = await projectRepo.updateTask(taskId, {
      title: body.title,
      description: body.description,
      status: body.status,
      priority: body.priority,
      assigned_to_id: body.assignedToId,
      assigned_dept_id: body.assignedDeptId,
      due_date: body.dueDate,
      progress: body.progress,
    }, user.id);

    await this._emit(projectId, 'PROJECT_TASK_UPDATED', {
      task: { ...updated, project_id: projectId },
      actor: { id: user.id, name: user.name },
      message: `Task updated in ${project.name}`,
    });
    return updated;
  }

  async deleteTask(user, projectId, taskId) {
    const { project, role } = await this._getAccess(projectId, user);
    if (!ProjectRules.canDeleteTask(role, user)) {
      this._throw(403, 'Only the project creator, lead, or CEO can delete tasks');
    }
    const task = await projectRepo.getTask(taskId);
    if (!task || Number(task.project_id) !== Number(projectId)) this._throw(404, 'Task not found');
    await projectRepo.deleteTask(taskId);
    await this._emit(projectId, 'PROJECT_TASK_UPDATED', { taskId, deleted: true, actor: { id: user.id, name: user.name } });
    return { ok: true };
  }

  async addComment(user, projectId, taskId, body) {
    const { project, role } = await this._getAccess(projectId, user);
    if (!ProjectRules.canCommentOnTask(role)) {
      this._throw(403, 'Only project members can comment on tasks');
    }
    if (!body.message || !body.message.trim()) this._throw(400, 'Comment message is required');
    const task = await projectRepo.getTask(taskId);
    if (!task || Number(task.project_id) !== Number(projectId)) this._throw(404, 'Task not found');
    const comment = await projectRepo.addTaskComment(taskId, user.id, body.message.trim());
    await this._emit(projectId, 'PROJECT_TASK_UPDATED', {
      taskId, comment, actor: { id: user.id, name: user.name },
      message: `New comment on task "${task.title}"`,
    });
    return comment;
  }

  async getComments(user, projectId, taskId) {
    await this._getAccess(projectId, user);
    const task = await projectRepo.getTask(taskId);
    if (!task || Number(task.project_id) !== Number(projectId)) this._throw(404, 'Task not found');
    return projectRepo.getTaskComments(taskId);
  }

  async getLogs(user, projectId, taskId) {
    await this._getAccess(projectId, user);
    const task = await projectRepo.getTask(taskId);
    if (!task || Number(task.project_id) !== Number(projectId)) this._throw(404, 'Task not found');
    return projectRepo.getTaskLogs(taskId);
  }
}

module.exports = new ProjectService();
