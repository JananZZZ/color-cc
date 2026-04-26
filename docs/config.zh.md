# 配置指南

---

中文 | [English](config.en.md)

---

## 🎨 主题文件位置

主题配置存储在：
```
~/.claude/claude-dashboard.omp.json
```

## 🎯 自定义选项

### 更改颜色

编辑 `palette` 部分：

```json
{
  "palette": {
    "cosmic_pink": "#F5C2E7",
    "cosmic_purple": "#CBA6F7",
    "cosmic_blue": "#89B4FA",
    "cosmic_cyan": "#74C7EC",
    "cosmic_green": "#A6E3A1",
    "cosmic_yellow": "#F9E2AF",
    "cosmic_orange": "#FAB387",
    "cosmic_red": "#F38BA8"
  }
}
```

### 添加/删除指标

`blocks` 数组中的每个 `segment` 代表一个指标：

```json
{
  "type": "claude",
  "style": "diamond",
  "foreground": "p:deep_bg",
  "background": "p:cosmic_pink",
  "template": " 🤖 {{ .Model.DisplayName }} "
}
```

### 可用的模板变量

| 变量 | 描述 |
|------|------|
| `{{ .Model.DisplayName }}` | 模型名称 |
| `{{ .FormattedTokens }}` | 当前使用的 Token |
| `{{ .TokenUsagePercent }}` | Token 使用百分比 |
| `{{ .ContextWindow.TotalInputTokens }}` | 总输入 Token |
| `{{ .ContextWindow.TotalOutputTokens }}` | 总输出 Token |
| `{{ .FormattedCost }}` | 会话成本 |
| `{{ .FormattedDuration }}` | 会话时长 |
| `{{ .FormattedAPIDuration }}` | API 调用时长 |
| `{{ .Cost.TotalLinesAdded }}` | 添加的代码行数 |
| `{{ .Cost.TotalLinesRemoved }}` | 删除的代码行数 |
| `{{ .Workspace.ProjectDir }}` | 项目目录 |
| `{{ .Env.COMPUTERNAME }}` | 计算机名 |
| `{{ .FiveHourUsage }}` | 5 小时使用率 % |
| `{{ .SevenDayUsage }}` | 7 天使用率 % |

## 🔄 重新加载更改

更改在以下情况下生效：
1. 保存配置文件
2. 重启 Claude Code

## 📚 了解更多

- [Oh My Posh 文档](https://ohmyposh.dev/docs/configuration)
- [Claude Code 文档](https://code.anthropic.com/docs)
