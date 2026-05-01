# MLX Training Studio Installer

<p align="center">
  <strong>One-command installer for MLX Training Studio.</strong><br>
  <em>A native macOS GUI for fine-tuning LLMs on Apple Silicon, packaged for one-line install.</em>
</p>

<p align="center">
  <img src="assets/upstream/image2.png" width="700" alt="MLX Training Studio main window — training jobs sidebar and new training panel" />
</p>
<p align="center">
  <sup>
    Screenshot from upstream
    <a href="https://github.com/stevenatkin/mlx-lm-gui">stevenatkin/mlx-lm-gui</a>
    &nbsp;&middot;&nbsp; Apache-2.0
  </sup>
</p>

---

[MLX Training Studio](https://github.com/stevenatkin/mlx-lm-gui) is a native Swift macOS application
built by [Steven Atkin](https://github.com/stevenatkin) that puts a polished graphical interface
in front of Apple's [mlx-lm-lora](https://github.com/ml-explore/mlx-examples/tree/main/llms/mlx_lm)
fine-tuning library. It supports LoRA and QLoRA training for a wide range of open models directly
on your Apple Silicon Mac — no cloud, no Docker, no CUDA.

This repository is an **installer wrapper**, not the application itself. Because the upstream project
ships source code only (no signed binaries or App Store listing), this installer automates the
clone-build-install cycle: it runs preflight checks, clones the upstream source, builds it with
Xcode, and places the resulting `.app` in `/Applications`. It also handles updates and uninstalls,
and records a manifest so every operation is fully traceable and reversible.

---

<div class="grid cards" markdown>

-   :material-rocket-launch: **Frictionless install**

    ---

    One Homebrew formula. One command to build and place the app. The installer handles
    everything from cloning the upstream source to the final `open` call.

    [Quick install &rarr;](getting-started/quick-install.md)

-   :material-check-circle: **Hardware-aware preflight**

    ---

    Before touching your system, `mlx-training-studio doctor` verifies macOS version,
    Apple Silicon, full Xcode, Python 3.12+, git, and available disk space — and
    tells you exactly how to fix any failure.

    [Requirements &rarr;](getting-started/requirements.md)

-   :material-recycle: **Fully reversible**

    ---

    Every install writes a manifest. `uninstall` reads it back and removes exactly
    what was placed — no guesswork, no orphaned files. Re-running `install` is
    always safe.

    [Commands &rarr;](usage/commands.md)

</div>

---

## Quick start

```sh
# 1. Add the tap and install the CLI
brew tap jsgermanaai/tap
brew install jsgermanaai/tap/mlx-training-studio

# 2. Run preflight checks
mlx-training-studio doctor

# 3. Build and install the app
mlx-training-studio install
```

After the build completes (allow 5–10 minutes the first time), launch the app:

```sh
open "/Applications/MLX GUI.app"
```

---

## Where to go next

- [Getting started overview](getting-started/index.md) — understand the full journey before running anything.
- [Requirements](getting-started/requirements.md) — verify your machine is ready.
- [Commands reference](usage/commands.md) — full documentation for every subcommand.

---

!!! info "Credits"
    **MLX Training Studio** (the application installed by this repo) was created by
    [Steven Atkin](https://github.com/stevenatkin) and is published at
    [stevenatkin/mlx-lm-gui](https://github.com/stevenatkin/mlx-lm-gui)
    under the Apache License 2.0.

    This installer is an independent, unaffiliated packaging effort by
    [Jay German](https://github.com/jsgermanaai). All credit for the application itself
    belongs to Steven Atkin and contributors.
