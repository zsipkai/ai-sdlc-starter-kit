---
name: 4-test
description: Stage 4 of the SDLC — prove the implemented story with the full test matrix. Use when the user invokes /4-test after /3-implement. Writes missing tests, runs the matrix, updates TESTS.md coverage.
---

# /4 — Test

**Input:** an `IMPLEMENTED` story branch.
**Output:** the story's test plan fully executed — new tests written,
matrix green, TESTS.md coverage matrix updated.

## The matrix (run in this order — fast feedback first)

| Layer | Command | Budget |
|---|---|---|
| Contract/drift | `bash scripts/check-doc-drift.sh` | seconds |
| Backend | `cd backend/lambda && node --test` | ~15s |
| iOS unit | `xcodebuild test … -only-testing:KidStorytimeTests` | ~2 min |
| iOS UI (parallel) | `… -only-testing:KidStorytimeUITests -parallel-testing-enabled YES -parallel-testing-worker-count 4` | ~6 min |
| Live integration | `bash scripts/integration.sh` | ~5s |

(Full commands with workspace/scheme/destination live in TESTS.md §0.2 —
use the exact flags; `-parallel-testing-worker-count`, not the `-maximum-`
variant, forces 4 workers.)

## Steps

### 1. Write the tests the plan promised
Every acceptance criterion maps to at least one named test. Story touched
a mirrored constant? Both-side contract tests exist (the prompt-cap pair
is the template). New UI? UI test uses the identifiers shipped in /3.

### 2. Run the matrix
Bottom-up as tabled above. UI-suite hygiene when clones misbehave:
```bash
xcrun simctl shutdown all && xcrun simctl delete unavailable
```
Known baseline: zero failing tests (the last tracked failure closed with
STORY-002). Any red is signal about the change under test — triage it,
never park it as a new known failure.

### 3. Triage honestly
A failing test means: the code is wrong, the test is wrong, or the plan
was wrong. Fixing the test to pass without knowing which — that's the
governance prime directive violation. Figure out which first, then fix
that thing.

### 4. Update TESTS.md
New scenarios get a row in the §0.1 coverage matrix, tagged
`[AUTO]` / `[PARTIAL]` / `[MANUAL]` honestly. If something can only be
verified by hand (audio behavior, App Attest on device), say so and add
the manual steps.

### 5. Hand off
Plan status → `TESTED`, with a one-line result summary per matrix layer.
Point the developer at `/5-code-review`.
