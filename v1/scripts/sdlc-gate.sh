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

stage() {
  local name="$1"
  shift
  echo ""
  echo "== $name =="
  "$@" || overall=1
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
