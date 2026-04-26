#!/usr/bin/env python3
"""
color-cc cc-switch configuration injector

Injects statusLine configuration into all cc-switch providers
to ensure the dashboard persists across account switches.
"""

import json
import sqlite3
import os
from pathlib import Path


def get_config_path():
    """Get the platform-specific config path."""
    config_dir = Path.home() / ".claude"
    return str(config_dir / "claude-dashboard.omp.json")


def get_ohmyposh_command():
    """Get the Oh My Posh command for the current platform."""
    config_path = get_config_path()
    return f'oh-my-posh claude --config "{config_path}"'


def update_providers():
    """Update all Claude providers in cc-switch database."""
    db_path = Path.home() / ".cc-switch" / "cc-switch.db"

    if not db_path.exists():
        print(f"[ERROR] cc-switch database not found at {db_path}")
        return False

    # StatusLine configuration to inject
    statusline_config = {
        "type": "command",
        "command": get_ohmyposh_command(),
        "padding": 0,
        "refreshInterval": 5
    }

    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()

    # Get all Claude providers
    cursor.execute(
        "SELECT id, settings_config FROM providers WHERE app_type = ?",
        ("claude",)
    )
    providers = cursor.fetchall()

    if not providers:
        print("[INFO] No Claude providers found in cc-switch")
        conn.close()
        return True

    print(f"Found {len(providers)} provider(s) to update\n")

    updated_count = 0
    for provider_id, current_config_json in providers:
        try:
            current_config = json.loads(current_config_json)

            # Update only the statusLine configuration
            current_config["statusLine"] = statusline_config

            # Update database
            new_config_json = json.dumps(current_config, ensure_ascii=False)
            cursor.execute(
                "UPDATE providers SET settings_config = ? WHERE id = ? AND app_type = ?",
                (new_config_json, provider_id, "claude")
            )

            print(f"[OK] Updated provider: {provider_id}")
            print(f"     statusLine: {statusline_config['command'][:60]}...\n")
            updated_count += 1

        except json.JSONDecodeError:
            print(f"[WARN] Failed to parse config for provider: {provider_id}")
        except Exception as e:
            print(f"[ERROR] Failed to update provider {provider_id}: {e}")

    conn.commit()
    conn.close()

    if updated_count > 0:
        print(f"[SUCCESS] Updated {updated_count} provider(s)!")
        return True
    else:
        print("[WARN] No providers were updated")
        return False


if __name__ == "__main__":
    import sys

    print("color-cc cc-switch Configuration Injector")
    print("=" * 40)
    print()

    success = update_providers()
    sys.exit(0 if success else 1)
