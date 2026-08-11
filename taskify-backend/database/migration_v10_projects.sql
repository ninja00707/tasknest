-- Phase: Project Management
-- Safe, additive migration. No existing tables touched.

-- 1. Projects (top-level entity)
CREATE TABLE IF NOT EXISTS projects (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  description TEXT NOT NULL,
  status VARCHAR(20) NOT NULL DEFAULT 'planned'
    CHECK (status IN ('planned','in_progress','on_hold','completed')),
  priority VARCHAR(20) NOT NULL DEFAULT 'medium'
    CHECK (priority IN ('low','medium','high','urgent')),
  project_code VARCHAR(50),
  created_by_id INT NOT NULL REFERENCES users(id),
  created_by_dept INT NOT NULL REFERENCES departments(id),
  company_id INT NOT NULL REFERENCES companies(id),
  start_date DATE,
  end_date DATE,
  progress INT NOT NULL DEFAULT 0
    CHECK (progress >= 0 AND progress <= 100),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  version BIGINT
);

-- 2. Departments involved in a project
CREATE TABLE IF NOT EXISTS project_departments (
  id SERIAL PRIMARY KEY,
  project_id INT NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
  department_id INT NOT NULL REFERENCES departments(id),
  UNIQUE(project_id, department_id)
);

-- 3. Project members (people working on it)
CREATE TABLE IF NOT EXISTS project_members (
  id SERIAL PRIMARY KEY,
  project_id INT NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
  user_id INT NOT NULL REFERENCES users(id),
  role VARCHAR(20) NOT NULL DEFAULT 'member'
    CHECK (role IN ('lead','member')),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(project_id, user_id)
);

-- 4. Project observers (read-only watchers)
CREATE TABLE IF NOT EXISTS project_observers (
  id SERIAL PRIMARY KEY,
  project_id INT NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
  user_id INT NOT NULL REFERENCES users(id),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(project_id, user_id)
);

-- 5. Tasks inside a project
CREATE TABLE IF NOT EXISTS project_tasks (
  id SERIAL PRIMARY KEY,
  project_id INT NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
  title VARCHAR(255) NOT NULL,
  description TEXT NOT NULL,
  status VARCHAR(20) NOT NULL DEFAULT 'todo'
    CHECK (status IN ('todo','in_progress','in_review','done')),
  priority VARCHAR(20) NOT NULL DEFAULT 'medium'
    CHECK (priority IN ('low','medium','high','urgent')),
  assigned_to_id INT REFERENCES users(id),
  assigned_dept_id INT REFERENCES departments(id),
  progress INT NOT NULL DEFAULT 0
    CHECK (progress >= 0 AND progress <= 100),
  due_date DATE,
  created_by_id INT NOT NULL REFERENCES users(id),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  version BIGINT
);

-- 6. Task comments
CREATE TABLE IF NOT EXISTS project_task_comments (
  id SERIAL PRIMARY KEY,
  task_id INT NOT NULL REFERENCES project_tasks(id) ON DELETE CASCADE,
  user_id INT NOT NULL REFERENCES users(id),
  message TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 7. Task activity log
CREATE TABLE IF NOT EXISTS project_task_logs (
  id SERIAL PRIMARY KEY,
  task_id INT NOT NULL REFERENCES project_tasks(id) ON DELETE CASCADE,
  acted_by_id INT NOT NULL REFERENCES users(id),
  action VARCHAR(50) NOT NULL,
  old_value TEXT,
  new_value TEXT,
  note TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ── Indexes ─────────────────────────────────────────────────────
CREATE INDEX IF NOT EXISTS idx_projects_status        ON projects(status);
CREATE INDEX IF NOT EXISTS idx_projects_company       ON projects(company_id);
CREATE INDEX IF NOT EXISTS idx_projects_created_by    ON projects(created_by_id);
CREATE INDEX IF NOT EXISTS idx_proj_depts_project     ON project_departments(project_id);
CREATE INDEX IF NOT EXISTS idx_proj_depts_dept        ON project_departments(department_id);
CREATE INDEX IF NOT EXISTS idx_proj_members_project   ON project_members(project_id);
CREATE INDEX IF NOT EXISTS idx_proj_members_user      ON project_members(user_id);
CREATE INDEX IF NOT EXISTS idx_proj_obs_project       ON project_observers(project_id);
CREATE INDEX IF NOT EXISTS idx_proj_obs_user          ON project_observers(user_id);
CREATE INDEX IF NOT EXISTS idx_proj_tasks_project     ON project_tasks(project_id);
CREATE INDEX IF NOT EXISTS idx_proj_tasks_status      ON project_tasks(status);
CREATE INDEX IF NOT EXISTS idx_proj_tasks_assignee    ON project_tasks(assigned_to_id);
CREATE INDEX IF NOT EXISTS idx_proj_comments_task     ON project_task_comments(task_id);
CREATE INDEX IF NOT EXISTS idx_proj_logs_task         ON project_task_logs(task_id, created_at DESC);

-- ── Project code backfill ──────────────────────────────────────
UPDATE projects SET project_code = CONCAT('PRJ-', LPAD(id::text, 4, '0'))
WHERE project_code IS NULL;
