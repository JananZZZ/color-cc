import json
import sqlite3
import os
from pathlib import Path

db_path = Path.home() / '.cc-switch' / 'cc-switch.db'

# 稳定配置模板（跨账号）
stable_config = {
    "env": {
        "ENABLE_TOOL_SEARCH": "true",
        "CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC": "1",
        "API_TIMEOUT_MS": "3000000"
    },
    "hooks": {
        "SessionStart": [
            {"matcher": "", "hooks": [{"type": "command", "command": '& "node" "C:/Users/48304/clawd-on-desk/hooks/auto-start.js"', "shell": "powershell"}]},
            {"matcher": "", "hooks": [{"type": "command", "command": '& "node" "C:/Users/48304/clawd-on-desk/hooks/clawd-hook.js" SessionStart', "shell": "powershell"}]}
        ],
        "SessionEnd": [
            {"matcher": "", "hooks": [{"type": "command", "command": '& "node" "C:/Users/48304/clawd-on-desk/hooks/clawd-hook.js" SessionEnd', "shell": "powershell"}]}
        ],
        "UserPromptSubmit": [
            {"matcher": "", "hooks": [{"type": "command", "command": '& "node" "C:/Users/48304/clawd-on-desk/hooks/clawd-hook.js" UserPromptSubmit', "shell": "powershell"}]}
        ],
        "PreToolUse": [
            {"matcher": "", "hooks": [{"type": "command", "command": '& "node" "C:/Users/48304/clawd-on-desk/hooks/clawd-hook.js" PreToolUse', "shell": "powershell"}]}
        ],
        "PostToolUse": [
            {"matcher": "", "hooks": [{"type": "command", "command": '& "node" "C:/Users/48304/clawd-on-desk/hooks/clawd-hook.js" PostToolUse', "shell": "powershell"}]}
        ],
        "PostToolUseFailure": [
            {"matcher": "", "hooks": [{"type": "command", "command": '& "node" "C:/Users/48304/clawd-on-desk/hooks/clawd-hook.js" PostToolUseFailure', "shell": "powershell"}]}
        ],
        "Stop": [
            {"matcher": "", "hooks": [{"type": "command", "command": '& "node" "C:/Users/48304/clawd-on-desk/hooks/clawd-hook.js" Stop', "shell": "powershell"}]}
        ],
        "SubagentStart": [
            {"matcher": "", "hooks": [{"type": "command", "command": '& "node" "C:/Users/48304/clawd-on-desk/hooks/clawd-hook.js" SubagentStart', "shell": "powershell"}]}
        ],
        "SubagentStop": [
            {"matcher": "", "hooks": [{"type": "command", "command": '& "node" "C:/Users/48304/clawd-on-desk/hooks/clawd-hook.js" SubagentStop', "shell": "powershell"}]}
        ],
        "Notification": [
            {"matcher": "", "hooks": [{"type": "command", "command": '& "node" "C:/Users/48304/clawd-on-desk/hooks/clawd-hook.js" Notification', "shell": "powershell"}]}
        ],
        "Elicitation": [
            {"matcher": "", "hooks": [{"type": "command", "command": '& "node" "C:/Users/48304/clawd-on-desk/hooks/clawd-hook.js" Elicitation', "shell": "powershell"}]}
        ],
        "PreCompact": [
            {"matcher": "", "hooks": [{"type": "command", "command": '& "node" "C:/Users/48304/clawd-on-desk/hooks/clawd-hook.js" PreCompact', "shell": "powershell"}]}
        ],
        "PostCompact": [
            {"matcher": "", "hooks": [{"type": "command", "command": '& "node" "C:/Users/48304/clawd-on-desk/hooks/clawd-hook.js" PostCompact', "shell": "powershell"}]}
        ],
        "StopFailure": [
            {"matcher": "", "hooks": [{"type": "command", "command": '& "node" "C:/Users/48304/clawd-on-desk/hooks/clawd-hook.js" StopFailure', "shell": "powershell"}]}
        ],
        "PermissionRequest": [
            {"matcher": "", "hooks": [{"type": "http", "url": "http://127.0.0.1:23333/permission", "timeout": 600}]}
        ]
    },
    "statusLine": {
        "type": "command",
        "command": 'oh-my-posh claude --config "C:/Users/48304/.claude/claude-dashboard.omp.json"',
        "padding": 0,
        "refreshInterval": 5
    },
    "enabledPlugins": {
        "glm-plan-usage@zai-coding-plugins": True,
        "glm-plan-bug@zai-coding-plugins": True,
        "skill-creator@claude-plugins-official": True,
        "code-review@claude-plugins-official": True,
        "code-simplifier@claude-plugins-official": True,
        "security-guidance@claude-plugins-official": True,
        "pr-review-toolkit@claude-plugins-official": True
    },
    "extraKnownMarketplaces": {
        "zai-coding-plugins": {
            "source": {
                "source": "directory",
                "path": "C:\\Users\\48304\\AppData\\Local\\npm-cache\\_npx\\2f024689b4d0d3b0\\node_modules\\@z_ai\\coding-helper\\zai-coding-plugins"
            }
        }
    },
    "autoUpdatesChannel": "latest"
}

conn = sqlite3.connect(db_path)
cursor = conn.cursor()

# 获取所有 Claude providers
cursor.execute("SELECT id, settings_config FROM providers WHERE app_type = ?", ('claude',))
providers = cursor.fetchall()

print(f"Found {len(providers)} providers to update\n")

for provider_id, current_config_json in providers:
    current_config = json.loads(current_config_json)

    # 合并配置：保留账号特定的 ANTHROPIC_* env vars
    merged_config = stable_config.copy()

    # 保留并合并账号特定的环境变量
    if 'env' in current_config:
        anthropic_env = {k: v for k, v in current_config['env'].items() if k.startswith('ANTHROPIC_')}
        merged_config['env'] = {**stable_config['env'], **anthropic_env}

    # 保留可能存在的其他特定配置
    for key in ['language', 'cacheDirectory', 'dataDirectory', 'projectsDirectory', 'sessionsDirectory']:
        if key in current_config:
            merged_config[key] = current_config[key]

    # 更新数据库
    new_config_json = json.dumps(merged_config, ensure_ascii=False)
    cursor.execute(
        "UPDATE providers SET settings_config = ? WHERE id = ? AND app_type = ?",
        (new_config_json, provider_id, 'claude')
    )

    anthropic_vars = [k for k in merged_config['env'].keys() if k.startswith('ANTHROPIC_')]
    print(f"[OK] Updated provider: {provider_id}")
    print(f"     Preserved ANTHROPIC_ vars: {', '.join(anthropic_vars) if anthropic_vars else 'none'}\n")

conn.commit()
conn.close()
print("[SUCCESS] All providers updated successfully!")
