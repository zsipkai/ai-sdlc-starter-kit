#!/usr/bin/env bash

set -uo pipefail
cd "$(dirname "$0")/.."

fail=0

pass() { echo "PASS  $1"; }
fail_check() { echo "FAIL  $1"; fail=1; }

echo "Configure each check from a real repository contract."

# Example shape:
# code_limit=$(node scripts/read-free-limit.mjs)
# grep -q "$code_limit stories per day" docs/PRODUCT.md \
#   && pass "product limit matches code" \
#   || fail_check "product limit drift"

configuration_files=(
  AGENTS.md
  docs/PRODUCT.md
  docs/TESTS.md
  docs/INFRASTRUCTURE.md
  docs/DEPLOYMENT.md
  docs/DESIGN_SYSTEM.md
  docs/SDLC.md
  docs/rules/architecture-rules.md
  docs/rules/design-system-rules.md
  docs/rules/naming-conventions-best-practices-rules.md
  docs/rules/security-rules.md
  docs/rules/testing-rules.md
  scripts/sdlc-gate.sh
)

if rg -n "<[^>]+>|TODO|UNCONFIGURED" "${configuration_files[@]}" >/dev/null; then
  fail_check "starter placeholders remain in configured truth files"
else
  pass "configured truth files contain no starter placeholders"
fi

exit "$fail"
