# STORY-004 — Stop mislabeling provider failures as the user's daily limit

**Status: SHIPPED** (2026-08-14) (validated /2: self-pass V-1..V-4 + security-reviewer S-1..S-4 folded in)

## Scope
When story generation fails upstream (OpenAI non-OK, timeout, network
error), the user sees honest transient-failure copy and their daily story
quota is not consumed. HTTP 429 from our API comes to mean exactly one
thing: *our* quota. Non-goals: no retries, no provider failover, no
change to limits (ADR-003) or to reserve-before-spend (ADR-002 — we add
release-after-failure, which strengthens rather than contradicts it).

## Decisions checked
- ADR-002: quota still reserved before any upstream call. Release only
  on failure paths where no content was returned. No conflict.
- ADR-003: tier numbers untouched. No conflict.

## Files
| File | Change |
|---|---|
| `backend/lambda/services/quota.js` | new `releaseStoryQuota(installId)` — atomic `ADD storyCount -1`, conditional `storyCount > 0 AND day = :reservedDay` where the day is captured at reservation time (`reserveStoryQuota` returns it) — S-3: conditioning on release-time today() could refund across a midnight day-roll. Release errors are logged and swallowed — a failed refund must not mask the primary error. |
| `backend/lambda/index.mjs` | `storyGenerate`: on `!res.ok` → release + return **502 `{"error":"upstream_unavailable"}`** (was: pass-through of OpenAI's status). On abort/timeout → **NO release** (S-1: OpenAI may have billed a completed generation that arrived late; refunding those would let timeout storms spend upstream unbounded), keep 504. On pre-response network throw → release, rethrow. Log becomes status + parsed OpenAI `error.code`, sanitized (≤64 chars, `^[a-z0-9_.-]+$` allowlist, else 'unparseable') — S-4; no body slice (security-rules.md #9). |
| `backend/lambda/test/quota.test.js` | release: decrements; condition floors at 0; day-guard present; swallow-on-conditional-failure. |
| `backend/lambda/test/helpers/fakeServices.js` | fake quota gains `releaseStoryQuota` recorder (calls tracked for assertions). |
| `backend/lambda/test/handler.test.js` | upstream 429 → our 502 + release called (the "429 is ours alone" contract); upstream 500 → 502 + release; our-quota exhaustion still → 429 with no release; hung upstream (timeout) → 504 with **no release** (S-1 assertion; needs `STORY_TIMEOUT_MS` env override mirroring the existing TTS-test timeout pattern). |
| `KidStorytime/API/BackendClient.swift` | non-2xx branch: 502 with `upstream_unavailable` → transient copy ("Story magic is having a moment — please try again in a little while."), distinct from quota copy. 429 mapping unchanged. |
| `docs/rules/error-handling.md` | #7: pin the semantic — 429 = our quota only; 502 = upstream provider failed. |
| `docs/backlog/STORY-004-…md` | status → DONE at ship. |

No new iOS files → no pbxproj change. No mirrored numeric constants → no
new contract-test pair; the "429 is ours" rule is itself pinned by the new
handler test.

## Risk register
- **Security:** refund could be seen as enabling free retry storms — but
  the per-IP rate limit (30/min) + Lambda reserved concurrency bound attempts (S-2: no per-install limiter exists — do not claim one), and a failed upstream
  call costs ~nothing; successes still consume quota. → security-reviewer
  to confirm in /2 (backend surface).
- **Race:** concurrent generate where one fails: `ADD` is atomic; the
  same-day condition prevents cross-day corruption.
- **Client compat:** older client treats unknown 502 via generic
  `apiError` path — degraded copy, not breakage.
- **Rollback:** single revert commit + `deploy.sh` dev→prod.
- App Store impact: none (no paywall/metadata change).

## Test plan
Backend: 4 new quota tests + 3 new handler tests, full suite stays green
(81 pass / 1 skip baseline). iOS: unit suite + build (no logic change
beyond message mapping; no UI structure change → UI suite not required by
this story). Gates: `--fast` at commit, `--full` at ship. Live check:
OpenAI is currently out of credits — a real generate attempt after deploy
must now show the transient copy, not "Daily limit reached", and must NOT
decrement the day's remaining quota. (The incident becomes the test rig.)

## Steps
1. `releaseStoryQuota` + quota tests.
2. `storyGenerate` failure paths + 502 mapping + log hygiene + handler tests.
3. `BackendClient` 502 branch + copy.
4. error-handling.md #7 wording.
5. Gates, ship per /6 (deploy dev → verify live → prod).

## Validation findings (/2)

- **V-1 (BLOCKER, resolved):** file list missed
  `backend/lambda/test/helpers/fakeServices.js` — the fake quota service
  must gain a `releaseStoryQuota` recorder or the new handler assertions
  cannot exist. → Added to Files.
- **V-2 (SHOULD → follow-up):** `speechChunk` (index.mjs:341) and
  `speechBatch` (:371) burn TTS-char quota on upstream failure — same
  defect class, deliberately out of 004's scope. → Filed as STORY-005.
- **V-3 (NOTE):** nothing in the backend emits 402; the client's
  `402 || 429` quota mapping keeps working unchanged.
- **V-4 (NOTE):** backend/README makes no status-code claims about
  story/generate, so error-handling.md is the only doc to touch.
- **V-5 (security-reviewer):** see appended verdict below.

- **V-5 (security-reviewer verdict):** SHIP AFTER FIXES — S-1 (HIGH) no
  release on timeout/abort: folded into Files + Test plan. S-2 risk-register
  wording corrected. S-3 reservation-day condition: adopted. S-4 log
  sanitization: adopted. All four resolved in this plan revision.

## /3 + /4 evidence
- Backend suite: 85 tests, 84 pass, 0 fail, 1 skip (baseline) — includes
  4 new tests: upstream 5xx → 502 + refund; upstream 429 → 502 + refund
  (the incident test); our-quota → 429 no refund; hung upstream → 504 +
  NO refund (S-1, via STORY_UPSTREAM_TIMEOUT_MS override in its own file).
- Implementation deviations from plan: client copy reads "Story time is
  having trouble right now. Please try again in a little while." (plan
  draft's em-dash phrasing dropped per web content rules); release
  logging is name-only (`err.name`) rather than hashed installId — no ID
  needed at all beats hashing one.
- iOS: BUILD SUCCEEDED with the 502 branch; fast gate green.

## /5 review report
- security-reviewer (diff-level, commit 4627a19): S-1 timeout-no-refund
  honored (code + test verified); S-3 reservation-day condition honored;
  S-4 sanitized logging honored; release-swallow semantics fail closed
  (a lost refund consumes quota — attacker gains nothing); 502 body is a
  constant, nothing upstream-controlled reaches the client. Pre-existing
  log-hygiene debt at index.mjs:212/215 + :351 noted as OUT of this
  story's scope. **Verdict: SHIP.**
- Generalist pass (orchestrator): diff read for governance rules 1-8 —
  comments explain why (billed-after-abort rationale, PII note), no
  narration logs added, no defensive theater. Clean.

## /6 ship evidence
- Merged to main 861b97e (--no-ff), full-gate components green on the
  merged tree (drift 7/7, backend 84/0, iOS build + unit suite).
- Dev deploy: lambda code update Successful; live generate on dev
  returned HTTP 200 with a real story (OpenAI credits restored by the
  developer mid-ship — the planned creditless-502 live repro was no
  longer reproducible; failure-path behavior remains proven by the four
  /4 handler tests). Quota consumed on success (0→1) and NOT refunded —
  correct; test credit returned via scripts/dev-reset-quota.sh.
- Prod deploy: initial script run hit a transient Lambda
  ResourceConflictException; code push retried explicitly. Verified by
  CONTENT, not by CodeSha256 (re-zips differ by timestamps): downloaded
  the running prod bundle — contains upstream_unavailable mapping,
  releaseStoryQuota, and the S-1 no-refund-on-timeout comment.
- Live integration: 14/14 PASS.
