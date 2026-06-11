-- Generated import script
BEGIN;

-- Create departments for groups that don't exist
DO $$
DECLARE
  next_id INT;
BEGIN
  SELECT COALESCE(MAX(id), 0) + 1 INTO next_id FROM departments;
  IF NOT EXISTS (SELECT 1 FROM departments WHERE UPPER(code) = 'COMBINE STAFF') THEN
    INSERT INTO departments (id, name, code, company_id, parent_id, tier)
    VALUES (next_id, 'COMBINE STAFF', 'COMBINE STAFF', 0, NULL, 'lower');
    next_id := next_id + 1;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM departments WHERE UPPER(code) = 'DXDX') THEN
    INSERT INTO departments (id, name, code, company_id, parent_id, tier)
    VALUES (next_id, 'DXDX', 'DXDX', 0, NULL, 'lower');
    next_id := next_id + 1;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM departments WHERE UPPER(code) = 'FDFD') THEN
    INSERT INTO departments (id, name, code, company_id, parent_id, tier)
    VALUES (next_id, 'FDFD', 'FDFD', 0, NULL, 'lower');
    next_id := next_id + 1;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM departments WHERE UPPER(code) = 'FMAG') THEN
    INSERT INTO departments (id, name, code, company_id, parent_id, tier)
    VALUES (next_id, 'FMAG', 'FMAG', 0, NULL, 'lower');
    next_id := next_id + 1;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM departments WHERE UPPER(code) = 'FMCG') THEN
    INSERT INTO departments (id, name, code, company_id, parent_id, tier)
    VALUES (next_id, 'FMCG', 'FMCG', 0, NULL, 'lower');
    next_id := next_id + 1;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM departments WHERE UPPER(code) = 'FMPG') THEN
    INSERT INTO departments (id, name, code, company_id, parent_id, tier)
    VALUES (next_id, 'FMPG', 'FMPG', 0, NULL, 'lower');
    next_id := next_id + 1;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM departments WHERE UPPER(code) = 'FMSG') THEN
    INSERT INTO departments (id, name, code, company_id, parent_id, tier)
    VALUES (next_id, 'FMSG', 'FMSG', 0, NULL, 'lower');
    next_id := next_id + 1;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM departments WHERE UPPER(code) = 'HOCM') THEN
    INSERT INTO departments (id, name, code, company_id, parent_id, tier)
    VALUES (next_id, 'HOCM', 'HOCM', 0, NULL, 'lower');
    next_id := next_id + 1;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM departments WHERE UPPER(code) = 'HOCM DAILY WAGER') THEN
    INSERT INTO departments (id, name, code, company_id, parent_id, tier)
    VALUES (next_id, 'HOCM DAILY WAGER', 'HOCM DAILY WAGER', 0, NULL, 'lower');
    next_id := next_id + 1;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM departments WHERE UPPER(code) = 'LAFM') THEN
    INSERT INTO departments (id, name, code, company_id, parent_id, tier)
    VALUES (next_id, 'LAFM', 'LAFM', 0, NULL, 'lower');
    next_id := next_id + 1;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM departments WHERE UPPER(code) = 'LARA') THEN
    INSERT INTO departments (id, name, code, company_id, parent_id, tier)
    VALUES (next_id, 'LARA', 'LARA', 0, NULL, 'lower');
    next_id := next_id + 1;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM departments WHERE UPPER(code) = 'LBFM') THEN
    INSERT INTO departments (id, name, code, company_id, parent_id, tier)
    VALUES (next_id, 'LBFM', 'LBFM', 0, NULL, 'lower');
    next_id := next_id + 1;
  END IF;
END $$;

-- Insert users
DO $$
DECLARE
  dept_id INT;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'muhammadnaveedakhtar@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'COMBINE STAFF';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Muhammad Naveed Akhtar', 'muhammadnaveedakhtar@um.com.pk', '10000317', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'rashidaliflow@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'COMBINE STAFF';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Rashid Ali', 'rashidaliflow@um.com.pk', '10000318', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'ghulamabbas@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'COMBINE STAFF';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Ghulam Abbas', 'ghulamabbas@um.com.pk', '10000319', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'imran@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'COMBINE STAFF';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Muhammad Imran', 'imran@um.com.pk', '10000320', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'amirabbas@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'COMBINE STAFF';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Amir Abbas', 'amirabbas@um.com.pk', '10000321', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'majidhussainflow@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'COMBINE STAFF';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Majid Hussain', 'majidhussainflow@um.com.pk', '10000324', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'nasirflow.@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'COMBINE STAFF';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Muhammad Nasir Khan', 'nasirflow.@um.com.pk', '10000322', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'shafqathussain@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'COMBINE STAFF';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Shafqat Hussain', 'shafqathussain@um.com.pk', '10000323', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'adeelshahzadgillflow@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'COMBINE STAFF';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Adeel Shahzad Gill', 'adeelshahzadgillflow@um.com.pk', '10000327', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'asgharflow.@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'COMBINE STAFF';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Asghar', 'asgharflow.@um.com.pk', '10000869', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'farooqmasihflow@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'COMBINE STAFF';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Farooq Masih', 'farooqmasihflow@um.com.pk', '10000329', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'lalvictorflow@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'COMBINE STAFF';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Lal Victor', 'lalvictorflow@um.com.pk', '10000328', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'rafaqatsalamatflow@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'COMBINE STAFF';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Rafaqat Salamat', 'rafaqatsalamatflow@um.com.pk', '10000330', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'yousufmasihflow@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'COMBINE STAFF';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Yousuf Masih', 'yousufmasihflow@um.com.pk', '10000326', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'farhat.perveen@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'DXDX';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Farhat Perveen', 'farhat.perveen@um.com.pk', '10000870', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'yusra.jabbar@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'DXDX';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Yusra', 'yusra.jabbar@um.com.pk', '10000001', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'crm.dx@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'DXDX';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Humais Khan', 'crm.dx@um.com.pk', '10000871', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'hassan.adil@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'DXDX';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Hassan Adil', 'hassan.adil@um.com.pk', '10000010', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'wasaymalik@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'DXDX';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Abdul Wasay Malik', 'wasaymalik@um.com.pk', '10000011', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'sultan@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'DXDX';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Muhammad Sultan', 'sultan@um.com.pk', '10000012', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'scm.ops@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'DXDX';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Muhammad Umair', 'scm.ops@um.com.pk', '10000779', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'mfaisal@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'DXDX';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Muhammad Faisal Khan', 'mfaisal@um.com.pk', '10000648', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'talhasabeelflow@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'DXDX';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Muhammad Talha Sabeel', 'talhasabeelflow@um.com.pk', '10000848', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'shahbaz.akhtar@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'FDFD';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Sheikh Shahbaz Akhtar', 'shahbaz.akhtar@um.com.pk', '10000018', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'khaliq@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'FDFD';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Syed Muhammed Khaliq Uzzaman', 'khaliq@um.com.pk', '10000016', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'haider.ali@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'FDFD';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Haider Ali', 'haider.ali@um.com.pk', '10000019', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'm.zeeshan.@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'FDFD';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Muhammad Zeeshan Khan', 'm.zeeshan.@um.com.pk', '10000739', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'doc@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'FDFD';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Muhammad Faizan', 'doc@um.com.pk', '10000022', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'doc2@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'FDFD';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Zehrish', 'doc2@um.com.pk', '10000023', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'cr@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'FDFD';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Khawaja Aleem Shah', 'cr@um.com.pk', '10000021', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'coordinator.fa@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'FDFD';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Kosain Hanif', 'coordinator.fa@um.com.pk', '10000050', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'procurement.fa@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'FDFD';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Muhammad Saad', 'procurement.fa@um.com.pk', '10000610', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'uzair.saeed@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'FDFD';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Muhammad Uzair', 'uzair.saeed@um.com.pk', '10000048', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'oaf@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'FDFD';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Muhammad Qamar Khan', 'oaf@um.com.pk', '10000632', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'ammar.waseem@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'FDFD';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Muhammad Ammar Waseem', 'ammar.waseem@um.com.pk', '10000047', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'sarfaraz.hussain@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'FDFD';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Muhammad Sarfaraz Hussain', 'sarfaraz.hussain@um.com.pk', '10000046', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'kabeer.alam@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'FDFD';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Kabeer Alam', 'kabeer.alam@um.com.pk', '10000045', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'scm@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'FDFD';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Sajid Mustafa', 'scm@um.com.pk', '10000051', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'adeel.ahmed@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'FDFD';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Adeel Ahmed', 'adeel.ahmed@um.com.pk', '10000056', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'abdulaziz@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'FDFD';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Abdul Aziz', 'abdulaziz@um.com.pk', '10000062', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'dost.muhammad@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'FDFD';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Dost Muhammad', 'dost.muhammad@um.com.pk', '10000055', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'muhammadarshad@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'FDFD';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Muhammad Arshad', 'muhammadarshad@um.com.pk', '10000058', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'tanveerahmedkhanflow@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'FDFD';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Tanveer Ahmed Khan', 'tanveerahmedkhanflow@um.com.pk', '10000059', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'abdulsalamflow@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'FDFD';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Abdul Salam', 'abdulsalamflow@um.com.pk', '10000897', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'imranflow@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'FDFD';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Imran', 'imranflow@um.com.pk', '10000597', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'aliakbar@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'FDFD';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Ali Akbar', 'aliakbar@um.com.pk', '10000061', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'nasirflow@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'FDFD';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Malik Muhammad Nasir Asad', 'nasirflow@um.com.pk', '10000547', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'mushtaq.flow@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'FDFD';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Malik Mushtaq Ahmed', 'mushtaq.flow@um.com.pk', '10000918', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'mastankhan@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'FDFD';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Mastan Khan', 'mastankhan@um.com.pk', '10000057', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'muhammadali@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'FDFD';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Muhammad Ali', 'muhammadali@um.com.pk', '10000065', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'muneerflow@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'FDFD';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Muhammad Muneer', 'muneerflow@um.com.pk', '10000875', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'm.nasirflow@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'FDFD';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Muhammad Nasir', 'm.nasirflow@um.com.pk', '10000860', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'muhammadsameenflow@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'FDFD';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Muhammad Sameen', 'muhammadsameenflow@um.com.pk', '10000060', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'naveed@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'FDFD';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Naveed', 'naveed@um.com.pk', '10000054', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'sadiqali@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'FDFD';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Sadiq Ali', 'sadiqali@um.com.pk', '10000066', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'wazeermuhammad@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'FDFD';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Wazeer Muhammad', 'wazeermuhammad@um.com.pk', '10000052', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'mzohaib@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'FMAG';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Muhammad Zohaib Soomro', 'mzohaib@um.com.pk', '10000068', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'ahmed.sohaib@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'FMAG';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Ahmed Sohaib', 'ahmed.sohaib@um.com.pk', '10000069', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'hasanflow@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'FMAG';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Hasan Ali', 'hasanflow@um.com.pk', '10000904', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'syedanzalaliflow@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'FMAG';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Syed Anzal Ali', 'syedanzalaliflow@um.com.pk', '10000722', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'mohsin.akhlas@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'FMCG';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Mohsin Akhlas', 'mohsin.akhlas@um.com.pk', '10000114', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'safiullah@flow.com') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'FMCG';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Safi Ullah Wasim', 'safiullah@flow.com', '10000812', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'emranfarook@gmail.com') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'FMCG';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Emran Farook', 'emranfarook@gmail.com', '10000565', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'stats.fm@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'FMCG';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Akber Mughal', 'stats.fm@um.com.pk', '10000168', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'owais.najam@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'FMCG';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Owais Najam', 'owais.najam@um.com.pk', '10000115', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'cod.msdz1@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'FMCG';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Tamanna Qasim', 'cod.msdz1@um.com.pk', '10000170', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'masood.ahmed@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'FMCG';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Masood Ahmed', 'masood.ahmed@um.com.pk', '10000113', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'hafeezurrehmanflow@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'FMCG';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Hafeez Ur Rehman', 'hafeezurrehmanflow@um.com.pk', '10000111', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'umair.flow@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'FMCG';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Muhammad Umair', 'umair.flow@um.com.pk', '10000892', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'mohsin.hassan@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'FMCG';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Syed Mohsin Hasan', 'mohsin.hassan@um.com.pk', '10000112', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'abdul.jabbar@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'FMCG';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Abdul Jabbar Khan', 'abdul.jabbar@um.com.pk', '10000121', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'laiqflow@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'FMCG';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Laiq Zada', 'laiqflow@um.com.pk', '10000905', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'muhammadqamar@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'FMCG';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Muhammad Qamar', 'muhammadqamar@um.com.pk', '10000119', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'syedfarooqazamflow@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'FMCG';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Syed Farooq Azam', 'syedfarooqazamflow@um.com.pk', '10000122', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'farhan.jamal@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'FMCG';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Farhan Jamal', 'farhan.jamal@um.com.pk', '10000116', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'aliyaan@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'FMCG';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Aliyaan', 'aliyaan@um.com.pk', '10000125', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'amjadansariflow@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'FMCG';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Amjad Ansari', 'amjadansariflow@um.com.pk', '10000120', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'arsalan@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'FMCG';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Arsalan', 'arsalan@um.com.pk', '10000118', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'hafizfarhan@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'FMCG';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Hafiz Farhan', 'hafizfarhan@um.com.pk', '10000123', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'khansher@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'FMCG';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Khan Sher', 'khansher@um.com.pk', '10000126', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'muhammadfarhanflow@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'FMCG';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Muhammad Farhan', 'muhammadfarhanflow@um.com.pk', '10000124', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'muhammad.sohail@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'FMCG';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Muhammad Sohail', 'muhammad.sohail@um.com.pk', '10000064', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'muhammadwaseemaslamflow@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'FMCG';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Muhammad Waseem Aslam', 'muhammadwaseemaslamflow@um.com.pk', '10000387', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'rehanuddinsiddiquiflow@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'FMCG';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Rehan Uddin Siddiqui', 'rehanuddinsiddiquiflow@um.com.pk', '10000117', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'khalid@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'FMPG';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Khalid Gulab', 'khalid@um.com.pk', '10000128', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'sarfraz.owais@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'FMPG';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Sarfaraz Owais Siddiqui', 'sarfraz.owais@um.com.pk', '10000129', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'arsalan.irshad.msd@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'FMPG';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Muhammad Arsalan Irshad', 'arsalan.irshad.msd@um.com.pk', '10000171', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'noshad.flow@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'FMPG';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Muhammad Noshad Gull', 'noshad.flow@um.com.pk', '10000913', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'vaccination.services@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'FMPG';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Syed Kashif Nayyar Ahmed Jilani', 'vaccination.services@um.com.pk', '10000169', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'm.fahadflow@gmail.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'FMPG';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Muhammad Fahad', 'm.fahadflow@gmail.com.pk', '10000723', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'nauman.siddiqui@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'FMSG';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Nauman Haider Siddiqui', 'nauman.siddiqui@um.com.pk', '10000551', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'humayun.khan@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'FMSG';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Hafiz Humayun Khan', 'humayun.khan@um.com.pk', '10000067', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'm.hunainflow@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'FMSG';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Muhammad Hunain', 'm.hunainflow@um.com.pk', '10000903', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'hussainflow@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'FMSG';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Muhammad Hussain', 'hussainflow@um.com.pk', '10000886', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'ali.inayat@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'HOCM';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Ali Inayat', 'ali.inayat@um.com.pk', '10000277', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'muhammad.siraj@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'HOCM';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Muhammad Siraj', 'muhammad.siraj@um.com.pk', '10000269', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'zaki@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'HOCM';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Muhammad Zaki Uddin Farooqui', 'zaki@um.com.pk', '10000261', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'tariq.khan@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'HOCM';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Tariq Ali Khan', 'tariq.khan@um.com.pk', '10000265', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'naveed.jabbar@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'HOCM';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Muhammad Naveed', 'naveed.jabbar@um.com.pk', '10000278', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'shahfahad@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'HOCM';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Shah Fahad Khan', 'shahfahad@um.com.pk', '10000266', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'ziyad.ashrafi@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'HOCM';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Muhammad Ziyad Ashrafi', 'ziyad.ashrafi@um.com.pk', '10000279', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'adeel.mashkoor@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'HOCM';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Syed Adeel Mashkoor', 'adeel.mashkoor@um.com.pk', '10000273', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'muhammad.arsalan@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'HOCM';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Muhammad Arsalan', 'muhammad.arsalan@um.com.pk', '10000276', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'umer.farooq@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'HOCM';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Muhammad Umer Farooq', 'umer.farooq@um.com.pk', '10000275', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'syedm.ramizflow@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'HOCM';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Syed Muhammad Ramiz', 'syedm.ramizflow@um.com.pk', '10000919', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'wajahatullah@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'HOCM';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Wajahat Ullah Khan', 'wajahatullah@um.com.pk', '10000274', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'shabbir.hussain@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'HOCM';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Shabbir', 'shabbir.hussain@um.com.pk', '10000270', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'sheraz.ahmad@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'HOCM';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Sheraz Ahmad', 'sheraz.ahmad@um.com.pk', '10000262', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'hamidflow.@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'HOCM';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Muhammad Hamid', 'hamidflow.@um.com.pk', '10000889', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'kumail.arif@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'HOCM';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Kumail Arif', 'kumail.arif@um.com.pk', '10000287', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'yaqoobchohanflow@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'HOCM';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Muhammad Yaqoob Chohan', 'yaqoobchohanflow@um.com.pk', '10000301', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'owais.raza@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'HOCM';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Muhammad Owais Raza', 'owais.raza@um.com.pk', '10000284', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'chanzebflow@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'HOCM';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Chanzeb', 'chanzebflow@um.com.pk', '10000348', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'muhammadaslamflow@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'HOCM';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Muhammad Aslam', 'muhammadaslamflow@um.com.pk', '10000303', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'abdurrehman@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'HOCM';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Abdul Rehman', 'abdurrehman@um.com.pk', '10000314', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'muhammadriazhussain@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'HOCM';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Muhammad Riaz Hussain', 'muhammadriazhussain@um.com.pk', '10000282', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'haiderali@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'HOCM';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Haider Ali', 'haiderali@um.com.pk', '10000280', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'muhammadadnan@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'HOCM';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Muhammad Adnan', 'muhammadadnan@um.com.pk', '10000315', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'gulzar.flowahmed@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'HOCM';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Muhammad Gulzaar Ahmed', 'gulzar.flowahmed@um.com.pk', '10000800', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'nooruddin@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'HOCM';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Noor Ud Din', 'nooruddin@um.com.pk', '10000298', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'syedwasihassan@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'HOCM';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Syed Wasi Hassan', 'syedwasihassan@um.com.pk', '10000292', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'huraira.khan@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'HOCM';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Huraira Khan', 'huraira.khan@um.com.pk', '10000306', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'aliramzanflow@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'HOCM';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Ali Ramzan', 'aliramzanflow@um.com.pk', '10000343', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'amnasiddiqui@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'HOCM';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Amna Siddiq', 'amnasiddiqui@um.com.pk', '10000294', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'humeraatiq@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'HOCM';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Humera Atiq', 'humeraatiq@um.com.pk', '10000285', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'owaisahmedkhanflow@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'HOCM';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Owais Ahmed Khan', 'owaisahmedkhanflow@um.com.pk', '10000297', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'muhammadatharkhanflow@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'HOCM';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Muhammad Athar Khan', 'muhammadatharkhanflow@um.com.pk', '10000296', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'muhammadkhurramali@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'HOCM';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Muhammad Khurram Ali', 'muhammadkhurramali@um.com.pk', '10000289', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'umairmaqbool@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'HOCM';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Umair Maqbool', 'umairmaqbool@um.com.pk', '10000281', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'dostmuhammad@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'HOCM';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Dost Muhammad', 'dostmuhammad@um.com.pk', '10000341', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'ghulamrasoolflow@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'HOCM';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Ghulam Rasool', 'ghulamrasoolflow@um.com.pk', '10000344', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'hafizmuhammad@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'HOCM';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Hafiz Muhammad', 'hafizmuhammad@um.com.pk', '10000333', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'ibrahimshahflow@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'HOCM';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Ibrahim Shah', 'ibrahimshahflow@um.com.pk', '10000346', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'safdaraliflow@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'HOCM';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Safdar Ali', 'safdaraliflow@um.com.pk', '10000316', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'zarmalikshahflow@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'HOCM';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Zar Malik Shah', 'zarmalikshahflow@um.com.pk', '10000312', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'rameez.hussain@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'HOCM';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Syed Rameez Hussain', 'rameez.hussain@um.com.pk', '10000371', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'kamran.flow@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'HOCM';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Kamran', 'kamran.flow@um.com.pk', '10000726', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'anwar.manzoor@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'HOCM';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Anwar', 'anwar.manzoor@um.com.pk', '10000763', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'ashfaqgillflow@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'HOCM';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Ashfaq Gill', 'ashfaqgillflow@um.com.pk', '10000628', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'imranayoub@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'HOCM';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Imran Ayoub', 'imranayoub@um.com.pk', '10000304', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'imranpervezflow@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'HOCM';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Imran Pervez', 'imranpervezflow@um.com.pk', '10000313', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'johnsonjozafflow@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'HOCM';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Johnson', 'johnsonjozafflow@um.com.pk', '10000291', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'johnson@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'HOCM';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Johnson', 'johnson@um.com.pk', '10000353', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'kalseydona@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'HOCM';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Kalsey Dona', 'kalseydona@um.com.pk', '10000340', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'kashiflow@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'HOCM';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Kashif', 'kashiflow@um.com.pk', '10000550', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'munirbashirflow@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'HOCM';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Munir Bashir', 'munirbashirflow@um.com.pk', '10000293', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'naveedmasihflow@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'HOCM';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Naveed Masih', 'naveedmasihflow@um.com.pk', '10000336', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'sehoon.joseph@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'HOCM';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Sehoon Joseph', 'sehoon.joseph@um.com.pk', '10000764', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'viki@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'HOCM';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Viki', 'viki@um.com.pk', '10000302', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'muhammadsaqib@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'HOCM';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Muhammad Saqib', 'muhammadsaqib@um.com.pk', '10000300', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'ss@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'HOCM';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Muhammad Shahid Siddiqui', 'ss@um.com.pk', '10000357', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'farhan.saghir@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'HOCM';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Farhan Saghir', 'farhan.saghir@um.com.pk', '10000822', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'rasheed.hr@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'HOCM';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Muhammad Rasheed', 'rasheed.hr@um.com.pk', '10000359', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'adnan.hr@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'HOCM';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Adnan Najeeb', 'adnan.hr@um.com.pk', '10000358', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'azhan.hr@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'HOCM';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Azhan Ahmed Qureshi', 'azhan.hr@um.com.pk', '10000734', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'sufiyan.hr@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'HOCM';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Muhammad Sufiyan', 'sufiyan.hr@um.com.pk', '10000813', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'zia@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'HOCM';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Zia ul Hassan', 'zia@um.com.pk', '10000364', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'amna.khan@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'HOCM';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Amna Khan', 'amna.khan@um.com.pk', '10000363', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'talhabashir@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'HOCM';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Talha Bashir', 'talhabashir@um.com.pk', '10000362', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'import.doc@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'HOCM';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Muhammad Asad Sheikh', 'import.doc@um.com.pk', '10000528', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'faraz.hanif@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'HOCM';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Faraz', 'faraz.hanif@um.com.pk', '10000366', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'qasim.flow@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'HOCM';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Muhammad Qasim Mehmood', 'qasim.flow@um.com.pk', '10000920', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'bilal.ahmed@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'HOCM';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Bilal Ahmed', 'bilal.ahmed@um.com.pk', '10000369', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'it.support@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'HOCM';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Muhammad Fashi Ullah Khan', 'it.support@um.com.pk', '10000368', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'mhamzakhan@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'HOCM';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Muhammad Hamza Khan', 'mhamzakhan@um.com.pk', '10000641', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'yahyaajmalflow@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'HOCM';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Muhammad Yahya Ajmal', 'yahyaajmalflow@um.com.pk', '10000657', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'farrukh.rauf@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'HOCM';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Dilawar Farrukh Rauf', 'farrukh.rauf@um.com.pk', '10000365', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'shahzadriaz@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'HOCM';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Shahzad Riaz', 'shahzadriaz@um.com.pk', '10000013', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'mohsin.chohan@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'HOCM';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Mohsin Ahmed Chohan', 'mohsin.chohan@um.com.pk', '10000373', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'naveedahmed@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'HOCM';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Naveed Ahmed', 'naveedahmed@um.com.pk', '10000372', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'mohammad.farhan@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'HOCM';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Mohammad Farhan', 'mohammad.farhan@um.com.pk', '10000375', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'qamar.flow@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'HOCM';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Qamar Uddin', 'qamar.flow@um.com.pk', '10000915', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'riazhussainflow@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'HOCM';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Riaz Hussain', 'riazhussainflow@um.com.pk', '10000681', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'muhammadyaqoobflow@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'HOCM';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Muhammad Yaqoob', 'muhammadyaqoobflow@um.com.pk', '10000376', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'muhammadafzalflow@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'HOCM';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Muhammad Afzal', 'muhammadafzalflow@um.com.pk', '10000378', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'muhammadghalib@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'HOCM';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Muhammad Ghalib', 'muhammadghalib@um.com.pk', '10000384', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'muhammadsalmansiddiquiflow@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'HOCM';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Muhammad Salman Siddiqui', 'muhammadsalmansiddiquiflow@um.com.pk', '10000379', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'm.sulemanflow@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'HOCM';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Muhammad Suleman', 'm.sulemanflow@um.com.pk', '10000392', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'muhammadubaidsirajflow@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'HOCM';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Muhammad Ubaid Siraj', 'muhammadubaidsirajflow@um.com.pk', '10000382', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'rizwanahmedflow@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'HOCM';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Rizwan Ahmed', 'rizwanahmedflow@um.com.pk', '10000383', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'salmanmalik@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'HOCM';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Salman Malik', 'salmanmalik@um.com.pk', '10000380', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'shahriyar@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'HOCM';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Shahriyar', 'shahriyar@um.com.pk', '10000385', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'shakirullah@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'HOCM';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Shakir Ullah', 'shakirullah@um.com.pk', '10000381', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'mehr.khan@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'HOCM';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Mehr Un Nisa', 'mehr.khan@um.com.pk', '10000399', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'abdul.hafeez@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'HOCM';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Abdul Hafeez', 'abdul.hafeez@um.com.pk', '10000396', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'muhammad.masood@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'HOCM';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Muhammad Masood', 'muhammad.masood@um.com.pk', '10000397', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'mnoman@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'HOCM';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Muhammad Noman', 'mnoman@um.com.pk', '10000627', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'shiraz.silas@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'HOCM';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Shiraz', 'shiraz.silas@um.com.pk', '10000826', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'muhammad.raheel@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'HOCM';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Muhammad Raheel Abbasi', 'muhammad.raheel@um.com.pk', '10000398', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'abdulqayoomflow@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'HOCM';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Abdul Qayoom', 'abdulqayoomflow@um.com.pk', '10000718', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'mehtabaliflow@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'HOCM';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Mehtab Ali', 'mehtabaliflow@um.com.pk', '10000288', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'hunain.ali@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'HOCM';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Hunain Ali', 'hunain.ali@um.com.pk', '10000025', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'sami.khan@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'HOCM';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Muhammad Sami Khan', 'sami.khan@um.com.pk', '10000131', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'miraalflow@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'HOCM';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Miraal Javed', 'miraalflow@um.com.pk', '10000693', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'naimaflow@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'HOCM';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Naima Mukhtar', 'naimaflow@um.com.pk', '10000698', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'khizerflow@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'HOCM';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Khizer Ur Rehman Khan Ghori', 'khizerflow@um.com.pk', '10000796', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'pa.im@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'HOCM';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Muhammad Sohail', 'pa.im@um.com.pk', '10000401', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'azim@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'HOCM';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Muhammad Shamim Azim', 'azim@um.com.pk', '10000400', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'sarfaraz.ahmed@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'HOCM';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Sarfaraz Ahmed Khan', 'sarfaraz.ahmed@um.com.pk', '10000409', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'pkg.store@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'HOCM';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Fazal ur Rehman Khan', 'pkg.store@um.com.pk', '10000408', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'adnanrehmatflow@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'HOCM';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Adnan Rehmat', 'adnanrehmatflow@um.com.pk', '10000407', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'kashmirflow@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'HOCM';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Kashmir', 'kashmirflow@um.com.pk', '10000404', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'muhammadkaleem@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'HOCM';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Muhammad Kaleem', 'muhammadkaleem@um.com.pk', '10000405', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'sikandar@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'HOCM';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Sikandar', 'sikandar@um.com.pk', '10000406', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'ubaidurrehmanflow.@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'HOCM';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Ubaid Ur Rehman', 'ubaidurrehmanflow.@um.com.pk', '10000127', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'waseemakram@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'HOCM';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Waseem Akram', 'waseemakram@um.com.pk', '10000388', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'shams.flow@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'HOCM DAILY WAGER';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Shams Ullah Rafeeq', 'shams.flow@um.com.pk', '10000825', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'aslam.flow@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'HOCM DAILY WAGER';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Aslam Muhammad', 'aslam.flow@um.com.pk', '10000310', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'yousuf.flow@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'HOCM DAILY WAGER';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Yousaf Khan', 'yousuf.flow@um.com.pk', '10000736', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'khalil.flow@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'HOCM DAILY WAGER';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Khalil Akram', 'khalil.flow@um.com.pk', '10000622', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'ali.flow@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'HOCM DAILY WAGER';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Muhammad Ali Hamza', 'ali.flow@um.com.pk', '10000766', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'israfeel.flow@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'HOCM DAILY WAGER';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Muhammad Israfeel Khan', 'israfeel.flow@um.com.pk', '10000705', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'kashif.flow@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'HOCM DAILY WAGER';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Muhammad Kashif', 'kashif.flow@um.com.pk', '10000828', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'nauman.flow@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'HOCM DAILY WAGER';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Muhammad Nauman Malik', 'nauman.flow@um.com.pk', '10000618', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'naveed.flow@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'HOCM DAILY WAGER';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Naveed Ahmed', 'naveed.flow@um.com.pk', '10000704', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'noorflow@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'HOCM DAILY WAGER';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Noor Alam', 'noorflow@um.com.pk', '10000746', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'shafi.flow@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'HOCM DAILY WAGER';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Shafi Muhammad', 'shafi.flow@um.com.pk', '10000700', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'shaman.flow@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'HOCM DAILY WAGER';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Shaman', 'shaman.flow@um.com.pk', '10000702', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'waqas.flow@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'HOCM DAILY WAGER';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Waqas', 'waqas.flow@um.com.pk', '10000063', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'waseem.flow@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'HOCM DAILY WAGER';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Waseem Ahmed', 'waseem.flow@um.com.pk', '10000623', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'saqibkhanflow@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'HOCM DAILY WAGER';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Saqib Khan', 'saqibkhanflow@um.com.pk', '10000851', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'hamza.khan@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'LAFM';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Hamza Ali Khan', 'hamza.khan@um.com.pk', '10000492', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'boviteam@gmail.com') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'LAFM';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Ammar Malik', 'boviteam@gmail.com', '10000490', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'cod.la@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'LAFM';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Muhammad Aziz Ur Rehman', 'cod.la@um.com.pk', '10000493', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'waqas.saleem@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'LAFM';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Muhammad Waqas Saleem', 'waqas.saleem@um.com.pk', '10000491', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'cod.la2@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'LAFM';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Sufyan Malik', 'cod.la2@um.com.pk', '10000494', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'muzammilflow@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'LAFM';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Syed Muzammil Ali', 'muzammilflow@um.com.pk', '10000852', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'abdulflow.@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'LAFM';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Abdul Muqeet', 'abdulflow.@um.com.pk', '10000742', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'abdul.wahabflow@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'LAFM';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Abdul Wahab', 'abdul.wahabflow@um.com.pk', '10000854', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'adnanhafeezflow@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'LAFM';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Adnan Hafeez', 'adnanhafeezflow@um.com.pk', '10000858', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'muhammad.aliflow@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'LAFM';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Muhammad Ali', 'muhammad.aliflow@um.com.pk', '10000855', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'm.sufyanflow@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'LAFM';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Muhammad Sufyan', 'm.sufyanflow@um.com.pk', '10000857', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'm.waqarflow.@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'LAFM';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Muhammad Waqar', 'm.waqarflow.@um.com.pk', '10000861', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'muheetflow.@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'LAFM';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Muheet', 'muheetflow.@um.com.pk', '10000890', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'sameerflow@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'LAFM';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Sameer', 'sameerflow@um.com.pk', '10000853', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'tahirflow@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'LAFM';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Tahir Imam Bukhsh', 'tahirflow@um.com.pk', '10000620', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'zubairflow@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'LAFM';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Zubair Ahmed', 'zubairflow@um.com.pk', '10000856', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'ghalib.akhter@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'LARA';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Ghalib Akhter Saleemi', 'ghalib.akhter@um.com.pk', '10000495', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'faisal.shahab@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'LARA';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Faisal Shahab', 'faisal.shahab@um.com.pk', '10000513', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'saqib.shamim@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'LARA';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Muhammad Saqib Shamim', 'saqib.shamim@um.com.pk', '10000516', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'hammadali@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'LARA';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Hammad Ali', 'hammadali@um.com.pk', '10000902', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'irfan.baloch@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'LARA';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Irfan Baloch', 'irfan.baloch@um.com.pk', '10000053', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'muhammadramizhussainflow@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'LARA';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Muhammad Ramiz Hussain', 'muhammadramizhussainflow@um.com.pk', '10000519', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'sabirkhan@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'LARA';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Sabir Khan', 'sabirkhan@um.com.pk', '10000517', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'sherinkhan@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'LARA';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Sherin Khan', 'sherinkhan@um.com.pk', '10000518', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'cod.la3@um.com.pk') THEN
    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = 'LBFM';
    IF dept_id IS NOT NULL THEN
      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
      VALUES ('Fareed Ahmed Soomro', 'cod.la3@um.com.pk', '10000797', '$2b$12$30fH2wW0T4fetbHpahdLVO1qFmiogECJRR1cg3IpIbckmnT0VbpXe', 2, dept_id, 0, TRUE, TRUE);
    END IF;
  END IF;
END $$;

COMMIT;