---
name: 3-implement
description: Stage 3 of the SDLC — implement an APPROVED story plan exactly. Use when the user invokes /3-implement. The plan is the contract; deviations go back to the plan, not into the code.
---

# /3 — Implement

**Input:** an `APPROVED` plan in `docs/storyPlans/`.
**Output:** a story branch with the implementation, docs updated, unit
tests green locally.
**Hard rule:** the plan is the contract. Discovering mid-implementation
that the plan is wrong is normal — the response is to update the plan
(re-validating if the change is material), never to silently diverge.

## Steps

### 1. Branch
```bash
git checkout -b story/<STORY-ID>-<slug>
```

### 2. Load the constraints
Read (don't skim) the rules for the surfaces you're touching:
`docs/rules/swift-coding-standards.md` for iOS work,
`docs/rules/security-rules.md` for anything under `backend/` or `API/`,
plus `error-handling.md` and `naming-conventions.md` always. The
governance rules (`ai-generation-governance.md`) apply to every line.

### 3. Work the plan's steps in order
Per step:
- Implement exactly what the step says.
- New iOS files: register in `project.pbxproj` **in the same edit** —
  the repo must stay buildable in Xcode at every commit.
- New UI: accessibility identifiers per naming-conventions §4, same diff.
- Behavior documented anywhere → update that doc in the same commit
  (the pre-commit drift gate enforces the known contracts; you own the
  rest).
- Run the narrow test target for what you changed before moving on:
  ```bash
  xcodebuild test -workspace KidStorytime.xcworkspace -scheme KidStorytime \
    -destination 'platform=iOS Simulator,name=iPhone 16 Pro,OS=18.4' \
    -only-testing:KidStorytimeTests/<RelevantTests>
  ```
  Backend: `cd backend/lambda && node --test`.

### 4. Self-check before handoff
- Diff review against `ai-generation-governance.md` rules 1–7: would a
  human reviewer smell machine-generated code? Fix it now, not in /5.
- `bash scripts/sdlc-gate.sh --fast` passes.
- Commit in plan-step-sized commits; messages say *why* (the story ID
  gives the what).

### 5. Hand off
Update the plan's status to `IMPLEMENTED`, note any approved deviations
in the plan, and point the developer at `/4-test`.
