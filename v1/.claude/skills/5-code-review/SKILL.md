---
name: 5-code-review
description: Stage 5 of the SDLC — multi-agent review of a tested story branch. Use when the user invokes /5-code-review after /4-test. Fans out specialist reviewers in parallel, consolidates severity-ranked findings, fixes what blocks.
---

# /5 — Code Review

**Input:** a `TESTED` story branch.
**Output:** a review report appended to the story plan, blockers fixed,
status `REVIEWED`.
**Principle:** one model reviewing its own diff is proofreading, not
review. Risk surfaces get independent specialist passes, in parallel.

## Steps

### 1. Scope the diff
```bash
git diff main...HEAD --stat
```
Map changed paths to reviewers (the plan's risk register predicted this;
verify against reality):

| Diff touches | Reviewer agent |
|---|---|
| anything under `KidStorytime/` | `swiftui-reviewer` |
| `backend/`, `API/`, entitlements, CloudFormation, `ModelSecrets` | `security-reviewer` |
| paywall, `.storekit`, privacy/terms pages, docs/APP_STORE_LISTING.md | `appstore-reviewer` |
| any behavior/limit/structure documented elsewhere | `doc-drift-checker` |

### 2. Fan out — in parallel, in one message
Spawn every applicable agent simultaneously; each gets the diff scope and
reports findings in its own numbering (UI-n / S-n / AS-n / D-n). While
they run, do the generalist pass yourself: correctness of the actual
logic, edge cases the specialists don't own, and the human-written-feel
check (`ai-generation-governance.md` rules 1–8).

### 3. Consolidate
Merge into one severity-ranked table in the plan under `## Review report`:
finding ID, severity, file:line, one-line summary, resolution. De-duplicate
across reviewers (same root cause = one row, credited to both).

### 4. Resolve
- CRITICAL / BLOCKER: fix now, on this branch. Re-run the narrow tests
  for whatever the fix touched.
- HIGH: fix now unless the developer explicitly defers — deferral becomes
  a new backlog story, linked from the report.
- MEDIUM / LOW: fix if cheap (<15 min), else backlog story.
- FALSE POSITIVE: keep the row, mark it, one line of evidence why. (Review
  history has caught reviewers reviewing stale state — verify against the
  current file before accepting *or* dismissing.)

### 5. Verify the fixes
`bash scripts/sdlc-gate.sh --fast` plus the narrow test targets touched by
review fixes. Then plan status → `REVIEWED`, point the developer at
`/6-ship`.
