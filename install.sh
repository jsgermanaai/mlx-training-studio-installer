#!/usr/bin/env bash
# install.sh — top-level entry point for MLX Training Studio Installer.
#
# Works in two modes:
#   1. Piped via curl | bash: bootstraps by cloning this repo to a temp dir,
#      then re-execs bin/mlx-training-studio with the "install" subcommand.
#   2. Executed from a clone: delegates directly to bin/mlx-training-studio.

set -euo pipefail
IFS=$'\n\t'

INSTALLER_REPO="https://github.com/jsgermanaai/mlx-training-studio-installer.git"

# Detect whether we are running from a real file on disk (clone mode) or from
# a pipe (curl | bash). In pipe mode BASH_SOURCE[0] is either empty, "main",
# or a non-existent path. The robust test is: does it resolve to a real file?
_is_pipe_mode() {
  [[ -z "${BASH_SOURCE[0]:-}" ]] || [[ ! -f "${BASH_SOURCE[0]}" ]]
}

_bootstrap_from_pipe() {
  echo "MLX Training Studio Installer — bootstrapping from network..."
  local tmp_dir
  tmp_dir="$(mktemp -d)"
  # Ensure temp dir is cleaned up on exit.
  trap 'rm -rf "$tmp_dir"' EXIT

  echo "Cloning installer to temporary directory: $tmp_dir"
  git clone --depth=1 "$INSTALLER_REPO" "$tmp_dir/installer"

  echo "Launching installer..."
  exec bash "$tmp_dir/installer/bin/mlx-training-studio" "${@:-install}"
}

_run_from_clone() {
  local script_dir
  script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  exec bash "$script_dir/bin/mlx-training-studio" "${@:-install}"
}

main() {
  if _is_pipe_mode; then
    _bootstrap_from_pipe "$@"
  else
    _run_from_clone "$@"
  fi
}

main "$@"
