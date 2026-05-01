# Files & Paths

Everything the installer reads and writes is listed here. No files are created
outside these locations without explicit user input.

---

## Path reference

| Item | Default path | Created by | Removed by |
|---|---|---|---|
| Upstream source clone | `~/Library/Application Support/MLX Training Studio/source` | `install`, `update` | `uninstall` (if user confirms) |
| Install manifest | `~/Library/Application Support/MLX Training Studio/manifest.json` | `install`, `update` | `uninstall` (always) |
| Installed app | `/Applications/MLX GUI.app` | `install`, `update` | `uninstall` |
| Xcode derived data | `<source_dir>/.build/` | `build_app` | Not removed by installer — clear manually to free space |
| Homebrew shim | `$(brew --prefix)/bin/mlx-training-studio` | Homebrew | `brew uninstall` |
| Homebrew cellar | `$(brew --prefix)/Cellar/mlx-training-studio/` | Homebrew | `brew uninstall` |

All paths can be overridden with environment variables — see
[Environment Variables](env-vars.md).

---

## `~/Library/Application Support/MLX Training Studio/`

This directory is the installer's home base. It contains:

```
~/Library/Application Support/MLX Training Studio/
├── manifest.json          ← installer manifest (written by this installer)
└── source/                ← upstream git clone (stevenatkin/mlx-lm-gui)
    ├── .build/            ← Xcode derived data (large; safe to delete)
    ├── MLX GUI.xcodeproj/
    └── ...
```

The app itself may also write data to this directory (or a subdirectory) for
its own storage of training configs and venv files. The installer only manages
`manifest.json` and `source/` — it does not touch anything else inside this
directory.

---

## Manifest schema { #manifest-schema }

The manifest is a plain JSON file written without requiring `jq`. Schema:

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

| Field | Type | Description |
|---|---|---|
| `installer_version` | string | SemVer of this installer at the time of install/update. |
| `installed_at` | string | ISO 8601 UTC timestamp of the last install or update. |
| `upstream_commit` | string | Full commit SHA of the upstream source at install time. |
| `upstream_remote` | string | The git remote URL that was cloned. |
| `app_path` | string | Absolute path to the installed `.app` bundle. |
| `source_path` | string | Absolute path to the upstream source clone directory. |

The `update` command reads `source_path` and `app_path` from the manifest to
recover the correct install paths even if the user has changed the defaults
since the original install.

---

## Xcode derived data

Xcode writes build artifacts to `<source_dir>/.build/Build/Products/Release/`.
After a successful install, this directory is no longer needed and can be deleted
to recover several gigabytes of disk space:

```sh
rm -rf ~/Library/Application\ Support/MLX\ Training\ Studio/source/.build
```

The next `update` or `install` will recreate it.

---

## Homebrew paths

When installed via Homebrew:

```sh
# The shim that sets MLX_TS_LIB_DIR
$(brew --prefix)/bin/mlx-training-studio

# The actual script and lib/ directory
$(brew --prefix)/Cellar/mlx-training-studio/<version>/bin/mlx-training-studio
$(brew --prefix)/Cellar/mlx-training-studio/<version>/lib/
```

The Homebrew formula creates a shim at `$(brew --prefix)/bin/mlx-training-studio`
that sets `MLX_TS_LIB_DIR` to the cellar's `lib/` directory before delegating to
the real script. This ensures the CLI finds its libraries regardless of where
Homebrew is installed (`/opt/homebrew` on Apple Silicon, `/usr/local` on older
setups).
