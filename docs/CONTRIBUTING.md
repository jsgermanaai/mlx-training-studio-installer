# Contributing

Thank you for your interest in contributing to MLX Training Studio Installer.

## Setting up a development environment

The installer is pure Bash. No compiled dependencies are needed beyond standard
macOS tools.

### Recommended tools

| Tool | Purpose | Install |
|---|---|---|
| [shellcheck](https://www.shellcheck.net/) | Static analysis for shell scripts | `brew install shellcheck` |
| [shfmt](https://github.com/mvdan/sh) | Shell script formatter | `brew install shfmt` |

### Install dev tools

```sh
brew install shellcheck shfmt
```

### Lint

```sh
shellcheck install.sh bin/mlx-training-studio lib/*.sh
```

### Format check

```sh
shfmt --diff install.sh bin/mlx-training-studio lib/*.sh
```

### Format in place

```sh
shfmt -w install.sh bin/mlx-training-studio lib/*.sh
```

## Testing changes locally

The safest way to test is with the doctor subcommand, which runs all preflight
checks without modifying anything:

```sh
bash bin/mlx-training-studio doctor
```

To test the full install flow without affecting your real `/Applications`:

```sh
MLX_TS_INSTALL_DIR="${HOME}/Applications" \
MLX_TS_SOURCE_DIR="/tmp/mlx-ts-test-source" \
MLX_TS_NONINTERACTIVE=1 \
  bash bin/mlx-training-studio install
```

Clean up after a test run:

```sh
rm -rf /tmp/mlx-ts-test-source
rm -rf "${HOME}/Applications/MLX GUI.app"
rm -f "${HOME}/Library/Application Support/MLX Training Studio/manifest.json"
```

## Commit message style

This project follows [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>(<scope>): <short summary>

[optional body]
```

Types: `feat`, `fix`, `docs`, `refactor`, `test`, `ci`, `chore`.

Examples:
```
feat(checks): add check_disk_space warning threshold option
fix(build): quote xcodeproj path to handle space in project name
docs(troubleshooting): add Gatekeeper quarantine fix
```

## Pull request guidelines

1. Fork the repo and create a branch named `<type>/<short-description>`.
2. Ensure `shellcheck` passes with no new warnings.
3. Ensure `shfmt --diff` reports no formatting differences.
4. Test locally with `MLX_TS_NONINTERACTIVE=1` before opening a PR.
5. Write a clear description of what changed and why.
6. Reference any related issues in the PR body.

## Scope

This repo is intentionally a thin installer wrapper. Please do not add:
- Auto-update daemons or background services
- Analytics or telemetry of any kind
- Features that belong in the upstream application

For upstream app improvements, open an issue or PR at
[stevenatkin/mlx-lm-gui](https://github.com/stevenatkin/mlx-lm-gui).
