#!/usr/bin/env bash
# lib/checks.sh — Preflight checks for MLX Training Studio Installer.
#
# Each check function returns 0 on pass, non-zero on fail, and prints a
# clear message via the log helpers. Requires lib/log.sh to be sourced first.

set -euo pipefail
IFS=$'\n\t'

# ---------------------------------------------------------------------------
# check_macos_version — require macOS 13.0 (Ventura) or later.
# ---------------------------------------------------------------------------
check_macos_version() {
  local version
  version="$(sw_vers -productVersion)"
  local major
  major="$(printf '%s' "$version" | cut -d. -f1)"

  if [[ "$major" -lt 13 ]]; then
    err "macOS $version detected. macOS 13.0 (Ventura) or later is required."
    return 1
  fi

  ok "macOS $version — OK"
  return 0
}

# ---------------------------------------------------------------------------
# check_apple_silicon — require arm64 architecture.
# ---------------------------------------------------------------------------
check_apple_silicon() {
  local arch
  arch="$(uname -m)"

  if [[ "$arch" != "arm64" ]]; then
    err "Architecture '$arch' detected. Apple Silicon (arm64) is required."
    err "Intel Macs are not supported by the upstream application."
    return 1
  fi

  ok "Architecture: arm64 (Apple Silicon) — OK"
  return 0
}

# ---------------------------------------------------------------------------
# check_full_xcode — require full Xcode (not just Command Line Tools).
# ---------------------------------------------------------------------------
check_full_xcode() {
  local xcode_path
  if ! xcode_path="$(xcode-select -p 2>/dev/null)"; then
    err "xcode-select: no developer tools path found."
    _print_xcode_remediation
    return 1
  fi

  # Command Line Tools install at /Library/Developer/CommandLineTools, not
  # inside an Xcode.app bundle. Reject paths that don't contain Xcode.app.
  if [[ "$xcode_path" != */Xcode.app/* ]] && [[ "$xcode_path" != */Xcode*.app/* ]]; then
    err "Developer tools path '$xcode_path' does not point to a full Xcode installation."
    err "Command Line Tools alone are not sufficient to build Swift apps."
    _print_xcode_remediation
    return 1
  fi

  # Verify xcodebuild actually works (it may still fail if the license has not
  # been accepted, or if the path is stale).
  local xcodebuild_out
  if ! xcodebuild_out="$(xcodebuild -version 2>&1)"; then
    err "xcodebuild reported an error:"
    err "  $xcodebuild_out"
    err "You may need to accept the Xcode license:"
    err "  sudo xcodebuild -license accept"
    return 1
  fi

  ok "Xcode: $xcodebuild_out — OK"
  return 0
}

# _print_xcode_remediation — internal helper, prints Xcode install steps.
_print_xcode_remediation() {
  err "Remediation:"
  err "  1. Install full Xcode from the Mac App Store:"
  err "       open 'https://apps.apple.com/app/xcode/id497799835'"
  err "  2. After installation, switch the active developer directory:"
  err "       sudo xcode-select -s /Applications/Xcode.app/Contents/Developer"
  err "  3. Accept the Xcode license:"
  err "       sudo xcodebuild -license accept"
  # Attempt to open the App Store page automatically if we have a TTY.
  if [[ -t 1 ]]; then
    open "https://apps.apple.com/app/xcode/id497799835" 2>/dev/null || true
  fi
}

# ---------------------------------------------------------------------------
# check_python — find Python 3.12+, not the macOS stub at /usr/bin/python3.
# Exports MLX_TS_PYTHON with the resolved path on success.
# ---------------------------------------------------------------------------
check_python() {
  local candidates=("python3.14" "python3.13" "python3.12" "python3")
  local found_python=""
  local found_version=""

  for candidate in "${candidates[@]}"; do
    local candidate_path
    candidate_path="$(command -v "$candidate" 2>/dev/null)" || continue

    # Reject the macOS stub — it just prints a dialog.
    if [[ "$candidate_path" == "/usr/bin/python3" ]]; then
      continue
    fi

    # Verify it is actually Python 3.12+.
    local version_str
    version_str="$("$candidate_path" -c 'import sys; print(sys.version_info.major, sys.version_info.minor)' 2>/dev/null)" || continue

    local py_major py_minor
    py_major="$(printf '%s' "$version_str" | awk '{print $1}')"
    py_minor="$(printf '%s' "$version_str" | awk '{print $2}')"

    if [[ "$py_major" -ge 3 ]] && [[ "$py_minor" -ge 12 ]]; then
      found_python="$candidate_path"
      found_version="$py_major.$py_minor"
      break
    fi
  done

  if [[ -z "$found_python" ]]; then
    err "Python 3.12 or later not found (the /usr/bin/python3 stub does not qualify)."
    err "Remediation: brew install python@3.12"
    return 1
  fi

  export MLX_TS_PYTHON="$found_python"
  ok "Python $found_version at $found_python — OK"
  return 0
}

# ---------------------------------------------------------------------------
# check_git — require git on PATH.
# ---------------------------------------------------------------------------
check_git() {
  if ! command -v git &>/dev/null; then
    err "git not found on PATH."
    err "Remediation: install Xcode or Command Line Tools, or 'brew install git'."
    return 1
  fi

  local git_version
  git_version="$(git --version)"
  ok "$git_version — OK"
  return 0
}

# ---------------------------------------------------------------------------
# check_disk_space — warn (do not fail) if less than 5 GB free in $HOME.
# ---------------------------------------------------------------------------
check_disk_space() {
  # df -k reports 1K blocks; 5 GB = 5 * 1024 * 1024 = 5242880 blocks.
  local free_kb
  free_kb="$(df -k "$HOME" 2>/dev/null | awk 'NR==2 {print $4}')"

  if [[ -z "$free_kb" ]]; then
    warn "Could not determine free disk space — skipping disk check."
    return 0
  fi

  local required_kb=$((5 * 1024 * 1024))
  if [[ "$free_kb" -lt "$required_kb" ]]; then
    local free_gb
    free_gb="$(awk "BEGIN {printf \"%.1f\", $free_kb/1024/1024}")"
    warn "Only ${free_gb} GB free in \$HOME. At least 5 GB is recommended."
    warn "The build may fail if disk space is exhausted."
    # Return 0 — this is a warning, not a hard failure.
    return 0
  fi

  local free_gb
  free_gb="$(awk "BEGIN {printf \"%.1f\", $free_kb/1024/1024}")"
  ok "Disk space: ${free_gb} GB free — OK"
  return 0
}

# ---------------------------------------------------------------------------
# run_all_checks — run every check, accumulate results, return non-zero if any
# hard check failed.
# ---------------------------------------------------------------------------
run_all_checks() {
  local pass=0
  local fail=0

  _run_check() {
    local fn="$1"
    if "$fn"; then
      pass=$((pass + 1))
    else
      fail=$((fail + 1))
    fi
  }

  info "Running preflight checks..."
  _run_check check_macos_version
  _run_check check_apple_silicon
  _run_check check_full_xcode
  _run_check check_python
  _run_check check_git
  _run_check check_disk_space

  echo >&2
  info "Preflight summary: $pass passed, $fail failed."

  if [[ "$fail" -gt 0 ]]; then
    err "$fail check(s) failed. Please resolve the issues above and re-run."
    return 1
  fi

  ok "All checks passed."
  return 0
}
