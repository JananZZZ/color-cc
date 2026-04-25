# Configuration Guide

## 🎨 Theme File Location

The theme configuration is stored at:
```
~/.claude/claude-dashboard.omp.json
```

## 🎯 Customization Options

### Change Colors

Edit the `palette` section:

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

### Add/Remove Metrics

Each `segment` in the `blocks` array represents one metric:

```json
{
  "type": "claude",
  "style": "diamond",
  "foreground": "p:deep_bg",
  "background": "p:cosmic_pink",
  "template": " 🤖 {{ .Model.DisplayName }} "
}
```

### Available Template Variables

| Variable | Description |
|----------|-------------|
| `{{ .Model.DisplayName }}` | Model name |
| `{{ .FormattedTokens }}` | Current tokens used |
| `{{ .TokenUsagePercent }}` | Token usage percentage |
| `{{ .ContextWindow.TotalInputTokens }}` | Total input tokens |
| `{{ .ContextWindow.TotalOutputTokens }}` | Total output tokens |
| `{{ .FormattedCost }}` | Session cost |
| `{{ .FormattedDuration }}` | Session duration |
| `{{ .FormattedAPIDuration }}` | API call duration |
| `{{ .Cost.TotalLinesAdded }}` | Lines of code added |
| `{{ .Cost.TotalLinesRemoved }}` | Lines of code removed |
| `{{ .Workspace.ProjectDir }}` | Project directory |
| `{{ .Env.COMPUTERNAME }}` | Computer name |
| `{{ .FiveHourUsage }}` | 5-hour usage % |
| `{{ .SevenDayUsage }}` | 7-day usage % |

## 🔄 Reload Changes

Changes take effect when you:
1. Save the config file
2. Restart Claude Code

## 📚 Learn More

- [Oh My Posh Documentation](https://ohmyposh.dev/docs/configuration)
- [Claude Code Docs](https://code.anthropic.com/docs)
