const pool = require('../../database/db');

class ProjectRepository {
  // ── Create a project with departments, members and observers ──────────
  async createProject({ name, description, priority, startDate, endDate, createdBy, deptIds, memberIds, observerIds }) {
    const client = await pool.connect();
    try {
      await client.query('BEGIN');

      const code = `PRJ-${Date.now().toString(36).toUpperCase()}`;
      const proj = await client.query(
        `INSERT INTO projects (name, description, priority, project_code, created_by_id, created_by_dept, company_id, start_date, end_date, version)
         VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, 1)
         RETURNING *`,
        [name, description, priority || 'medium', code, createdBy.id, createdBy.department_id, createdBy.company_id, startDate || null, endDate || null]
      );
      const project = proj.rows[0];

      // Creator is always the project lead
      await client.query(
        `INSERT INTO project_members (project_id, user_id, role) VALUES ($1, $2, 'lead')
         ON CONFLICT (project_id, user_id) DO UPDATE SET role = 'lead'`,
        [project.id, createdBy.id]
      );

      for (const deptId of deptIds || []) {
        await client.query(
          `INSERT INTO project_departments (project_id, department_id) VALUES ($1, $2)
           ON CONFLICT (project_id, department_id) DO NOTHING`,
          [project.id, deptId]
        );
      }

      for (const userId of memberIds || []) {
        await client.query(
          `INSERT INTO project_members (project_id, user_id, role) VALUES ($1, $2, 'member')
           ON CONFLICT (project_id, user_id) DO NOTHING`,
          [project.id, userId]
        );
      }

      for (const userId of observerIds || []) {
        await client.query(
          `INSERT INTO project_observers (project_id, user_id) VALUES ($1, $2)
           ON CONFLICT (project_id, user_id) DO NOTHING`,
          [project.id, userId]
        );
      }

      await client.query('COMMIT');
      return project;
    } catch (err) {
      await client.query('ROLLBACK');
      throw err;
    } finally {
      client.release();
    }
  }

  // ── List projects visible to a user ─────────────────────────────────────
  async listProjects(user, scope = 'all', filters = {}) {
    const params = [];
    let where = '';
    const joins = [];

    if (scope === 'observed') {
      params.push(user.id);
      where = `WHERE EXISTS (SELECT 1 FROM project_observers po WHERE po.project_id = p.id AND po.user_id = $${params.length})`;
    } else if (scope === 'mine') {
      params.push(user.id);
      where = `WHERE p.created_by_id = $${params.length}`;
    } else if (scope === 'member') {
      params.push(user.id);
      where = `WHERE EXISTS (SELECT 1 FROM project_members pm WHERE pm.project_id = p.id AND pm.user_id = $${params.length})`;
    } else if (user.role === 'ceo' || user.role === 'developer') {
      if (!user.see_all_companies) {
        params.push(user.company_id);
        where = `WHERE p.company_id = $${params.length}`;
      }
    } else {
      // Manager / employee: creator, member, or department involved.
      // Pure observers see projects ONLY in the 'observed' scope.
      params.push(user.id);
      const userIdIdx = params.length;
      params.push(user.department_id);
      const deptIdx = params.length;
      where = `WHERE (
        p.created_by_id = $${userIdIdx}
        OR EXISTS (SELECT 1 FROM project_members pm WHERE pm.project_id = p.id AND pm.user_id = $${userIdIdx})
        OR EXISTS (SELECT 1 FROM project_departments pd WHERE pd.project_id = p.id AND pd.department_id = $${deptIdx})
      )`;
    }

    if (filters.status) {
      params.push(filters.status);
      where += `${where ? ' AND' : 'WHERE'} p.status = $${params.length}`;
    }

    const sql = `
      SELECT
        p.id, p.name, p.description, p.status, p.priority, p.project_code,
        p.created_by_id, p.created_by_dept, p.company_id,
        p.start_date, p.end_date, p.progress, p.created_at, p.updated_at,
        creator.name AS created_by_name,
        cd.name AS created_by_dept_name, cd.code AS created_by_dept_code,
        (SELECT COUNT(*) FROM project_members m WHERE m.project_id = p.id) AS member_count,
        (SELECT COUNT(*) FROM project_observers o WHERE o.project_id = p.id) AS observer_count,
        (SELECT COUNT(*) FROM project_tasks t WHERE t.project_id = p.id) AS task_count,
        (SELECT COUNT(*) FROM project_tasks t WHERE t.project_id = p.id AND t.status = 'done') AS done_count,
        (SELECT COUNT(*) FROM project_departments d WHERE d.project_id = p.id) AS dept_count,
        EXISTS (SELECT 1 FROM project_observers po WHERE po.project_id = p.id AND po.user_id = $${params.length + 1}) AS is_observer
      FROM projects p
      JOIN users creator ON creator.id = p.created_by_id
      JOIN departments cd ON cd.id = p.created_by_dept
      ${joins.join('\n')}
      ${where}
      ORDER BY p.created_at DESC
    `;
    params.push(user.id);
    const result = await pool.query(sql, params);
    return result.rows;
  }

  // ── Project access: fetch project and the viewer's role ────────────────
  async getProjectAccess(projectId, user) {
    const result = await pool.query(
      `SELECT
         p.*,
         creator.name AS created_by_name,
         cd.name AS created_by_dept_name, cd.code AS created_by_dept_code,
         (SELECT role FROM project_members pm WHERE pm.project_id = p.id AND pm.user_id = $2) AS member_role,
         EXISTS (SELECT 1 FROM project_observers po WHERE po.project_id = p.id AND po.user_id = $2) AS is_observer,
         EXISTS (SELECT 1 FROM project_departments pd WHERE pd.project_id = p.id AND pd.department_id = $3) AS dept_involved
       FROM projects p
       JOIN users creator ON creator.id = p.created_by_id
       JOIN departments cd ON cd.id = p.created_by_dept
       WHERE p.id = $1`,
      [projectId, user.id, user.department_id]
    );
    return result.rows[0] || null;
  }

  async getProject(projectId) {
    const result = await pool.query(
      `SELECT p.*, creator.name AS created_by_name,
              cd.name AS created_by_dept_name, cd.code AS created_by_dept_code
       FROM projects p
       JOIN users creator ON creator.id = p.created_by_id
       JOIN departments cd ON cd.id = p.created_by_dept
       WHERE p.id = $1`,
      [projectId]
    );
    return result.rows[0] || null;
  }

  async getProjectDepartments(projectId) {
    const result = await pool.query(
      `SELECT d.id, d.name, d.code FROM project_departments pd
       JOIN departments d ON d.id = pd.department_id
       WHERE pd.project_id = $1 ORDER BY d.name`,
      [projectId]
    );
    return result.rows;
  }

  async getProjectMembers(projectId) {
    const result = await pool.query(
      `SELECT pm.user_id AS id, u.name, u.code, d.name AS department_name, pm.role
       FROM project_members pm
       JOIN users u ON u.id = pm.user_id
       LEFT JOIN departments d ON d.id = u.department_id
       WHERE pm.project_id = $1 ORDER BY pm.role, u.name`,
      [projectId]
    );
    return result.rows;
  }

  async getProjectObservers(projectId) {
    const result = await pool.query(
      `SELECT po.user_id AS id, u.name, u.code, d.name AS department_name
       FROM project_observers po
       JOIN users u ON u.id = po.user_id
       LEFT JOIN departments d ON d.id = u.department_id
       WHERE po.project_id = $1 ORDER BY u.name`,
      [projectId]
    );
    return result.rows;
  }

  async getProjectTasks(projectId) {
    const result = await pool.query(
      `SELECT t.*,
         assignee.name AS assigned_to_name,
         ad.name AS assigned_dept_name, ad.code AS assigned_dept_code,
         creator.name AS created_by_name,
         (SELECT COUNT(*) FROM project_task_comments c WHERE c.task_id = t.id) AS comment_count
       FROM project_tasks t
       LEFT JOIN users assignee ON assignee.id = t.assigned_to_id
       LEFT JOIN departments ad ON ad.id = t.assigned_dept_id
       JOIN users creator ON creator.id = t.created_by_id
       WHERE t.project_id = $1
       ORDER BY t.created_at DESC`,
      [projectId]
    );
    return result.rows;
  }

  async getProjectTickets(projectId) {
    const result = await pool.query(
      `WITH RECURSIVE seed AS (
          SELECT id, parent_ticket_id FROM tickets WHERE project_id = $1
        ),
        upward AS (
          SELECT id, parent_ticket_id FROM seed
          UNION
          SELECT p.id, p.parent_ticket_id FROM tickets p
          JOIN upward u ON p.id = u.parent_ticket_id
        ),
        full_tree AS (
          SELECT id FROM upward
          UNION
          SELECT c.id FROM tickets c
          JOIN full_tree f ON c.parent_ticket_id = f.id
        )
       SELECT t.id, t.title, t.description, t.status, t.priority, t.ticket_number,
              t.assigned_dept_id, t.assigned_to_id, t.created_by_id,
              t.created_by_dept, t.due_date, t.created_at, t.updated_at,
              t.is_sub_ticket, t.parent_ticket_id, t.ticket_type,
              t.overall_progress, t.closed_at, t.reopen_count, t.project_id,
              ad.name AS assigned_dept_name, ad.code AS assigned_dept_code,
              u.name AS assigned_to_name,
              creator.name AS created_by_name,
              ll.action AS last_action,
              ll.acted_by_name AS last_acted_by_name,
              (SELECT COUNT(*) FROM tickets WHERE parent_ticket_id = t.id) AS immediate_child_count,
              EXISTS (
                WITH RECURSIVE descendants AS (
                  SELECT id, status FROM tickets WHERE parent_ticket_id = t.id
                  UNION ALL
                  SELECT child.id, child.status FROM tickets child
                  JOIN descendants d ON child.parent_ticket_id = d.id
                )
                SELECT 1 FROM descendants WHERE status != 'closed'
              ) AS has_active_children,
              pt.title AS parent_ticket_title,
              pt.ticket_number AS parent_ticket_number,
              EXISTS (
                SELECT 1 FROM ticket_logs tl WHERE tl.ticket_id = t.id AND tl.action = 'disputed'
              ) AS disputed
       FROM tickets t
       LEFT JOIN departments ad ON ad.id = t.assigned_dept_id
       LEFT JOIN users u ON u.id = t.assigned_to_id
       JOIN users creator ON creator.id = t.created_by_id
       LEFT JOIN tickets pt ON pt.id = t.parent_ticket_id
       LEFT JOIN LATERAL (
         SELECT l.action, u.name AS acted_by_name, l.created_at
         FROM ticket_logs l
         LEFT JOIN users u ON u.id = l.acted_by_id
         WHERE l.ticket_id = t.id
         ORDER BY l.created_at DESC
         LIMIT 1
       ) ll ON true
       WHERE t.id IN (SELECT id FROM full_tree)
       ORDER BY t.created_at DESC`,
      [projectId]
    );

    const rows = result.rows;
    if (rows.length === 0) return rows;

    const byId = new Map(rows.map(r => [r.id, r]));
    const childrenByParent = new Map();
    for (const r of rows) {
      if (r.parent_ticket_id != null) {
        if (!childrenByParent.has(r.parent_ticket_id)) childrenByParent.set(r.parent_ticket_id, []);
        childrenByParent.get(r.parent_ticket_id).push(r);
      }
    }

    const toChildModel = (r) => ({
      id: r.id,
      ticket_number: r.ticket_number,
      title: r.title,
      description: r.description,
      status: r.status,
      assigned_dept_id: r.assigned_dept_id,
      dept_code: r.assigned_dept_code,
      dept_name: r.assigned_dept_name,
      assigned_to_id: r.assigned_to_id,
      assignee_name: r.assigned_to_name,
      created_by_id: r.created_by_id,
      created_by_dept: r.created_by_dept,
      created_by_name: r.created_by_name,
      created_by_dept_code: r.created_by_dept_code,
      created_at: r.created_at,
      priority: r.priority,
      immediate_child_count: r.immediate_child_count,
      has_active_children: r.has_active_children,
      closed_at: r.closed_at,
      reopen_count: r.reopen_count,
    });

    const allDescendants = (id) => {
      const out = [];
      const stack = [...(childrenByParent.get(id) || [])];
      const seen = new Set();
      while (stack.length) {
        const n = stack.pop();
        if (seen.has(n.id)) continue;
        seen.add(n.id);
        out.push(n);
        const kids = childrenByParent.get(n.id);
        if (kids) for (const k of kids) stack.push(k);
      }
      return out;
    };

    const roots = rows.filter(r => r.parent_ticket_id == null || !byId.has(r.parent_ticket_id));
    return roots.map(r => ({ ...r, children: allDescendants(r.id).map(toChildModel) }));
  }

  // ── Update project ──────────────────────────────────────────────────────
  async updateProject(projectId, fields) {
    const allowed = ['name', 'description', 'status', 'priority', 'start_date', 'end_date'];
    const sets = [];
    const params = [];
    for (const key of Object.keys(fields)) {
      if (!allowed.includes(key)) continue;
      if (fields[key] === undefined) continue;
      params.push(fields[key]);
      sets.push(`${key} = $${params.length}`);
    }
    if (sets.length === 0) return null;
    params.push(projectId);
    const result = await pool.query(
      `UPDATE projects SET ${sets.join(', ')}, updated_at = NOW(), version = COALESCE(version, 0) + 1
       WHERE id = $${params.length} RETURNING *`,
      params
    );
    return result.rows[0] || null;
  }

  async deleteProject(projectId) {
    const result = await pool.query(`DELETE FROM projects WHERE id = $1 RETURNING id`, [projectId]);
    return result.rows[0] ? true : false;
  }

  // ── Members / Observers / Departments management ────────────────────────
  async addMembers(projectId, userIds, role = 'member') {
    for (const userId of userIds) {
      await pool.query(
        `INSERT INTO project_members (project_id, user_id, role) VALUES ($1, $2, $3)
         ON CONFLICT (project_id, user_id) DO UPDATE SET role = EXCLUDED.role`,
        [projectId, userId, role]
      );
    }
    return true;
  }

  async removeMember(projectId, userId) {
    await pool.query(`DELETE FROM project_members WHERE project_id = $1 AND user_id = $2`, [projectId, userId]);
    return true;
  }

  async addObservers(projectId, userIds) {
    for (const userId of userIds) {
      await pool.query(
        `INSERT INTO project_observers (project_id, user_id) VALUES ($1, $2)
         ON CONFLICT (project_id, user_id) DO NOTHING`,
        [projectId, userId]
      );
    }
    return true;
  }

  async removeObserver(projectId, userId) {
    await pool.query(`DELETE FROM project_observers WHERE project_id = $1 AND user_id = $2`, [projectId, userId]);
    return true;
  }

  async addDepartments(projectId, deptIds) {
    for (const deptId of deptIds) {
      await pool.query(
        `INSERT INTO project_departments (project_id, department_id) VALUES ($1, $2)
         ON CONFLICT (project_id, department_id) DO NOTHING`,
        [projectId, deptId]
      );
    }
    return true;
  }

  async removeDepartment(projectId, deptId) {
    await pool.query(`DELETE FROM project_departments WHERE project_id = $1 AND department_id = $2`, [projectId, deptId]);
    return true;
  }

  // ── Tasks ───────────────────────────────────────────────────────────────
  async createTask(projectId, { title, description, priority, assignedToId, assignedDeptId, dueDate, createdById }) {
    const result = await pool.query(
      `INSERT INTO project_tasks (project_id, title, description, priority, assigned_to_id, assigned_dept_id, due_date, created_by_id, version)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, 1)
       RETURNING *`,
      [projectId, title, description, priority || 'medium', assignedToId || null, assignedDeptId || null, dueDate || null, createdById]
    );
    const task = result.rows[0];
    await this.logTask(task.id, createdById, 'created', null, task.status);
    await this.recomputeProjectProgress(projectId);
    return task;
  }

  async getTask(taskId) {
    const result = await pool.query(
      `SELECT t.*, assignee.name AS assigned_to_name, ad.code AS assigned_dept_code, ad.name AS assigned_dept_name
       FROM project_tasks t
       LEFT JOIN users assignee ON assignee.id = t.assigned_to_id
       LEFT JOIN departments ad ON ad.id = t.assigned_dept_id
       WHERE t.id = $1`,
      [taskId]
    );
    return result.rows[0] || null;
  }

  async updateTask(taskId, fields, actorId) {
    const allowed = ['title', 'description', 'status', 'priority', 'assigned_to_id', 'assigned_dept_id', 'due_date', 'progress'];
    // Only these may be explicitly cleared with null; the rest (title, status,
    // priority, progress) are NOT NULL and must never be written as null.
    const nullClears = ['description', 'assigned_to_id', 'assigned_dept_id', 'due_date'];
    const sets = [];
    const params = [];
    const before = await this.getTask(taskId);
    if (!before) return null;

    for (const key of Object.keys(fields)) {
      if (!allowed.includes(key)) continue;
      const value = fields[key];
      if (value === undefined) continue;
      if (value === null && !nullClears.includes(key)) continue;
      params.push(value);
      sets.push(`${key} = $${params.length}`);
    }
    if (sets.length === 0) return null;

    params.push(taskId);
    const result = await pool.query(
      `UPDATE project_tasks SET ${sets.join(', ')}, updated_at = NOW(), version = COALESCE(version, 0) + 1
       WHERE id = $${params.length} RETURNING *`,
      params
    );
    const after = result.rows[0];

    for (const key of Object.keys(fields)) {
      if (!allowed.includes(key) || fields[key] === undefined) continue;
      const oldV = before[key];
      const newV = after[key];
      if (String(oldV) !== String(newV)) {
        await this.logTask(taskId, actorId, `status_${after.status}`, oldV, newV, key);
      }
    }

    const proj = await pool.query(`SELECT project_id FROM project_tasks WHERE id = $1`, [taskId]);
    if (proj.rows[0]) await this.recomputeProjectProgress(proj.rows[0].project_id);

    return after;
  }

  async deleteTask(taskId) {
    const proj = await pool.query(`SELECT project_id FROM project_tasks WHERE id = $1`, [taskId]);
    await pool.query(`DELETE FROM project_tasks WHERE id = $1`, [taskId]);
    if (proj.rows[0]) await this.recomputeProjectProgress(proj.rows[0].project_id);
    return true;
  }

  async recomputeProjectProgress(projectId) {
    await pool.query(
      `UPDATE projects SET
         progress = COALESCE((SELECT AVG(progress)::int FROM project_tasks WHERE project_id = $1), 0),
         status = CASE
           WHEN (SELECT COUNT(*) FROM project_tasks WHERE project_id = $1) > 0
                AND (SELECT COUNT(*) FROM project_tasks WHERE project_id = $1 AND status != 'done') = 0
           THEN 'completed'
           WHEN (SELECT COUNT(*) FROM project_tasks WHERE project_id = $1 AND status IN ('in_progress','in_review')) > 0
           THEN 'in_progress'
           ELSE status
         END,
         updated_at = NOW(),
         version = COALESCE(version, 0) + 1
       WHERE id = $1`,
      [projectId]
    );
  }

  async logTask(taskId, actorId, action, oldValue, newValue, note) {
    await pool.query(
      `INSERT INTO project_task_logs (task_id, acted_by_id, action, old_value, new_value, note) VALUES ($1, $2, $3, $4, $5, $6)`,
      [taskId, actorId, action, oldValue === undefined ? null : String(oldValue), newValue === undefined ? null : String(newValue), note || null]
    );
  }

  async addTaskComment(taskId, userId, message) {
    const result = await pool.query(
      `INSERT INTO project_task_comments (task_id, user_id, message) VALUES ($1, $2, $3) RETURNING *`,
      [taskId, userId, message]
    );
    const comment = result.rows[0];
    const user = await pool.query(`SELECT name FROM users WHERE id = $1`, [userId]);
    comment.user_name = user.rows[0]?.name || null;
    return comment;
  }

  async getTaskComments(taskId) {
    const result = await pool.query(
      `SELECT c.*, u.name AS user_name FROM project_task_comments c
       JOIN users u ON u.id = c.user_id
       WHERE c.task_id = $1 ORDER BY c.created_at ASC`,
      [taskId]
    );
    return result.rows;
  }

  async getTaskLogs(taskId) {
    const result = await pool.query(
      `SELECT l.*, u.name AS actor_name FROM project_task_logs l
       JOIN users u ON u.id = l.acted_by_id
       WHERE l.task_id = $1 ORDER BY l.created_at ASC`,
      [taskId]
    );
    return result.rows;
  }

  // ── Users related to a project (for realtime notifications) ────────────
  async getProjectUsers(projectId) {
    const result = await pool.query(
      `SELECT DISTINCT user_id FROM (
         SELECT p.created_by_id AS user_id FROM projects p WHERE p.id = $1
         UNION ALL SELECT pm.user_id FROM project_members pm WHERE pm.project_id = $1
         UNION ALL SELECT po.user_id FROM project_observers po WHERE po.project_id = $1
         UNION ALL SELECT u.id FROM project_departments pd
           JOIN users u ON u.department_id = pd.department_id
           WHERE pd.project_id = $1
       ) x WHERE user_id IS NOT NULL`,
      [projectId]
    );
    return result.rows.map(r => r.user_id);
  }
}

module.exports = new ProjectRepository();
