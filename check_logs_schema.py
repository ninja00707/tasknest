import psycopg2
conn = psycopg2.connect(host='localhost', dbname='taskify', user='postgres', password='Qasim@11')
cur = conn.cursor()
cur.execute("SELECT column_name, data_type FROM information_schema.columns WHERE table_name='ticket_logs' ORDER BY ordinal_position")
for r in cur.fetchall():
    print(f'{r[0]:20s} {r[1]}')
cur.close()
conn.close()
