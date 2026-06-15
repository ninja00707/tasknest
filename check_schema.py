import psycopg2
conn = psycopg2.connect(host='localhost', dbname='taskify', user='postgres', password='Qasim@11')
cur = conn.cursor()
cur.execute("SELECT id, name, code FROM departments ORDER BY id")
depts = cur.fetchall()
for d in depts:
    print(f"  {d[0]:>3}  {d[1]:-<40s} {d[2]}")
cur.execute("SELECT id, name, email, code, role_id FROM users ORDER BY id LIMIT 5")
users = cur.fetchall()
print()
for u in users:
    print(f"  {u[0]:>3}  {u[1]:-<30s} {u[2]}  code={u[3]}  role={u[4]}")
cur.execute("SELECT id, name FROM roles ORDER BY id")
roles = cur.fetchall()
print()
for r in roles:
    print(f"  {r[0]:>3}  {r[1]}")
cur.close()
conn.close()
