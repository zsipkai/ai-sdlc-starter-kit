#!/usr/bin/env bash
# Doc-drift gate: fails when documentation claims diverge from code reality.
#
# Every check here exists because this exact class of bug shipped once:
#   - PRODUCT.md promised "3 stories free" while code enforced 1/day
#   - WEB.md described 8 bento cards while index.html had 4
#   - the story prompt grew past the backend's 3000-char cap (live 413)
#
# Run standalone or via scripts/sdlc-gate.sh. Exit non-zero on any drift.

set -uo pipefail
cd "$(dirname "$0")/.."

fail=0
say_pass() { echo "  PASS  $1"; }
say_fail() { echo "  FAIL  $1"; fail=1; }

echo "── Doc-drift checks ──────────────────────────────────"

# ── 1. Free-tier stories/day: quota.js is the source of truth ──────────────
code_free=$(node -e "
  import('./backend/lambda/services/quota.js').then(m =>
    console.log(m.LIMITS.free.storiesPerDay))" 2>/dev/null)
if [ "$code_free" != "1" ]; then
  say_fail "quota.js free.storiesPerDay is '$code_free' — update this script's expectations AND all docs deliberately"
else
  if grep -q "1 personalized story per day" docs/PRODUCT.md \
     && grep -q "1 personalized story every day" docs/APP_STORE_LISTING.md; then
    say_pass "free tier = 1 story/day consistent (quota.js, PRODUCT.md, APP_STORE_LISTING.md)"
  else
    say_fail "free tier: quota.js says $code_free/day but docs/PRODUCT.md or docs/APP_STORE_LISTING.md say otherwise"
  fi
fi

# ── 2. Premium stories/day ──────────────────────────────────────────────────
code_prem=$(node -e "
  import('./backend/lambda/services/quota.js').then(m =>
    console.log(m.LIMITS.premium.storiesPerDay))" 2>/dev/null)
if grep -q "10 personalized stories per day" docs/APP_STORE_LISTING.md \
   && grep -q "10 personalized stories per day" docs/PRODUCT.md; then
  [ "$code_prem" = "10" ] \
    && say_pass "premium tier = 10 stories/day consistent" \
    || say_fail "premium tier: docs say 10/day, quota.js says $code_prem"
else
  say_fail "premium tier: expected '10 personalized stories per day' in docs/PRODUCT.md + docs/APP_STORE_LISTING.md"
fi

# ── 3. Prompt cap: backend cap ↔ iOS test mirror ────────────────────────────
code_cap=$(node -e "
  import('./backend/lambda/services/quota.js').then(m =>
    console.log(m.LIMITS.perRequest.maxPromptChars))" 2>/dev/null)
ios_cap=$(grep -o 'backendMaxPromptChars = [0-9]*' KidStorytimeTests/StoryPromptBuilderTests.swift | grep -o '[0-9]*')
if [ "$code_cap" = "$ios_cap" ] && [ -n "$code_cap" ]; then
  say_pass "prompt cap mirrored: backend=$code_cap, iOS test constant=$ios_cap"
else
  say_fail "prompt cap drift: backend=$code_cap vs iOS test constant=$ios_cap"
fi

# ── 4. WEB.md structure claims ↔ actual HTML ────────────────────────────────
html_bento=$(grep -c '<article class="bento-card' web/index.html)
if grep -q "${html_bento} asymmetric feature cards" web/README.md 2>/dev/null; then
  say_pass "WEB.md bento count matches index.html ($html_bento cards)"
else
  say_fail "WEB.md bento claim doesn't match index.html actual ($html_bento cards)"
fi
html_faq=$(grep -c 'class="faq-q"' web/index.html)
grep -q "(${html_faq} questions)" web/README.md \
  && say_pass "WEB.md FAQ count matches index.html ($html_faq questions)" \
  || say_fail "WEB.md FAQ claim doesn't match index.html actual ($html_faq questions)"

# ── 5. Old-brand zero tolerance ─────────────────────────────────────────────
# MARKET_ANALYSIS.md keeps competitor names on purpose; ADRs record history.
# --exclude=".git" (the file, not the dir): in a linked worktree .git is a
# pointer file whose content is the main repo's on-disk path — VCS plumbing,
# not shippable content.
residue=$(grep -r -i -l -E "little[^a-z]{0,3}heroes|littleheroes|bedtimestories" \
  --exclude-dir=".git" --exclude-dir="node_modules" --exclude-dir=".claude" \
  --exclude-dir="build" --exclude-dir="DerivedData" --exclude-dir="Old Design" \
  --exclude-dir="Pods" --exclude-dir="decisions" --exclude-dir="xcuserdata" \
  --exclude=".git" --exclude="MARKET_ANALYSIS.md" --exclude="check-doc-drift.sh" \
  . 2>/dev/null | wc -l | tr -d ' ')
[ "$residue" = "0" ] \
  && say_pass "zero old-brand references outside allowed historical docs" \
  || { say_fail "old-brand residue in $residue file(s):"; \
       grep -r -i -l -E "little[^a-z]{0,3}heroes|littleheroes|bedtimestories" \
         --exclude-dir=".git" --exclude-dir="node_modules" --exclude-dir=".claude" \
         --exclude-dir="build" --exclude-dir="DerivedData" --exclude-dir="Old Design" \
         --exclude-dir="Pods" --exclude-dir="decisions" --exclude-dir="xcuserdata" \
         --exclude=".git" --exclude="MARKET_ANALYSIS.md" --exclude="check-doc-drift.sh" . 2>/dev/null | sed 's/^/          /'; }

# ── 6. Every relative markdown link resolves ────────────────────────────────
if python3 scripts/check-md-links.py > /tmp/mdlinks.out 2>&1; then
  say_pass "all relative markdown links resolve ($(grep -o 'checked [0-9]*' /tmp/mdlinks.out))"
else
  say_fail "broken markdown links:"; cat /tmp/mdlinks.out | sed 's/^/          /'
fi

echo "──────────────────────────────────────────────────────"
if [ "$fail" = "0" ]; then
  echo "  Doc-drift: ALL CLEAN"
else
  echo "  Doc-drift: FAILURES — docs and code disagree. Fix both sides in the same commit."
fi
exit $fail
