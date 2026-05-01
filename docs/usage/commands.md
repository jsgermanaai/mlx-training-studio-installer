# Commands

`mlx-training-studio` is a CLI dispatcher with six subcommands. All subcommands
write log output to **stderr** so that stdout stays clean for piping. Exit codes
follow Unix conventions: `0` on success, non-zero on failure.

---

## install { #install }

```sh
mlx-training-studio install
```

Runs the complete install sequence:

1. All preflight checks (same as `doctor`).
2. Interactive prompts for source directory, install location, and optional git
   ref — skipped when `MLX_TS_NONINTERACTIVE=1`.
3. Clone or update the upstream source at `MLX_TS_SOURCE_DIR`.
4. Build `MLX GUI.app` with `xcodebuild -configuration Release`.
5. Copy the built `.app` to `MLX_TS_INSTALL_DIR` atomically (via a `.tmp`
   intermediate).
6. Write the install manifest to
   `~/Library/Application Support/MLX Training Studio/manifest.json`.

**Side effects:** clones/updates `MLX_TS_SOURCE_DIR`, creates
`MLX_TS_INSTALL_DIR/MLX GUI.app`, writes the manifest.

**Exit codes:**

| Code | Meaning |
|---|---|
| `0` | Install succeeded. |
| `1` | Preflight check failed — see error output. |
| `1` | Build failed — see xcodebuild output. |

**Example:**

```text
[INFO] === MLX Training Studio Installer — install ===
[INFO] Running preflight checks...
[ OK ] macOS 14.5 — OK
[ OK ] Architecture: arm64 (Apple Silicon) — OK
[ OK ] Xcode: Xcode 16.2  Build version 16C5032a — OK
[ OK ] Python 3.12 at /opt/homebrew/bin/python3.12 — OK
[ OK ] git version 2.47.1 — OK
[ OK ] Disk space: 128.3 GB free — OK
[INFO] Preflight summary: 6 passed, 0 failed.
[ OK ] All checks passed.

Source directory (upstream will be cloned here) [~/Library/Application Support/MLX Training Studio/source]:
Install location [1]:
Git ref to pin (leave blank to track HEAD):

[INFO] Install preferences:
[INFO]   Source directory : ~/Library/Application Support/MLX Training Studio/source
[INFO]   Install location : /Applications
[INFO]   Tracking         : HEAD (latest)

[INFO] Cloning upstream source to: ~/Library/Application Support/MLX Training Studio/source
[ OK ] Clone complete.
[INFO] Building MLX GUI.app (this may take several minutes)...
[ OK ] ** BUILD SUCCEEDED **
[INFO] Installing MLX GUI.app to /Applications...
[ OK ] Installed: /Applications/MLX GUI.app
[ OK ] Manifest written to: ~/Library/Application Support/MLX Training Studio/manifest.json
[ OK ] === Installation complete ===
[INFO] Launch the app: open "/Applications/MLX GUI.app"
```

!!! tip "Non-interactive install"
    ```sh
    MLX_TS_NONINTERACTIVE=1 mlx-training-studio install
    ```
    Uses all defaults. Combine with `MLX_TS_SOURCE_DIR`, `MLX_TS_INSTALL_DIR`,
    and `MLX_TS_REF` for fully scripted installs. See
    [Environment Variables](../reference/env-vars.md).

---

## update { #update }

```sh
mlx-training-studio update
```

Updates an existing installation:

1. Reads the manifest to recover stored `source_path` and `app_path` (these can
   be overridden with env vars).
2. Runs preflight checks.
3. Fetches the latest changes from `origin/main` (or the pinned ref) and resets
   the working tree.
4. Rebuilds and atomically replaces the installed `.app`.
5. Rewrites the manifest with the new commit SHA and timestamp.

**Requires:** an existing manifest (`mlx-training-studio install` must have been
run before).

!!! warning "Dirty working tree"
    If the source directory has uncommitted local changes, `update` will abort
    with:
    ```
    [ERR ] Working tree is dirty in <src_dir>. Back up your changes and re-run.
    ```
    Stash or discard local changes before updating.

---

## uninstall { #uninstall }

```sh
mlx-training-studio uninstall
```

Removes the installed app and optionally cleans up source and manifest:

1. Reads the manifest (or falls back to default paths if no manifest exists).
2. Removes `MLX GUI.app` from the install directory.
3. Prompts: "Remove source directory?" — defaults to **no**.
4. Removes the manifest file.

**Side effects:** removes `MLX GUI.app`; optionally removes the source clone.

!!! tip "Non-interactive uninstall"
    ```sh
    MLX_TS_NONINTERACTIVE=1 mlx-training-studio uninstall
    ```
    In non-interactive mode, the "Remove source directory?" prompt defaults to
    **no**, so only the `.app` and manifest are removed.

---

## doctor { #doctor }

```sh
mlx-training-studio doctor
```

Runs all preflight checks and prints a pass/fail summary. Makes **no changes**
to your system.

| Check | What it verifies |
|---|---|
| macOS version | 13.0 (Ventura) or later via `sw_vers` |
| Apple Silicon | `uname -m` == `arm64` |
| Full Xcode | `xcode-select -p` points inside `*.app`, `xcodebuild -version` succeeds |
| Python 3.12+ | Finds `python3.12`–`python3.14` or `python3` ≥ 3.12, excludes `/usr/bin/python3` |
| git | `git` is on `PATH` |
| Disk space | ≥ 5 GB free in `$HOME` (warning only — not a hard failure) |

**Exit codes:** `0` if all hard checks pass; `1` if any hard check fails.

See [Quick Install — doctor output](../getting-started/quick-install.md#what-doctor-output-looks-like)
for example success and failure output.

---

## status { #status }

```sh
mlx-training-studio status
```

Prints the contents of the install manifest to stdout. Useful for checking which
upstream commit is currently installed.

**Example output:**

```json
{
  "installer_version": "0.1.0",
  "installed_at": "2026-04-30T18:42:00Z",
  "upstream_commit": "a3f9c21b84d7e05c1f2843b6d9a0e1f3c5d2e4b8",
  "upstream_remote": "https://github.com/stevenatkin/mlx-lm-gui",
  "app_path": "/Applications/MLX GUI.app",
  "source_path": "/Users/jay/Library/Application Support/MLX Training Studio/source"
}
```

If no manifest exists, `status` prints a warning and exits non-zero.

---

## help { #help }

```sh
mlx-training-studio help
# or
mlx-training-studio --help
mlx-training-studio -h
```

Prints usage information and the list of environment variables.

---

!!! example "Common usage patterns"
    **Check health at any time:**
    ```sh
    mlx-training-studio doctor
    ```

    **Update to latest upstream:**
    ```sh
    mlx-training-studio update
    ```

    **Pin to a specific commit:**
    ```sh
    MLX_TS_REF=a3f9c21 mlx-training-studio install
    ```

    **Install to user Applications folder:**
    ```sh
    MLX_TS_INSTALL_DIR="${HOME}/Applications" mlx-training-studio install
    ```

    **Fully automated (CI/scripted) install:**
    ```sh
    MLX_TS_NONINTERACTIVE=1 \
    MLX_TS_SOURCE_DIR=/opt/mlx-lm-gui-source \
    MLX_TS_INSTALL_DIR=/Applications \
      mlx-training-studio install
    ```
