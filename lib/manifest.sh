#!/usr/bin/env bash
# lib/manifest.sh — Manifest path constants and shared helpers.
#
# The manifest is a JSON file recording what was installed, where, and when.
# Requires lib/log.sh to be sourced first.

set -euo pipefail
IFS=$'\n\t'

# ---------------------------------------------------------------------------
# Constants
# ---------------------------------------------------------------------------

MANIFEST_DIR="${HOME}/Library/Application Support/MLX Training Studio"
MANIFEST_PATH="${MANIFEST_DIR}/manifest.json"

# ---------------------------------------------------------------------------
# manifest_exists — return 0 if a manifest file is present.
# ---------------------------------------------------------------------------
manifest_exists() {
  [[ -f "$MANIFEST_PATH" ]]
}

# ---------------------------------------------------------------------------
# read_manifest — print the manifest contents to stdout if it exists.
# ---------------------------------------------------------------------------
read_manifest() {
  if ! manifest_exists; then
    warn "No manifest found at: $MANIFEST_PATH"
    warn "MLX Training Studio does not appear to be installed."
    return 1
  fi
  cat "$MANIFEST_PATH"
}

# ---------------------------------------------------------------------------
# write_manifest — write a JSON manifest without requiring jq.
# Arguments (positional):
#   $1 — installer_version
#   $2 — upstream_commit
#   $3 — upstream_remote
#   $4 — app_path
#   $5 — source_path
# ---------------------------------------------------------------------------
write_manifest() {
  local installer_version="$1"
  local upstream_commit="$2"
  local upstream_remote="$3"
  local app_path="$4"
  local source_path="$5"
  local installed_at
  installed_at="$(date -u '+%Y-%m-%dT%H:%M:%SZ')"

  mkdir -p "$MANIFEST_DIR"

  printf '{
  "installer_version": "%s",
  "installed_at": "%s",
  "upstream_commit": "%s",
  "upstream_remote": "%s",
  "app_path": "%s",
  "source_path": "%s"
}\n' \
    "$installer_version" \
    "$installed_at" \
    "$upstream_commit" \
    "$upstream_remote" \
    "$app_path" \
    "$source_path" \
    >"$MANIFEST_PATH"

  ok "Manifest written to: $MANIFEST_PATH"
}
