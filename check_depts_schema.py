import psycopg2
conn = psycopg2.connect(host='localhost', dbname='taskify', user='postgres', password='Qasim@11')
cur = conn.cursor()
cur.execute("SELECT column_name, data_type, character_maximum_length, is_nullable, column_default FROM information_schema.columns WHERE table_name='departments' ORDER BY ordinal_position")
for r in cur.fetchall():
    print(f'{r[0]:25s} {r[1]:15s} len={r[2]} nullable={r[3]} default={r[4]}')
cur.close()
conn.close()
