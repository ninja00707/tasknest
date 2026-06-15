import openpyxl
import re

wb = openpyxl.load_workbook(r'D:\Users\Qasim\Desktop\Updated Matrix EmployeeList.xlsx')
ws = wb.active
data = []
for row in ws.iter_rows(min_row=4, max_row=ws.max_row, values_only=True):
    if row[0] is not None:
        data.append(row)

# Dept ID 200+ for MX-specific, 50=Admin (Combine Staff), 79=IT
dept_map = {
    'Admin': 50,
    'IT': 79,
}
shared_dept_ids = [50, 79]

# Map other departments (excluding Admin/IT)
seen = set()
depts_in_order = []
for r in data:
    d = r[4]
    if d not in dept_map and d not in seen:
        depts_in_order.append(d)
        seen.add(d)

next_id = 200
for d in depts_in_order:
    dept_map[d] = next_id
    next_id += 1

# Generate unique department codes
dept_codes = {}
for d, did in sorted(dept_map.items(), key=lambda x: x[1]):
    if did in shared_dept_ids:
        continue  # existing dept, no need to create
    parts = d.split()
    if len(parts) == 1:
        code = parts[0][:5].upper()
    elif len(parts) == 2:
        code = (parts[0][:3] + parts[1][:3]).upper()
    else:
        code = ''.join(p[0] for p in parts[:4]).upper()
    base = code
    suffix = 1
    while code in dept_codes.values():
        code = base + str(suffix)
        suffix += 1
    dept_codes[d] = code

def get_role_id(desig):
    if desig in ('Chairman', 'Chief Executive Officer'):
        return 0
    if any(k in desig for k in ['Manager', 'Deputy', 'Head Of', 'Supervisor', ' Incharge', 'Senior']):
        return 1
    if desig.startswith('GM') or desig.startswith('General Manager'):
        return 1
    return 2

lines = []
lines.append("-- ============================================================")
lines.append("--  Matrix Pharma Migration - Departments + 148 Employees")
lines.append("-- ============================================================")
lines.append("BEGIN;")
lines.append("")
lines.append("-- 1. Add is_shared column to departments")
lines.append("ALTER TABLE departments ADD COLUMN IF NOT EXISTS is_shared BOOLEAN DEFAULT FALSE;")
lines.append("")
lines.append("-- 2. Mark Administration [Combine Staff] (50) and IT [HOCM] (79) as shared")
lines.append("UPDATE departments SET is_shared = TRUE WHERE id IN (50, 79);")
lines.append("")

lines.append("-- 3. Create Matrix Pharma-specific departments (company_id=1)")
for d in depts_in_order:
    did = dept_map[d]
    lines.append(f"INSERT INTO departments (id, name, code, company_id, parent_id, tier, is_shared) VALUES ({did}, '{d}', '{dept_codes[d]}', 1, NULL, 'lower', FALSE) ON CONFLICT (id) DO NOTHING;")
lines.append("")

pw = "$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq"

lines.append("-- 4. Import Matrix Pharma employees (company_id=1, password: UM@2024)")
for row in data:
    sno, code, name, desig, dept, join_date, report_to, mobile, group_, email, gender, cnic = row
    role_id = get_role_id(desig)
    dept_id = dept_map[dept]
    email_clean = email.replace("'", "''") if email else ""
    name_clean = name.replace("'", "''")
    lines.append(f"INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password) SELECT '{name_clean}', '{email_clean}', '{code}', '{pw}', {role_id}, {dept_id}, 1, TRUE, TRUE WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = '{email_clean}');")

lines.append("")
lines.append("-- 5. Set designations for Matrix Pharma employees")
for row in data:
    sno, code, name, desig, dept, join_date, report_to, mobile, group_, email, gender, cnic = row
    if desig:
        desig_clean = desig.replace("'", "''")
        lines.append(f"UPDATE users SET designation = '{desig_clean}' WHERE code = '{code}';")
lines.append("")

lines.append("-- 6. Set reports_to hierarchy for Matrix Pharma")
for row in data:
    sno, code, name, desig, dept, join_date, report_to, mobile, group_, email, gender, cnic = row
    if report_to and report_to != '-':
        match = re.search(r'\((\d+)\)', report_to)
        if match:
            mgr_code = match.group(1)
            lines.append(f"UPDATE users SET reports_to = (SELECT id FROM users WHERE code = '{mgr_code}') WHERE code = '{code}';")
lines.append("")

lines.append("COMMIT;")

output = "\n".join(lines)
outpath = r"D:\Users\Qasim\Documents\GitHub\tasknest\taskify-backend\database\migration_matrix.sql"
with open(outpath, "w") as f:
    f.write(output)

roles = {}
for row in data:
    r = get_role_id(row[3])
    roles[r] = roles.get(r, 0) + 1

print(f"Generated {outpath}")
print(f"MX-specific departments: {len(depts_in_order)} (IDs {min(dept_map.values())}-{max(dept_map.values())})")
print(f"Shared: Admin(Combine Staff)->50, IT[HOCM]->79")
print(f"Employees: {len(data)}")
print(f"  CEO (0): {roles.get(0, 0)}, Manager (1): {roles.get(1, 0)}, Employee (2): {roles.get(2, 0)}")
