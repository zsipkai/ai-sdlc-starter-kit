#!/usr/bin/env bash

set -uo pipefail
cd "$(dirname "$0")/.."

mode="${1:---fast}"
overall=0

case "$mode" in
  --fast|--full|--deploy) ;;
  *)
    echo "Usage: bash scripts/sdlc-gate.sh [--fast|--full|--deploy]"
    exit 2
    ;;
esac

# Quiet mode (SDLC_GATE_QUIET=1): identical commands and exit behavior —
# SUCCESS output shrinks to one line per stage (full detail in
# build/gate-last.log); failures always print verbatim. The gate runs on
# every commit, and its success banner is agent-context you pay for.
quiet="${SDLC_GATE_QUIET:-0}"
gate_log="build/gate-last.log"
[ "$quiet" = "1" ] && { mkdir -p build; : > "$gate_log"; }

stage() {
  local name="$1"
  shift
  if [ "$quiet" = "1" ]; then
    local out rc
    out=$("$@" 2>&1); rc=$?
    printf '== %s ==\n%s\n' "$name" "$out" >> "$gate_log"
    if [ "$rc" -eq 0 ]; then
      echo "  ok $name"
    else
      echo ""
      echo "== $name =="
      printf '%s\n' "$out"
      overall=1
    fi
  else
    echo ""
    echo "== $name =="
    "$@" || overall=1
  fi
}

unconfigured() {
  echo "UNCONFIGURED: replace the TODO command in scripts/sdlc-gate.sh"
  return 1
}

stage "change-record state" bash scripts/check-change-records.sh
stage "Markdown links" python3 scripts/check-md-links.py
stage "documentation drift" bash scripts/check-doc-drift.sh
stage "static analysis" unconfigured
stage "fast tests" unconfigured

if [ "$mode" = "--full" ] || [ "$mode" = "--deploy" ]; then
  stage "build" unconfigured
  stage "full automated tests" unconfigured
fi

if [ "$mode" = "--deploy" ]; then
  stage "deployment tests" unconfigured
fi

echo ""
if [ "$overall" -eq 0 ]; then
  echo "GATE PASSED ($mode)"
else
  echo "GATE FAILED ($mode). Fix the cause. Do not weaken the check."
fi

exit "$overall"
