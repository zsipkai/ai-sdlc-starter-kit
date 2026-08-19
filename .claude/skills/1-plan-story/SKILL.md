---
name: 1-plan-story
description: Stage 1 of the SDLC — turn a backlog story into an implementation plan. Use when the user invokes /1-plan-story with a story ID, or asks to plan a story. Produces docs/storyPlans/<STORY-ID>-plan.md. Writes NO production code.
---

# /1 — Plan Story

**Input:** a story ID (e.g. `STORY-001`) or path under `docs/backlog/`.
**Output:** `docs/storyPlans/<STORY-ID>-plan.md`, status `DRAFT`.
**Hard rule:** no production code, no file edits outside `docs/`. Planning
that "just quickly fixes" something has skipped three gates.

## Steps

### 0. Clean start
`git status` — if not on `main` or the tree is dirty, stop and ask whether
to stash, commit, or abort. Never plan on top of unrelated changes. Then
`git pull origin main`.

### 1. Read the story
Load `docs/backlog/<STORY-ID>-*.md`. If acceptance criteria are missing or
untestable, stop — fix the story first (that's a conversation, not a guess).

### 2. Check prior decisions
Search `docs/decisions/` for ADRs touching this area **before** making any
technical choice. Decisions already made are not re-litigated in a plan.
If the story conflicts with an ADR, surface the conflict to the developer.

### 3. Explore the code
Use the Explore agent to map the blast radius: files to change, tests that
cover them, contracts involved (tier numbers, prompt caps, a11y IDs). Read
the relevant rules in `docs/rules/` for the areas touched.

### 4. Write the plan
Create `docs/storyPlans/<STORY-ID>-plan.md`:

```markdown
# <STORY-ID> — <title>          Status: DRAFT
## Scope
What changes, user-visibly. Explicit non-goals.
## Files
Each file to touch and why. New iOS files note pbxproj registration.
## Contracts affected
Tier numbers / caps / a11y identifiers / API shapes — with the matching
contract-test and doc updates the diff must include (drift rule).
## Risk register
- App Store impact? (paywall, metadata, privacy → appstore-reviewer in /5)
- Security impact? (backend, API, entitlements → security-reviewer in /5)
- The one thing most likely to break, and how we'd notice.
## Test plan
Which existing tests prove no regression; which new tests the story needs
(named, per naming-conventions §11). UI-affecting stories list the
identifiers new UI must carry.
## Steps
Ordered implementation steps sized for review (each a coherent commit).
```

### 5. Hand off
Tell the developer the plan path and the open questions (if any), then
point them at `/2-validate-plan`. Do not start implementing.
