#!/usr/bin/env bash
# caffeine — keep your computer awake while this terminal is open.
# Works on macOS (uses `caffeinate`) and Linux (uses `systemd-inhibit`).

set -u

fmt() {
  local total=$1
  local h=$(( total / 3600 ))
  local m=$(( (total % 3600) / 60 ))
  local s=$(( total % 60 ))
  printf "%dh %dm %ds" "$h" "$m" "$s"
}

CHILD_PID=""

cleanup() {
  printf "\n"
  if [[ -n "$CHILD_PID" ]] && kill -0 "$CHILD_PID" 2>/dev/null; then
    kill "$CHILD_PID" 2>/dev/null || true
    wait "$CHILD_PID" 2>/dev/null || true
  fi
  exit 0
}

trap cleanup INT TERM

uname_s=$(uname -s)
case "$uname_s" in
  Darwin)
    caffeinate -dimsu >/dev/null 2>&1 &
    CHILD_PID=$!
    ;;
  Linux)
    if command -v systemd-inhibit >/dev/null 2>&1; then
      systemd-inhibit \
        --what=idle:sleep:handle-lid-switch \
        --who=caffeine \
        --why="User requested" \
        --mode=block \
        sleep infinity >/dev/null 2>&1 &
      CHILD_PID=$!
    else
      echo "caffeine: systemd-inhibit not found; sleep may still trigger." >&2
    fi
    ;;
  *)
    echo "caffeine: unsupported platform: $uname_s" >&2
    exit 2
    ;;
esac

start=$(date +%s)
while true; do
  now=$(date +%s)
  elapsed=$(( now - start ))
  printf "\rcaffeine  %s  [Ctrl+C] to stop.   " "$(fmt "$elapsed")"
  sleep 1
done
