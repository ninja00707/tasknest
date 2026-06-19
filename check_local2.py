import psycopg2
conn = psycopg2.connect(host='localhost', dbname='taskify', user='postgres', password='Qasim@11')
cur = conn.cursor()
cur.execute("SELECT company_id, department_id, COUNT(*) FROM users WHERE department_id IN (75,79,87,50) GROUP BY company_id, department_id ORDER BY company_id, department_id")
for r in cur.fetchall():
    print(f"  company={r[0]}  dept={r[1]:>3}: {r[2]} users")
cur.execute("SELECT d.id, d.name, u.cnt FROM (SELECT department_id, COUNT(*) as cnt FROM users WHERE company_id=1 GROUP BY department_id) u JOIN departments d ON d.id=u.department_id ORDER BY u.cnt DESC")
print("\nMX users by department:")
for r in cur.fetchall():
    print(f"  dept={r[0]:>3} {r[1]:-<40s} {r[2]} users")
cur.close()
conn.close()
