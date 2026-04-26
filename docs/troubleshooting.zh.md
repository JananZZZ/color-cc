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

```powershell
irm https://raw.githubusercontent.com/JananZZZ/color-cc/main/install.ps1 | iex
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

## 仍然有问题？

1. 查看 [GitHub Issues](https://github.com/JananZZZ/color-cc/issues)
2. 创建新问题并提供详细信息：
   - 操作系统和版本
   - 错误消息
   - 重现步骤
   - 截图（如适用）
