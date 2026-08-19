---
name: 2-validate-plan
description: Stage 2 of the SDLC — adversarial review of a DRAFT story plan before any code is written. Use when the user invokes /2-validate-plan after /1-plan-story. Promotes the plan to APPROVED or sends it back.
---

# /2 — Validate Plan (the devil's advocate gate)

**Input:** a `DRAFT` plan in `docs/storyPlans/`.
**Output:** the same plan, status `APPROVED` — or `DRAFT` with a findings
section the developer must resolve.
**Why this stage exists:** bad plans become bad code at 10× the cost. This
is the cheapest place in the whole pipeline to kill a mistake.

## Steps

### 1. Attack the plan yourself
Read the plan cold and try to break it:

- **Completeness** — does the file list cover everything the scope implies?
  (Classic miss: the doc updates. Behavior changes touch PRODUCT.md /
  TESTS.md / WEB.md / docs/APP_STORE_LISTING.md — the drift gate will block the
  commit anyway, so the plan must include them.)
- **Contracts** — if a tier number, cap, or a11y ID moves, are both-side
  contract tests in the plan?
- **Cheaper path** — is there a smaller change with the same user outcome?
  Name it; make the plan justify the bigger one.
- **ADR conflicts** — anything here contradicting `docs/decisions/`?
- **Testability** — can each acceptance criterion fail? A criterion no
  test can fail is decoration.
- **The rollback question** — if this ships broken Friday night, what's
  the undo? (Code revert / CloudFormation rollback / App Store expedited
  review — the answer differs by surface and belongs in the risk register.)

### 2. Fan out specialists on risk surfaces
Spawn in parallel, as relevant, per the plan's own risk register:
- `security-reviewer` — plan touches backend/API/entitlements/infra
- `appstore-reviewer` — plan touches paywall/StoreKit/metadata/privacy
- `swiftui-reviewer` — plan touches navigation, a11y, audio, or concurrency

They review **the plan**, not code — cheaper to move a wall on paper.

### 3. Consolidate
Append a `## Validation findings` section: numbered findings, each
`BLOCKER` / `SHOULD` / `NOTE`, with a resolution line. Every BLOCKER needs
either a plan edit or an explicit developer override (recorded).

### 4. Verdict
- All blockers resolved → set status `APPROVED`, tell the developer to
  proceed with `/3-implement`.
- Otherwise → keep `DRAFT`, list what's unresolved. Never approve a plan
  to be polite; the whole pipeline inherits this gate's honesty.
