# Quick Install

Choose the method that fits your workflow. Homebrew is recommended because it
gives you a versioned CLI entry-point and makes future upgrades clean.

=== "Homebrew (recommended)"

    ```sh
    # 1. Add the tap (one-time)
    brew tap jsgermanaai/tap

    # 2. Install the CLI
    brew install jsgermanaai/tap/mlx-training-studio

    # 3. Verify requirements
    mlx-training-studio doctor

    # 4. Build and install the app
    mlx-training-studio install
    ```

    !!! tip "Why Homebrew?"
        The Homebrew formula pins the installer version, integrates with `brew upgrade`,
        and sets `MLX_TS_LIB_DIR` automatically so the CLI finds its libraries
        regardless of where Homebrew stores its cellar.

=== "One-liner curl"

    ```sh
    curl -fsSL \
      https://raw.githubusercontent.com/jsgermanaai/mlx-training-studio-installer/main/install.sh \
      | bash
    ```

    !!! warning "curl | bash defaults"
        Piping to bash accepts all interactive prompts at their default values
        (source in `~/Library/Application Support/MLX Training Studio/source`,
        install to `/Applications`). If you want custom paths, use the Homebrew
        method or the clone-and-run method and set environment variables.

=== "Clone and run"

    ```sh
    git clone https://github.com/jsgermanaai/mlx-training-studio-installer.git
    cd mlx-training-studio-installer
    ./install.sh
    ```

    Or run specific subcommands directly:

    ```sh
    bash bin/mlx-training-studio doctor
    bash bin/mlx-training-studio install
    ```

    !!! note "Full control"
        Cloning gives you access to all environment variable overrides and lets
        you inspect the scripts before running them. This is the best option for
        CI/automation environments.

---

## What `doctor` output looks like

### All checks pass

```text
[INFO] === MLX Training Studio Installer — doctor ===
[INFO] Running preflight checks...
[ OK ] macOS 14.5 — OK
[ OK ] Architecture: arm64 (Apple Silicon) — OK
[ OK ] Xcode: Xcode 16.2
       Build version 16C5032a — OK
[ OK ] Python 3.12 at /opt/homebrew/bin/python3.12 — OK
[ OK ] git version 2.47.1 — OK
[ OK ] Disk space: 128.3 GB free — OK

[INFO] Preflight summary: 6 passed, 0 failed.
[ OK ] All checks passed.
```

### Missing Xcode (example failure)

```text
[INFO] === MLX Training Studio Installer — doctor ===
[INFO] Running preflight checks...
[ OK ] macOS 14.5 — OK
[ OK ] Architecture: arm64 (Apple Silicon) — OK
[ERR ] Developer tools path '/Library/Developer/CommandLineTools'
       does not point to a full Xcode installation.
[ERR ] Command Line Tools alone are not sufficient to build Swift apps.
[ERR ] Remediation:
[ERR ]   1. Install full Xcode from the Mac App Store:
[ERR ]        open 'https://apps.apple.com/app/xcode/id497799835'
[ERR ]   2. After installation, switch the active developer directory:
[ERR ]        sudo xcode-select -s /Applications/Xcode.app/Contents/Developer
[ERR ]   3. Accept the Xcode license:
[ERR ]        sudo xcodebuild -license accept
[ OK ] Python 3.12 at /opt/homebrew/bin/python3.12 — OK
[ OK ] git version 2.47.1 — OK
[ OK ] Disk space: 128.3 GB free — OK

[INFO] Preflight summary: 5 passed, 1 failed.
[ERR ] 1 check(s) failed. Please resolve the issues above and re-run.
```

---

## After the install completes

```sh
open "/Applications/MLX GUI.app"
```

The first time you open the app, Gatekeeper may display a warning because the
app is locally built rather than notarized. See
[First Run](first-run.md#gatekeeper) for the one-line fix.

Continue to [First Run](first-run.md) to configure your Python environment inside
the app.
