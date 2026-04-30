# Changelog

All notable changes to color-cc will be documented in this file.

## [1.2.0] - 2026-05-01

### Added
- **Gitee 镜像支持**: 安装脚本自动检测网络环境，GitHub 不可达时自动切换到 Gitee 镜像
- **Gitee 手动安装命令**: README 和文档中添加 Gitee 直链安装方式
- **安装网络诊断**: 故障排除文档新增 Gitee 404 和下载失败排查说明

### Changed
- **仪表板布局升级**: 第二行新增 🎯 LastHit、💿 LastMiss、📤 LastOut 三个实时指标段
  - `LastHit`: 当前请求缓存命中量
  - `LastMiss`: 当前请求未命中量（输入 + 新缓存写入）
  - `LastOut`: 当前请求输出 Token 量
- **版本号**: 所有脚本和配置统一升级到 1.2.0

### Fixed
- **网络检测误判**: PowerShell 改用 TCP Socket 测试替代 HTTP 请求检测，避免 HTTP 404 被误判为不可达
- **Bash 检测修复**: curl 移除 `-f` 标志，防止非 2xx 响应被当作连接失败
- **troubleshooting.en.md**: 修复安装 URL 中错误的 `username` 占位符

## [1.1.0] - 2025-01-XX

### Fixed
- **Token percentage rendering**: Added conditional check to prevent template rendering error when `RemainingPercentage` is nil
- **Git segment optimization**: Removed duplicate git segment from line 3, consolidated to line 4
- **Git status display**: Simplified to show only `.HEAD` (branch name) and `.BranchStatus` (ahead/behind)

### Known Limitations
- Oh My Posh git segment working/staging status properties (`.Working.Changed`, `.Staging.Changed`) are unreliable and have been removed from display

### Added
- Bilingual documentation support (English/Chinese)
- `.gitignore` file for cleaner repository

### Changed
- Restructured documentation files with language suffixes (`README.en.md`, `README.zh.md`)

## [1.0.0] - 2024-XX-XX

### Added
- Initial release
- 4-line cosmic-themed dashboard for Claude Code
- One-command installation (Windows PowerShell & Linux/macOS bash)
- cc-switch integration for multi-account persistence
- Real-time token usage and cost tracking
- Git branch and status display
