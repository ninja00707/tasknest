$backupDir = "D:\taskify\database_backup"
$timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm"
$filename = "taskify_backup_$timestamp.sql"
$filepath = Join-Path $backupDir $filename

if (!(Test-Path $backupDir)) { New-Item -ItemType Directory -Path $backupDir -Force | Out-Null }

$env:PGPASSWORD = "Qasim@11"
& "C:\Program Files\PostgreSQL\18\bin\pg_dump.exe" -U postgres -h localhost -p 5432 -d taskify --format=p --file $filepath
Remove-Item Env:PGPASSWORD

if ($LASTEXITCODE -eq 0) {
    Write-Output "Backup saved: $filepath"
    $size = (Get-Item $filepath).Length / 1MB
    Write-Output "Size: $([math]::Round($size, 2)) MB"

    $maxAge = 30
    Get-ChildItem $backupDir -Filter "taskify_backup_*.sql" | Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-$maxAge) } | Remove-Item -Force
    Write-Output "Removed backups older than $maxAge days"
} else {
    Write-Output "Backup FAILED"
    exit 1
}