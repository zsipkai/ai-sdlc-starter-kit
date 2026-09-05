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
3. Add the cross-family second opinion (routing rule 16) on `STANDARD`, `HIGH`, or `CRITICAL` risk: run `bash scripts/second-opinion.sh STORY-NNN review` (charter + record + diff in one pack), have the human paste it into a **top** model of a different family, and paste the findings back as `X-n` rows — or add `--auto` to send the pack to the second family's API and capture the findings without a paste (per-token cost on that account). A different family catches what same-family reviewers systematically miss. Judge only, never gate; declare a skip in the verdict.
4. Perform a general correctness, edge-case, maintainability, simplicity, and design-conformance pass.
5. Check that tests reach the intended behavior and could reject a plausible wrong implementation. Inspect deletions, weakened assertions, changed mocks, narrowed data, skips, retries, and bypassed setup.
6. Require human owner review for changed instructions, skills, reviewers, hooks, critical tests, gates, CI, dependencies, deployment config, or ownership policy.
7. Consolidate findings by severity with file evidence, concrete failure, and recommended repair. Preserve disproved findings with the evidence that closed them.
8. Fix blocking and high findings. Record any allowed exception with owner, scope, reason, compensating control, and expiry or follow-up.
9. Re-run focused tests for every repair and repeat the affected acceptance proofs.
10. If a repair materially changes scope, design, or a public contract, return to the owning earlier stage instead of approving locally.
11. Record reviewer identities, findings, fixes, retests, remaining risks, and human acceptance decisions. Append the stage's spend line, then hand off to `/test-regression` in a fresh session — the full matrix must certify the exact reviewed candidate.
12. Set `Review outcome: REVIEW-CLEARED` and stage `REVIEW-CLEARED` only when no blocking finding remains.

Exit condition: independent review is recorded, every blocker is fixed or explicitly owned through policy, and all affected acceptance evidence remains green.
