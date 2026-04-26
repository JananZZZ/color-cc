# Changelog

All notable changes to color-cc will be documented in this file.

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
