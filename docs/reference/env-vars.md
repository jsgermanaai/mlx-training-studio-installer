# Environment Variables

All `MLX_TS_*` environment variables are read at runtime — the installer never
writes a `.env` file or persists them. Set them in your shell, in a CI
environment, or prefix them on the command line.

---

## Reference table

| Variable | Purpose | Default | Example |
|---|---|---|---|
| `MLX_TS_NONINTERACTIVE` | Skip all interactive prompts; accept defaults silently. Set to `1` to enable. | _(unset — interactive)_ | `MLX_TS_NONINTERACTIVE=1` |
| `MLX_TS_SOURCE_DIR` | Directory where the upstream `stevenatkin/mlx-lm-gui` source is cloned. Created if it does not exist. | `~/Library/Application Support/MLX Training Studio/source` | `MLX_TS_SOURCE_DIR=/opt/mlx-src` |
| `MLX_TS_INSTALL_DIR` | Parent directory where `MLX GUI.app` is placed. | `/Applications` | `MLX_TS_INSTALL_DIR="${HOME}/Applications"` |
| `MLX_TS_REF` | Git ref to check out after cloning or fetching. Empty string tracks `HEAD`. Accepts commit SHA, branch, or tag. | _(empty — tracks HEAD)_ | `MLX_TS_REF=a3f9c21` |
| `MLX_TS_LIB_DIR` | Path to the installer's `lib/` directory. Set automatically by the Homebrew formula shim. Rarely needed manually. | _(auto-resolved from `bin/` location)_ | `MLX_TS_LIB_DIR=/usr/local/lib/mlx-ts` |

---

## Precedence

For `MLX_TS_SOURCE_DIR` and `MLX_TS_INSTALL_DIR`:

1. **Environment variable** — takes priority if set.
2. **Interactive prompt** — used if the variable is unset and a TTY is available.
3. **Manifest** — for `update`, stored paths from the manifest are used as
   fallbacks after env vars but before the prompt.
4. **Hardcoded default** — last resort.

---

## Combining for unattended installs

```sh
# Fully automated install — no prompts, custom paths, pinned commit
MLX_TS_NONINTERACTIVE=1 \
MLX_TS_SOURCE_DIR="${HOME}/opt/mlx-lm-gui-source" \
MLX_TS_INSTALL_DIR="${HOME}/Applications" \
MLX_TS_REF="a3f9c21b84d7e05c1f2843b6d9a0e1f3c5d2e4b8" \
  mlx-training-studio install
```

```sh
# CI environment — install to a test location
MLX_TS_NONINTERACTIVE=1 \
MLX_TS_INSTALL_DIR="/tmp/mlx-test-applications" \
MLX_TS_SOURCE_DIR="/tmp/mlx-test-source" \
  mlx-training-studio install
```

---

## Cleanup after test installs

```sh
rm -rf /tmp/mlx-test-source
rm -rf /tmp/mlx-test-applications/MLX\ GUI.app
rm -f "${HOME}/Library/Application Support/MLX Training Studio/manifest.json"
```

!!! tip
    In non-interactive mode, the uninstall prompt "Remove source directory?"
    defaults to **no**. To clean up the source dir automatically, either remove
    it manually (as above) or set `MLX_TS_SOURCE_DIR` and handle it in your
    own script.
