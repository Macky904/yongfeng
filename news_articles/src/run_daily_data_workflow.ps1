# Daily sequential data workflow for Windows Task Scheduler.
# The script is ASCII-only to remain compatible with Windows PowerShell 5.

$ErrorActionPreference = 'Stop'
$root = 'D:\yongfeng'
$newsSrc = Join-Path $root 'news_articles\src'
$logDir = Join-Path $root 'news_articles\logs'
$logPath = Join-Path $logDir ("daily_data_workflow_{0}.log" -f (Get-Date -Format 'yyyy-MM-dd'))
$retrySeconds = 600

New-Item -ItemType Directory -Path $logDir -Force | Out-Null

function Write-WorkflowLog([string]$message) {
    Add-Content -LiteralPath $logPath -Encoding utf8 -Value ("{0} {1}" -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'), $message)
}

function Load-UserEnvironment {
    $env:DATABASE_URL = [Environment]::GetEnvironmentVariable('DATABASE_URL', 'User')
    $env:HTTPS_PROXY = [Environment]::GetEnvironmentVariable('HTTPS_PROXY', 'User')
    $env:HTTP_PROXY = [Environment]::GetEnvironmentVariable('HTTP_PROXY', 'User')
    $env:TWS_PROXY = [Environment]::GetEnvironmentVariable('TWS_PROXY', 'User')
    foreach ($name in @('REPORT_SMTP_PASSWORD', 'REPORT_EMAIL_TO', 'REPORT_EMAIL_FROM', 'REPORT_SMTP_HOST', 'REPORT_SMTP_PORT')) {
        $value = [Environment]::GetEnvironmentVariable($name, 'User')
        if (-not [string]::IsNullOrWhiteSpace($value)) {
            Set-Item -Path ("Env:" + $name) -Value $value
        }
    }
    if ([string]::IsNullOrWhiteSpace($env:DATABASE_URL)) {
        throw 'DATABASE_URL user environment variable is missing.'
    }
}

$managedPython = 'C:\Users\Macky\.workbuddy\binaries\python\envs\default\Scripts\python.exe'
$hedgingPython = 'C:\Users\Macky\AppData\Local\hermes\hermes-agent\venv\Scripts\python.exe'
$steps = @(
    @{ Name = 'hedging'; Python = $hedgingPython; Script = Join-Path $root '套期保值hedging_announcements\src\04_incremental_update_postgres.py'; WorkDir = Join-Path $root '套期保值hedging_announcements\src' },
    @{ Name = 'options'; Python = $managedPython; Script = Join-Path $newsSrc '04_crawl_option_daily.py'; WorkDir = $newsSrc },
    @{ Name = 'foreign_futures'; Python = $managedPython; Script = Join-Path $root '外盘期货日线数据库\src\update_daily_tv.py'; WorkDir = Join-Path $root '外盘期货日线数据库\src' },
    @{ Name = 'news'; Python = $managedPython; Script = Join-Path $newsSrc 'run_daily_news.py'; WorkDir = $newsSrc }
)

try {
    Load-UserEnvironment
    foreach ($step in $steps) {
        if (-not (Test-Path -LiteralPath $step.Python)) { throw "Python not found for $($step.Name)" }
        if (-not (Test-Path -LiteralPath $step.Script)) { throw "Script not found for $($step.Name)" }
    }
}
catch {
    Write-WorkflowLog ("FATAL: " + $_.Exception.Message)
    exit 1
}

$attempt = 0
while ($true) {
    $attempt++
    $failed = @()
    Write-WorkflowLog "ATTEMPT=$attempt START"
    foreach ($step in $steps) {
        Write-WorkflowLog "STEP=$($step.Name) START"
        Push-Location $step.WorkDir
        try {
            & $step.Python $step.Script
            $rc = $LASTEXITCODE
        }
        finally {
            Pop-Location
        }
        if ($rc -ne 0) {
            $failed += "$($step.Name):rc=$rc"
            Write-WorkflowLog "STEP=$($step.Name) FAILED rc=$rc"
            break
        }
        Write-WorkflowLog "STEP=$($step.Name) DONE"
    }

    if ($failed.Count -eq 0) {
        Write-WorkflowLog 'ALL_DATA_STEPS_DONE; sending PDF report.'
        Push-Location $newsSrc
        try {
            & $managedPython (Join-Path $newsSrc '05_send_daily_pdf_report.py')
            $reportRc = $LASTEXITCODE
        }
        finally {
            Pop-Location
        }
        if ($reportRc -eq 0) {
            Write-WorkflowLog 'WORKFLOW_DONE; email sent.'
            exit 0
        }
        $failed += "pdf_report:rc=$reportRc"
        Write-WorkflowLog "PDF_REPORT_FAILED rc=$reportRc"
    }

    Write-WorkflowLog ("RETRY_IN_SECONDS=$retrySeconds failures=" + ($failed -join ','))
    Start-Sleep -Seconds $retrySeconds
}
