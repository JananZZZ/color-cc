#!/usr/bin/env pwsh
# color-cc installer for Windows
# Usage: irm https://raw.githubusercontent.com/JananZZZ/color-cc/main/install.ps1 | iex

$ErrorActionPreference = "Stop"

# Configuration
$REPO_RAW = "https://raw.githubusercontent.com/JananZZZ/color-cc/main"
$CONFIG_URL = "$REPO_RAW/config/claude-dashboard.omp.json"
$CONFIG_DEST = "$env:USERPROFILE\.claude\claude-dashboard.omp.json"
$DB_PATH = "$env:USERPROFILE\.cc-switch\cc-switch.db"

Write-Host ""
Write-Host "  ██╗   ██╗ ██████╗ ██╗   ██╗ █████╗                  " -ForegroundColor Cyan
Write-Host "  ██║   ██║██╔═══██╗██║   ██║██╔══██╗                 " -ForegroundColor Cyan
Write-Host "  ██║   ██║██║   ██║██║   ██║███████║                 " -ForegroundColor Cyan
Write-Host "  ╚██╗ ██╔╝██║   ██║██║   ██║██╔══██║                 " -ForegroundColor Cyan
Write-Host "   ╚████╔╝ ╚██████╔╝╚██████╔╝██║  ██║                 " -ForegroundColor Cyan
Write-Host "    ╚═══╝   ╚═════╝  ╚═════╝ ╚═╝  ╚═╝                 " -ForegroundColor Cyan
Write-Host "              🎨 Claude Code Dashboard                " -ForegroundColor Yellow
Write-Host ""

# Function: Check command exists
function Test-Command {
    param([string]$Command)
    $null = Get-Command $Command -ErrorAction SilentlyContinue
    return $?
}

# Function: Backup file
function Backup-File {
    param([string]$Path)
    if (Test-Path $Path) {
        $backupDir = Split-Path $Path | Join-Path -ChildPath "backup"
        $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
        $filename = Split-Path $Path -Leaf
        New-Item -ItemType Directory -Force -Path $backupDir | Out-Null
        Copy-Item $Path "$backupDir\${filename}_$timestamp" -Force
        Write-Host "   ✓ Backed up $filename" -ForegroundColor Gray
    }
}

# 1. Check Claude Code
Write-Host "🔍 Checking Claude Code..." -ForegroundColor Yellow
$claudePath = "$env:USERPROFILE\.claude"
if (-not (Test-Path $claudePath)) {
    Write-Host "   ❌ Claude Code not found at $claudePath" -ForegroundColor Red
    Write-Host "   Please install Claude Code first" -ForegroundColor Red
    exit 1
}
Write-Host "   ✓ Found at $claudePath" -ForegroundColor Green

# 2. Check Oh My Posh
Write-Host ""
Write-Host "📦 Checking Oh My Posh..." -ForegroundColor Yellow
if (-not (Test-Command oh-my-posh)) {
    Write-Host "   Installing Oh My Posh..." -ForegroundColor Gray
    try {
        winget install JanDeDobbeleer.OhMyPosh --accept-source-agreements --silent
        Write-Host "   ✓ Oh My Posh installed" -ForegroundColor Green
        # Refresh PATH
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
    } catch {
        Write-Host "   ❌ Failed to install Oh My Posh" -ForegroundColor Red
        Write-Host "   Please install manually: winget install JanDeDobbeleer.OhMyPosh" -ForegroundColor Gray
        exit 1
    }
} else {
    Write-Host "   ✓ Already installed" -ForegroundColor Green
}

# 3. Backup existing config
Write-Host ""
Write-Host "💾 Backing up existing config..." -ForegroundColor Yellow
Backup-File "$claudePath\settings.json"
Backup-File "$claudePath\claude-dashboard.omp.json"

# 4. Download theme config
Write-Host ""
Write-Host "🎨 Downloading theme..." -ForegroundColor Yellow
try {
    Invoke-RestMethod -Uri $CONFIG_URL -OutFile $CONFIG_DEST
    Write-Host "   ✓ Theme downloaded to $CONFIG_DEST" -ForegroundColor Green
} catch {
    Write-Host "   ❌ Failed to download theme" -ForegroundColor Red
    exit 1
}

# 5. Update settings.json
Write-Host ""
Write-Host "⚙️  Updating settings.json..." -ForegroundColor Yellow
try {
    $settingsPath = "$claudePath\settings.json"
    $settings = Get-Content $settingsPath -Raw | ConvertFrom-Json

    # Add or update statusLine
    $settings.statusLine = @{
        type = "command"
        command = "oh-my-posh claude --config `"$CONFIG_DEST`""
        padding = 0
        refreshInterval = 5
    }

    $settings | ConvertTo-Json -Depth 10 | Set-Content $settingsPath
    Write-Host "   ✓ statusLine configured" -ForegroundColor Green
} catch {
    Write-Host "   ❌ Failed to update settings.json" -ForegroundColor Red
    exit 1
}

# 6. Update cc-switch database (if exists)
if (Test-Path $DB_PATH) {
    Write-Host ""
    Write-Host "🔄 Updating cc-switch providers..." -ForegroundColor Yellow
    try {
        # Download inject script
        $injectScriptUrl = "$REPO_RAW/scripts/inject_config.py"
        $injectScript = "$env:TEMP\color-cc-inject.py"
        Invoke-RestMethod -Uri $injectScriptUrl -OutFile $injectScript

        # Install better-sqlite3 if not available
        if (-not (Test-Command python)) {
            Write-Host "   ⚠ Python not found, skipping cc-switch config" -ForegroundColor Yellow
        } else {
            # Install better-sqlite3
            Write-Host "   Installing better-sqlite3..." -ForegroundColor Gray
            python -m pip install better-sqlite3 -q 2>$null

            # Run inject script
            python $injectScript
            Write-Host "   ✓ cc-switch providers updated" -ForegroundColor Green
        }

        # Cleanup
        Remove-Item $injectScript -Force -ErrorAction SilentlyContinue
    } catch {
        Write-Host "   ⚠ cc-switch update skipped (may require manual setup)" -ForegroundColor Yellow
    }
} else {
    Write-Host ""
    Write-Host "ℹ️  cc-switch not found - statusLine will work but may reset on account switch" -ForegroundColor Cyan
}

# Success message
Write-Host ""
Write-Host "✅ Installation complete!" -ForegroundColor Green
Write-Host ""
Write-Host "📝 Next steps:" -ForegroundColor White
Write-Host "   1. Close and restart Claude Code" -ForegroundColor Gray
Write-Host "   2. Your new dashboard will appear at the bottom" -ForegroundColor Gray
Write-Host ""
Write-Host "🎨 Customize: Edit $CONFIG_DEST" -ForegroundColor Cyan
Write-Host "📖 Docs: https://github.com/JananZZZ/color-cc" -ForegroundColor Cyan
Write-Host ""
