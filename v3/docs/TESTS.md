# Test Truth

## Coverage matrix

| Scenario | Evidence | Test or manual procedure | Provenance | Adverse proof |
|---|---|---|---|---|
| <critical behavior> | AUTO | `<exact test name>` | AC | `<negative, boundary, or error case>` |

Use AUTO, PARTIAL, or MANUAL honestly.

## Exact commands

```bash
<fast test command>
<full test command>
<deployment test command>
```

## Test editing policy

- Identify whether code, test, change record, or environment is wrong before editing a failure.
- Do not add sleeps, unbounded retries, skips, or weaker assertions to turn red green.
- Record discarded environment failures separately from product failures.
- For changed tests, confirm the evidence would fail under a plausible wrong implementation.
- Review test diffs as critically as production diffs. Deleting, skipping, weakening, or materially remocking a security-critical or contract-critical test requires explicit human approval and a recorded replacement proof.
- Verify that fixtures, mocks, selectors, and test doubles exercise the intended production boundary rather than a convenient local approximation.
- Follow `docs/rules/testing-rules.md` for skips, provenance, adverse cases, and manual evidence.

## Acceptance versus regression

- Acceptance proof is fast and change-scoped. It maps every criterion to direct evidence.
- Regression proof runs the complete configured matrix after review fixes on the combined tree.
- Neither result may be presented as the other.

## Skips and manual gaps

| Test or scenario | Reason | Owner | Follow-up story | Expiry or review date |
|---|---|---|---|---|
| None | | | | |

A skip without an owner and follow-up is a hidden failure, not test coverage.

## Process evaluations

Keep a small corpus of real failures that the lifecycle must continue to detect. A skill, reviewer, rule, or gate change should replay the affected cases and record the expected outcome, actual outcome, trial count when probabilistic, grader, and transcript or tool-trace reference when available.

| Process case | Control under test | Expected outcome | Grader | Last result |
|---|---|---|---|---|
| <known unsafe design or bad diff> | <skill/reviewer/gate> | <blocker, finding, or failed check> | <script/model/human> | <date and result> |
