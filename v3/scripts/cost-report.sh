#!/usr/bin/env bash
# Cost report: aggregates the per-stage spend that stages append to each
# change record ("Tokens spent (<stage>): <n> — <note>"), plus the
# Size / Risk / Execution model / Budget metadata. Cost claims come from
# this report, never from memory. Lines whose note says "estimate" or
# "best-effort" print with an (est.) marker — self-estimates are never
# presented as measurements.
#
# Usage: bash scripts/cost-report.sh [docs/changeRecords]

set -uo pipefail
cd "$(dirname "$0")/.."
DIR="${1:-docs/changeRecords}"

printf '%-12s %-4s %-9s %-6s %-8s %s\n' "STORY" "SIZE" "RISK" "TIER" "BUDGET" "TOKENS SPENT (by stage)"
echo "------------------------------------------------------------------------"

total=0
for f in "$DIR"/STORY-*.md; do
  [ -e "$f" ] || continue
  id=$(basename "$f" .md)
  size=$(grep -m1 -E '^Size:' "$f" | awk '{print $2}')
  risk=$(grep -m1 -E '^Risk:' "$f" | awk '{print $2}')
  tier=$(grep -m1 -E '^Execution model:' "$f" | awk '{print $3}')
  budget=$(grep -m1 -E '^Budget:' "$f" | awk '{print $2}')
  spent=$(grep -E '^Tokens spent \(' "$f" \
    | sed -E 's/Tokens spent \(([^)]+)\):[[:space:]]*~?([0-9]+)(.*(estimate|best-effort).*)?.*/\1=\2\3/' \
    | sed -E 's/=([0-9]+).*(estimate|best-effort).*/=\1(est.)/' | tr '\n' ' ')
  story_total=$(grep -E '^Tokens spent \(' "$f" \
    | sed -E 's/.*\):[[:space:]]*~?([0-9]+).*/\1/' | awk '{s+=$1} END {print s+0}')
  total=$((total + story_total))
  printf '%-12s %-4s %-9s %-6s %-8s %s-> %s\n' \
    "$id" "${size:--}" "${risk:--}" "${tier:--}" "${budget:--}" "${spent:-"(no spend recorded) "}" "$story_total"
done

echo "------------------------------------------------------------------------"
echo "TOTAL recorded spend: $total tokens"
