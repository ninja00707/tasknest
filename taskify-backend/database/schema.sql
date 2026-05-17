-- Database Schema for Task Management System

CREATE TABLE IF NOT EXISTS companies (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS departments (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    company_id INTEGER REFERENCES companies(id) ON DELETE CASCADE,
    parent_department_id INTEGER REFERENCES departments(id) ON DELETE CASCADE,
    is_shared BOOLEAN DEFAULT FALSE -- Flag for shared departments like HR/IT
);

-- If users table already exists from previous steps, we alter it to add new columns.
-- We use a DO block to safely add columns if they don't exist in PostgreSQL.
DO $$ 
BEGIN
    BEGIN
        ALTER TABLE users ADD COLUMN name VARCHAR(255);
    EXCEPTION WHEN duplicate_column THEN END;
    
    BEGIN
        ALTER TABLE users ADD COLUMN company_id INTEGER REFERENCES companies(id);
    EXCEPTION WHEN duplicate_column THEN END;
    
    BEGIN
        ALTER TABLE users ADD COLUMN department_id INTEGER REFERENCES departments(id);
    EXCEPTION WHEN duplicate_column THEN END;
    
    BEGIN
        ALTER TABLE users ADD COLUMN role VARCHAR(50) DEFAULT 'user'; -- 'user', 'manager', 'ceo'
    EXCEPTION WHEN duplicate_column THEN END;
END $$;

CREATE TABLE IF NOT EXISTS tickets (
    id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    creator_id INTEGER NOT NULL REFERENCES users(id),
    target_department_id INTEGER NOT NULL REFERENCES departments(id),
    company_id INTEGER NOT NULL REFERENCES companies(id),
    assignee_id INTEGER REFERENCES users(id),
    status VARCHAR(50) DEFAULT 'open', -- 'open', 'in_progress', 'closed'
    reopen_count INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    closed_at TIMESTAMP
);

-- Pre-seed some initial companies
INSERT INTO companies (name) VALUES ('UM Enterprises'), ('Matrix Pharma') ON CONFLICT DO NOTHING;
