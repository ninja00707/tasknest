/**
 * Project Module — Business Rules & Access Control
 * =================================================
 *
 * RULE 1: Members can be CRUD
 *   - Any authenticated user who is a project member (lead/member role) can
 *     create, read, update, and delete project members.
 *   - Members cannot remove themselves if they are the project lead.
 *
 * RULE 2: Only managers can create projects
 *   - Enforced at route level via `isManager` middleware.
 *   - CEO and developer roles also inherit manager permissions.
 *
 * RULE 3: Only the manager who created the project can edit the project
 *   - The creator (project lead) has full edit access.
 *   - CEO can edit any project in their company.
 *   - Other managers, members, and observers cannot edit project details.
 *
 * RULE 4: Observers can be editable
 *   - The project creator can add or remove observers at any time.
 *   - Project leads can also manage observers.
 *   - Observers themselves cannot modify the observer list.
 *
 * RULE 5: Tasks work like tickets
 *   - Tasks have ticket-like fields: title, description, status, priority,
 *     assignee, due date, progress, comments, and activity logs.
 *   - Tasks follow a workflow: todo → in_progress → done.
 *   - Task comments support threaded discussions like ticket comments.
 *   - Task history logs all changes (like ticket logs).
 */

class ProjectRules {
  // ── Role constants ──────────────────────────────────────────────────────
  static get ROLES() {
    return {
      CREATOR: 'creator',
      LEAD: 'lead',
      MEMBER: 'member',
      OBSERVER: 'observer',
      DEPARTMENT: 'department',
      CEO: 'ceo',
      VIEWER: 'viewer',
    };
  }

  // ── Task status workflow (like tickets) ────────────────────────────────
  static get TASK_STATUS() {
    return {
      TODO: 'todo',
      IN_PROGRESS: 'in_progress',
      DONE: 'done',
    };
  }

  static get TASK_STATUSES() {
    return ['todo', 'in_progress', 'done'];
  }

  // ── Project status workflow ────────────────────────────────────────────
  static get PROJECT_STATUS() {
    return {
      PLANNED: 'planned',
      IN_PROGRESS: 'in_progress',
      ON_HOLD: 'on_hold',
      COMPLETED: 'completed',
    };
  }

  static get PROJECT_STATUSES() {
    return ['planned', 'in_progress', 'on_hold', 'completed'];
  }

  // ── Priority levels (like tickets) ─────────────────────────────────────
  static get PRIORITIES() {
    return ['low', 'medium', 'high', 'urgent'];
  }

  // ── Rule 1: Members can be CRUD ────────────────────────────────────────
  // Any project member (lead or member role) can manage other members.
  static canManageMembers(userRole, user, project) {
    if (userRole === this.ROLES.OBSERVER) return false;
    if (userRole === this.ROLES.VIEWER) return false;
    if (userRole === this.ROLES.DEPARTMENT) return false;
    // Creator, lead, member, and CEO can manage members
    return true;
  }

  // ── Rule 2: Only managers can create projects ──────────────────────────
  // Enforced at route level — this is a helper for service-layer checks.
  static canCreateProject(user) {
    const isManager = user.role === 'manager' || user.role === 'ceo' || user.role === 'developer';
    return isManager;
  }

  // ── Rule 3: Only the manager who created the project can edit ──────────
  static canEditProject(userRole, user, project) {
    // CEO can edit any project in their company
    if (user.role === 'ceo' || user.role === 'developer') {
      return true;
    }
    // Only the creator (who must be a manager) can edit
    if (userRole === this.ROLES.CREATOR && user.role === 'manager') {
      return true;
    }
    return false;
  }

  // ── Rule 4: Observers can be editable ──────────────────────────────────
  // The creator and leads can add/remove observers.
  static canManageObservers(userRole, user, project) {
    // CEO can manage observers on any project
    if (user.role === 'ceo' || user.role === 'developer') {
      return true;
    }
    // Creator can manage observers
    if (userRole === this.ROLES.CREATOR) {
      return true;
    }
    // Lead can manage observers
    if (userRole === this.ROLES.LEAD) {
      return true;
    }
    return false;
  }

  // ── Rule 5: Tasks work like tickets ────────────────────────────────────
  // Tasks have full CRUD with ticket-like workflow.
  static canCreateTask(userRole) {
    return userRole !== this.ROLES.OBSERVER && userRole !== this.ROLES.VIEWER;
  }

  static canUpdateTask(userRole, task, user) {
    // Observers cannot update tasks
    if (userRole === this.ROLES.OBSERVER) return false;
    if (userRole === this.ROLES.VIEWER) return false;
    // Creator, lead, and CEO can update any task
    if (userRole === this.ROLES.CREATOR || userRole === this.ROLES.LEAD) return true;
    if (user.role === 'ceo' || user.role === 'developer') return true;
    // Members can update tasks assigned to them
    if (userRole === this.ROLES.MEMBER && task && Number(task.assigned_to_id) === Number(user.id)) {
      return true;
    }
    return false;
  }

  static canDeleteTask(userRole, user) {
    // Only creator, lead, and CEO can delete tasks
    if (userRole === this.ROLES.CREATOR) return true;
    if (userRole === this.ROLES.LEAD) return true;
    if (user.role === 'ceo' || user.role === 'developer') return true;
    return false;
  }

  static canCommentOnTask(userRole) {
    // Observers cannot comment (read-only)
    return userRole !== this.ROLES.OBSERVER && userRole !== this.ROLES.VIEWER;
  }

  // ── General access helpers ─────────────────────────────────────────────
  static canViewProject(userRole) {
    return true; // Any authenticated user with a role can view
  }

  static canDeleteProject(userRole, user, project) {
    // Only creator or CEO can delete a project
    if (userRole === this.ROLES.CREATOR) return true;
    if (user.role === 'ceo' || user.role === 'developer') return true;
    return false;
  }

  // ── Resolve the viewer's role for a project ────────────────────────────
  static resolveRole(user, project) {
    const isCeo = user.role === 'ceo' || user.role === 'developer';
    const seeAll = isCeo && (user.see_all_companies || project.company_id === user.company_id);
    const isCreator = Number(project.created_by_id) === Number(user.id);
    const isLead = project.member_role === 'lead';
    const isMember = !!project.member_role;
    const isObserver = project.is_observer;
    const deptInvolved = project.dept_involved;

    if (isCreator) return this.ROLES.CREATOR;
    if (isLead) return this.ROLES.LEAD;
    if (isMember) return this.ROLES.MEMBER;
    if (isObserver) return this.ROLES.OBSERVER;
    if (seeAll) return this.ROLES.CEO;
    if (deptInvolved) return this.ROLES.DEPARTMENT;
    return this.ROLES.VIEWER;
  }
}

module.exports = ProjectRules;
