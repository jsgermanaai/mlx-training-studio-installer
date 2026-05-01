# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

## [Unreleased]

## [0.1.0] - 2026-04-30

### Added

- `install.sh` — top-level entry point that works via both `curl | bash` and
  direct clone execution.
- `bin/mlx-training-studio` — CLI dispatcher with subcommands: `install`,
  `update`, `uninstall`, `doctor`, `status`, `help`.
- `lib/log.sh` — colored logging helpers (`info`, `ok`, `warn`, `err`, `die`,
  `prompt`, `confirm`) with automatic TTY detection.
- `lib/checks.sh` — preflight checks for macOS version (13+), Apple Silicon,
  full Xcode installation, Python 3.12+, git, and disk space.
- `lib/prompts.sh` — interactive prompts for source directory, install location,
  and optional git ref pinning; respects `MLX_TS_NONINTERACTIVE=1`.
- `lib/build.sh` — `clone_or_update_source`, `build_app`, `install_app`,
  `write_manifest`, and `run_full_install` orchestration.
- `lib/manifest.sh` — manifest path constants and read/write helpers.
- `docs/TROUBLESHOOTING.md` — common issues and remediation steps.
- `docs/CONTRIBUTING.md` — developer setup, lint/format tooling, PR guidelines.
- `.github/workflows/ci.yml` — shellcheck + shfmt CI on GitHub Actions.
- `.shellcheckrc`, `.editorconfig`, `.gitignore` — project configuration.
- `NOTICE` — Apache-2.0 attribution for the upstream `stevenatkin/mlx-lm-gui`.

[0.1.0]: https://github.com/jsgermanaai/mlx-training-studio-installer/releases/tag/v0.1.0
[Unreleased]: https://github.com/jsgermanaai/mlx-training-studio-installer/compare/v0.1.0...HEAD
