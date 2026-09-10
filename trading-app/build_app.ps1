$ErrorActionPreference = "Stop"
$src = "$PSScriptRoot\ai_trader"
$dst = "C:\ait"

if (-not (Test-Path $dst)) { New-Item -ItemType Directory -Path $dst | Out-Null }

robocopy "$src\lib" "$dst\lib" /MIR /NFL /NDL /NJH /NJS | Out-Null
robocopy "$src\windows" "$dst\windows" /MIR /NFL /NDL /NJH /NJS /XD build x64 CMakeFiles | Out-Null
if (Test-Path "$src\test") { robocopy "$src\test" "$dst\test" /MIR /NFL /NDL /NJH /NJS | Out-Null }
Copy-Item "$src\pubspec.yaml" $dst -Force
Copy-Item "$src\pubspec.lock" $dst -Force -ErrorAction SilentlyContinue
Copy-Item "$src\analysis_options.yaml" $dst -Force

Push-Location $dst
try {
    Get-Process ai_trader -ErrorAction SilentlyContinue | Stop-Process -Force
    Start-Sleep 1
    $env:_CL_ = "/D_SILENCE_EXPERIMENTAL_COROUTINE_DEPRECATION_WARNINGS"
    if (-not ($env:Path -like "*ait_tools*")) { $env:Path = "C:\ait_tools;$env:Path" }
    flutter pub get
    if ($LASTEXITCODE -ne 0) { throw "pub get failed" }
    flutter build windows --debug
    if ($LASTEXITCODE -ne 0) { throw "build failed" }
} finally {
    Pop-Location
}

Write-Host "`nBuild OK: C:\ait\build\windows\x64\runner\Debug\ai_trader.exe"
Start-Process "$dst\build\windows\x64\runner\Debug\ai_trader.exe"
Write-Host "App launched."
