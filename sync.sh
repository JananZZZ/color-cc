#!/usr/bin/env bash
# color-cc Sync Script
# Run this script to sync the dashboard config to all cc-switch providers
# Usage: ./sync.sh

set -e

# Configuration
REPO_RAW="https://raw.githubusercontent.com/JananZZZ/color-cc/main"
CONFIG_URL="$REPO_RAW/config/claude-dashboard.omp.json"
CONFIG_DEST="$HOME/.claude/claude-dashboard.omp.json"
INJECT_SCRIPT_URL="$REPO_RAW/scripts/inject_config.py"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo ""
echo "  ╔════════════════════════════════════════╗"
echo "  ║       color-cc Config Sync v1.1.0      ║"
echo "  ╚════════════════════════════════════════╝"
echo ""

# 1. Download latest theme config
echo -e "${YELLOW}[1/3] Downloading theme config...${NC}"
if curl -fsSL "$CONFIG_URL" -o "$CONFIG_DEST"; then
    echo -e "      ${GREEN}Theme saved to: $CONFIG_DEST${NC}"
else
    echo -e "      ${RED}[ERROR] Failed to download theme${NC}"
    exit 1
fi

# 2. Update main settings.json
echo ""
echo -e "${YELLOW}[2/3] Updating settings.json...${NC}"
SETTINGS_PATH="$HOME/.claude/settings.json"

if command -v jq >/dev/null 2>&1; then
    tmp=$(mktemp)
    jq --arg sl "oh-my-posh claude --config \"$CONFIG_DEST\"" \
        '.statusLine = {type: "command", command: $sl, padding: 0, refreshInterval: 5}' \
        "$SETTINGS_PATH" > "$tmp" && mv "$tmp" "$SETTINGS_PATH"
    echo -e "      ${GREEN}statusLine configured${NC}"
elif command -v python3 >/dev/null 2>&1; then
    python3 << EOF
import json

with open('$SETTINGS_PATH', 'r') as f:
    settings = json.load(f)

settings['statusLine'] = {
    'type': 'command',
    'command': f'oh-my-posh claude --config "$CONFIG_DEST"',
    'padding': 0,
    'refreshInterval': 5
}

with open('$SETTINGS_PATH', 'w') as f:
    json.dump(settings, f, indent=2)
EOF
    echo -e "      ${GREEN}statusLine configured${NC}"
else
    echo -e "      ${YELLOW}[WARN] jq or python3 required to update settings.json${NC}"
fi

# 3. Update cc-switch providers
echo ""
echo -e "${YELLOW}[3/3] Updating cc-switch providers...${NC}"
INJECT_SCRIPT="/tmp/color-cc-inject.py"

if command -v python3 >/dev/null 2>&1; then
    # Download inject script
    curl -fsSL "$INJECT_SCRIPT_URL" -o "$INJECT_SCRIPT"

    # Install better-sqlite3 if needed
    if ! python3 -m pip show better-sqlite3 >/dev/null 2>&1; then
        echo "      Installing better-sqlite3..." | ${GRAY}
        python3 -m pip install better-sqlite3 -q 2>/dev/null
    fi

    # Run inject script
    python3 "$INJECT_SCRIPT"

    # Cleanup
    rm -f "$INJECT_SCRIPT"
else
    echo -e "      ${YELLOW}[WARN] Python3 not found${NC}"
    echo -e "      ${YELLOW}cc-switch providers not updated${NC}"
    echo -e "      Install Python3 to sync all providers${NC}" | ${GRAY}
fi

# Success
echo ""
echo -e "${GREEN}✅ Sync complete!${NC}"
echo ""
echo "Next steps:"
echo -e "  ${NC}1. Restart Claude Code${NC}"
echo -e "  ${NC}2. Your dashboard will appear at the bottom${NC}"
echo ""
