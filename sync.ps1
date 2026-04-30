#!/usr/bin/env pwsh
# color-cc Sync Script
# Run this script to sync the dashboard config to all cc-switch providers
# Usage: .\sync.ps1

$ErrorActionPreference = "Stop"

# Configuration - GitHub source (primary)
$GITHUB_RAW = "https://raw.githubusercontent.com/JananZZZ/color-cc/main"
# Configuration - Gitee source (fallback for users in China)
$GITEE_RAW = "https://gitee.com/JananZZZ/Color-cc/raw/main"

# Detect best download source
function Get-RepoRaw {
    $reachable = $false
    try {
        $client = New-Object System.Net.Sockets.TcpClient
        $result = $client.BeginConnect("raw.githubusercontent.com", 443, $null, $null)
        $reachable = $result.AsyncWaitHandle.WaitOne(3000, $false)
        $client.Close()
    } catch {
        $reachable = $false
    }
    if ($reachable) {
        return $GITHUB_RAW
    }
    Write-Host "      ⚠ GitHub unreachable, using Gitee mirror" -ForegroundColor Yellow
    return $GITEE_RAW
}

$REPO_RAW = Get-RepoRaw
$CONFIG_URL = "$REPO_RAW/config/claude-dashboard.omp.json"
$CONFIG_DEST = "$env:USERPROFILE\.claude\claude-dashboard.omp.json"
$INJECT_SCRIPT_URL = "$REPO_RAW/scripts/inject_config.py"

Write-Host ""
Write-Host "  ╔════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "  ║       color-cc Config Sync v1.2.0      ║" -ForegroundColor Cyan
Write-Host "  ╚════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# 1. Download latest theme config
Write-Host "[1/3] Downloading theme config..." -ForegroundColor Yellow
try {
    Invoke-RestMethod -Uri $CONFIG_URL -OutFile $CONFIG_DEST
    Write-Host "      Theme saved to: $CONFIG_DEST" -ForegroundColor Green
} catch {
    Write-Host "      [ERROR] Failed to download theme" -ForegroundColor Red
    exit 1
}

# 2. Update main settings.json
Write-Host ""
Write-Host "[2/3] Updating settings.json..." -ForegroundColor Yellow
try {
    $settingsPath = "$env:USERPROFILE\.claude\settings.json"
    $settings = Get-Content $settingsPath -Raw | ConvertFrom-Json

    $settings.statusLine = @{
        type = "command"
        command = "oh-my-posh claude --config `"$CONFIG_DEST`""
        padding = 0
        refreshInterval = 5
    }

    $settings | ConvertTo-Json -Depth 10 | Set-Content $settingsPath
    Write-Host "      statusLine configured" -ForegroundColor Green
} catch {
    Write-Host "      [ERROR] Failed to update settings.json" -ForegroundColor Red
    exit 1
}

# 3. Update cc-switch providers
Write-Host ""
Write-Host "[3/3] Updating cc-switch providers..." -ForegroundColor Yellow
$injectScript = "$env:TEMP\color-cc-inject.py"

try {
    # Download inject script
    Invoke-RestMethod -Uri $INJECT_SCRIPT_URL -OutFile $injectScript

    # Check if Python exists
    $pythonCmd = Get-Command python -ErrorAction SilentlyContinue
    if ($pythonCmd) {
        # Install better-sqlite3 if needed
        python -m pip show better-sqlite3 > $null 2>&1
        if ($LASTEXITCODE -ne 0) {
            Write-Host "      Installing better-sqlite3..." -ForegroundColor Gray
            python -m pip install better-sqlite3 -q
        }

        # Run inject script
        python $injectScript
    } else {
        Write-Host "      [WARN] Python not found" -ForegroundColor Yellow
        Write-Host "      cc-switch providers not updated" -ForegroundColor Yellow
        Write-Host "      Install Python to sync all providers" -ForegroundColor Gray
    }

    # Cleanup
    Remove-Item $injectScript -Force -ErrorAction SilentlyContinue
} catch {
    Write-Host "      [WARN] cc-switch update failed" -ForegroundColor Yellow
    Write-Host "      Your dashboard will still work for current account" -ForegroundColor Gray
}

# Success
Write-Host ""
Write-Host "✅ Sync complete!" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor White
Write-Host "  1. Restart Claude Code" -ForegroundColor Gray
Write-Host "  2. Your dashboard will appear at the bottom" -ForegroundColor Gray
Write-Host ""
