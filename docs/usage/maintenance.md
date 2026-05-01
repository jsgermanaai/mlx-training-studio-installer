# Updating & Uninstalling

---

## Updating

```sh
mlx-training-studio update
```

The `update` command fetches the latest changes from the upstream repository,
rebuilds the app, and atomically replaces the installed `.app`. Your existing
training configurations and model adapters are not affected — they live in a
separate location managed by the app itself.

### What update does, step by step

1. Reads the install manifest to recover `source_path` and `app_path`.
2. Runs all preflight checks (same as `doctor`).
3. Inside `source_path`, runs:
   ```sh
   git fetch --quiet origin
   git reset --hard origin/main
   ```
4. If `MLX_TS_REF` is set, additionally runs `git checkout <ref>`.
5. Rebuilds with `xcodebuild -configuration Release`.
6. Atomically replaces `MLX GUI.app` via a `.tmp` intermediate.
7. Writes an updated manifest with the new commit SHA and timestamp.

### When to update

- When the upstream project adds new training modes, model support, or bug fixes.
- After `mlx-training-studio status` shows an older commit than `origin/main`.
- Whenever the app behavior feels stale relative to the upstream changelog.

### Pinning a specific commit

If you want to lock to a known-good upstream commit rather than always tracking
`HEAD`, set `MLX_TS_REF` before calling `update` (or `install`):

```sh
MLX_TS_REF=a3f9c21b84d7e05c1f2843b6d9a0e1f3c5d2e4b8 mlx-training-studio update
```

To return to tracking HEAD, unset `MLX_TS_REF` and run `update` again:

```sh
unset MLX_TS_REF
mlx-training-studio update
```

!!! warning "Dirty source directory"
    If you have modified files in the source directory, `update` will refuse to
    proceed to protect your changes:

    ```
    [ERR ] Working tree is dirty in <source_dir>. Back up your changes and re-run.
    ```

    To resolve:
    ```sh
    cd ~/Library/Application\ Support/MLX\ Training\ Studio/source
    git status          # review changes
    git stash           # or: git checkout -- .  to discard
    mlx-training-studio update
    ```

---

## Uninstalling

```sh
mlx-training-studio uninstall
```

Removes the installed `.app` and the manifest. Optionally removes the cloned
source directory.

### What uninstall removes

| Item | Removed by default | Prompted |
|---|---|---|
| `MLX GUI.app` (from install dir) | Yes | No |
| Install manifest (`manifest.json`) | Yes | No |
| Source clone (`source_path`) | No | Yes — defaults to **no** |

!!! note
    App-internal data — training configurations, model adapter weights,
    `~/Library/Application Support/MLX Training Studio/` (other than the
    manifest) — is **not** touched by `uninstall`. Remove those manually if
    you want a completely clean slate.

### Non-interactive uninstall

```sh
MLX_TS_NONINTERACTIVE=1 mlx-training-studio uninstall
```

The "Remove source directory?" prompt defaults to **no** in non-interactive mode,
so only the `.app` and manifest are removed.

---

## Reinstalling

Re-running `install` is always safe. The installer is idempotent:

- If the source directory already exists, it fetches and resets to `origin/main`
  instead of cloning from scratch.
- The `.app` is replaced atomically, so no half-installed state can occur.

```sh
mlx-training-studio install
```

---

## Full reset (clean slate)

To remove everything including app data:

```sh
# 1. Uninstall the app and manifest
mlx-training-studio uninstall

# 2. When prompted "Remove source directory?", type y
#    Or run non-interactively with explicit source removal:
rm -rf ~/Library/Application\ Support/MLX\ Training\ Studio/source

# 3. Remove app-internal data (training configs, venv, adapters)
rm -rf ~/Library/Application\ Support/MLX\ Training\ Studio

# 4. Verify
mlx-training-studio status
# Expected: [WARN] No manifest found...
```

After a full reset, run `mlx-training-studio install` to start fresh.

---

## Migrating to a new machine

The source clone and installed app are machine-specific (compiled for your exact
Xcode and macOS version). **Do not copy the `.app` binary between machines.**

To migrate:

1. Install the CLI on the new machine (Homebrew or clone).
2. Run `mlx-training-studio install` — the installer will clone upstream and
   build a fresh `.app` natively.
3. Copy any training configuration YAML files from the old machine's
   `~/Library/Application Support/MLX Training Studio/` to the same path on the
   new machine.
