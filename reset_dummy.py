import psycopg2
conn = psycopg2.connect(host='localhost', dbname='taskify', user='postgres', password='Qasim@11')
cur = conn.cursor()
cur.execute("SELECT table_name FROM information_schema.tables WHERE table_schema='public' AND table_type='BASE TABLE' ORDER BY table_name")
tables = [r[0] for r in cur.fetchall()]
for t in tables:
    cur.execute(f'SELECT COUNT(*) FROM "{t}"')
    cnt = cur.fetchone()[0]
    print(f'{t}: {cnt} rows')
print()
cur.execute("""
SELECT
    tc.table_name,
    kcu.column_name,
    ccu.table_name AS foreign_table_name,
    ccu.column_name AS foreign_column_name
FROM information_schema.table_constraints tc
JOIN information_schema.key_column_usage kcu ON tc.constraint_name = kcu.constraint_name
JOIN information_schema.constraint_column_usage ccu ON ccu.constraint_name = tc.constraint_name
WHERE tc.constraint_type = 'FOREIGN KEY'
ORDER BY tc.table_name, kcu.column_name
""")
for r in cur.fetchall():
    print(f'{r[0]}.{r[1]} -> {r[2]}.{r[3]}')
cur.close()
conn.close()
