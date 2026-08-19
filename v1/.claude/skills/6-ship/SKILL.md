---
name: 6-ship
description: Stage 6 of the SDLC — final gate, merge, deploy, verify live. Use when the user invokes /6-ship after /5-code-review. Runs the full hard gate, ships each affected surface, and proves it live.
---

# /6 — Ship

**Input:** a `REVIEWED` story branch.
**Output:** merged to `main`, deployed surfaces verified live, plan
status `SHIPPED`.

## Steps

### 1. The full hard gate
```bash
bash scripts/sdlc-gate.sh --full     # drift + backend + iOS build + iOS unit
```
UI-heavy story or anything touching navigation/a11y:
```bash
bash scripts/sdlc-gate.sh --ui       # adds the parallel UI suite
```
Red gate = stop. No "it's just the known failure" hand-waving — verify the
failure list matches the documented baseline exactly, or fix.

### 2. Pre-flight (only for release-bound work)
Story affects the App Store build? Walk docs/PRE-FLIGHT.md end to end and run
`./scripts/check-entitlements.sh`. Submission-bound metadata? Run the
`appstore-reviewer` agent one final time against the finished state —
its verdict line (`READY TO SUBMIT` / `NOT READY`) goes in the plan.

### 3. Merge
```bash
git checkout main && git pull origin main
git merge --no-ff story/<STORY-ID>-<slug>
git push origin main
```
(Or open a PR with `gh pr create` when review-by-human is wanted — the
plan's review report is the PR description.)

### 4. Deploy what changed — nothing more
| Surface changed | Deploy | Verify |
|---|---|---|
| `backend/` | `cd backend && STAGE=development ./deploy.sh`, verify, then `STAGE=production ./deploy.sh` | `bash scripts/integration.sh` — 14/14 |
| `web/` | `aws s3 sync web/ s3://kidstorytime-web-<AWS_ACCOUNT_ID>-us-east-2/ --exclude "WEB.md" --exclude "*.DS_Store" --delete --cache-control "public, max-age=300"` then invalidate `<CF_DISTRIBUTION_ID>` `/*` | curl the changed pages — 200 and the change visible (deploying the *file* is not deploying the *site*; this bit us once) |
| iOS only | nothing to deploy pre-release; TestFlight when the developer says so | `--full` gate already proved the build |

Dev-stage-first for the backend is not optional ceremony — prod and dev
share nothing but code, and dev is where a bad CloudFormation change is
survivable.

### 5. Close the loop
- Plan status → `SHIPPED`, with deploy evidence (test counts, curl
  results, invalidation ID) pasted in.
- Story file in `docs/backlog/` → status `DONE`.
- Anything learned that changes the rules → edit the rule file now and
  note it in the plan; rules that drift from practice stop being read.
