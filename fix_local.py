import psycopg2
conn = psycopg2.connect(host='localhost', dbname='taskify', user='postgres', password='Qasim@11')
cur = conn.cursor()

# Move MX Admin users from dept 75 to dept 87
cur.execute("UPDATE users SET department_id = 87 WHERE company_id = 1 AND department_id = 75")
print(f"Moved MX Admin users: {cur.rowcount}")

# Fix is_shared flags
cur.execute("UPDATE departments SET is_shared = FALSE WHERE id = 75")
print(f"Dept 75 is_shared=FALSE: {cur.rowcount}")
cur.execute("UPDATE departments SET is_shared = TRUE WHERE id = 87")
print(f"Dept 87 is_shared=TRUE: {cur.rowcount}")

conn.commit()
cur.close()
conn.close()
print("Done")
