# Kid Storytime — Agent Constitution

iOS bedtime-stories app (SwiftUI) + AWS Lambda proxy + static web.
App Store name: *Kid Storytime: Bedtime Stories*. Bundle:
`com.sipkai.KidStorytime`. Live site: https://kidstorytime.app.

## How work happens here

Feature work runs through the gated SDLC — six skills, each a stage:

`/1-plan-story` → `/2-validate-plan` → `/3-implement` → `/4-test` →
`/5-code-review` → `/6-ship`

Full explanation: **SDLC.md**. Stories live in `docs/backlog/`,
plans in `docs/storyPlans/`. Small fixes may skip stages deliberately —
say so out loud; never skip them silently.

## Hard rules (the ten that are never negotiable)

1. The plan is the contract — deviations go back to the plan, not into code.
2. Never weaken a gate to pass it (tests, caps, drift checks, thresholds).
3. Keep the project buildable in Xcode: new/moved/deleted iOS files update
   `project.pbxproj` in the same change.
4. Docs change with behavior, same commit — the pre-commit drift gate
   enforces the known contracts (`scripts/check-doc-drift.sh`).
5. Cross-codebase constants ship with contract tests on both sides.
6. No upstream API key ever exists client-side.
7. Premium gating decisions come from `PremiumManager.canUse(_:)` only;
   tier numbers come from `backend/lambda/services/quota.js#LIMITS` only.
8. Check `docs/decisions/` before making a technical choice; ADRs are not
   re-litigated in plans.
9. Money, deletion of AWS resources, price/tier/legal changes, and
   `--no-verify` need an explicit human yes.
10. Code must read human-written — `docs/rules/ai-generation-governance.md`
    rules 1–8 apply to every diff.

## Before writing code

Read the rules for the surface you're touching — they are short and every
one encodes a shipped bug:

| Surface | Rules |
|---|---|
| Any Swift | docs/rules/swift-coding-standards.md |
| backend / API / infra | docs/rules/security-rules.md |
| Structure & boundaries | docs/rules/architecture-rules.md |
| Errors & user messaging | docs/rules/error-handling.md |
| Names, IDs, keys | docs/rules/naming-conventions.md |
| Every diff | docs/rules/ai-generation-governance.md |

## Quick commands

```bash
bash scripts/sdlc-gate.sh --fast   # drift + backend tests (~15s; also the pre-commit hook)
bash scripts/sdlc-gate.sh --full   # + iOS build + unit tests
bash scripts/sdlc-gate.sh --ui     # + parallel UI suite
bash scripts/integration.sh        # live smoke against prod/dev/web
bash scripts/install-hooks.sh      # once per clone
```

Always open `KidStorytime.xcworkspace`, never the `.xcodeproj` (CocoaPods).

## Document map

Product & engineering source of truth: PRODUCT.md (its §16.5
trap list is required reading for SwiftUI work). Testing: TESTS.md.
Infra: INFRASTRUCTURE.md · DEPLOYMENT.md.
Release: PRE-FLIGHT.md · APP_STORE_LISTING.md.
Specialist reviewers live in `.claude/agents/` (security, App Store,
SwiftUI, doc-drift) — /2 and /5 fan them out on risk surfaces.
