# Agentic SDLC Starter Kit — v3

**What's new in v3: the cross-family second opinion.** Same pipeline
and cost control as v2, plus one rule: on any story of STANDARD risk or
higher, the two verification gates each add one reviewer from a
**different model family** — because reviewers from one family share
that family's blind spots, and a flat-fee chat subscription on your
laptop makes the extra top-tier judge free.

**Carried from v2: cost control.** Model routing, token budgets, and a
self-computed bill — measured on a real story at **~44% cheaper** than
running everything on the top model, with zero gates weakened.

## The idea in three sentences

AI agents do the work; mechanical gates keep them honest. v2 adds one
insight: **the expensive model should do all the thinking (plan, attack,
review, ship) and a cheap model should do all the typing** — which is
only safe because everything the cheap model produces passes top-tier
review plus gates that don't care who wrote the code. Risk picks the
model, size picks the budget, and a script refuses any commit that
routes risky work to a cheap model.

## How the cost control works

1. Every story card carries two fields: `Size` (S–XXL) and `Risk`
   (LOW–CRITICAL).
2. `/plan-task` turns them into two metadata lines in the change record:
   `Execution model: small | mid | top` (from Risk — never from Size)
   and `Budget:` (from Size — S=100k … XL=1M tokens; XXL must be split).
3. `/develop-code` applies the tier by **delegation**: the top-tier
   orchestrator hands the record to a subagent running the cheap model.
   If it gets stuck, the stage re-runs one tier up — never improvises.
4. `/validate-design` and `/clear-review` always run the top model.
   **Verification never downsizes.**
5. `scripts/check-change-records.sh` enforces the floor: HIGH or
   CRITICAL risk below `top` fails the commit. Not a guideline — a
   locked door.
6. Every stage appends what it spent to the record;
   `scripts/cost-report.sh` prints the whole repo's bill.

Sixteen rules total in [docs/rules/model-routing-rules.md](docs/rules/model-routing-rules.md),
including the context/output economy: keep instruction files stable
(they're cached at ~10% price), start every stage in a fresh session,
match thinking effort to the tier, grep before you read, and fan out to
judge — never to type.

## How the second opinion works (new in v3)

1. On `Risk: STANDARD` or higher, `/validate-design` and
   `/clear-review` run `bash scripts/second-opinion.sh STORY-NNN
   design|review`.
2. The script emits one self-contained prompt pack: reviewer charter +
   change record (+ the diff for review). Paste it into a **top** model
   of another family (e.g. the ChatGPT desktop app if your pipeline
   runs Claude-class models); paste the findings back. Or add `--auto`
   and the script sends the pack to the other family's API itself
   (`export OPENAI_API_KEY` first) — fully unattended, cents per review
   instead of a free paste.
3. The findings join the same severity-ranked consolidation as every
   reviewer's, numbered `X-n`. **Judge, never gate** — the deciding
   gates stay mechanical scripts.
4. Verification never downsizes across families either: the other
   family's top model, never a mini variant.
5. Free bonus: the pack is an isolation test. A model with no repo
   access must be able to judge from the pack alone — if it can't, the
   change record was incomplete, and that's a finding.

Skipping it on an eligible story is declared in the verdict, never
silently. Why bother at all: models from one family make *correlated*
mistakes, so a same-family reviewer tends to grade its own failure
modes as fine. A second family decorrelates the judges — an ensemble,
at zero marginal cost on a flat-fee subscription.

## Install

Same as v1 (see [docs/SDLC.md](docs/SDLC.md) and the templates), plus:
run `bash scripts/install-hooks.sh` — the pre-commit gate now runs
quiet (one line per check on success; full detail lands in
`build/gate-last.log` and failures always print everything).

## The measured result behind the 44%

One real XL/LOW story (a 271-site mechanical migration): 643,851 tokens
total, 47% of them on the small tier — ~44% cheaper than all-top at
15:3:1 tier pricing, under budget. The review stage ran 3.6× its
estimate and earned it: it caught the cheap model's mistakes (a strong
capture in an escaping closure, wrong privacy annotations, an evadable
gate pattern) before they shipped. That's the whole thesis: cheap
hands, expensive eyes, gates that don't blink.

## License

MIT — see [../LICENSE](../LICENSE).
