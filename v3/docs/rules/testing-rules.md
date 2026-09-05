# Testing and Evidence Rules

Tests are evidence about behavior, not decoration around implementation.

## Required evidence

1. Every acceptance criterion maps to a named automated or manual proof.
2. Every material behavior has at least one adverse, boundary, or error case that could expose a plausible wrong implementation.
3. Contract changes are tested at every owned boundary, not only at the producer.
4. High-risk changes use an independent reviewer to inspect whether tests could pass for the wrong reason.
5. Manual evidence states who performed it, where, when, and what was observed.

## Test integrity

1. Diagnose whether product code, test code, environment, or specification is wrong before editing a failure.
2. Never weaken an assertion, add a broad retry, insert a sleep, or disable a check merely to make a run green.
3. A skipped test records the blocking reason, owner, follow-up story, and expiry. Silent or permanent skips are forbidden.
4. A passing test must exercise the intended path. Verify identifiers, fixtures, mocks, and selectors against the real implementation.
5. Tests remain deterministic, isolated, and repeatable at their declared layer.
6. Review test diffs for deletion, weakened assertions, changed mocks, narrowed data, bypassed setup, and paths that no longer reach production behavior.
7. Weakening, deleting, skipping, or materially remocking a security-critical or contract-critical test requires explicit human approval and an equal or stronger replacement proof.

## Provenance

Record why important tests exist:

- `AC`: proves a story acceptance criterion;
- `REGRESSION`: preserves a real failure or incident;
- `CONTRACT`: protects a boundary shared by multiple components;
- `RISK`: exercises a threat, failure mode, or rollback condition.

When a new failure class appears, add the smallest permanent test or deterministic check that would reject its return.

## Verification

- Run fast, narrow evidence before slow broad suites.
- Record exact commands, counts, failures investigated, and manual gaps.
- For changed tests, demonstrate that the proof fails when the protected behavior is deliberately broken or contradicted by a controlled counterexample.

## Process tests

Skills and reviewers are production process code. When they change, replay the relevant real failure cases and record outcome, grader, trial count when probabilistic, and diagnostic transcript or tool trace when available. Agent self-report is not a passing result.
