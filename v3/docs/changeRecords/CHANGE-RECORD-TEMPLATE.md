# STORY-NNN: <Title>

Stage: PLANNED
Risk: LOW | STANDARD | HIGH | CRITICAL
Size: S | M | L | XL | XXL
Execution model: small | mid | top (per docs/rules/model-routing-rules.md — assigned in /plan-task, checked in /validate-design; HIGH/CRITICAL risk requires top)
Budget: <from the size table — S=100k M=250k L=500k XL=1M; XXL must be split>
Owner: <accountable human>
Story: `docs/backlog/STORY-NNN-<slug>.md`
Coordination issue: <optional URL or key>
Deployment candidate: <commit SHA when known>
Harness and version: <agent harness and version when available>
Model: <model or None recorded by harness>

## Discovery Brief

Planning outcome: PLANNED

### Outcome and non-goals

### Current behavior and observations

### Context manifest

List the rules, ADRs, living docs, component docs, code, tests, schemas, contracts, specifications, history, issues, logs, web pages, and tool results read for this change. State why each source matters, classify it as `TRUSTED`, `VERIFIED`, or `UNTRUSTED`, and record how material external claims were checked. Record contradictions as blockers.

| Source | Trust class | Why it matters | Verification |
|---|---|---|---|
| <path, URL, issue, log, or tool result> | <TRUSTED/VERIFIED/UNTRUSTED> | <reason> | <code, test, system, or human check> |

### Declared scope and runtime authority

- Expected files or directories:
- Control-plane files expected to change: None
- Dependencies expected to change: None
- Allowed tools:
- Filesystem scope:
- Network destinations:
- Credential or permission profile:

### Affected owners and contracts

### Unknowns and blockers

### Development tasks

Order small tasks by dependency. Name verified files and tests; label uncertain paths as hypotheses.

### Acceptance map

| Acceptance criterion | Primary proof | Adverse or boundary proof | Layer |
|---|---|---|---|
| <criterion> | <test or procedure> | <negative case> | <unit/integration/UI/live/manual> |

### Risk, observability, and rollback

| Risk or failure mode | Tier | Detection | Mitigation | Rollback owner |
|---|---|---|---|---|
| <risk> | <tier> | <signal> | <control> | <human or role> |

### Human checkpoints

| Decision | Required? | Owner | Evidence or date |
|---|---|---|---|
| Story ready | yes | <name or role> | <reference> |
| Design validation | <based on risk> | <name or role> | <reference> |
| Outcome acceptance | <based on risk> | <name or role> | <reference> |
| Merge or production deployment | yes | <name or role> | <reference> |

### Agent budget and spend ledger

- Token budget (stop-loss): from the size table in the `Budget:` metadata
- Allowed tier by stage: per docs/rules/model-routing-rules.md (execution at the routed tier; verification always top)
- Stop condition: crossing the budget halts the stage for a human decision — raise, split, or escalate the tier

Each stage appends one line here as it finishes (mark estimates as such):

`Tokens spent (<stage>): <n> — <note>`

`scripts/cost-report.sh` aggregates these lines across all records.
- Actual cost:

## Design Verdict

Design outcome: PENDING

### Validated design and simpler alternative considered

### Findings and resolutions

| ID | Severity | Finding | Evidence | Resolution or owner |
|---|---|---|---|---|
| <ID> | <BLOCKER/SHOULD/NOTE> | <finding> | <reference> | <resolution> |

### Second opinion (rule 16 — Risk ≠ LOW)

<Family and model used; `X-n` findings in the table above — or the skip, declared.>

### Exceptions and waivers

Use `None` when no exception exists. Every exception needs scope, owner, reason, compensating control, and expiry or follow-up.

| Rule or gate | Scope | Approved by | Reason | Compensating control | Expires or follow-up |
|---|---|---|---|---|---|
| None | | | | | |

## Implementation Record

Development outcome: PENDING

### Changed files and reasons

- <path and reason>

### Actual scope and authority used

- Files outside declared scope: <None, or reason and approval>
- Control-plane files changed: <None, or list and human owner review>
- Dependencies added or changed: <None, or provenance, security review, and lockfile evidence>
- Tools and network destinations used:
- Credentials or permissions used:

### Decisions and documentation updated

- <decision, document, or None with reason>

### Narrow checks

- <command and result>

### Deviations

- <None, or deviation plus resolution>

## Acceptance Evidence

Acceptance outcome: PENDING

| Acceptance criterion | Proof run | Result | Adverse proof | Result | Evidence |
|---|---|---|---|---|---|
| <criterion> | <test or procedure> | <pass/fail> | <negative case> | <pass/fail> | <log or reference> |

### Failures, skips, and manual gaps

## Review Verdict

Review outcome: PENDING

### Reviewers and scope

- <reviewer and reviewed surface>

### Second opinion (rule 16 — Risk ≠ LOW)

<Family and model used; `X-n` findings below — or the skip, declared.>

### Findings, fixes, and focused retests

- <finding, resolution, and retest evidence>

### Remaining risks and human acceptance

- <risk and owner, or None; acceptance evidence when required>

## Regression Certificate

Regression outcome: PENDING

- Commit SHA:
- Environment:
- Full gate command:
- Build and static analysis:
- Unit and integration:
- UI or end-to-end:
- Security and drift checks:
- Required CI:
- Skips or discarded runs:
- Result:

## Deployment Record

Deployment outcome: PENDING

- Human deployment approval:
- Required CI URL or receipt:
- Merge SHA:
- Artifact or provenance identifier:
- Deployment surface and identifier:
- Live behavior observed:
- Health and guardrail signals:
- Monitoring window:
- Rollback status:

## Definition of Done

- [ ] Every acceptance criterion has recorded evidence.
- [ ] Required adverse, boundary, permission, and error cases pass.
- [ ] No unexplained skip, suppression, retry, sleep, or weakened assertion remains.
- [ ] Code, tests, documentation, decisions, and contracts agree.
- [ ] No blocking review finding remains.
- [ ] Actual files, dependencies, tools, network access, and permissions match the declared scope or have an owned explanation.
- [ ] Every control-plane change has explicit human owner review and evidence that the control was not weakened.
- [ ] Every exception has an owner, compensating control, and expiry or follow-up.
- [ ] Required human checkpoints are recorded.
- [ ] The reviewed combined tree passed the full required matrix.
- [ ] Deployment, live verification, observation, and rollback status are recorded when applicable.
