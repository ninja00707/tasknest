@echo off
setlocal

:: Find the latest backup file
for /f "delims=" %%i in ('dir "D:\Users\Qasim\Documents\GitHub\tasknest\Backups\taskify_backup_*.sql" /b /o-d') do set "backup=%%i" & goto found
echo No backup file found!
pause
exit /b

:found
set "fullpath=D:\Users\Qasim\Documents\GitHub\tasknest\Backups\%backup%"
echo Using: %backup%

set PGPASSWORD=Qasim@11
C:\"Program Files\PostgreSQL\18\bin\psql.exe" -U postgres -h localhost -p 5432 -c "SELECT pg_terminate_backend(pg_stat_activity.pid) FROM pg_stat_activity WHERE pg_stat_activity.datname = 'taskify' AND pid <> pg_backend_pid();" -c "DROP DATABASE IF EXISTS taskify;" -c "CREATE DATABASE taskify WITH TEMPLATE template0;"
C:\"Program Files\PostgreSQL\18\bin\psql.exe" -U postgres -h localhost -p 5432 -d taskify -f "%fullpath%" -q
echo Done! Press any key.
pause
