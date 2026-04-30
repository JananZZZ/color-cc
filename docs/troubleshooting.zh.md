# 故障排除

---

中文 | [English](troubleshooting.en.md)

---

## 仪表板未显示

### 重启 Claude Code
仪表板仅在完全重启 Claude Code 后才会显示。

### 检查 Oh My Posh 安装
```powershell
oh-my-posh --version
```

应该返回版本号（例如 `29.10.0`）。

### 验证配置文件存在
```powershell
Test-Path $env:USERPROFILE\.claude\claude-dashboard.omp.json
```

应该返回 `True`。

### 检查 settings.json
```powershell
Get-Content $env:USERPROFILE\.claude\settings.json | Select-String statusLine
```

应该显示指向主题文件的 statusLine 配置。

## 数据错误或缺失

### Token 计数显示 0
- 确保您在活动的 Claude Code 会话中
- 仪表板每 5 秒更新一次

### 成本未显示
- 成本跟踪需要活动对话
- 检查您的 API 凭据是否有效

### Git 信息缺失
- 确保您在 git 仓库中
- 运行 `git status` 验证 git 是否正常工作

## 切换账号后 (cc-switch)

切换提供商后仪表板消失了？重新运行安装脚本：

**GitHub（默认）**
```powershell
irm https://raw.githubusercontent.com/JananZZZ/color-cc/main/install.ps1 | iex
```

**Gitee（国内镜像）**
```powershell
irm https://gitee.com/JananZZZ/Color-cc/raw/main/install.ps1 | iex
```

安装程序将恢复 statusLine 配置。

## 颜色看起来不对

### 终端颜色支持
确保您的终端支持真彩色（24 位）。

### Windows Terminal
设置 → 配置文件 → 颜色 → 颜色方案：
- 使用深色背景以获得最佳效果
- 如果可用，启用"终端颜色"

## 脚本错误

### PowerShell 执行策略
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### 未找到 curl (Windows)
安装 curl 或使用：
```powershell
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/JananZZZ/color-cc/main/install.ps1" -OutFile "install.ps1"
./install.ps1
```

## 安装时提示 Gitee 仓库 404

如果你在安装时看到类似以下错误：

```
fatal: repository 'https://gitee.com/JananZZZ/Color-cc.git/' not found
```

**原因**：你使用的"一键安装"工具尝试通过 `git clone` 从 Gitee 克隆仓库，但这种方式不是 color-cc 官方支持的安装方式。

**解决方法**：
1. 请使用官方提供的安装命令（见 README），不要使用第三方工具的 git clone
2. 官方安装脚本会自动检测网络并选择合适的下载源
3. 如果 GitHub 无法访问，手动使用 Gitee Raw 地址安装：

**Windows**
```powershell
irm https://gitee.com/JananZZZ/Color-cc/raw/main/install.ps1 | iex
```

**Linux / macOS**
```bash
curl -fsSL https://gitee.com/JananZZZ/Color-cc/raw/main/install.sh | bash
```

> ⚠ 注意：安装使用 Raw 文件直链（`/raw/main/`），不是 `git clone`。

## 安装时提示下载失败

这通常是因为 `raw.githubusercontent.com` 在国内无法直接访问。

**解决方法**：
- 安装脚本会自动检测并切换到 Gitee 源
- 如果自动检测失败，手动使用上面的 Gitee 安装命令
- 如果你在 Gitee 上也遇到问题，请在 [GitHub Issues](https://github.com/JananZZZ/color-cc/issues) 反馈

## 仍然有问题？

1. 查看 [GitHub Issues](https://github.com/JananZZZ/color-cc/issues)
2. 创建新问题并提供详细信息：
   - 操作系统和版本
   - 错误消息
   - 重现步骤
   - 截图（如适用）
