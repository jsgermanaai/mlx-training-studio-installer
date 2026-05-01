# Troubleshooting

Use `mlx-training-studio doctor` as your first diagnostic step — it checks the
most common failure conditions and prints remediation instructions automatically.

```sh
mlx-training-studio doctor
```

If doctor passes but something else is wrong, the sections below cover every
known failure mode. Each section includes the actual error message text you
will see, so searching this page should find your issue quickly.

---

??? "Xcode missing or wrong version — `xcodebuild: error: tool 'xcodebuild' requires Xcode`"

    **Symptoms:**

    `mlx-training-studio doctor` prints:
    ```
    [ERR ] Developer tools path '/Library/Developer/CommandLineTools'
           does not point to a full Xcode installation.
    [ERR ] Command Line Tools alone are not sufficient to build Swift apps.
    ```

    Or `xcodebuild` itself says:
    ```
    xcodebuild: error: tool 'xcodebuild' requires Xcode, but active
    developer directory '/Library/Developer/CommandLineTools' is a command
    line tools instance.
    ```

    **Cause:** Only Command Line Tools are installed. Building a Swift app requires
    the full Xcode IDE.

    **Fix:**

    1. Install Xcode from the Mac App Store:
       ```sh
       open "https://apps.apple.com/app/xcode/id497799835"
       ```

    2. Switch the active developer directory:
       ```sh
       sudo xcode-select -s /Applications/Xcode.app/Contents/Developer
       ```

    3. Accept the license:
       ```sh
       sudo xcodebuild -license accept
       ```

    4. Verify:
       ```sh
       xcode-select -p
       # /Applications/Xcode.app/Contents/Developer
       xcodebuild -version
       # Xcode 16.x
       ```

    5. Re-run doctor:
       ```sh
       mlx-training-studio doctor
       ```

---

??? "Gatekeeper blocks launch — `\"MLX GUI.app\" cannot be opened because the developer cannot be verified`"

    **Symptoms:** Double-clicking `MLX GUI.app` shows a dialog:
    > "MLX GUI.app" cannot be opened because the developer cannot be verified.

    **Cause:** macOS quarantines all files downloaded from the internet. When the
    installer copies the built app from the derived data directory to `/Applications`,
    the quarantine attribute is sometimes inherited.

    **Fix (command line — recommended):**
    ```sh
    xattr -dr com.apple.quarantine "/Applications/MLX GUI.app"
    ```

    **Fix (Finder):**
    Right-click `MLX GUI.app` in `/Applications`, choose **Open**, then click
    **Open** in the confirmation dialog. This grants a permanent exception.

    This action is required only once per installation. After `update`, you may
    need to repeat it if the attribute reappears.

---

??? "Python stub — `Python 3.12 not found` / `Command Line Tools requested`"

    **Symptoms:**

    `mlx-training-studio doctor` prints:
    ```
    [ERR ] Python 3.12 or later not found (the /usr/bin/python3 stub does
           not qualify).
    [ERR ] Remediation: brew install python@3.12
    ```

    Or opening a terminal and running `python3` shows a macOS dialog offering
    to install Command Line Tools instead of running Python.

    **Cause:** `/usr/bin/python3` on macOS is a stub. It is not a real Python
    runtime and cannot install packages.

    **Fix:**
    ```sh
    brew install python@3.12
    ```

    After installation:
    ```sh
    which python3.12
    # /opt/homebrew/bin/python3.12
    mlx-training-studio doctor
    ```

---

??? "Update aborted — `Working tree is dirty in <source_dir>`"

    **Symptoms:**

    `mlx-training-studio update` prints:
    ```
    [ERR ] Working tree is dirty in ~/Library/Application Support/
           MLX Training Studio/source. Back up your changes and re-run.
    ```

    **Cause:** Files in the upstream source directory have been modified since
    the last clone or update. The installer refuses to overwrite local changes.

    **Fix:**

    1. Review what changed:
       ```sh
       cd ~/Library/Application\ Support/MLX\ Training\ Studio/source
       git status
       git diff
       ```

    2. If you want to keep the changes, stash them:
       ```sh
       git stash
       ```
       Or copy them out of the directory manually.

    3. If you do not need the changes, discard them:
       ```sh
       git checkout -- .
       ```

    4. Re-run the update:
       ```sh
       mlx-training-studio update
       ```

---

??? "Build fails with code-signing errors — `errSecInternalComponent` / `Apple development team`"

    **Symptoms:**

    `xcodebuild` output contains:
    ```
    error: No signing certificate "Apple Development" found
    error: Code signing is required for product type 'Application' in SDK 'macOS'
    ```
    Or:
    ```
    errSecInternalComponent
    ```

    **Cause:** The upstream Xcode project may have a code-signing requirement
    configured for development builds. Local builds do not require a valid Apple
    Developer account if signing is disabled.

    **Fix:**

    Check whether the project has automatic signing enabled. The installer runs
    with `-configuration Release` but does not pass code-signing flags. If you
    see signing errors, try building manually with signing disabled:

    ```sh
    cd ~/Library/Application\ Support/MLX\ Training\ Studio/source
    xcodebuild \
      -project "MLX GUI.xcodeproj" \
      -configuration Release \
      CODE_SIGN_IDENTITY="" \
      CODE_SIGNING_REQUIRED=NO \
      CODE_SIGNING_ALLOWED=NO \
      clean build
    ```

    If this succeeds, open an issue in the
    [installer repository](https://github.com/jsgermanaai/mlx-training-studio-installer/issues)
    with your Xcode version so the build flags can be updated.

---

??? "App opens then immediately quits"

    **Symptoms:** `MLX GUI.app` launches (icon appears in Dock) but quits within
    a second or two, with no error dialog.

    **Cause:** Usually a missing entitlement or a crash on launch. The most common
    cause is that the app requires disabling the sandbox, and the local build did
    not preserve the entitlements from the Xcode project.

    **Fix:**

    1. Check the system log for crash reports:
       ```sh
       log show --last 5m --predicate 'process == "MLX GUI"' --info
       ```

    2. Look for a crash report in:
       ```sh
       ls ~/Library/Logs/DiagnosticReports/ | grep "MLX GUI"
       ```

    3. If you see `__THE_PROCESS_HAS_FORKED_AND_YOU_CANNOT_USE_THIS_COREFOUNDATION_FUNCTIONALITY___YOU_MUST_EXEC__` or sandbox errors, the entitlements may be missing. Try a clean install:
       ```sh
       mlx-training-studio uninstall
       mlx-training-studio install
       ```

---

??? "Hugging Face token / model download issues"

    **Symptoms:** The app fails to download a model, showing a 401 or 403 error
    in the output log, or `huggingface_hub` raises an authentication error.

    **Cause:** Missing, expired, or incorrectly pasted token.

    **Fix:**

    1. Generate a new read token at
       [huggingface.co/settings/tokens](https://huggingface.co/settings/tokens).
    2. Open the app's Settings panel (++cmd+comma++) and paste the token into
       the **Hugging Face Token** field.
    3. For gated models (Llama 3, Gemma, etc.), ensure you have accepted the
       model's license on the Hugging Face model page before attempting a download.

---

??? "venv creation fails inside the app"

    **Symptoms:** Clicking **Create venv** in Settings produces an error in the
    Output Log such as:
    ```
    Error: No module named venv
    ```
    or:
    ```
    python3: command not found
    ```

    **Cause:** The Python interpreter path in Settings is wrong, or the Python
    installation is incomplete.

    **Fix:**

    1. Verify the path in Settings points to a real Python 3.12+ binary:
       ```sh
       /opt/homebrew/bin/python3.12 --version
       # Python 3.12.x
       ```
    2. If the path is correct but `venv` is missing, reinstall Python:
       ```sh
       brew reinstall python@3.12
       ```
    3. Update the path in Settings if you changed Python installations.

---

??? "mlx-lm-lora install fails — pip errors"

    **Symptoms:** Clicking **Install mlx-lm-lora** in Settings shows pip errors:
    ```
    ERROR: Could not find a version that satisfies the requirement mlx-lm-lora
    ```
    or build errors during wheel compilation.

    **Cause:** Usually a Python version mismatch, no network access, or PyPI
    being temporarily unavailable.

    **Fix:**

    1. Verify network access:
       ```sh
       curl -s https://pypi.org/simple/mlx-lm-lora/ | head -5
       ```

    2. Try installing manually in the venv to see the full error:
       ```sh
       # Activate the venv (path may differ — check app settings)
       source ~/Library/Application\ Support/MLX\ Training\ Studio/venv/bin/activate
       pip install mlx-lm-lora --verbose
       ```

    3. Ensure Python 3.12+ is selected in Settings — older versions may not
       have compatible mlx-lm-lora wheels.
