#!/usr/bin/env bash
# lib/build.sh — Clone, build, and install MLX Training Studio.
#
# Requires lib/log.sh and lib/manifest.sh to be sourced first.
# Consumes the following env vars (set by lib/prompts.sh or defaults):
#   MLX_TS_SOURCE_DIR   — clone destination
#   MLX_TS_INSTALL_DIR  — .app install parent directory
#   MLX_TS_REF          — optional git ref to pin

set -euo pipefail
IFS=$'\n\t'

UPSTREAM_REMOTE="https://github.com/stevenatkin/mlx-lm-gui"
XCODEPROJ="MLX GUI.xcodeproj"
APP_NAME="MLX GUI.app"
INSTALLER_VERSION="0.1.0"

# ---------------------------------------------------------------------------
# clone_or_update_source — clone the upstream repo or fetch + reset to latest.
# ---------------------------------------------------------------------------
clone_or_update_source() {
  local src_dir="${MLX_TS_SOURCE_DIR}"

  if [[ -d "$src_dir/.git" ]]; then
    info "Source directory exists. Fetching latest changes..."

    # Refuse to clobber uncommitted local changes.
    local git_status
    git_status="$(git -C "$src_dir" status --porcelain 2>/dev/null)"
    if [[ -n "$git_status" ]]; then
      die "Working tree is dirty in $src_dir. Back up your changes and re-run."
    fi

    git -C "$src_dir" fetch --quiet origin
    git -C "$src_dir" reset --hard origin/main
    ok "Source updated to latest origin/main."
  else
    info "Cloning upstream source to: $src_dir"
    mkdir -p "$(dirname "$src_dir")"
    git clone "$UPSTREAM_REMOTE" "$src_dir"
    ok "Clone complete."
  fi

  # Pin to a specific ref if requested.
  if [[ -n "${MLX_TS_REF:-}" ]]; then
    info "Pinning to ref: $MLX_TS_REF"
    git -C "$src_dir" checkout --quiet "$MLX_TS_REF"
  fi
}

# ---------------------------------------------------------------------------
# build_app — run xcodebuild inside the cloned source directory.
# ---------------------------------------------------------------------------
build_app() {
  local src_dir="${MLX_TS_SOURCE_DIR}"
  local xcodeproj_path="${src_dir}/${XCODEPROJ}"

  if [[ ! -d "$xcodeproj_path" ]]; then
    die "Xcode project not found at: $xcodeproj_path"
  fi

  info "Building $APP_NAME (this may take several minutes)..."

  # NOTE: The space in "MLX GUI.xcodeproj" requires careful quoting.
  # We pass -project as a single quoted argument to xcodebuild.
  xcodebuild \
    -project "$xcodeproj_path" \
    -configuration Release \
    -derivedDataPath "${src_dir}/.build" \
    clean build \
    2>&1 | _filter_xcodebuild_output

  ok "Build complete."
}

# _filter_xcodebuild_output — reduce xcodebuild's verbose output to useful lines.
_filter_xcodebuild_output() {
  while IFS= read -r line; do
    case "$line" in
      "** BUILD SUCCEEDED"*) ok "$line" ;;
      "** BUILD FAILED"*)    err "$line" ;;
      error:*)               err "$line" ;;
      warning:*)             warn "$line" ;;
    esac
  done
}

# ---------------------------------------------------------------------------
# _find_built_app — locate the .app bundle under the derived data directory.
# Prints the path to stdout on success.
# ---------------------------------------------------------------------------
_find_built_app() {
  local src_dir="${MLX_TS_SOURCE_DIR}"
  local products_dir="${src_dir}/.build/Build/Products/Release"
  local app_path="${products_dir}/${APP_NAME}"

  if [[ ! -d "$app_path" ]]; then
    die "Built app not found at: $app_path"
  fi

  printf '%s' "$app_path"
}

# ---------------------------------------------------------------------------
# install_app — copy the built .app to the install directory atomically.
# ---------------------------------------------------------------------------
install_app() {
  local install_dir="${MLX_TS_INSTALL_DIR}"
  local built_app
  built_app="$(_find_built_app)"
  local dest="${install_dir}/${APP_NAME}"
  local dest_tmp="${install_dir}/${APP_NAME}.tmp"

  info "Installing $APP_NAME to $install_dir..."
  mkdir -p "$install_dir"

  # Atomic replacement: copy to .tmp, then mv over any existing bundle.
  # cp -R copies bundle contents recursively; rm -rf clears any stale .tmp.
  rm -rf "$dest_tmp"
  cp -R "$built_app" "$dest_tmp"
  rm -rf "$dest"
  mv "$dest_tmp" "$dest"

  ok "Installed: $dest"
}

# ---------------------------------------------------------------------------
# get_upstream_commit — print the current HEAD commit SHA in the source dir.
# ---------------------------------------------------------------------------
get_upstream_commit() {
  local src_dir="${MLX_TS_SOURCE_DIR}"
  git -C "$src_dir" rev-parse HEAD 2>/dev/null || printf 'unknown'
}

# ---------------------------------------------------------------------------
# run_full_install — orchestrate the complete install sequence.
# ---------------------------------------------------------------------------
run_full_install() {
  clone_or_update_source
  build_app
  install_app

  local commit
  commit="$(get_upstream_commit)"
  local app_path="${MLX_TS_INSTALL_DIR}/${APP_NAME}"

  write_manifest \
    "$INSTALLER_VERSION" \
    "$commit" \
    "$UPSTREAM_REMOTE" \
    "$app_path" \
    "${MLX_TS_SOURCE_DIR}"
}
