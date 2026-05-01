# Troubleshooting

## "xcodebuild: error: tool 'xcodebuild' requires Xcode"

This error means the Command Line Tools are installed but the full Xcode app is not.
Building a Swift app requires the complete Xcode toolchain.

**Fix:**

1. Install full Xcode from the Mac App Store:
   ```sh
   open "https://apps.apple.com/app/xcode/id497799835"
   ```

2. Once installed, point the developer tools path at it:
   ```sh
   sudo xcode-select -s /Applications/Xcode.app/Contents/Developer
   ```

3. Accept the Xcode license:
   ```sh
   sudo xcodebuild -license accept
   ```

4. Re-run `mlx-training-studio doctor` to verify.

---

## macOS Gatekeeper: "cannot verify developer"

Because the app is built locally rather than distributed through the Mac App Store or
with an Apple Developer notarization, Gatekeeper may block it on first launch.

**Fix (option A — command line):**
```sh
xattr -dr com.apple.quarantine "/Applications/MLX GUI.app"
```

**Fix (option B — Finder):**
Right-click the app in `/Applications` and choose "Open". Confirm in the dialog.

This is a one-time action per installation.

---

## "Python 3.12 not found"

The macOS system Python at `/usr/bin/python3` is a stub that installs Command Line
Tools; it is not a usable Python runtime and will not work with mlx-lm-lora.

**Fix:**
```sh
brew install python@3.12
```

After installation, re-run:
```sh
mlx-training-studio doctor
```

The installer searches for `python3.12`, `python3.13`, `python3.14`, and `python3`
(in that order), skipping `/usr/bin/python3`.

---

## "Working tree is dirty" during update

If you have modified files inside the source directory
(`~/Library/Application Support/MLX Training Studio/source`), the updater will
refuse to proceed to protect your changes.

**Fix:**

1. Back up any local changes you want to keep.
2. Reset the working tree:
   ```sh
   cd ~/Library/Application\ Support/MLX\ Training\ Studio/source
   git status         # review what's changed
   git stash          # or git checkout -- .
   ```
3. Re-run `mlx-training-studio update`.

---

## Build failures

**Xcode license not accepted:**
```sh
sudo xcodebuild -license accept
```

**Stale derived data:** clear the local build cache and retry:
```sh
rm -rf ~/Library/Application\ Support/MLX\ Training\ Studio/source/.build
mlx-training-studio install
```

**Missing Swift packages:** if the project uses Swift Package Manager dependencies,
ensure you have a network connection for the first build so SPM can resolve them.

---

## "Apple Silicon required" / Intel Mac not supported

The upstream application (`stevenatkin/mlx-lm-gui`) is built around Apple's MLX
framework, which targets Apple Silicon only. Intel Macs are not supported.

The `mlx-training-studio doctor` command will report this as a hard failure. There
is no workaround — the upstream app itself must be updated to support Intel.

---

## Checking overall health

Run the doctor command at any time to see a pass/fail summary of all requirements:

```sh
mlx-training-studio doctor
```
