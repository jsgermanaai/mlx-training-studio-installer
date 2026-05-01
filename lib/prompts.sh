#!/usr/bin/env bash
# lib/prompts.sh — Interactive setup prompts for MLX Training Studio Installer.
#
# Asks the user for installation preferences and exports them as env vars.
# Respects MLX_TS_NONINTERACTIVE=1 to skip all prompts and use defaults.
# Requires lib/log.sh to be sourced first.

set -euo pipefail
IFS=$'\n\t'

# ---------------------------------------------------------------------------
# Default values
# ---------------------------------------------------------------------------

_DEFAULT_SOURCE_DIR="${HOME}/Library/Application Support/MLX Training Studio/source"
_DEFAULT_INSTALL_LOCATION="/Applications"
_DEFAULT_REF="HEAD"

# ---------------------------------------------------------------------------
# gather_install_preferences — populates the following exported variables:
#   MLX_TS_SOURCE_DIR     — where to clone upstream source
#   MLX_TS_INSTALL_DIR    — where to install the .app (/Applications or ~/Applications)
#   MLX_TS_REF            — git ref to pin (empty string = track HEAD)
# ---------------------------------------------------------------------------
gather_install_preferences() {
  # --- Source directory ---
  if [[ -z "${MLX_TS_SOURCE_DIR:-}" ]]; then
    prompt MLX_TS_SOURCE_DIR \
      "Source directory (upstream will be cloned here)" \
      "$_DEFAULT_SOURCE_DIR"
  fi
  export MLX_TS_SOURCE_DIR

  # --- Install location ---
  if [[ -z "${MLX_TS_INSTALL_DIR:-}" ]]; then
    info "Install location options:"
    info "  1) /Applications         (system-wide, requires no sudo for bundles)"
    info "  2) ~/Applications        (user-local)"
    local choice
    prompt choice "Choose install location [1/2]" "1"
    case "$choice" in
      2) MLX_TS_INSTALL_DIR="${HOME}/Applications" ;;
      *) MLX_TS_INSTALL_DIR="/Applications" ;;
    esac
  fi
  export MLX_TS_INSTALL_DIR

  # --- Git ref ---
  if [[ -z "${MLX_TS_REF:-}" ]]; then
    info "Pin to a specific commit or tag, or track the latest HEAD."
    info "Upstream (stevenatkin/mlx-lm-gui) has no published tags as of this installer's release."
    local ref_input
    prompt ref_input \
      "Git ref to pin (commit SHA, tag, or leave blank to track HEAD)" \
      ""
    MLX_TS_REF="${ref_input:-}"
  fi
  export MLX_TS_REF

  echo >&2
  info "Install preferences:"
  info "  Source directory : $MLX_TS_SOURCE_DIR"
  info "  Install location : $MLX_TS_INSTALL_DIR"
  if [[ -n "${MLX_TS_REF:-}" ]]; then
    info "  Pinned ref       : $MLX_TS_REF"
  else
    info "  Tracking         : HEAD (latest)"
  fi
  echo >&2
}
