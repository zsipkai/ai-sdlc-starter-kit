---
name: validate-design
description: Adversarially challenges a PLANNED change for architectural fit, simplicity, contracts, security, reversibility, and testability. Use before implementation to produce a DESIGN-VALIDATED verdict or explicit blockers.
---

# Validate Design

Input: one change record at stage `PLANNED`.

Output: a Design Verdict and stage `DESIGN-VALIDATED`, or recorded blockers with the stage unchanged.

Hard rule: do not approve by politeness or by silently rewriting the proposal until objections disappear. Do not edit production code.

## Procedure

1. Verify every named file, symbol, decision, owner, contract, and dependency against repository evidence.
2. Test big-picture fit: preserve component boundaries, single owners, durable identifiers, and accepted decisions.
3. Propose the smallest simpler approach that can meet the same outcome. Record why it is sufficient or why the larger design is necessary.
4. Trace schemas, mirrored values, APIs, navigation, persistence, permissions, money, privacy, and other affected contracts end to end.
5. Challenge each acceptance proof. Confirm it can fail under a plausible wrong implementation and covers adverse, boundary, and error behavior.
6. Check rollback per surface, observability, migration safety, operational impact, cost, trust boundaries, stage authority, and required human decisions.
7. Identify any change to instructions, skills, reviewers, hooks, tests that defend critical behavior, gate scripts, CI, dependencies, deployment config, or ownership policy. Require explicit human review and an independent proof that the control was not weakened.
8. Ask applicable read-only specialists for independent findings on high-risk surfaces.
9. Check the model routing: a `small` or `mid` executor on a HIGH/CRITICAL-risk or ambiguous task is a `BLOCKER` (the change-record gate also rejects it mechanically); an over-tiered mechanical task is a `NOTE`.
10. Add the cross-family second opinion (routing rule 16) on `STANDARD`, `HIGH`, or `CRITICAL` risk: run `bash scripts/second-opinion.sh STORY-NNN design`, have the human paste the pack into a **top** model of a different family, and paste the findings back as `X-n` rows with the same severities — or add `--auto` to send the pack to the second family's API and capture the findings without a paste (per-token cost on that account). Judge only, never gate; declare a skip in the verdict. If the foreign model cannot judge from the pack alone, the record failed the isolation test — that is a finding.
11. Append numbered `BLOCKER`, `SHOULD`, and `NOTE` findings. Record evidence and resolution without deleting the original concern.
12. Obtain the required human design decision for `HIGH` and `CRITICAL` work.
13. Record the validated design, set `Design outcome: DESIGN-VALIDATED`, and set stage `DESIGN-VALIDATED` only when no blocker remains. Use `Design outcome: BLOCKED` and preserve stage `PLANNED` otherwise. Hand off to `/develop-code` in a fresh session.

Exit condition: the Design Verdict explains why the approach fits, why it is no more complex than necessary, how it will be proven, how it can be reversed, and who owns any consequential decision.
