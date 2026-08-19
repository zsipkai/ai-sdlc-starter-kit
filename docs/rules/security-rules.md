# Security Rules — Kid Storytime

> Threat model: **the OpenAI and ElevenLabs keys cost real money per call.**
> Every rule here defends the path between an attacker and a five-figure
> API bill. Read this before touching `backend/`, `KidStorytime/API/`,
> or any CloudFormation template.

## The invariants (never negotiable)

1. **No upstream API key ever exists client-side.** Not in Swift, not in the
   web bundle, not in a config file that ships. Keys live only in Lambda
   environment variables sourced from CloudFormation `NoEcho` parameters.
2. **Every authenticated route requires a valid App Attest assertion** bound
   to `(method, path, sha256(body))`. Structural validity is not enough —
   the canonical payload hash must match what the client signed.
3. **The App Attest counter is strictly monotonic per install**, enforced by
   a DynamoDB conditional update. That conditional is the replay defense;
   any in-Lambda counter check is just documentation.
4. **The `simulator` install bypass answers only when `STAGE=development`.**
   The production handler rejects it before any other processing.
5. **Quota is reserved *before* upstream spend,** atomically, via DynamoDB
   conditional write. Never call OpenAI/ElevenLabs first and account later.

## Changing quota or caps

6. `backend/lambda/services/quota.js#LIMITS` is the single source of truth
   for tier numbers and per-request caps. Changing any value requires, in
   the same commit:
   - the mirrored iOS constant + its contract test
     (`StoryPromptBuilderTests`),
   - the backend contract test (`quota.test.js`),
   - PRODUCT.md §6 and APP_STORE_LISTING.md,
   - a passing `scripts/check-doc-drift.sh`.
7. **`perRequest` caps must stay ≤ the daily caps they protect.** A
   per-request TTS cap above the free daily quota turns one call into a
   full-quota burn.

## Logging

8. **Never log a raw `installId`** — hash it (`sha256(...).slice(0,8)`) so
   log lines correlate without being linkable across exports.
9. **Never log upstream error bodies.** OpenAI echoes the offending prompt
   in moderation errors, and prompts contain children's names. Log status
   code + parsed error code only.
10. Request headers `X-App-Assertion` and `X-Premium-Proof` never appear in
    logs at any level.

## IAM & infrastructure

11. The Lambda role gets **exactly** the DynamoDB actions it uses, scoped to
    exact table ARNs. No wildcards, no S3, no Secrets Manager, no
    `lambda:InvokeFunction`.
12. Reserved concurrency stays set (currently 50) — it is the hard ceiling
    on parallel upstream spend.
13. S3 buckets are private with `BucketOwnerEnforced`; only the CloudFront
    OAI principal reads the web bucket. The one exception is the
    `getkidstorytime-redirect` website bucket, which serves only a 301.
14. Rotating `CHALLENGE_HMAC_SECRET` invalidates in-flight challenges
    (≤5 min blast radius) and is always safe. Rotate upstream API keys in
    the provider dashboard first, then redeploy.

## StoreKit / premium proof

15. Premium claims are proven by StoreKit 2 JWS verified server-side against
    the full ladder: Apple Root CA G3 chain → bundle ID → product allow-list
    → ownership → revocation → environment → expiry. Skipping any rung
    accepts forged receipts.
16. The client treats `X-Premium-Proof` as opportunistic — the server's
    verdict is the only one that matters for quota.

## Review triggers

Any diff touching these paths gets the `security-reviewer` agent in /5:
`backend/lambda/**`, `KidStorytime/API/**`, `KidStorytime/ModelSecrets.swift`,
`*.entitlements`, `backend/cloudformation.yaml`, `infra/**`.
