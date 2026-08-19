#!/usr/bin/env bash
# SDLC quality gate — the hard enforcement layer behind the /1../6 workflow.
#
# Modes:
#   --fast   doc-drift + backend tests (~15s). Runs on every commit via the
#            pre-commit hook. Fails the commit on any drift or test failure.
#   --full   everything in --fast PLUS iOS build + iOS unit tests (~4 min).
#            Run by /6-ship before any push or deploy.
#   --ui     adds the full UI test suite on top of --full (~12 min).
#            Run before App Store submission or after UI-heavy changes.
#
# Skip in an emergency with `git commit --no-verify` — and expect the
# reviewer to ask why.

set -uo pipefail
cd "$(dirname "$0")/.."

MODE="${1:---fast}"
overall=0
stage() { echo ""; echo "════ $1 ════"; }

stage "Doc-drift"
bash scripts/check-doc-drift.sh || overall=1

stage "Backend tests (node)"
( cd backend/lambda && node --test 2>&1 | tail -8 ) || overall=1
# node --test exits non-zero on failure; tail keeps output readable

if [ "$MODE" = "--full" ] || [ "$MODE" = "--ui" ]; then
  stage "iOS build (workspace, Debug)"
  xcodebuild build \
    -workspace KidStorytime.xcworkspace -scheme KidStorytime \
    -configuration Debug \
    -destination 'platform=iOS Simulator,name=iPhone 16 Pro,OS=18.4' \
    -derivedDataPath build/DerivedData -quiet 2>&1 | grep -E "error:|BUILD" || true
  build_result=${PIPESTATUS[0]}
  [ "$build_result" != "0" ] && overall=1

  stage "iOS unit tests"
  xcodebuild test \
    -workspace KidStorytime.xcworkspace -scheme KidStorytime \
    -configuration Debug \
    -destination 'platform=iOS Simulator,name=iPhone 16 Pro,OS=18.4' \
    -only-testing:KidStorytimeTests \
    -derivedDataPath build/DerivedData 2>&1 | grep -E "TEST (SUCCEEDED|FAILED)" || true
  test_result=${PIPESTATUS[0]}
  [ "$test_result" != "0" ] && overall=1
fi

if [ "$MODE" = "--ui" ]; then
  stage "iOS UI tests (parallel, 4 workers)"
  xcodebuild test \
    -workspace KidStorytime.xcworkspace -scheme KidStorytime \
    -configuration Debug \
    -destination 'platform=iOS Simulator,name=iPhone 16 Pro,OS=18.4' \
    -only-testing:KidStorytimeUITests \
    -parallel-testing-enabled YES -parallel-testing-worker-count 4 \
    -derivedDataPath build/DerivedData 2>&1 | grep -E "TEST (SUCCEEDED|FAILED)|failed on" || true
  ui_result=${PIPESTATUS[0]}
  [ "$ui_result" != "0" ] && overall=1
fi

echo ""
if [ "$overall" = "0" ]; then
  echo "════ GATE PASSED ($MODE) ════"
else
  echo "════ GATE FAILED ($MODE) — do not ship ════"
fi
exit $overall
