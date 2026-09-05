# Model Routing Rules

> Goal: save money, preserve quality. The mechanism that makes both true
> at once: **generation may be cheap only while verification stays
> expensive.** The gates do not care which model wrote the code — that is
> exactly why a cheaper model is safe to use behind them.

## The tiers

| Tier | Meaning | Current models (snapshot — update as the lineup changes) |
|---|---|---|
| `small` | fast, cheap, excellent at fully-specified mechanical work | Haiku-class |
| `mid` | solid general engineering | Sonnet-class |
| `top` | strongest judgment, subtle-bug detection | Opus-class |

The tier names are the contract; the model names are a snapshot.

## Routing (assigned in /plan-task, checked in /validate-design)

1. **Risk routes, size budgets.** The executing tier follows Risk and
   ambiguity, never Size alone — a one-line change on the money path
   outranks a 300-file mechanical rename.

| Risk | Executing tier for /develop-code |
|---|---|
| LOW + mechanical + fully specified (passes the isolation test) | `small` |
| STANDARD | `mid` |
| HIGH / CRITICAL, ambiguous, or touching money / security / store compliance / concurrency / control-plane files | `top` — no exceptions |

2. **Unit-test authoring caps at `mid`.** Writing tests from a precise
   acceptance map is specification-following, not invention. Quality is
   preserved one stage later: the test *diff* is explicitly reviewed at
   top tier in /clear-review (weakened assertions, changed mocks,
   narrowed data, skips are all findings).
3. **Low-complexity support work runs `small`.** Docs formatting,
   changelogs, backlog grooming, comment fixes, log summarization —
   anything with a grep-provable done-condition and no judgment calls.
4. **Verification never downsizes.** /validate-design and /clear-review
   always run `top`. A reviewer must never be weaker than the executor
   it grades. /test-regression may be driven by `small` (it runs the
   canonical gate script and reports honestly); /deploy-change runs
   `top` — it can touch production, and its token cost is trivial anyway.

## Escalation (what keeps cheap from becoming sloppy)

5. **Escalate, don't struggle.** A blocker, an ambiguity, a failing test
   the tier can't explain, or any deviation from the record means
   re-running the stage one tier up — never improvising through it.
   One failed attempt = automatic upgrade.
6. **Never self-downgrade.** A stage may escalate its own tier; only
   /plan-task (checked by /validate-design) may assign a lower one.
7. **Record it.** The change record's `Size:`, `Risk:`, and
   `Execution model:` metadata keep routing auditable. The change-record
   gate enforces the floor mechanically: a HIGH/CRITICAL record with a
   non-`top` execution tier fails the commit.

## Budgets (the stop-loss)

8. **Size sets the token budget** at /plan-task, written into the
   record's `Budget:` metadata:

| Size | Budget (output tokens, whole pipeline) |
|---|---|
| S | 100k |
| M | 250k |
| L | 500k |
| XL | 1M |
| XXL | not runnable — an XXL story must be split before /plan-task ends |

9. **Crossing the budget is a stop, not a warning.** The stage halts,
   records where the tokens went, and the human chooses: raise the
   budget, split the story, or escalate the tier (a cheap model burning
   its budget usually means the plan was under-specified — fix the plan).
10. **Every stage appends its spend** to the change record
    (`Tokens spent (<stage>): <n> — <note>`). `scripts/cost-report.sh`
    aggregates these lines across all records — the repo computes its
    own bill, and cost claims come from that report, never from memory.

## Context and output economy (the other half of the bill)

The model is stateless: every turn re-sends the whole prefix
(instructions, rules, conversation) at input price, output costs ~5×
input, and thinking bills as output.

11. **Prefix stability (caching).** Instruction files — `AGENTS.md` /
    `CLAUDE.md`, `.claude/**`, `docs/rules/**`, `docs/SDLC.md` — are
    cache-prefix files: identical prefixes re-read at ~0.1× price, and
    any edit makes everything after it full price again. They change
    only through the docs/process-only lane, in batches, between
    stories — never as a side effect mid-stage.
12. **Fresh session per stage.** A stage handoff ends the session; the
    next stage starts in a new one with `/<stage> STORY-NNN` and only
    the change record — which passes the isolation test, so it needs
    nothing else. Long sessions re-pay their whole history every turn
    (2–6× more tokens without this discipline). Subagents are fresh by
    construction; the orchestrator must be too.
13. **Output economy.** The execution tier implies an effort level —
    `small` = low, `mid` = medium, `top` = high — set wherever the
    harness exposes it; the top tier earns its thinking only at
    /validate-design, /clear-review, and /deploy-change. Every subagent
    prompt states a return budget and demands raw structured data
    (tables, lists, counts), never narrative.
14. **Input economy.** Grep before you read; never read a whole file to
    change one function; tool output beyond ~100 lines gets filtered or
    tailed, or summarized by a `small`-tier subagent before it enters
    the orchestrator's context; the gate runs quiet (one line on
    success, everything on failure). What enters the context is paid
    for again on every later turn.
15. **Parallelism policy: fan out to judge, never to type.** Independent
    reviewers run in parallel because they must not share a context.
    Execution runs as one agent — the single exception is disjoint
    mechanical batches on the `small` tier when wall-clock matters.
    Parallel `top`-tier execution is never justified by cost.

## The second opinion (two families, one judge set)

16. **Cross-family second opinion on verification.** On a record at
    `Risk: STANDARD` or higher, /validate-design and /clear-review each
    add one reviewer from a **different model family** than the one
    running the pipeline (e.g. a GPT-class model when the pipeline runs
    Claude-class, or vice versa). Why: reviewers from one family share
    that family's blind spots — they grade their own systematic
    mistakes as fine. A second family decorrelates the judge set; it is
    rule 15's fan-out-to-judge applied across vendors.
    The mechanics, kept deliberately simple:
    - `bash scripts/second-opinion.sh STORY-NNN design|review` builds a
      self-contained prompt pack in `build/` (charter + change record,
      plus the diff for review). The human pastes it into the other
      family's **top** model and pastes the findings back — rule 4
      crosses families too: verification never downsizes, so never a
      mini/nano variant.
    - `--auto` sends the same pack to the second family's API instead
      (`OPENAI_API_KEY` from the environment, never stored in the repo;
      model pinned by `SECOND_OPINION_MODEL`, default a top GPT-class
      snapshot) and writes the findings next to the pack — the fully
      unattended path: pack → foreign review → consolidation → fixes.
    - Findings (numbered `X-n`) enter the same severity-ranked
      consolidation as every reviewer's. **Judge, never gate**: the
      deciding gates stay mechanical scripts; no foreign model clears
      or blocks a stage by itself.
    - Marginal cost: zero on a flat-fee chat subscription via the
      paste path; `--auto` bills cents per review to the API account —
      automate the transport when volume justifies paying for it.
    - The pack doubles as the isolation test: a model with no repo
      access must be able to judge from the pack alone. If it can't,
      the change record was incomplete — that is a finding.
    Skipping the second opinion on an eligible record is declared in
    the verdict, out loud — never silently.

Not adopted (yet): the **Batch API** (50% off, stacks with caching)
applies only to non-interactive workloads. Add it as rule 17 when your
first such workload exists (bulk audits, an evaluation suite). A rule
nobody runs is a rule that drifts.
