# color-cc

> ✨ Claude Code 终端的极简、优雅仪表板

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![Claude Code](https://img.shields.io/badge/Claude%20Code-compatible-brightgreen.svg)]()

---

中文 | [English](README.en.md)

---

## 📸 预览

<img src="assets/screenshots/dashboard.png" width="800">

## ✨ 特性

- 🎨 **4 行仪表板** - 一目了然的模型、Token、成本、Git 信息
- 🚀 **一键安装** - 几秒钟内即可完成配置
- 🔄 **自动持久化** - cc-switch 账号切换时设置保持不变
- 🎯 **实时指标** - 实时跟踪 Token 使用和成本
- 🌈 **Cosmic 主题** - 灵感来自 Catppuccin 的柔美色彩

## 📦 快速开始

### 一行安装命令

**Windows (PowerShell)**
```powershell
irm https://raw.githubusercontent.com/JananZZZ/color-cc/main/install.ps1 | iex
```

**Linux / macOS**
```bash
curl -fsSL https://raw.githubusercontent.com/JananZZZ/color-cc/main/install.sh | bash
```

### 重启 Claude Code

就这样！🎉 重启 Claude Code 即可看到新的仪表板。

## 📖 你将看到

| 行 | 内容 |
|------|---------|
| **1** | 🤖 模型 & 🧠 Token 使用（当前/总量，已用%） |
| **2** | 📥 输入 / 📤 输出 / 💾 缓存 Token |
| **3** | 💰 成本 / ⏱️ 会话时长 / 🌐 API 时间 / 📝 代码变更 |
| **4** | 📂 项目 / 🌿 Git 分支 & 状态 / 💻 电脑名 |

## ⚙️ 配置

想要自定义？编辑 `~/.claude/claude-dashboard.omp.json`

**调色板：**
```json
{
  "cosmic_pink": "#F5C2E7",
  "cosmic_purple": "#CBA6F7",
  "cosmic_blue": "#89B4FA",
  "cosmic_cyan": "#74C7EC",
  "cosmic_green": "#A6E3A1",
  "cosmic_yellow": "#F9E2AF",
  "cosmic_orange": "#FAB387",
  "cosmic_red": "#F38BA8"
}
```

[配置指南 →](docs/config.zh.md)

## 🛠️ 要求

- 已安装 Claude Code
- Oh My Posh（脚本会自动安装）
- Windows PowerShell 5.1+ 或 bash 4.0+

## 🔧 故障排除

仪表板没有显示？查看[故障排除指南](docs/troubleshooting.zh.md)。

## 🤝 贡献

欢迎贡献！阅读 [贡献指南](CONTRIBUTING.zh.md)

## 📄 许可证

[MIT License](LICENSE) © 2025

---

## 贡献者

由社区用 ❤️ 制作，感谢所有 [贡献者](https://github.com/JananZZZ/color-cc/graphs/contributors)
