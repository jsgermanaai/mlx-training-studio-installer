# Contributing

Contributions to the installer are welcome. The project is intentionally a thin
wrapper — please keep that scope in mind when proposing changes.

---

## Dev environment setup

The installer is pure Bash. You need:

- macOS with Apple Silicon (to run and test the install flow end-to-end)
- [shellcheck](https://www.shellcheck.net/) — static analysis for shell scripts
- [shfmt](https://github.com/mvdan/sh) — shell script formatter
- [mkdocs-material](https://squidfunk.github.io/mkdocs-material/) — for docs
  contributions

```sh
# Install lint/format tools
brew install shellcheck shfmt

# Install docs dependencies
pip install -r requirements-docs.txt
```

---

## Working on the docs

The documentation site uses [MkDocs Material](https://squidfunk.github.io/mkdocs-material/).
To preview locally:

```sh
pip install -r requirements-docs.txt
mkdocs serve
```

Then open [http://127.0.0.1:8000](http://127.0.0.1:8000) in your browser.
Changes to any `docs/*.md` file reload automatically.

To build a static site for inspection:

```sh
mkdocs build --strict
```

The `--strict` flag treats warnings as errors — the same mode used in CI.

---

## Lint and format

```sh
# Check for issues
shellcheck install.sh bin/mlx-training-studio lib/*.sh

# Check formatting (does not modify files)
shfmt --diff install.sh bin/mlx-training-studio lib/*.sh

# Apply formatting
shfmt -w install.sh bin/mlx-training-studio lib/*.sh
```

Both `shellcheck` and `shfmt` run automatically on every push and pull request
via the [CI workflow](https://github.com/jsgermanaai/mlx-training-studio-installer/blob/main/.github/workflows/ci.yml).

---

## Testing changes

### Run preflight checks (no side effects)

```sh
bash bin/mlx-training-studio doctor
```

### Test a full install in an isolated location

```sh
MLX_TS_NONINTERACTIVE=1 MLX_TS_INSTALL_DIR="${HOME}/Applications" MLX_TS_SOURCE_DIR="/tmp/mlx-ts-test-source"   bash bin/mlx-training-studio install
```

### Clean up after a test run

```sh
rm -rf /tmp/mlx-ts-test-source
rm -rf "${HOME}/Applications/MLX GUI.app"
rm -f "${HOME}/Library/Application Support/MLX Training Studio/manifest.json"
```

---

## Commit message style

This project uses [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>(<scope>): <short summary in imperative mood>

[optional body — explain why, not what]
```

**Types:**

| Type | Use for |
|---|---|
| `feat` | New feature or capability |
| `fix` | Bug fix |
| `docs` | Documentation changes only |
| `refactor` | Code change that neither fixes a bug nor adds a feature |
| `test` | Adding or improving tests |
| `ci` | Changes to CI workflows |
| `chore` | Dependency bumps, config tweaks, etc. |

**Examples:**

```
feat(checks): add disk space warning threshold option
fix(build): quote xcodeproj path to handle space in project name
docs(troubleshooting): add Gatekeeper quarantine fix
ci: switch to actions/deploy-pages for MkDocs deploy
```

---

## Pull request guidelines

1. Fork the repository and create a branch named `<type>/<short-description>`,
   e.g., `fix/gatekeeper-quarantine-flag`.
2. Make sure `shellcheck` passes with no new warnings.
3. Make sure `shfmt --diff` reports no formatting differences.
4. Test locally with `MLX_TS_NONINTERACTIVE=1` before opening a PR.
5. Write a clear PR description explaining what changed and why. Reference any
   related issues.
6. Keep PRs focused — one logical change per PR.

---

## Scope

This repo is intentionally a thin installer wrapper. Please do not add:

- Auto-update daemons or background services
- Analytics or telemetry of any kind
- Features that belong in the upstream application itself

For upstream app improvements (new training modes, UI changes, etc.), open an
issue or PR at [stevenatkin/mlx-lm-gui](https://github.com/stevenatkin/mlx-lm-gui).

---

## Code of conduct

This project follows the spirit of the
[Contributor Covenant](https://www.contributor-covenant.org/). Be respectful,
constructive, and assume good faith. Issues and PRs that are abusive, off-topic,
or spam will be closed without discussion.
