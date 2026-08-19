# STORY-004 — Stop mislabeling provider failures as the user's daily limit

- **Status:** DONE (2026-08-14, plan: ../storyPlans/STORY-004-plan.md)
- **Surfaces:** iOS / backend

## Story
As a parent, when story generation fails because of a provider problem
(OpenAI out of credits, rate-limited, down), I should see "we're having
trouble right now, try again soon" — not "Daily limit reached. Try again
tomorrow," which blames me and tells me to give up for a day.

Origin: live incident 2026-08-14 20:22. OpenAI returned
`429 insufficient_quota` ("You have no credits remaining"); the backend
passed 429 through; `BackendClient.friendlyQuotaMessage` translates any
429 into the daily-limit copy. Three story credits were also burned from
the daily quota for generations that produced nothing.

## Acceptance criteria
1. Backend maps upstream 429/5xx to **502** with a machine-readable code
   (e.g. `{"error":"upstream_unavailable"}`); HTTP 429 from our API means
   exactly one thing: OUR quota.
2. iOS shows distinct copy for `upstream_unavailable` ("having trouble
   right now, try again in a bit") vs our 429 (daily-limit / paywall
   flow per STORY-003).
3. A story-quota reservation is **released when the upstream call fails**
   before any content is returned — failed generations must not consume
   the user's day.
4. Backend handler tests cover: upstream 429 → 502 + no net quota burn;
   upstream 500 → 502 + no net quota burn; our quota hit → 429.
5. Log line for upstream failure keeps status + error code only (no
   error body — the incident log echoed OpenAI's message, confirming
   security-rules.md #9 applies here).

## Non-goals
No retry/queue logic; no provider failover (ElevenLabs fallback exists
for TTS only).

## Links
CloudWatch /aws/lambda/kidstorytime-api-development 2026-08-14T18:22Z;
docs/rules/error-handling.md #7-9; STORY-003; ADR-003.
