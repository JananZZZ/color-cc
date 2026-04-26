#!/usr/bin/env python3
"""
color-cc cc-switch Configuration Injector

Injects statusLine configuration into all cc-switch providers
to ensure the dashboard persists across account switches.

This script is safe to run multiple times - it only updates
the statusLine configuration while preserving all other settings.
"""

import json
import sqlite3
import os
import sys
from pathlib import Path


def get_user_home():
    """Get the user's home directory in a cross-platform way."""
    return Path.home()


def get_config_path():
    """Get the platform-specific config path for Oh My Posh theme."""
    config_dir = get_user_home() / ".claude"
    config_file = config_dir / "claude-dashboard.omp.json"
    return str(config_file)


def get_ohmyposh_command():
    """Get the Oh My Posh command for the current platform."""
    config_path = get_config_path()
    # Use forward slashes for cross-platform compatibility
    config_path_normalized = config_path.replace("\\", "/")
    return f'oh-my-posh claude --config "{config_path_normalized}"'


def check_config_exists():
    """Check if the color-cc config file exists."""
    config_path = get_config_path()
    if not Path(config_path).exists():
        print(f"[WARN] color-cc config not found at: {config_path}")
        print("       Run the install script first:")
        print("       Windows: irm https://raw.githubusercontent.com/JananZZZ/color-cc/main/install.ps1 | iex")
        print("       Linux/macOS: curl -fsSL https://raw.githubusercontent.com/JananZZZ/color-cc/main/install.sh | bash")
        return False
    return True


def update_providers():
    """Update all Claude providers in cc-switch database."""
    db_path = get_user_home() / ".cc-switch" / "cc-switch.db"

    if not db_path.exists():
        print(f"[INFO] cc-switch not found at {db_path}")
        print("       Skipping cc-switch provider update")
        print("       Your statusLine will work for the current account")
        return True

    # StatusLine configuration to inject
    statusline_config = {
        "type": "command",
        "command": get_ohmyposh_command(),
        "padding": 0,
        "refreshInterval": 5
    }

    try:
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

        print(f"[INFO] Found {len(providers)} Claude provider(s)")
        print()

        updated_count = 0
        for provider_id, current_config_json in providers:
            try:
                current_config = json.loads(current_config_json)

                # Update only the statusLine configuration
                current_config["statusLine"] = statusline_config

                # Update database
                new_config_json = json.dumps(current_config, ensure_ascii=False, indent=2)
                cursor.execute(
                    "UPDATE providers SET settings_config = ? WHERE id = ? AND app_type = ?",
                    (new_config_json, provider_id, "claude")
                )

                # Truncate command for display
                cmd_display = statusline_config['command'][:50] + "..."
                print(f"  [OK] Provider: {provider_id}")
                print(f"        statusLine: {cmd_display}")
                updated_count += 1

            except json.JSONDecodeError as e:
                print(f"  [WARN] Failed to parse config for provider: {provider_id}")
                print(f"        Error: {e}")
            except Exception as e:
                print(f"  [ERROR] Failed to update provider {provider_id}: {e}")

        conn.commit()
        conn.close()

        print()
        if updated_count > 0:
            print(f"[SUCCESS] Updated {updated_count} provider(s)!")
            print()
            print("Your dashboard will now persist across account switches.")
            return True
        else:
            print("[WARN] No providers were updated")
            return False

    except sqlite3.Error as e:
        print(f"[ERROR] Database error: {e}")
        return False
    except Exception as e:
        print(f"[ERROR] Unexpected error: {e}")
        return False


def main():
    """Main entry point."""
    print()
    print("  ╔════════════════════════════════════════╗")
    print("  ║   color-cc cc-switch Config Injector  ║")
    print("  ║           Version: 1.1.0               ║")
    print("  ╚════════════════════════════════════════╝")
    print()

    # Check if config exists
    if not check_config_exists():
        sys.exit(1)

    # Show what we're doing
    print(f"[INFO] Config file: {get_config_path()}")
    print(f"[INFO] Command: {get_ohmyposh_command()[:60]}...")
    print()

    # Update providers
    success = update_providers()

    if success:
        print()
        print("Next steps:")
        print("  1. Restart Claude Code")
        print("  2. Your dashboard will appear at the bottom")
        print()
        sys.exit(0)
    else:
        print()
        print("Please check the errors above and try again.")
        print()
        sys.exit(1)


if __name__ == "__main__":
    main()
