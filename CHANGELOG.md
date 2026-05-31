# Changelog

All notable changes to AnyForm.

## [1.0.0] — 2026-05-30

### Added
- `--branch` / `-b` — Install from a specific branch instead of the default branch
- `--build-flags` — Pass additional flags to `go build` (e.g. ldflags, build tags)
- `--list` / `-l` — List installed custom provider binaries
- `--clean` / `-c` — Remove installed provider(s), with optional version filtering
- `--clean-all` — Remove all installed providers
- `--force` / `-f` — Skip confirmation prompts for destructive operations
- `--completion` — Generate shell completion scripts for bash, zsh, and fish
- `--opentofu` — Install providers to OpenTofu registry path with correct config block
- `--silent` / `-s` — Silent mode with suppressed progress output
- `--self-update` / `-U` — Self-update mechanism to latest GitHub release
- `--check-update` — Check if a newer version is available
- Provider management (`--list`, `--clean`, `--clean-all`)
- Shell completions for bash, zsh, fish

### Changed
- Improved error handling throughout (validation, temp directories, git refs)
- Detailed function comments for readability
- Strict mode (`set -euo pipefail`) for fail-fast behavior
- Standardized `print_error` function for consistent error output
- Improved cleanup and trap handling for temporary resources

### Fixed
- Silent mode (`-s`) no longer prints git output (#7)
- Nested trap in `self_update()` no longer overrides global cleanup
- CI passes on both macOS and Ubuntu (30/30 → 39/39 tests)
- Mock scripts now POSIX-compatible for dash on Ubuntu runners

## [0.10.0] — 2024-12-14

### Added
- Strict mode (`set -euo pipefail`)
- Variable initialization for safety
- Standardized `print_error` function
- Improved cleanup and trap handling
- Dependency checks for curl, git, go
- CI: macOS runner added to test matrix

## [0.9.0] — 2024-11-17
- Initial public release with core provider install functionality
- Commit, tag, and PR-based provider installation
- `--print-configuration` flag for Terraform config block output
- Self-update and version check commands
