#!/usr/bin/env bash
# lib/log.sh — Logging and user-interaction helpers.
#
# Provides: info, ok, warn, err, die, prompt, confirm.
# Colors are auto-disabled when stdout/stderr is not a TTY.

set -euo pipefail
IFS=$'\n\t'

# ---------------------------------------------------------------------------
# Color setup
# ---------------------------------------------------------------------------

_log_color_enabled() {
  [[ -t 2 ]]
}

_clr() {
  local code="$1"
  shift
  if _log_color_enabled; then
    printf '\033[%sm%s\033[0m' "$code" "$*"
  else
    printf '%s' "$*"
  fi
}

# ---------------------------------------------------------------------------
# Public logging functions — all write to stderr so stdout stays clean.
# ---------------------------------------------------------------------------

# info <message> — informational message.
info() {
  printf '%s %s\n' "$(_clr '34' '[INFO]')" "$*" >&2
}

# ok <message> — success message.
ok() {
  printf '%s %s\n' "$(_clr '32' '[ OK ]')" "$*" >&2
}

# warn <message> — non-fatal warning.
warn() {
  printf '%s %s\n' "$(_clr '33' '[WARN]')" "$*" >&2
}

# err <message> — error message (does not exit).
err() {
  printf '%s %s\n' "$(_clr '31' '[ERR ]')" "$*" >&2
}

# die <message> — print error and exit 1.
die() {
  err "$*"
  exit 1
}

# ---------------------------------------------------------------------------
# Interactive helpers
# ---------------------------------------------------------------------------

# prompt <variable_name> <question> [default] — read a line from the user.
# Stores the result in the named variable. If MLX_TS_NONINTERACTIVE=1 or
# stdin is not a TTY, uses the default value without prompting.
prompt() {
  local var_name="$1"
  local question="$2"
  local default="${3:-}"

  if [[ "${MLX_TS_NONINTERACTIVE:-0}" == "1" ]] || [[ ! -t 0 ]]; then
    printf -v "$var_name" '%s' "$default"
    return 0
  fi

  local display_default=""
  if [[ -n "$default" ]]; then
    display_default=" [$(_clr '36' "$default")]"
  fi

  printf '%s%s: ' "$question" "$display_default" >&2
  local reply
  IFS= read -r reply
  if [[ -z "$reply" ]]; then
    reply="$default"
  fi
  printf -v "$var_name" '%s' "$reply"
}

# confirm <question> [default_yes] — yes/no prompt. Returns 0 for yes, 1 for no.
# default_yes: pass "y" to default to yes, "n" to default to no (default: "y").
# In non-interactive / pipe mode, accepts the default silently.
confirm() {
  local question="$1"
  local default="${2:-y}"

  local hint
  if [[ "$default" == "y" ]]; then
    hint="[Y/n]"
  else
    hint="[y/N]"
  fi

  if [[ "${MLX_TS_NONINTERACTIVE:-0}" == "1" ]] || [[ ! -t 0 ]]; then
    if [[ "$default" == "y" ]]; then
      return 0
    else
      return 1
    fi
  fi

  printf '%s %s: ' "$question" "$(_clr '36' "$hint")" >&2
  local reply
  IFS= read -r reply
  reply="${reply:-$default}"

  case "$reply" in
    [yY][eE][sS]|[yY]) return 0 ;;
    *) return 1 ;;
  esac
}
