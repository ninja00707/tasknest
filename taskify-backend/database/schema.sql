DROP SCHEMA public CASCADE;
CREATE SCHEMA public;

-- ── Companies ────────────────────────────────────────────────
CREATE TABLE companies (
  id         INT PRIMARY KEY,
  name       VARCHAR(100) NOT NULL,
  slug       VARCHAR(50)  NOT NULL UNIQUE,
  created_at TIMESTAMPTZ  DEFAULT NOW()
);

INSERT INTO companies (id, name, slug) VALUES
  (0, 'UM Enterprises', 'um'),
  (1, 'Matrix Pharma',  'matrix');

-- ── Departments ──────────────────────────────────────────────
CREATE TABLE departments (
  id            INT PRIMARY KEY,
  name          VARCHAR(100)  NOT NULL,
  code          VARCHAR(20)   NOT NULL UNIQUE,
  company_id    INT           REFERENCES companies(id),
  parent_id     INT           REFERENCES departments(id),
  tier          VARCHAR(20)   NOT NULL CHECK (tier IN ('upper','lower')),
  created_at    TIMESTAMPTZ   DEFAULT NOW()
);

-- Upper management
INSERT INTO departments (id, name, code, company_id, parent_id, tier) VALUES
  (0, 'HR',          'HR',   0, NULL, 'upper'),
  (1, 'Admin',       'ADM',  0, NULL, 'upper'),
  (2, 'IT',          'IT',   1, NULL, 'upper'),
  (3, 'Procurement', 'PROC', 1, NULL, 'upper');

-- Lower departments (UM Enterprises)
INSERT INTO departments (id, name, code, company_id, parent_id, tier) VALUES
  (4, 'LA',      'LA',   0, NULL, 'lower'),
  (5, 'Feed',    'FEED', 0, NULL, 'lower'),
  (6, 'FM',      'FM',   0, NULL, 'lower'),
  (7, 'Drag',    'DRAG', 1, NULL, 'lower'),
  (8, 'Finance', 'FIN',  1, NULL, 'lower');

-- LA sub-departments
INSERT INTO departments (id, name, code, company_id, parent_id, tier) VALUES
  (9,  'LARA', 'LARA', 0, 4, 'lower'),
  (10, 'LAFM', 'LAFM', 0, 4, 'lower'),
  (11, 'LBFM', 'LBFM', 0, 4, 'lower');

-- FM sub-departments
INSERT INTO departments (id, name, code, company_id, parent_id, tier) VALUES
  (12, 'FMAS', 'FMAS', 0, 6, 'lower'),
  (13, 'FMPS', 'FMPS', 0, 6, 'lower'),
  (14, 'FMSG', 'FMSG', 0, 6, 'lower'),
  (15, 'Directors', 'DIR', 0, NULL, 'upper');

-- ── Roles ────────────────────────────────────────────────────
CREATE TABLE roles (
  id   INT PRIMARY KEY,
  name VARCHAR(30) NOT NULL UNIQUE
);

INSERT INTO roles (id, name) VALUES
  (0, 'ceo'),
  (1, 'manager'),
  (2, 'employee');

-- ── Users ────────────────────────────────────────────────────
CREATE TABLE users (
  id            SERIAL PRIMARY KEY,
  name          VARCHAR(100) NOT NULL,
  email         VARCHAR(150) NOT NULL UNIQUE,
  password_hash VARCHAR(255) NOT NULL,
  role_id       INT          NOT NULL REFERENCES roles(id),
  department_id INT          NOT NULL REFERENCES departments(id),
  company_id    INT          NOT NULL REFERENCES companies(id),
  is_active     BOOLEAN      DEFAULT TRUE,
  created_at    TIMESTAMPTZ  DEFAULT NOW()
);

-- ── Tickets ──────────────────────────────────────────────────
CREATE TABLE tickets (
  id                SERIAL PRIMARY KEY,
  title             VARCHAR(255)  NOT NULL,
  description       TEXT          NOT NULL,
  status            VARCHAR(20)   NOT NULL DEFAULT 'open'
                    CHECK (status IN ('open','in_progress','completed','closed')),
  priority          VARCHAR(20)   NOT NULL DEFAULT 'medium'
                    CHECK (priority IN ('low','medium','high','urgent')),

  -- who created it
  created_by_id     INT           NOT NULL REFERENCES users(id),
  created_by_dept   INT           NOT NULL REFERENCES departments(id),

  -- which department it is assigned to
  assigned_dept_id  INT           NOT NULL REFERENCES departments(id),

  -- which individual is working on it (optional self-assign)
  assigned_to_id    INT           REFERENCES users(id),

  -- transfer tracking
  transferred_from  INT           REFERENCES departments(id),
  transferred_at    TIMESTAMPTZ,

  -- close / reopen tracking
  closed_by_id      INT           REFERENCES users(id),
  closed_at         TIMESTAMPTZ,
  reopened_at       TIMESTAMPTZ,
  reopen_count      INT           DEFAULT 0,

  due_date          DATE,
  created_at        TIMESTAMPTZ   DEFAULT NOW(),
  updated_at        TIMESTAMPTZ   DEFAULT NOW()
);

-- ── Ticket Comments ──────────────────────────────────────────
CREATE TABLE ticket_comments (
  id         SERIAL PRIMARY KEY,
  ticket_id  INT         NOT NULL REFERENCES tickets(id) ON DELETE CASCADE,
  user_id    INT         NOT NULL REFERENCES users(id),
  message    TEXT        NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ── Ticket Activity Log ──────────────────────────────────────
CREATE TABLE ticket_logs (
  id          SERIAL PRIMARY KEY,
  ticket_id   INT         NOT NULL REFERENCES tickets(id) ON DELETE CASCADE,
  acted_by_id INT         NOT NULL REFERENCES users(id),
  action      VARCHAR(50) NOT NULL,  -- created | assigned | transferred | status_changed | closed | reopened
  old_value   VARCHAR(100),
  new_value   VARCHAR(100),
  note        TEXT,
  created_at  TIMESTAMPTZ DEFAULT NOW()
);
-- ── Notifications ────────────────────────────────────────────
CREATE TABLE notifications (
  id         SERIAL PRIMARY KEY,
  user_id    INT         NOT NULL REFERENCES users(id),
  ticket_id  INT         REFERENCES tickets(id),
  message    TEXT        NOT NULL,
  is_read    BOOLEAN     DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);


-- ── Indexes ──────────────────────────────────────────────────
CREATE INDEX idx_tickets_dept    ON tickets(assigned_dept_id);
CREATE INDEX idx_tickets_status  ON tickets(status);
CREATE INDEX idx_tickets_creator ON tickets(created_by_id);
CREATE INDEX idx_notifications   ON notifications(user_id, is_read);


-- ── Auto-update updated_at ───────────────────────────────────
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN NEW.updated_at = NOW(); RETURN NEW; END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tickets_updated_at
  BEFORE UPDATE ON tickets
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();
--//OLD 
-- -- ============================================================
-- --  Taskify — Full Database Schema
-- --  Companies: UM Enterprises | Matrix Pharma
-- -- ============================================================

-- -- ── Companies ────────────────────────────────────────────────
-- CREATE TABLE companies (
--   id         SERIAL PRIMARY KEY,
--   name       VARCHAR(100) NOT NULL,
--   slug       VARCHAR(50)  NOT NULL UNIQUE,
--   created_at TIMESTAMPTZ  DEFAULT NOW()
-- );

-- INSERT INTO companies (name, slug) VALUES
--   ('UM Enterprises', 'um'),
--   ('Matrix Pharma',  'matrix');

-- -- ── Departments ──────────────────────────────────────────────
-- CREATE TABLE departments (
--   id            SERIAL PRIMARY KEY,
--   name          VARCHAR(100)  NOT NULL,
--   code          VARCHAR(20)   NOT NULL UNIQUE,
--   company_id    INT           REFERENCES companies(id),
--   parent_id     INT           REFERENCES departments(id),  -- for sub-depts
--   tier          VARCHAR(20)   NOT NULL CHECK (tier IN ('upper','lower')),
--   created_at    TIMESTAMPTZ   DEFAULT NOW()
-- );

-- -- Upper management (shared across both companies)
-- INSERT INTO departments (name, code, company_id, parent_id, tier) VALUES
--   ('HR',          'HR',   NULL, NULL, 'upper'),
--   ('Admin',       'ADM',  NULL, NULL, 'upper'),
--   ('IT',          'IT',   NULL, NULL, 'upper'),
--   ('Procurement', 'PROC', NULL, NULL, 'upper');

-- -- Lower departments (UM Enterprises)
-- INSERT INTO departments (name, code, company_id, parent_id, tier) VALUES
--   ('LA',      'LA',   1, NULL, 'lower'),
--   ('Feed',    'FEED', 1, NULL, 'lower'),
--   ('FM',      'FM',   1, NULL, 'lower'),
--   ('Drag',    'DRAG', 1, NULL, 'lower'),
--   ('Finance', 'FIN',  1, NULL, 'lower');

-- -- LA sub-departments
-- INSERT INTO departments (name, code, company_id, parent_id, tier)
--   SELECT 'LARA', 'LARA', 1, id, 'lower' FROM departments WHERE code = 'LA';
-- INSERT INTO departments (name, code, company_id, parent_id, tier)
--   SELECT 'LAFM', 'LAFM', 1, id, 'lower' FROM departments WHERE code = 'LA';
-- INSERT INTO departments (name, code, company_id, parent_id, tier)
--   SELECT 'LBFM', 'LBFM', 1, id, 'lower' FROM departments WHERE code = 'LA';

-- -- FM sub-departments
-- INSERT INTO departments (name, code, company_id, parent_id, tier)
--   SELECT 'FMAS', 'FMAS', 1, id, 'lower' FROM departments WHERE code = 'FM';
-- INSERT INTO departments (name, code, company_id, parent_id, tier)
--   SELECT 'FMPS', 'FMPS', 1, id, 'lower' FROM departments WHERE code = 'FM';
-- INSERT INTO departments (name, code, company_id, parent_id, tier)
--   SELECT 'FMSG', 'FMSG', 1, id, 'lower' FROM departments WHERE code = 'FM';

-- -- ── Roles ────────────────────────────────────────────────────
-- CREATE TABLE roles (
--   id   SERIAL PRIMARY KEY,
--   name VARCHAR(30) NOT NULL UNIQUE  -- ceo | manager | employee
-- );

-- INSERT INTO roles (name) VALUES ('ceo'), ('manager'), ('employee');

-- -- ── Users ────────────────────────────────────────────────────
-- CREATE TABLE users (
--   id            SERIAL PRIMARY KEY,
--   name          VARCHAR(100) NOT NULL,
--   email         VARCHAR(150) NOT NULL UNIQUE,
--   password_hash VARCHAR(255) NOT NULL,
--   role_id       INT          NOT NULL REFERENCES roles(id),
--   department_id INT          NOT NULL REFERENCES departments(id),
--   company_id    INT          NOT NULL REFERENCES companies(id),
--   is_active     BOOLEAN      DEFAULT TRUE,
--   created_at    TIMESTAMPTZ  DEFAULT NOW()
-- );

-- -- ── Tickets ──────────────────────────────────────────────────
-- CREATE TABLE tickets (
--   id                SERIAL PRIMARY KEY,
--   title             VARCHAR(255)  NOT NULL,
--   description       TEXT          NOT NULL,
--   status            VARCHAR(20)   NOT NULL DEFAULT 'open'
--                     CHECK (status IN ('open','in_progress','completed','closed')),
--   priority          VARCHAR(20)   NOT NULL DEFAULT 'medium'
--                     CHECK (priority IN ('low','medium','high','urgent')),

--   -- who created it
--   created_by_id     INT           NOT NULL REFERENCES users(id),
--   created_by_dept   INT           NOT NULL REFERENCES departments(id),

--   -- which department it is assigned to
--   assigned_dept_id  INT           NOT NULL REFERENCES departments(id),

--   -- which individual is working on it (optional self-assign)
--   assigned_to_id    INT           REFERENCES users(id),

--   -- transfer tracking
--   transferred_from  INT           REFERENCES departments(id),
--   transferred_at    TIMESTAMPTZ,

--   -- close / reopen tracking
--   closed_by_id      INT           REFERENCES users(id),
--   closed_at         TIMESTAMPTZ,
--   reopened_at       TIMESTAMPTZ,
--   reopen_count      INT           DEFAULT 0,

--   due_date          DATE,
--   created_at        TIMESTAMPTZ   DEFAULT NOW(),
--   updated_at        TIMESTAMPTZ   DEFAULT NOW()
-- );

-- -- ── Ticket Comments ──────────────────────────────────────────
-- CREATE TABLE ticket_comments (
--   id         SERIAL PRIMARY KEY,
--   ticket_id  INT         NOT NULL REFERENCES tickets(id) ON DELETE CASCADE,
--   user_id    INT         NOT NULL REFERENCES users(id),
--   message    TEXT        NOT NULL,
--   created_at TIMESTAMPTZ DEFAULT NOW()
-- );

-- -- ── Ticket Activity Log ──────────────────────────────────────
-- CREATE TABLE ticket_logs (
--   id          SERIAL PRIMARY KEY,
--   ticket_id   INT         NOT NULL REFERENCES tickets(id) ON DELETE CASCADE,
--   acted_by_id INT         NOT NULL REFERENCES users(id),
--   action      VARCHAR(50) NOT NULL,  -- created | assigned | transferred | status_changed | closed | reopened
--   old_value   VARCHAR(100),
--   new_value   VARCHAR(100),
--   note        TEXT,
--   created_at  TIMESTAMPTZ DEFAULT NOW()
-- );

-- -- ── Notifications ────────────────────────────────────────────
-- CREATE TABLE notifications (
--   id         SERIAL PRIMARY KEY,
--   user_id    INT         NOT NULL REFERENCES users(id),
--   ticket_id  INT         REFERENCES tickets(id),
--   message    TEXT        NOT NULL,
--   is_read    BOOLEAN     DEFAULT FALSE,
--   created_at TIMESTAMPTZ DEFAULT NOW()
-- );

-- -- ── Indexes ──────────────────────────────────────────────────
-- CREATE INDEX idx_tickets_dept    ON tickets(assigned_dept_id);
-- CREATE INDEX idx_tickets_status  ON tickets(status);
-- CREATE INDEX idx_tickets_creator ON tickets(created_by_id);
-- CREATE INDEX idx_notifications   ON notifications(user_id, is_read);

-- -- ── Auto-update updated_at ───────────────────────────────────
-- CREATE OR REPLACE FUNCTION update_updated_at()
-- RETURNS TRIGGER AS $$
-- BEGIN NEW.updated_at = NOW(); RETURN NEW; END;
-- $$ LANGUAGE plpgsql;

-- CREATE TRIGGER tickets_updated_at
--   BEFORE UPDATE ON tickets
--   FOR EACH ROW EXECUTE FUNCTION update_updated_at();