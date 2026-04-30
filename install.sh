#!/usr/bin/env bash
# color-cc installer for Linux/macOS
# Version: 1.2.0
# Usage: curl -fsSL https://raw.githubusercontent.com/JananZZZ/color-cc/main/install.sh | bash

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
GRAY='\033[0;37m'
NC='\033[0m' # No Color

# Configuration - GitHub source (primary)
GITHUB_RAW="https://raw.githubusercontent.com/JananZZZ/color-cc/main"
# Configuration - Gitee source (fallback for users in China)
GITEE_RAW="https://gitee.com/JananZZZ/Color-cc/raw/main"

# Detect best download source
echo -e "🔗 ${GRAY}Checking download source...${NC}"
if curl -s --connect-timeout 3 https://raw.githubusercontent.com >/dev/null 2>&1; then
    REPO_RAW="$GITHUB_RAW"
    echo -e "   ${GRAY}Using GitHub${NC}"
else
    REPO_RAW="$GITEE_RAW"
    echo -e "   ⚠ ${YELLOW}GitHub unreachable, switching to Gitee mirror${NC}"
fi

CONFIG_URL="$REPO_RAW/config/claude-dashboard.omp.json"
CONFIG_DEST="$HOME/.claude/claude-dashboard.omp.json"
DB_PATH="$HOME/.cc-switch/cc-switch.db"

echo ""
echo "  ██╗   ██╗ ██████╗ ██╗   ██╗ █████╗                  " | ${CYAN}
echo "  ██║   ██║██╔═══██╗██║   ██║██╔══██╗                 " | ${CYAN}
echo "  ██║   ██║██║   ██║██║   ██║███████║                 " | ${CYAN}
echo "  ╚██╗ ██╔╝██║   ██║██║   ██║██╔══██║                 " | ${CYAN}
echo "   ╚████╔╝ ╚██████╔╝╚██████╔╝██║  ██║                 " | ${CYAN}
echo "    ╚═══╝   ╚═════╝  ╚═════╝ ╚═╝  ╚═╝                 " | ${CYAN}
echo "              🎨 Claude Code Dashboard                " | ${YELLOW}
echo ""

# Function: Check command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function: Backup file
backup_file() {
    local file="$1"
    if [ -f "$file" ]; then
        local backup_dir="$(dirname "$file")/backup"
        local timestamp=$(date +%Y%m%d_%H%M%S)
        local filename=$(basename "$file")
        mkdir -p "$backup_dir"
        cp "$file" "$backup_dir/${filename}_${timestamp}"
        echo -e "   ${GREEN}✓${NC} Backed up $filename"
    fi
}

# 1. Check Claude Code
echo -e "${YELLOW}🔍 Checking Claude Code...${NC}"
CLAUDE_PATH="$HOME/.claude"
if [ ! -d "$CLAUDE_PATH" ]; then
    echo -e "   ${RED}❌ Claude Code not found at $CLAUDE_PATH${NC}"
    echo -e "   Please install Claude Code first${NC}"
    exit 1
fi
echo -e "   ${GREEN}✓${NC} Found at $CLAUDE_PATH"

# 2. Check Oh My Posh
echo ""
echo -e "${YELLOW}📦 Checking Oh My Posh...${NC}"
if ! command_exists oh-my-posh; then
    echo "   Installing Oh My Posh..." | ${GRAY}
    if [[ "$OSTYPE" == "darwin"* ]]; then
        brew install jandedobbeleer/oh-my-posh/oh-my-posh
    else
        curl -s https://ohmyposh.dev/install.sh | bash -s
    fi
    echo -e "   ${GREEN}✓${NC} Oh My Posh installed"
    # Refresh PATH
    export PATH="$HOME/.local/bin:$PATH"
else
    echo -e "   ${GREEN}✓${NC} Already installed"
fi

# 3. Backup existing config
echo ""
echo -e "${YELLOW}💾 Backing up existing config...${NC}"
backup_file "$CLAUDE_PATH/settings.json"
backup_file "$CLAUDE_PATH/claude-dashboard.omp.json"

# 4. Download theme config
echo ""
echo -e "${YELLOW}🎨 Downloading theme...${NC}"
if curl -fsSL "$CONFIG_URL" -o "$CONFIG_DEST"; then
    echo -e "   ${GREEN}✓${NC} Theme downloaded to $CONFIG_DEST"
else
    echo -e "   ${RED}❌ Failed to download theme${NC}"
    exit 1
fi

# 5. Update settings.json
echo ""
echo -e "${YELLOW}⚙️  Updating settings.json...${NC}"
SETTINGS_PATH="$CLAUDE_PATH/settings.json"

# Create default settings.json if it doesn't exist
if [ ! -f "$SETTINGS_PATH" ]; then
    echo -e "   ${GRAY}Creating new settings.json...${NC}"
    echo "{}" > "$SETTINGS_PATH"
fi

if command_exists jq; then
    # Use jq if available
    tmp=$(mktemp)
    jq --arg sl "oh-my-posh claude --config \"$CONFIG_DEST\"" \
        '.statusLine = {type: "command", command: $sl, padding: 0, refreshInterval: 5}' \
        "$SETTINGS_PATH" > "$tmp" && mv "$tmp" "$SETTINGS_PATH"
    echo -e "   ${GREEN}✓${NC} statusLine configured"
elif command_exists python3; then
    # Use Python as fallback
    python3 << EOF
import json

try:
    with open('$SETTINGS_PATH', 'r') as f:
        settings = json.load(f)
except (FileNotFoundError, json.JSONDecodeError):
    settings = {}

settings['statusLine'] = {
    'type': 'command',
    'command': f'oh-my-posh claude --config "$CONFIG_DEST"',
    'padding': 0,
    'refreshInterval': 5
}

with open('$SETTINGS_PATH', 'w') as f:
    json.dump(settings, f, indent=2)
EOF
    echo -e "   ${GREEN}✓${NC} statusLine configured"
else
    echo -e "   ${YELLOW}⚠ Could not update settings.json (jq or python3 required)${NC}"
fi

# 6. Update cc-switch database (if exists)
if [ -f "$DB_PATH" ]; then
    echo ""
    echo -e "${YELLOW}🔄 Updating cc-switch providers...${NC}"
    if command_exists python3; then
        # Download inject script
        INJECT_SCRIPT_URL="$REPO_RAW/scripts/inject_config.py"
        INJECT_SCRIPT="/tmp/color-cc-inject.py"
        echo "   Downloading inject script..." | ${GRAY}
        if curl -fsSL "$INJECT_SCRIPT_URL" -o "$INJECT_SCRIPT"; then
            # Install better-sqlite3
            echo "   Installing better-sqlite3..." | ${GRAY}
            python3 -m pip install better-sqlite3 -q 2>/dev/null

            # Run inject script
            if python3 "$INJECT_SCRIPT" 2>&1; then
                echo -e "   ${GREEN}✓${NC} cc-switch providers updated"
            else
                echo -e "   ${YELLOW}[!] cc-switch inject script failed${NC}"
            fi
        else
            echo -e "   ${YELLOW}[!] Failed to download inject script${NC}"
        fi

        # Cleanup
        rm -f "$INJECT_SCRIPT"
    fi
else
    echo ""
    echo -e "${CYAN}ℹ️  cc-switch not found - statusLine will work but may reset on account switch${NC}"
fi

# Success message
echo ""
echo -e "${GREEN}✅ Installation complete!${NC}"
echo ""
echo -e "${NC}📝 Next steps:${NC}"
echo -e "   ${GRAY}1. Close and restart Claude Code${NC}"
echo -e "   ${GRAY}2. Your new dashboard will appear at the bottom${NC}"
echo ""
echo -e "${CYAN}🎨 Customize: Edit $CONFIG_DEST${NC}"
echo -e "${CYAN}📖 Docs: https://github.com/JananZZZ/color-cc${NC}"
echo ""
