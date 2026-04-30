#!/usr/bin/env python3
"""
Create or update GitHub Release for color-cc

Usage: python create_release.py <github_token>
"""

import sys
import json
import subprocess
from pathlib import Path


def get_current_tags():
    """Get current git tags."""
    result = subprocess.run(
        ["git", "tag", "-l", "--sort=-version:refname"],
        capture_output=True, text=True
    )
    tags = result.stdout.strip().split('\n')
    return [t for t in tags if t]


def get_tag_commit(tag):
    """Get commit hash for a tag."""
    result = subprocess.run(
        ["git", "rev-list", "-1", tag],
        capture_output=True, text=True
    )
    return result.stdout.strip()


def get_commits_since(since_tag):
    """Get commits since a tag."""
    result = subprocess.run(
        ["git", "log", f"{since_tag}..HEAD", "--oneline"],
        capture_output=True, text=True
    )
    return result.stdout.strip()


def create_release(token, tag, title, body):
    """Create GitHub release using API."""
    import urllib.request

    url = f"https://api.github.com/repos/JananZZZ/color-cc/releases"
    data = {
        "tag_name": tag,
        "name": title,
        "body": body,
        "draft": False,
        "prerelease": False
    }

    req = urllib.request.Request(
        url,
        data=json.dumps(data).encode('utf-8'),
        headers={
            'Authorization': f'token {token}',
            'Accept': 'application/vnd.github.v3+json',
            'Content-Type': 'application/json'
        }
    )

    try:
        response = urllib.request.urlopen(req)
        return json.loads(response.read().decode('utf-8'))
    except urllib.error.HTTPError as e:
        print(f"HTTP Error: {e.code}")
        print(e.read().decode('utf-8'))
        return None


def main():
    if len(sys.argv) < 2:
        print("Usage: python create_release.py <github_token>")
        print("\nGet a token from: https://github.com/settings/tokens")
        print("Required scopes: repo (public_repo)")
        sys.exit(1)

    token = sys.argv[1]

    # Get latest tag
    tags = get_current_tags()
    if not tags:
        print("No tags found!")
        sys.exit(1)

    latest_tag = tags[0]
    print(f"Latest tag: {latest_tag}")

    # Read changelog
    changelog_path = Path(__file__).parent.parent / "CHANGELOG.md"
    if changelog_path.exists():
        changelog = changelog_path.read_text(encoding='utf-8')
    else:
        changelog = "See commits for changes"

    # Release notes
    release_notes = f"""# {latest_tag} - color-cc Release

## 🎨 Claude Code 终端仪表板

完整更新日志请查看 [CHANGELOG.md](https://github.com/JananZZZ/color-cc/blob/main/CHANGELOG.md)

---

{changelog}

## 🚀 快速安装

**Windows (PowerShell)**
```powershell
irm https://raw.githubusercontent.com/JananZZZ/color-cc/main/install.ps1 | iex
```

**Linux / macOS**
```bash
curl -fsSL https://raw.githubusercontent.com/JananZZZ/color-cc/main/install.sh | bash
```

> ⚠ **国内用户**：如果 GitHub 无法访问，脚本会自动切换到 Gitee 镜像。

**Windows (PowerShell) — Gitee**
```powershell
irm https://gitee.com/JananZZZ/Color-cc/raw/main/install.ps1 | iex
```

**Linux / macOS — Gitee**
```bash
curl -fsSL https://gitee.com/JananZZZ/Color-cc/raw/main/install.sh | bash
```

## 🔄 同步配置

**Windows**
```powershell
.\\sync.ps1
```

**Linux / macOS**
```bash
./sync.sh
```

---

## 📄 许可证

MIT License © 2025
"""

    print(f"Creating release for {latest_tag}...")

    result = create_release(
        token,
        latest_tag,
        f"{latest_tag} - color-cc Release",
        release_notes
    )

    if result:
        print(f"✅ Release created!")
        print(f"   URL: {result.get('html_url')}")
    else:
        print("❌ Failed to create release")
        sys.exit(1)


if __name__ == "__main__":
    main()
