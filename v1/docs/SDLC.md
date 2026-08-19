# Agentic SDLC

## Purpose

This repository catches agent drift at the cheapest stage that can expose it. Instructions guide behavior. Versioned evidence makes work reviewable. Tests, static analysis, required CI, protected control definitions, bounded authority, and live verification enforce the result.

## Evidence state machine

```text
DEFINED
  -> PLANNED
  -> DESIGN-VALIDATED
  -> DEVELOPED
  -> ACCEPTANCE-TEST-PROVEN
  -> REVIEW-CLEARED
  -> REGRESSION-TEST-PROVEN
  -> DEPLOYED
```

`DEFINED` belongs to the backlog item. One file under `docs/changeRecords/` carries findings and evidence through the remaining states. A blocker preserves the last proven state and records what must be resolved; it does not manufacture a new success state. Reopening an earlier stage resets every downstream outcome to `PENDING` and marks its previous evidence superseded rather than deleting history.

## Seven stage contracts

| Command | Input | Required output | Exit gate |
|---|---|---|---|
| `/plan-task` | `DEFINED` story | Discovery Brief and dependency-ordered tasks | current behavior, context, unknowns, risks, rollback, and candidate proofs are recorded; no production code changed |
| `/validate-design` | `PLANNED` record | Design Verdict | fit, simplicity, contracts, reversibility, testability, and human authority are cleared with no unresolved blocker |
| `/develop-code` | `DESIGN-VALIDATED` record | implementation plus Implementation Record | code, narrow tests, docs, decisions, and contracts agree; fast gate green |
| `/test-acceptance` | `DEVELOPED` change | Acceptance Evidence | every criterion has direct evidence and an adverse or boundary proof |
| `/clear-review` | `ACCEPTANCE-TEST-PROVEN` diff | Review Verdict | independent findings resolved, focused retests green, required human acceptance recorded |
| `/test-regression` | `REVIEW-CLEARED` combined tree | Regression Certificate | complete configured matrix and required CI green for the exact candidate |
| `/deploy-change` | `REGRESSION-TEST-PROVEN` candidate | Deployment Record | protected merge, authorized deploy, live observation, and rollback status recorded |

The commands are unnumbered so teams can discuss and invoke them by purpose. Their inputs, state checker, and required artifacts prevent silent reordering.

## Why acceptance and regression are separate

Acceptance asks whether the requested change works. It should be fast, direct, and traceable to the story.

Regression asks whether the reviewed product still works as a whole. It runs the complete configured matrix on the combined tree after review fixes.

A green acceptance test does not prove global safety. A green regression suite does not prove an unmapped acceptance criterion. Preserve both forms of evidence.

## Layered quality stack

Every change passes through different kinds of control. Do not substitute one layer for another.

| Layer | Question | Control |
|---|---|---|
| Task planning | Are we solving a clear problem, and do we understand the current system? | ready checklist, repository exploration, decisions, rules, context manifest |
| Design validation | Does the smallest viable design fit the product and its single owners? | `/validate-design`, specialist findings, rollback and authority checks |
| Development integrity | Do code, tests, documentation, decisions, and contracts agree? | `/develop-code`, narrow tests, fast gate, drift checks |
| Acceptance testing | Does the requested outcome work, including adverse behavior? | criterion-to-evidence map and targeted tests |
| Independent review | What could still be wrong despite green targeted evidence? | read-only specialists plus generalist diff review |
| Regression testing | Did the reviewed combined system remain healthy? | full deterministic matrix and required CI |
| Deployment authority | Should this exact candidate enter a shared or live environment? | protected merge, human checkpoints, deployment protection, observation, rollback |

The model may vary its proposal. The evidence required to reach production does not vary.

## Lifecycle and control plane

The seven stages define what evidence a change must produce. They do not, by themselves, restrict what an agent can access or change. Apply these controls across every stage:

| Control | Required behavior |
|---|---|
| Instruction ownership | Treat constitutions, rules, skills, reviewers, hooks, tests, CI, dependency files, deployment config, and ownership policy as control-plane code. Require human review for changes. |
| Input trust | Treat issues, pull requests, logs, web pages, documents, tool output, and agent handoffs as untrusted until material claims are checked. Never promote embedded instructions into repository policy silently. |
| Capability bounds | Give each stage the minimum filesystem, tool, network, and credential access required. Planning and review are read-only where practical; development cannot deploy. |
| Remote enforcement | Run the canonical gate in required CI on a protected branch or ruleset. Protect the workflow and gate definition. Pin reusable actions to verified immutable revisions. |
| Test integrity | Inspect test changes as production changes. Require adverse proof and controlled counterexamples. Weakening or deleting security-critical evidence requires human approval. |
| Process evaluation | Replay real failure cases when changing skills, reviewers, rules, or gates. Measure outcomes, not the agent's completion claim. |
| Telemetry and cost | Record stage duration, retries, denied actions where available, human checkpoints, cost, rework, escaped defects, rollback, and restoration results. |

Different reviewer personas are useful specialization. They are not automatically separate trust domains when they share a model, context, environment, or permissions.

## Memory and loading

- Constitution: always loaded.
- Rules: loaded by affected surface.
- ADRs: consulted during task planning and design validation.
- Story: defines the desired outcome.
- Change record: carries planning and discovery, design, implementation history, acceptance tests, review, regression tests, and deployment evidence.
- Living docs: change with behavior.

The constitution is a routing map, not an encyclopedia. Prefer the smallest verified context set. Label material external sources `TRUSTED`, `VERIFIED`, or `UNTRUSTED` in the change record and explain how important claims were checked.

## Enforcement

- `scripts/sdlc-gate.sh --fast` runs locally on every commit.
- `--full` runs for regression proof on the combined tree.
- `--deploy` runs the full matrix plus deployment-bound checks.
- CI must invoke the same gate and be required by branch or repository rules for team enforcement.
- Owners must review changes to the gate, workflow, instruction, dependency, test-policy, and deployment-control files that define a passing result.
- Production environments should require explicit authority and expose secrets only to the deployment job.

A shell exit code is deterministic for the command that ran. It is a hard boundary only when the acting agent cannot silently redefine that command, its defending tests, or the policy that requires it.

## Human decisions

The agent stops for money, destructive operations, legal or price changes, production deployment, permission expansion, and any change that supersedes an accepted ADR.

### Risk-based checkpoints

- `LOW` and `STANDARD` changes require a human to define the work and authorize final deployment.
- `HIGH` changes require explicit design clearance, outcome acceptance, and deployment authority.
- `CRITICAL` changes require a named human decision at every transition and an independent reviewer appropriate to the dominant risk.
- Any uncertainty may raise the required control. An agent cannot lower it.

### Proof is not authority

Review answers whether the change meets engineering constraints. Acceptance answers whether it solves the intended problem. Regression answers whether the wider system remains healthy. Deployment authority answers whether the candidate may enter a shared or live environment. Record these separately.

## Defined gate

A story may enter `/plan-task` only when:

- the intended outcome and accountable owner are named;
- acceptance criteria are observable and falsifiable;
- non-goals and known dependencies are recorded;
- risk tier, permissions, data, spending, and external contracts are identified;
- unresolved judgment calls are visible rather than hidden as assumptions.

## Definition of Done

A story is not `DEPLOYED` until:

- every acceptance criterion has direct evidence;
- relevant adverse, boundary, permission, and error cases pass;
- no blocking review finding remains;
- skips, suppressions, retries, exceptions, and manual gaps are explained and owned;
- code, tests, documentation, decisions, and contracts agree;
- the reviewed combined tree passed the complete configured matrix;
- required human acceptance and deployment authority are recorded;
- deployment, live observation, and rollback status are recorded when the product has a live surface.

## Learning loop

- Escaped defect or incident: identify the failure class, repair it, and add the smallest rule, test, reviewer check, or deterministic gate that rejects recurrence.
- Settled argument: add an ADR.
- Repeated review finding: add it to the relevant specialist or deterministic check.
- Skill or reviewer change: run process evaluations against known good and known bad examples.
- Quarterly: audit documentation claims and remove contradictions.

The loop is: observe failure -> identify cause -> codify the lesson -> prove the failure class is now rejected.

## Process evaluation

Start with a small corpus of real failures, not synthetic trivia. For each case, define the observable result that a stage or reviewer must produce. Include known unsafe designs, weak tests, stale documentation, bypass attempts, and incomplete deployment records. Use deterministic graders where possible, multiple trials for probabilistic behavior, and human review for judgment-heavy outcomes. Preserve transcripts or tool traces when available so score changes can be diagnosed.

## Delivery measures

Measure the system around the agent:

- lead and wait time by stage;
- first-pass clearance and rework;
- review findings caught before merge;
- escaped defects, rollbacks, and time to restore;
- acceptance and regression stability;
- human active time and approval load;
- agent cost by story and stage;
- instruction, skill, reviewer, test, or gate changes caused by incidents.

Generated lines of code and agent self-reported completion are activity measures, not delivery outcomes.

## Maturity model

| Level | Capability |
|---|---|
| 0 | Chat-driven coding with transient context |
| 1 | Repository memory: constitution, rules, ADRs, and living truth |
| 2 | Evidence lifecycle: stories, seven stage contracts, change records, tests, review, regression, and deployment receipts |
| 3 | Enforced control plane: protected CI and process files, bounded runtime authority, process evals, telemetry, and protected deployment |
| 4 | Organizational system: issue synchronization, portfolio policy, service ownership, cross-repository metrics, and incident feedback |

This starter kit establishes Level 2 and documents the path to Level 3. It is not an enterprise control plane until the adopter configures and proves those controls for the repository's threat model.
