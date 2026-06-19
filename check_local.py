import psycopg2
conn = psycopg2.connect(host='localhost', dbname='taskify', user='postgres', password='Qasim@11')
cur = conn.cursor()
cur.execute("SELECT id, name, is_shared FROM departments WHERE id IN (50,75,79,87) ORDER BY id")
for r in cur.fetchall():
    print(f"  id={r[0]:>3}  {r[1]:-<45s} shared={r[2]}")
cur.execute("SELECT company_id, COUNT(*) FROM users GROUP BY company_id ORDER BY company_id")
print()
for r in cur.fetchall():
    print(f"  Company {r[0]}: {r[1]} users")
cur.close()
conn.close()
