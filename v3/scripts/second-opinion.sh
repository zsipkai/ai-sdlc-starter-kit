#!/usr/bin/env bash
# Second opinion (model-routing rule 16): build a self-contained prompt
# pack for a reviewer from a DIFFERENT model family. The human pastes the
# pack into that family's top model, pastes the findings back, and the
# stage consolidates them like any reviewer's. Judge only — the deciding
# gates stay mechanical and are never delegated to a foreign model.
#
# The pack doubles as the isolation test: a model with no repo access
# must be able to judge from this file alone. If it can't, the change
# record was incomplete — that is a finding, not a formatting problem.
#
# Usage: bash scripts/second-opinion.sh STORY-NNN design|review [--auto]
#   --auto  send the pack to the second family's API instead of pasting
#           (OPENAI_API_KEY from the environment, never stored in the
#           repo; per-token cost on that account — the manual paste
#           stays the free path).
# Adjust the diff base below if your integration branch is not `main`.

set -euo pipefail
cd "$(dirname "$0")/.."

STORY="${1:?usage: second-opinion.sh STORY-NNN design|review [--auto]}"
STAGE="${2:?usage: second-opinion.sh STORY-NNN design|review [--auto]}"
AUTO=0
[ "${3:-}" = "--auto" ] && AUTO=1
RECORD="docs/changeRecords/${STORY}.md"
[ -f "$RECORD" ] || { echo "No change record at $RECORD" >&2; exit 1; }
case "$STAGE" in
  design|review) ;;
  *) echo "Stage must be 'design' or 'review'" >&2; exit 1 ;;
esac

mkdir -p build
OUT="build/second-opinion-${STORY}-${STAGE}.md"

{
  echo "# Second-opinion ${STAGE} pass — ${STORY}"
  echo
  echo "You are an independent reviewer from a different model family than"
  echo "the one that produced the work below. You have no repository access:"
  echo "this file is everything. If something you need is missing from it,"
  echo "that is itself a finding — say what is missing, do not guess."
  echo
  if [ "$STAGE" = "design" ]; then
    echo "Attack this design before any code is written: missing or"
    echo "untestable acceptance criteria, hidden coupling, wrong assumptions,"
    echo "risk mis-classification, an execution tier too low for the risk,"
    echo "and any smaller change that reaches the same outcome. Do not"
    echo "restate the design; do not praise it."
  else
    echo "Review the diff against the change record — the record is the"
    echo "delivery contract. Hunt correctness bugs, security issues,"
    echo "contract drift, weakened or missing tests, and scope the record"
    echo "never asked for. Do not restate the diff; do not praise it."
  fi
  echo
  echo "Return ONLY, in under 500 words:"
  echo "- a findings table: X-n | BLOCKER/MAJOR/MINOR | where |"
  echo "  one-sentence defect | concrete failure scenario"
  echo "- one final line: VERDICT: CLEAR or VERDICT: SEE-FINDINGS"
  echo
  echo "---"
  echo
  echo "## The change record"
  echo
  cat "$RECORD"
  if [ "$STAGE" = "review" ]; then
    echo
    echo "---"
    echo
    echo "## The diff (main...HEAD)"
    echo
    echo '```diff'
    git diff main...HEAD
    echo '```'
  fi
} > "$OUT"

echo "Prompt pack: $OUT ($(wc -l < "$OUT" | tr -d ' ') lines)"

if [ "$AUTO" = "1" ]; then
  if [ -z "${OPENAI_API_KEY:-}" ] && [ -n "${SECOND_OPINION_KEY_CMD:-}" ]; then
    # Optional: point SECOND_OPINION_KEY_CMD at your secret manager —
    # a command that prints the key (e.g. `op read op://...`, or an
    # `aws lambda get-function-configuration --query ...` lookup). The
    # key lives only in this process's environment; never in the repo.
    OPENAI_API_KEY=$(eval "$SECOND_OPINION_KEY_CMD")
    export OPENAI_API_KEY
  fi
  : "${OPENAI_API_KEY:?--auto needs OPENAI_API_KEY (export it, or set SECOND_OPINION_KEY_CMD to a command that prints it)}"
  # Top tier only (rule 4 crosses families). Snapshot — update as the lineup changes.
  MODEL="${SECOND_OPINION_MODEL:-gpt-5.1}"
  FINDINGS="build/second-opinion-${STORY}-${STAGE}-findings.md"
  PAYLOAD="build/second-opinion-${STORY}-${STAGE}-payload.json"
  RESPONSE="build/second-opinion-${STORY}-${STAGE}-response.json"
  # Python only encodes/decodes JSON; curl carries the HTTPS call (it
  # uses the system trust store, unlike some local Python installs).
  python3 -c 'import json,sys; print(json.dumps({"model": sys.argv[2], "messages": [{"role": "user", "content": open(sys.argv[1], encoding="utf-8").read()}]}))' \
    "$OUT" "$MODEL" > "$PAYLOAD"
  curl -sS --max-time 600 https://api.openai.com/v1/chat/completions \
    -H "Authorization: Bearer $OPENAI_API_KEY" \
    -H "Content-Type: application/json" \
    --data-binary @"$PAYLOAD" > "$RESPONSE"
  python3 - "$RESPONSE" "$MODEL" > "$FINDINGS" <<'PY'
import json, sys
body = json.load(open(sys.argv[1], encoding="utf-8"))
if "error" in body:
    sys.stderr.write("OpenAI API error: %s\n" % json.dumps(body["error"])[:500])
    sys.exit(1)
print(body["choices"][0]["message"]["content"])
u = body.get("usage", {})
sys.stderr.write("usage: %s prompt + %s completion tokens (%s)\n"
                 % (u.get("prompt_tokens", "?"),
                    u.get("completion_tokens", "?"), sys.argv[2]))
PY
  echo "Second opinion ($MODEL) → $FINDINGS"
  echo "Consolidate its X-n rows like any reviewer's — judge, never gate."
else
  echo "Paste it into a TOP model of a different family (rule 4 crosses"
  echo "families — verification never downsizes), then paste the findings back."
  echo "(Or re-run with --auto to send it to the second family's API.)"
fi
