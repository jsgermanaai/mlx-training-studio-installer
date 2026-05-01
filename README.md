# MLX Training Studio Installer

> One-command installer for [MLX Training Studio](https://github.com/stevenatkin/mlx-lm-gui) — a native macOS GUI for fine-tuning LLMs with mlx-lm-lora.

[![License](https://img.shields.io/badge/license-Apache--2.0-blue.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/platform-macOS%2013%2B%20%7C%20Apple%20Silicon-lightgrey.svg)]()
[![Status](https://img.shields.io/badge/status-beta-orange.svg)]()

---

## What is this?

This repo is an **installer wrapper**, not the app's source code.

[MLX Training Studio](https://github.com/stevenatkin/mlx-lm-gui) (upstream project name: `mlx-lm-gui`) is a native Swift macOS app by [Steven Atkin](https://github.com/stevenatkin) that provides a graphical interface for fine-tuning large language models using Apple's [mlx-lm-lora](https://github.com/ml-explore/mlx-examples/tree/main/llms/mlx_lm) library. The upstream project ships source code only — no pre-built binaries or releases.

This installer:
- Clones the upstream source
- Builds it locally with Xcode
- Copies the resulting `.app` to `/Applications` (or `~/Applications`)
- Manages subsequent updates and uninstalls

---

## Quick Install

### Option 1 — Homebrew (recommended)

```sh
brew tap jsgermanaai/tap
brew install jsgermanaai/tap/mlx-training-studio
mlx-training-studio install
```

### Option 2 — One-liner

```sh
curl -fsSL https://raw.githubusercontent.com/jsgermanaai/mlx-training-studio-installer/main/install.sh | bash
```

### Option 3 — Clone and run

```sh
git clone https://github.com/jsgermanaai/mlx-training-studio-installer.git
cd mlx-training-studio-installer
./install.sh
```

---

## Requirements

| Requirement | Details |
|---|---|
| **macOS** | 13.0 (Ventura) or later |
| **Architecture** | Apple Silicon (M1 / M2 / M3 / M4) — Intel is not supported by the upstream app |
| **Xcode** | Full Xcode 15 or later — Command Line Tools alone are not sufficient. Install from the [Mac App Store](https://apps.apple.com/app/xcode/id497799835) |
| **Python** | 3.12 or later, not the macOS stub. Suggested: `brew install python@3.12` |
| **Git** | Any recent version on PATH |

---

## What the Installer Does

1. **Preflight checks** — verifies macOS version, Apple Silicon, full Xcode, Python 3.12+, git, and available disk space.
2. **Prompt for paths** — asks where to store the source and where to install the `.app` (skipped in non-interactive mode).
3. **Clone source** — clones `https://github.com/stevenatkin/mlx-lm-gui` to the chosen source directory (default: `~/Library/Application Support/MLX Training Studio/source`).
4. **Build** — runs `xcodebuild -configuration Release` inside the cloned project.
5. **Copy to Applications** — atomically replaces any existing `.app` at the chosen install location.
6. **Write manifest** — records the installed commit, paths, and timestamp to `~/Library/Application Support/MLX Training Studio/manifest.json`.

---

## Commands

| Command | Description |
|---|---|
| `mlx-training-studio install` | Run the full preflight, clone, build, and install sequence |
| `mlx-training-studio update` | Pull latest upstream changes, rebuild, and replace the installed app |
| `mlx-training-studio uninstall` | Remove the installed `.app`; optionally remove the source directory |
| `mlx-training-studio doctor` | Run preflight checks and print results without making any changes |
| `mlx-training-studio status` | Print the install manifest (version, commit, paths, last-updated timestamp) |

---

## Where Things Live

| Item | Default path |
|---|---|
| Upstream source | `~/Library/Application Support/MLX Training Studio/source` |
| Install manifest | `~/Library/Application Support/MLX Training Studio/manifest.json` |
| Installed app | `/Applications/MLX GUI.app` |

---

## Updating

```sh
mlx-training-studio update
```

This pulls the latest commits from the upstream `main` branch, rebuilds, and atomically replaces the running app.

---

## Uninstalling

```sh
mlx-training-studio uninstall
```

This removes the installed `.app` and prompts you to optionally remove the cloned source directory and manifest.

---

## Troubleshooting

See [docs/TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md) for common issues and remediation steps.

---

## Credits

> **The app being installed here was created by [Steven Atkin](https://github.com/stevenatkin).**
>
> The upstream project — [stevenatkin/mlx-lm-gui](https://github.com/stevenatkin/mlx-lm-gui) — is the sole author of MLX Training Studio. This installer repo is an independent, unaffiliated packaging effort. All credit for the application itself belongs to Steven Atkin and contributors.

The upstream project is licensed under the [Apache License, Version 2.0](https://www.apache.org/licenses/LICENSE-2.0). See [NOTICE](NOTICE) for full attribution.

---

## License

This installer is licensed under the Apache License, Version 2.0. See [LICENSE](LICENSE) and [NOTICE](NOTICE) for details.

---

## Contributing

See [docs/CONTRIBUTING.md](docs/CONTRIBUTING.md).
