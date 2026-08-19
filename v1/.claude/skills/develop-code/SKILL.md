---
name: develop-code
description: Develops one DESIGN-VALIDATED change while keeping production code, narrow tests, documentation, decisions, and mirrored contracts aligned. Use only after design validation has cleared the change.
---

# Develop Code

Input: one change record at stage `DESIGN-VALIDATED`.

Output: code, narrow tests, updated truth documents, an Implementation Record, and stage `DEVELOPED`.

Hard rule: do not hide scope or design drift in the diff. A material deviation returns to `/validate-design` before further implementation.

## Procedure

1. Create an isolated branch or use the worktree supplied by the orchestrator.
2. Reload the rules and truth documents named for each task and affected surface.
3. Implement the dependency-ordered tasks in small, buildable increments.
4. Add or update the narrow tests promised by the cleared design.
5. Update product, test, infrastructure, deployment, design-system, and component documentation in the same change as affected behavior.
6. Preserve each single source of truth. Update every consumer and contract test when a durable identifier, schema, mirrored value, or public contract changes.
7. Write an ADR when implementation requires a new durable technical decision. Return to design validation if it conflicts with an accepted decision.
8. Run the narrowest trustworthy checks after each coherent task and the fast gate before completion.
9. Compare actual changed files, dependencies, tools, network use, and permissions with the declared scope. Inspect the complete diff for invented APIs, duplicated owners, secrets, unrelated changes, stale references, control-plane changes, and documentation drift.
10. Append actual scope, changed files, dependency provenance, authority used, decisions, test results, documentation updates, and deviations to the Implementation Record. Set `Development outcome: DEVELOPED` and stage `DEVELOPED`.

Exit condition: planned tasks are complete, narrow checks and the fast gate are green, the repository is buildable, and code, tests, docs, decisions, and contracts tell the same story.
