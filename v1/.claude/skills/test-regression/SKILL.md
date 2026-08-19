---
name: test-regression
description: Runs the repository's complete deterministic quality matrix on a REVIEW-CLEARED combined tree and produces a REGRESSION-TEST-PROVEN certificate. Use after review fixes and before deployment authority is granted.
---

# Test Regression

Input: one change record at stage `REVIEW-CLEARED` on the latest combined tree.

Output: Regression Certificate and stage `REGRESSION-TEST-PROVEN`.

Hard rule: a red or missing required check stops the transition. Do not add skips, retries, suppressions, sleeps, or weaker thresholds merely to make the matrix green.

## Procedure

1. Update from the integration branch or construct the exact merge candidate without discarding unrelated work.
2. Confirm the change record, documentation links, and contract or drift checks are internally consistent.
3. Run `bash scripts/sdlc-gate.sh --full` in a clean environment when available.
4. Run the configured complete matrix: build, static analysis, unit, integration, UI or end-to-end, security, documentation drift, and required non-production smoke checks.
5. Record exact commands, commit SHA, environment, counts, duration, skips, and artifacts. Distinguish product failures from environmental runs that were discarded with evidence.
6. Return failures to the stage that owns the cause. Any code or test change invalidates the certificate and requires review of the new diff.
7. Confirm required CI reports against the same commit and that protected control definitions match the reviewed candidate when CI is configured.
8. Append the complete Regression Certificate, set `Regression outcome: REGRESSION-TEST-PROVEN`, and set stage `REGRESSION-TEST-PROVEN`.

Exit condition: the reviewed combined tree passed every configured required check with no unexplained gap, and the evidence identifies the exact commit that was proven.
