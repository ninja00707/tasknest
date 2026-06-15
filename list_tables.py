import psycopg2
conn = psycopg2.connect(host='localhost', dbname='taskify', user='postgres', password='Qasim@11')
cur = conn.cursor()
cur.execute("SELECT table_name FROM information_schema.tables WHERE table_schema='public' AND table_type='BASE TABLE' ORDER BY table_name")
for r in cur.fetchall():
    print(r[0])
cur.close()
conn.close()
