# Requirements

Before running the installer, confirm that your machine meets every item on this
page. The `doctor` subcommand automates most of these checks — but it is worth
reading through them once so you understand what is being verified and why.

---

## :material-cpu-64-bit: Apple Silicon

The upstream application is built around Apple's
[MLX](https://github.com/ml-explore/mlx) framework, which targets Apple Silicon
exclusively. Intel Macs are not supported.

| Chip family | Status |
|---|---|
| M1, M1 Pro, M1 Max, M1 Ultra | Supported |
| M2, M2 Pro, M2 Max, M2 Ultra | Supported |
| M3, M3 Pro, M3 Max | Supported |
| M4, M4 Pro, M4 Max | Supported |
| Intel | **Not supported** |

!!! tip "More unified memory = larger models"
    The training process keeps model weights, gradients, and activations all in
    unified memory. 16 GB is comfortable for 1–3 B parameter models at full
    precision; 32 GB or more opens up 7 B+ models.

Verify your architecture:

```sh
uname -m
# Expected: arm64
```

---

## :material-apple: macOS 13 Ventura or later

The installer enforces a minimum of macOS 13.0. Most users should be on 14 or 15.

```sh
sw_vers -productVersion
# Example output: 14.5
```

---

## :material-wrench: Full Xcode (not Command Line Tools)

This is the most common stumbling block. The upstream project is a Swift app — it
requires the **full Xcode IDE** to build, not just the Command Line Tools package.

| Install type | Path reported by `xcode-select -p` | Sufficient? |
|---|---|---|
| Command Line Tools only | `/Library/Developer/CommandLineTools` | No |
| Full Xcode | `/Applications/Xcode.app/Contents/Developer` | Yes |

!!! warning "xcodebuild requires Xcode"
    If only Command Line Tools are installed, `xcodebuild` will print:
    ```
    xcodebuild: error: tool 'xcodebuild' requires Xcode, but
    active developer directory '/Library/Developer/CommandLineTools'
    is a command line tools instance.
    ```
    `mlx-training-studio doctor` will catch this and print remediation steps.

=== "Install Xcode"

    Open the Mac App Store page directly:

    ```sh
    open "https://apps.apple.com/app/xcode/id497799835"
    ```

    Xcode is large (~14 GB). Allow time for the download and first-run setup.

=== "Switch active developer directory"

    If you have Xcode installed but the developer path still points to Command
    Line Tools, switch it:

    ```sh
    sudo xcode-select -s /Applications/Xcode.app/Contents/Developer
    ```

    Verify:

    ```sh
    xcode-select -p
    # Expected: /Applications/Xcode.app/Contents/Developer

    xcodebuild -version
    # Expected: Xcode 16.x  (or whatever version you have)
    #           Build version ...
    ```

=== "Accept the license"

    After a fresh Xcode install, you must accept the license before `xcodebuild`
    will function:

    ```sh
    sudo xcodebuild -license accept
    ```

    You will see the license text scroll by, then a confirmation prompt. Type
    `agree` and press ++return++.

---

## :material-language-python: Python 3.12 or later

The app's Python environment (venv, mlx-lm-lora installation) requires Python
3.12 or later. The macOS system stub at `/usr/bin/python3` does **not** qualify —
it is a shim that triggers a Command Line Tools dialog and cannot install packages.

The installer searches for `python3.12`, `python3.13`, `python3.14`, and `python3`
(in that order), skipping `/usr/bin/python3`.

Check what you have:

```sh
which python3
python3 --version
```

=== "Homebrew (recommended)"

    ```sh
    brew install python@3.12
    ```

    After installation, the binary is at `/opt/homebrew/bin/python3.12`.

=== "pyenv"

    If you manage multiple Python versions with pyenv:

    ```sh
    pyenv install 3.12.9
    pyenv global 3.12.9
    python3 --version
    # Python 3.12.9
    ```

---

## :material-harddisk: Disk space

Allow at least **5 GB** of free space in your home directory before installing:

- ~1 GB — upstream source clone
- ~3 GB — Xcode derived data (build artifacts; can be cleared after install)
- ~1 GB — headroom for the first model download inside the app

The installer warns (but does not abort) if free space is below 5 GB.

---

## :material-account: Hugging Face account

Not required to install the app, but required to download most modern models.
Create a free account at [huggingface.co](https://huggingface.co) and generate
a read token at [huggingface.co/settings/tokens](https://huggingface.co/settings/tokens).

You will paste the token into the app's Settings panel during [first run](first-run.md).

---

!!! abstract "Run all checks at once"
    ```sh
    mlx-training-studio doctor
    ```
    This runs every check above and prints a pass/fail summary with remediation
    steps for any failure. See [Commands](../usage/commands.md#doctor) for
    example output.
