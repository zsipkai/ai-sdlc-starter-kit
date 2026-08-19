# ADR-002 — All AI calls proxy through AWS behind Apple App Attest

- **Date:** 2026-05-02
- **Status:** Accepted
- **Surfaces:** iOS / backend / infra

## Context
OpenAI and ElevenLabs keys cost real money per call. Any key shipped in
the IPA is extractable in minutes; a public unauthenticated proxy is a
billing bomb. The app has no user accounts to hang auth on.

## Decision
Keys live only in Lambda env vars. Every authenticated route requires an
Apple App Attest assertion binding `(method, path, sha256(body))`, replay-
protected by a strictly monotonic counter enforced via DynamoDB
conditional writes. Install identity, daily quotas, and per-IP rate limits
live in DynamoDB. Simulator bypass answers only on the development stage.

## Consequences
Easy: revoking abuse (delete install row), quota enforcement before
upstream spend, zero client-side secrets. Hard: device-only testing for
the full auth path (App Attest doesn't run in simulator); backend must
deploy before any iOS build that changes auth. Forbidden: any route that
reaches OpenAI/ElevenLabs without quota reservation. Tripwire: the
security-reviewer agent checklist items 1–4.
