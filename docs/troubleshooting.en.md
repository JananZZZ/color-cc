# Troubleshooting

---

[中文](troubleshooting.zh.md) | English

---

## Dashboard not showing

### Restart Claude Code
The dashboard only appears after a full restart of Claude Code.

### Check Oh My Posh installation
```powershell
oh-my-posh --version
```

Should return a version number (e.g., `29.10.0`).

### Verify config file exists
```powershell
Test-Path $env:USERPROFILE\.claude\claude-dashboard.omp.json
```

Should return `True`.

### Check settings.json
```powershell
Get-Content $env:USERPROFILE\.claude\settings.json | Select-String statusLine
```

Should show the statusLine configuration pointing to the theme file.

## Wrong or missing data

### Token counts showing 0
- Make sure you're in an active Claude Code session
- The dashboard updates every 5 seconds

### Cost not displaying
- Cost tracking requires an active conversation
- Check your API credentials are valid

### Git info missing
- Make sure you're in a git repository
- Run `git status` to verify git is working

## After switching accounts (cc-switch)

Dashboard disappeared after switching providers? Re-run the install script:

**GitHub (default)**
```powershell
irm https://raw.githubusercontent.com/JananZZZ/color-cc/main/install.ps1 | iex
```

**Gitee (China mirror)**
```powershell
irm https://gitee.com/JananZZZ/Color-cc/raw/main/install.ps1 | iex
```

The installer will restore the statusLine configuration.

## Colors look wrong

### Terminal color support
Make sure your terminal supports true color (24-bit).

### Windows Terminal
Settings → Profiles → Colors → Color scheme:
- Use a dark background for best results
- Enable "Terminal color" if available

## Script errors

### PowerShell execution policy
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### curl not found (Windows)
Install curl or use:
```powershell
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/JananZZZ/color-cc/main/install.ps1" -OutFile "install.ps1"
./install.ps1
```

## Installation fails with Gitee 404

If you see an error like this during installation:

```
fatal: repository 'https://gitee.com/JananZZZ/Color-cc.git/' not found
```

**Cause**: The install tool you're using is trying to `git clone` from Gitee, which is not the official installation method for color-cc.

**Fix**:
1. Use the official install command from README, not a third-party tool
2. The official install script auto-detects the network and picks the right source
3. If GitHub is unreachable, manually use the Gitee raw URL:

**Windows**
```powershell
irm https://gitee.com/JananZZZ/Color-cc/raw/main/install.ps1 | iex
```

**Linux / macOS**
```bash
curl -fsSL https://gitee.com/JananZZZ/Color-cc/raw/main/install.sh | bash
```

> ⚠ Note: Installation uses raw file URLs (`/raw/main/`), not `git clone`.

## Download failure during installation

This usually happens when `raw.githubusercontent.com` is unreachable.

**Fix**:
- The install script will auto-detect and switch to Gitee source
- If auto-detection fails, manually use the Gitee install commands above
- If you encounter issues on Gitee too, report at [GitHub Issues](https://github.com/JananZZZ/color-cc/issues)

## Still having issues?

1. Check the [GitHub Issues](https://github.com/JananZZZ/color-cc/issues)
2. Create a new issue with details:
   - OS and version
   - Error message
   - Steps to reproduce
   - Screenshot (if applicable)
