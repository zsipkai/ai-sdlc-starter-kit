#!/usr/bin/env bash

set -uo pipefail
cd "$(dirname "$0")/.."

fail=0

report_fail() {
  echo "FAIL  $1"
  fail=1
}

section_has_content() {
  local file="$1"
  local heading="$2"

  awk -v target="## $heading" '
    $0 == target { inside=1; next }
    inside && /^## / { exit }
    inside && /[^[:space:]]/ { found=1 }
    END { exit found ? 0 : 1 }
  ' "$file"
}

section_has_unchecked_items() {
  local file="$1"
  local heading="$2"

  awk -v target="## $heading" '
    $0 == target { inside=1; next }
    inside && /^## / { exit }
    inside && /^[[:space:]]*-[[:space:]]*\[[[:space:]]\]/ { found=1 }
    END { exit found ? 0 : 1 }
  ' "$file"
}

section_has_placeholder() {
  local file="$1"
  local heading="$2"

  awk -v target="## $heading" '
    $0 == target { inside=1; next }
    inside && /^## / { exit }
    inside && /<[^>]+>/ { found=1 }
    END { exit found ? 0 : 1 }
  ' "$file"
}

field_has_value() {
  local file="$1"
  local label="$2"
  grep -Eq "^- ${label}:[[:space:]]*[^[:space:]<]" "$file"
}

stage_rank() {
  case "$1" in
    PLANNED) echo 1 ;;
    DESIGN-VALIDATED) echo 2 ;;
    DEVELOPED) echo 3 ;;
    ACCEPTANCE-TEST-PROVEN) echo 4 ;;
    REVIEW-CLEARED) echo 5 ;;
    REGRESSION-TEST-PROVEN) echo 6 ;;
    DEPLOYED) echo 7 ;;
    *) echo 0 ;;
  esac
}

found=0
while IFS= read -r record; do
  found=1
  current_stage=$(sed -n 's/^Stage:[[:space:]]*//p' "$record" | head -n 1)
  rank=$(stage_rank "$current_stage")

  if [ "$rank" -eq 0 ]; then
    report_fail "$record has missing or unknown stage: ${current_stage:-<none>}"
    continue
  fi

  grep -Eq '^# STORY-[0-9]+: [^<].+' "$record" \
    || report_fail "$record needs a concrete story title"
  grep -Eq '^Risk: (LOW|STANDARD|HIGH|CRITICAL)$' "$record" \
    || report_fail "$record needs one valid risk tier"
  grep -Eq '^Owner:[[:space:]]*[^[:space:]<]' "$record" \
    || report_fail "$record needs an accountable owner"
  grep -Eq '^Story:[[:space:]]*`?docs/backlog/STORY-' "$record" \
    || report_fail "$record needs a backlog story path"

  for heading in \
    "Discovery Brief" \
    "Design Verdict" \
    "Implementation Record" \
    "Acceptance Evidence" \
    "Review Verdict" \
    "Regression Certificate" \
    "Deployment Record" \
    "Definition of Done"; do
    grep -Fqx "## $heading" "$record" || report_fail "$record is missing section: $heading"
  done

  section_has_content "$record" "Discovery Brief" \
    || report_fail "$record reached $current_stage without a Discovery Brief"
  grep -Fqx "Planning outcome: PLANNED" "$record" \
    || report_fail "$record reached $current_stage without a PLANNED outcome"
  ! section_has_placeholder "$record" "Discovery Brief" \
    || report_fail "$record reached $current_stage with placeholders in the Discovery Brief"
  [ "$rank" -lt 2 ] || grep -Fqx "Design outcome: DESIGN-VALIDATED" "$record" \
    || report_fail "$record reached $current_stage without a DESIGN-VALIDATED outcome"
  [ "$rank" -lt 2 ] || ! section_has_placeholder "$record" "Design Verdict" \
    || report_fail "$record reached $current_stage with placeholders in the Design Verdict"
  [ "$rank" -lt 3 ] || grep -Fqx "Development outcome: DEVELOPED" "$record" \
    || report_fail "$record reached $current_stage without a DEVELOPED outcome"
  [ "$rank" -lt 3 ] || ! section_has_placeholder "$record" "Implementation Record" \
    || report_fail "$record reached $current_stage with placeholders in the Implementation Record"
  [ "$rank" -lt 4 ] || grep -Fqx "Acceptance outcome: ACCEPTANCE-TEST-PROVEN" "$record" \
    || report_fail "$record reached $current_stage without an ACCEPTANCE-TEST-PROVEN outcome"
  [ "$rank" -lt 4 ] || ! section_has_placeholder "$record" "Acceptance Evidence" \
    || report_fail "$record reached $current_stage with placeholders in Acceptance Evidence"
  [ "$rank" -lt 5 ] || grep -Fqx "Review outcome: REVIEW-CLEARED" "$record" \
    || report_fail "$record reached $current_stage without a REVIEW-CLEARED outcome"
  [ "$rank" -lt 5 ] || ! section_has_placeholder "$record" "Review Verdict" \
    || report_fail "$record reached $current_stage with placeholders in the Review Verdict"
  [ "$rank" -lt 6 ] || grep -Fqx "Regression outcome: REGRESSION-TEST-PROVEN" "$record" \
    || report_fail "$record reached $current_stage without a REGRESSION-TEST-PROVEN outcome"
  [ "$rank" -lt 6 ] || ! section_has_placeholder "$record" "Regression Certificate" \
    || report_fail "$record reached $current_stage with placeholders in the Regression Certificate"
  [ "$rank" -lt 6 ] || field_has_value "$record" "Commit SHA" \
    || report_fail "$record reached $current_stage without a regression commit SHA"
  [ "$rank" -lt 6 ] || field_has_value "$record" "Full gate command" \
    || report_fail "$record reached $current_stage without a full gate command"
  [ "$rank" -lt 6 ] || field_has_value "$record" "Result" \
    || report_fail "$record reached $current_stage without a regression result"
  [ "$rank" -lt 7 ] || grep -Fqx "Deployment outcome: DEPLOYED" "$record" \
    || report_fail "$record reached $current_stage without a DEPLOYED outcome"
  [ "$rank" -lt 7 ] || ! section_has_placeholder "$record" "Deployment Record" \
    || report_fail "$record reached $current_stage with placeholders in the Deployment Record"
  [ "$rank" -lt 7 ] || field_has_value "$record" "Human deployment approval" \
    || report_fail "$record reached $current_stage without human deployment approval"
  [ "$rank" -lt 7 ] || field_has_value "$record" "Required CI URL or receipt" \
    || report_fail "$record reached $current_stage without required CI evidence"
  [ "$rank" -lt 7 ] || field_has_value "$record" "Merge SHA" \
    || report_fail "$record reached $current_stage without a merge SHA"
  [ "$rank" -lt 7 ] || field_has_value "$record" "Live behavior observed" \
    || report_fail "$record reached $current_stage without live observation"
  [ "$rank" -lt 7 ] || field_has_value "$record" "Rollback status" \
    || report_fail "$record reached $current_stage without rollback status"
  [ "$rank" -lt 7 ] || ! section_has_unchecked_items "$record" "Definition of Done" \
    || report_fail "$record reached $current_stage with an incomplete Definition of Done"
done < <(find docs/changeRecords -type f -name 'STORY-*.md' -print | sort)

if [ "$found" -eq 0 ]; then
  echo "PASS  no active change records to validate"
elif [ "$fail" -eq 0 ]; then
  echo "PASS  change-record stages match their evidence"
fi

exit "$fail"
