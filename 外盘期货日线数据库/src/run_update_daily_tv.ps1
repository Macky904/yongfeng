# 外盘日线任务启动器：由 Windows 任务计划程序调用。
# 显式从当前 Windows 用户环境读取配置，避免任务进程未继承环境变量而静默退出。

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
        throw 'Windows 用户环境变量 DATABASE_URL 未设置。'
    }

    $python = 'C:\Users\Macky\.workbuddy\binaries\python\envs\default\Scripts\python.exe'
    $script = Join-Path $baseDir 'update_daily_tv.py'
    if (-not (Test-Path -LiteralPath $python)) { throw "Python 不存在：$python" }
    if (-not (Test-Path -LiteralPath $script)) { throw "更新脚本不存在：$script" }

    Write-LauncherLog 'START: configuration loaded; launching foreign futures updater.'
    & $python $script
    $exitCode = $LASTEXITCODE
    Write-LauncherLog "DONE: updater exit_code=$exitCode"
    exit $exitCode
}
catch {
    Write-LauncherLog ("FAILED: " + $_.Exception.Message)
    exit 1
}
