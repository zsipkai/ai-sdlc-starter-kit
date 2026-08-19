# Architecture Rules

Replace these examples with constraints and scars from this repository.

## Boundaries

1. Each layer has a named responsibility. Document the allowed dependency direction.
2. Domain decisions do not live in presentation code.
3. Long lived dependencies are created in one composition root and injected.
4. New external dependencies require an ADR.
5. Boundary rules that matter must have an architecture test or static check.
6. A change spanning independently deployed components records compatibility, deployment order, and rollback for partial rollout.

## Boundary matrix

Replace the examples with this repository's real boundaries.

| From | May depend on | Forbidden direction | Mechanical proof |
|---|---|---|---|
| `<presentation>` | `<application contracts>` | `<presentation>` into `<domain>` internals | `<architecture test>` |
| `<application>` | `<domain>` | `<application>` into `<infrastructure implementation>` | `<dependency check>` |
| `<infrastructure>` | `<domain interfaces>` | `<domain>` into `<infrastructure>` | `<architecture test>` |

## Single owners

| Concern | Sole owner | Everyone else |
|---|---|---|
| Authentication decision | `<owner>` | asks, never recreates |
| Pricing or tier limits | `<owner>` | mirrors only with contract tests |
| Navigation | `<owner>` | emits routes, never creates a second router |
| Persistence | `<owner>` | uses the owning interface |

## Change safety

- New public contracts define compatibility with existing consumers.
- Data or schema changes define forward migration, rollback limits, and mixed-version behavior.
- Parallel work is allowed only when file ownership, dependency order, and integration authority are explicit in the plan.
- The integration result is tested after merge or conflict resolution, not inferred from isolated branches.

## Scar format

For every project rule add:

- What failed.
- Where it failed.
- Why the boundary prevents recurrence.
- How review or a command verifies it.
