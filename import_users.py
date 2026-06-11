import openpyxl
import bcrypt

EXCEL_PATH = r"D:\Users\Qasim\Desktop\EmployeeList Headoffice (05-06-26).xlsx"
DEFAULT_PASSWORD = "UM@2024"

# Pre-compute bcrypt hash
HASHED_PW = bcrypt.hashpw(DEFAULT_PASSWORD.encode('utf-8'), bcrypt.gensalt()).decode('utf-8')
print(f"Using password hash: {HASHED_PW[:30]}...")

wb = openpyxl.load_workbook(EXCEL_PATH, data_only=True)
ws = wb.active

# Collect user rows and unique groups
users = []
groups_seen = set()

for r in range(5, ws.max_row + 1):
    code = ws.cell(r, 2).value
    name = ws.cell(r, 3).value
    dept_name = ws.cell(r, 5).value
    group_code = ws.cell(r, 8).value
    email = ws.cell(r, 9).value

    if not email or not name:
        continue

    email = str(email).strip().lower()
    name = str(name).strip()
    group_code = str(group_code).strip().upper() if group_code else ""

    if group_code:
        groups_seen.add(group_code)

    code_str = str(int(code)) if code else ""
    users.append({
        "name": name,
        "group_code": group_code,
        "email": email,
        "code": code_str,
    })

# We'll use a simple hash placeholder - real hashing happens on the server
# The password will be set to DEFAULT_PASSWORD using bcrypt via the server script

# Generate SQL
sql_lines = []
sql_lines.append("-- Generated import script")
sql_lines.append("BEGIN;")
sql_lines.append("")

# Get existing departments
sql_lines.append("-- Create departments for groups that don't exist")
sql_lines.append("DO $$")
sql_lines.append("DECLARE")
sql_lines.append("  next_id INT;")
sql_lines.append("BEGIN")
sql_lines.append("  SELECT COALESCE(MAX(id), 0) + 1 INTO next_id FROM departments;")

for gc in sorted(groups_seen):
    code = gc[:20]
    sql_lines.append(f"  IF NOT EXISTS (SELECT 1 FROM departments WHERE UPPER(code) = '{code}') THEN")
    sql_lines.append(f"    INSERT INTO departments (id, name, code, company_id, parent_id, tier)")
    sql_lines.append(f"    VALUES (next_id, '{gc}', '{code}', 0, NULL, 'lower');")
    sql_lines.append(f"    next_id := next_id + 1;")
    sql_lines.append(f"  END IF;")

sql_lines.append("END $$;")
sql_lines.append("")

# Insert users (skip existing by email)
sql_lines.append("-- Insert users")
sql_lines.append("DO $$")
sql_lines.append("DECLARE")
sql_lines.append("  dept_id INT;")
sql_lines.append("BEGIN")

for u in users:
    if not u["group_code"]:
        continue
    name_escaped = u["name"].replace("'", "''")
    email_escaped = u["email"].replace("'", "''")
    group_code_upper = u["group_code"][:20]
    emp_code = u["code"]

    if not emp_code:
        continue

    sql_lines.append(f"  IF NOT EXISTS (SELECT 1 FROM users WHERE email = '{email_escaped}') THEN")
    sql_lines.append(f"    SELECT id INTO dept_id FROM departments WHERE UPPER(code) = '{group_code_upper}';")
    sql_lines.append(f"    IF dept_id IS NOT NULL THEN")
    sql_lines.append(f"      INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)")
    sql_lines.append(f"      VALUES ('{name_escaped}', '{email_escaped}', '{emp_code}', '{HASHED_PW}', 2, dept_id, 0, TRUE, TRUE);")
    sql_lines.append(f"    END IF;")
    sql_lines.append(f"  END IF;")

sql_lines.append("END $$;")
sql_lines.append("")
sql_lines.append("COMMIT;")

sql = "\n".join(sql_lines)

# Write SQL file
output_path = r"D:\Users\Qasim\Documents\GitHub\tasknest\import_users.sql"
with open(output_path, "w", encoding="utf-8") as f:
    f.write(sql)

print(f"SQL file written to: {output_path}")
print(f"Total users to import: {len([u for u in users if u['group_code']])}")
print(f"Groups found: {len(groups_seen)}")
