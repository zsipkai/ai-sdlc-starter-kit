---
name: deploy-change
description: Authorizes, merges, deploys, observes, and closes a REGRESSION-TEST-PROVEN change with protected CI and live verification receipts. Use only after full regression and when required human deployment authority is available.
disable-model-invocation: true
---

# Deploy Change

Input: one change record at stage `REGRESSION-TEST-PROVEN` for the exact deployment candidate.

Output: Deployment Record, merged and deployed change where applicable, live verification, stage `DEPLOYED`, and story status `DONE`.

Hard rule: this stage does not repair product code under deployment credentials. A changed candidate returns to review and regression testing. Production, spending, destructive, legal, pricing, and permission-expanding actions require explicit human approval.

## Procedure

1. Confirm the Regression Certificate matches the current commit and all required CI status checks are green.
2. Confirm required review, outcome acceptance, production authority, exceptions, observability, and rollback ownership.
3. Run `bash scripts/sdlc-gate.sh --deploy` for deployment-bound work and record the result.
4. Inspect the exact proposed file set for secrets, workflow changes, generated artifacts, and unrelated changes.
5. Merge only through the repository's protected route. If conflict resolution changes the candidate, return to `/test-regression`.
6. Deploy only authorized, changed surfaces. Use development or staging first when the product supports it.
7. Verify the intended behavior in the live environment and check health, logs, and agreed guardrail signals. A successful deploy command is not live verification.
8. Roll back or stop rollout when live evidence fails. Record what happened before returning to the owning stage.
9. Append approvals, CI links, merge SHA, artifact or provenance identifier when available, deployment identifiers, observed behavior, monitoring window, and rollback status to the Deployment Record.
10. Set `Deployment outcome: DEPLOYED`, the record stage to `DEPLOYED`, and the story status to `DONE` only after the required live evidence exists.

Exit condition: the authorized change is merged, deployed when applicable, observed, recoverable, and permanently linked to its deployment evidence.
