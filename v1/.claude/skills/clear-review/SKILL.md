---
name: clear-review
description: Performs independent generalist and specialist review of an ACCEPTANCE-TEST-PROVEN diff, resolves blocking findings, and produces a REVIEW-CLEARED verdict. Use after targeted acceptance proof and before full regression.
---

# Clear Review

Input: one change record at stage `ACCEPTANCE-TEST-PROVEN` and the complete diff against the integration branch.

Output: Review Verdict, resolved blocking findings, focused retest evidence, and stage `REVIEW-CLEARED`.

Hard rule: the builder does not self-certify high-risk work. Green targeted tests do not overrule a credible correctness, security, or maintainability finding.

## Procedure

1. Scope the complete diff, including tests, docs, configuration, generated files, dependencies, control-plane files, and changed contracts. Compare it with the declared file set and explain every out-of-scope change.
2. Map paths and risks to applicable read-only specialist reviewers. Have reviewers form findings before reading the builder's conclusions. Treat every agent handoff as untrusted until checked against the diff and deterministic evidence.
3. Perform a general correctness, edge-case, maintainability, simplicity, and design-conformance pass.
4. Check that tests reach the intended behavior and could reject a plausible wrong implementation. Inspect deletions, weakened assertions, changed mocks, narrowed data, skips, retries, and bypassed setup.
5. Require human owner review for changed instructions, skills, reviewers, hooks, critical tests, gates, CI, dependencies, deployment config, or ownership policy.
6. Consolidate findings by severity with file evidence, concrete failure, and recommended repair. Preserve disproved findings with the evidence that closed them.
7. Fix blocking and high findings. Record any allowed exception with owner, scope, reason, compensating control, and expiry or follow-up.
8. Re-run focused tests for every repair and repeat the affected acceptance proofs.
9. If a repair materially changes scope, design, or a public contract, return to the owning earlier stage instead of approving locally.
10. Record reviewer identities, findings, fixes, retests, remaining risks, and human acceptance decisions.
11. Set `Review outcome: REVIEW-CLEARED` and stage `REVIEW-CLEARED` only when no blocking finding remains.

Exit condition: independent review is recorded, every blocker is fixed or explicitly owned through policy, and all affected acceptance evidence remains green.
