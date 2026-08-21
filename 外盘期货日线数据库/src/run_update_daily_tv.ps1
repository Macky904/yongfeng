# Windows Task Scheduler launcher for the foreign futures daily updater.
# Keep executable strings ASCII-only for Windows PowerShell 5 encoding compatibility.

$ErrorActionPreference = 'Stop'
$baseDir = Split-Path -Parent $PSCommandPath
$logDir = Join-Path (Split-Path -Parent $baseDir) 'logs'
$logPath = Join-Path $logDir ("update_daily_tv_launcher_{0}.log" -f (Get-Date -Format 'yyyy-MM-dd'))

New-Item -ItemType Directory -Path $logDir -Force | Out-Null

function Write-LauncherLog([string]$message) {
    $line = "{0} {1}" -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'), $message
    Add-Content -LiteralPath $logPath -Value $line -Encoding utf8
}

try {
    $env:DATABASE_URL = [Environment]::GetEnvironmentVariable('DATABASE_URL', 'User')
    $env:HTTPS_PROXY = [Environment]::GetEnvironmentVariable('HTTPS_PROXY', 'User')
    $env:HTTP_PROXY = [Environment]::GetEnvironmentVariable('HTTP_PROXY', 'User')

    if ([string]::IsNullOrWhiteSpace($env:DATABASE_URL)) {
        throw 'DATABASE_URL user environment variable is missing.'
    }

    $python = 'C:\Users\Macky\.workbuddy\binaries\python\envs\default\Scripts\python.exe'
    $script = Join-Path $baseDir 'update_daily_tv.py'
    if (-not (Test-Path -LiteralPath $python)) { throw "Python not found: $python" }
    if (-not (Test-Path -LiteralPath $script)) { throw "Updater not found: $script" }

    Write-LauncherLog 'START: configuration loaded; launching updater.'
    # The updater maintains its own UTF-8 file log.  Do not redirect native
    # stderr here: Windows PowerShell 5 writes redirected native output as
    # UTF-16 and makes diagnostic logs unreadable.
    & $python $script
    $exitCode = $LASTEXITCODE
    Write-LauncherLog "DONE: updater exit_code=$exitCode"
    exit $exitCode
}
catch {
    Write-LauncherLog ("FAILED: " + $_.Exception.Message)
    exit 1
}
