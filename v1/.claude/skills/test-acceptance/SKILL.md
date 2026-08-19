---
name: test-acceptance
description: Runs fast, change-focused proofs for every acceptance criterion on a DEVELOPED change, including adverse and boundary behavior. Use before independent review; this stage does not replace full regression.
---

# Test Acceptance

Input: one change record at stage `DEVELOPED`.

Output: Acceptance Evidence and stage `ACCEPTANCE-TEST-PROVEN`.

Hard rule: prove the requested behavior directly. Do not call a broad green build evidence for an unmapped acceptance criterion, and do not weaken a failing test.

## Procedure

1. Read `docs/rules/testing-rules.md` and the acceptance map in the Discovery Brief.
2. Map every criterion to a named automated or authorized manual proof.
3. Run the fastest targeted tests for changed behavior and contracts, fast layers first.
4. Exercise the planned adverse, boundary, permission, and error paths.
5. For changed tests, use a controlled counterexample or deliberate local break where safe to confirm the evidence can turn red for the protected behavior. Do not weaken or remove a security-critical or contract-critical test without explicit human approval and equal or stronger replacement proof.
6. Classify every failure before editing anything: product defect, test defect, requirement defect, environment defect, or flaky infrastructure.
7. Return production defects to `/develop-code`. If the intended behavior or design changes, return to `/validate-design`.
8. Record commands, counts, failures investigated, skips, manual gaps, and evidence for each criterion.
9. Update `docs/TESTS.md` with honest `AUTO`, `PARTIAL`, or `MANUAL` coverage.
10. Set `Acceptance outcome: ACCEPTANCE-TEST-PROVEN` and stage `ACCEPTANCE-TEST-PROVEN` only when every criterion has credible evidence.

Exit condition: every acceptance criterion has a named proof and adverse case, targeted checks are green, and no result is being represented as broader regression evidence.
