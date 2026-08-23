# v2 — Changes from v1

v1 gave you the seven-stage gated pipeline. v2 adds **cost control**:
model routing, token budgets, and a self-computed bill — measured on a
real story at **~44% cheaper** than running everything on the top model,
with zero gates weakened.

## New

- **`docs/rules/model-routing-rules.md`** — the whole policy in 15 rules:
  - three model tiers (`small` / `mid` / `top`); tier names are the
    contract, model names are a snapshot
  - **risk routes, size budgets**: the executing tier follows Risk and
    ambiguity, never Size — HIGH/CRITICAL, ambiguous, or
    money/security/store/concurrency/control-plane work runs `top`,
    no exceptions
  - unit-test authoring caps at `mid`; low-complexity support work runs
    `small`
  - **verification never downsizes** — /validate-design and
    /clear-review always run `top`
  - escalate-don't-struggle, never self-downgrade, record everything
  - size-based token budgets (S=100k … XL=1M; **XXL must be split
    before planning ends**); crossing a budget halts for a human call
  - the context/output economy: instruction files are cache-prefix
    files (batch their edits), fresh session per stage, effort follows
    the tier, grep-before-read, fan out to judge — never to type
- **`scripts/cost-report.sh`** — aggregates every change record's
  per-stage spend into one bill; estimates are marked `(est.)`.

## Changed

- **Story template**: two new header fields — `Size:` and `Risk:`.
- **Change-record template**: `Size:`, `Execution model:`, and `Budget:`
  metadata; the budget section is now a per-stage spend ledger.
- **Skills**: `/plan-task` assigns the tier and budget;
  `/validate-design` treats under-tiering risky work as a BLOCKER;
  `/develop-code` and `/test-acceptance` apply the tier by delegation
  (top-tier orchestrator, cheap-model subagent, stated return budget);
  every handoff starts the next stage **in a fresh session**; numeric
  evidence must come from quoted commands, never subagent self-reports.
- **`scripts/check-change-records.sh`**: mechanical routing floor —
  a HIGH/CRITICAL record routed below `top` fails the commit
  (fixture-proven); plus a `CHANGE_RECORDS_DIR` test seam.
- **`scripts/sdlc-gate.sh` + pre-commit hook**: quiet mode
  (`SDLC_GATE_QUIET=1`) — identical commands and exit behavior, success
  prints one line per stage, full detail goes to `build/gate-last.log`,
  failures always print verbatim.
- **`AGENTS.md` / `docs/SDLC.md`**: one routing row in the rules table
  and a short "Model routing and cost" section pointing at the rule file.

## Deliberately not included

- **Batch API** (50% off async work): only worth a rule once a
  non-interactive workload exists (bulk audits, an eval suite). A rule
  nobody runs is a rule that drifts.

## The measured run behind the numbers

One XL-size, LOW-risk story (a 271-site mechanical logging migration):
643,851 tokens total, 47% on the small tier → ~44% cheaper than all-top
at 15:3:1 tier pricing, under budget. Review ran 3.6× its estimate and
earned it — it caught the cheap model's mistakes (a strong capture in an
escaping closure, wrong privacy annotations, an evadable gate pattern)
before anything shipped. Cheap hands, expensive eyes, gates that don't
blink.
