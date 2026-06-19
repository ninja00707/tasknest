f = open(r'D:\Users\Qasim\Documents\GitHub\tasknest\taskify-backend\database\migration_matrix.sql', 'r')
lines = f.readlines()
# Print dept mapping section
for i, l in enumerate(lines):
    if 'shared' in l.lower() or 'Admin' in l:
        print(f'Line {i+1}: {l.rstrip()[:120]}')
f.close()
