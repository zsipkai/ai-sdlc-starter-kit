# AI SDLC Starter Kit

The complete, real file set behind a gated, agent-driven development
pipeline — extracted from **Kid Storytime**, a shipped iOS app whose code
is written almost entirely by AI coding agents. Nothing here is a mockup:
every file below ran (and runs) in production, catching real bugs on the
way to the App Store.

**The idea in one paragraph:** agents write the code, so the failure mode
isn't typos — it's *confident drift*. The cure is two kinds of files and
one script. Markdown the agent **reads** (a constitution, rules that cite
their scars, decision records, story cards). Markdown the agent
**executes** (six slash-command skills, one per pipeline stage). And one
shell gate wired into a git pre-commit hook — the only part the agent
can't talk its way past.

## The pipeline

```
/1-plan-story → /2-validate-plan → /3-implement → /4-test → /5-code-review → /6-ship
```

Each stage is a skill file that ends in an artifact the next stage
requires. One plan file per story travels the whole pipe and accretes its
validation findings, test evidence, review report, and ship proof — when
the story ships, the plan is its audit log.

## What's in the box

| Path | What it is |
|---|---|
| `CLAUDE.md` | The constitution: ten never-negotiable rules, auto-loaded every session |
| `.claude/skills/1…6/SKILL.md` | The six pipeline stages as executable skills |
| `.claude/agents/*.md` | Four specialist reviewers — security, App Store, SwiftUI, doc-drift — each one obsession + a checklist distilled from a real audit |
| `docs/rules/*.md` | Coding law per surface; every rule cites the shipped bug that created it |
| `docs/decisions/` | ADR template + two real decision records |
| `docs/backlog/` | Story template + a real story card |
| `docs/storyPlans/` | Two real plan files — including a test-forensics investigation, findings and all |
| `scripts/` | The mechanical gate: `sdlc-gate.sh`, the doc-drift checker, link checker, hook installer |
| `docs/sample-gate-output.txt` | What a passing gate run actually prints |

## Build yours in a weekend

Order matters — **enforcement before ceremony**:

1. Write your constitution (`CLAUDE.md`): ten rules you'd never waive.
2. Wire the gate: one script running your tests + consistency checks,
   installed as a pre-commit hook. This is the step that makes the rest real.
3. One rule file per surface you fear — seed each from a real bug you shipped.
4. Record standing decisions as ADRs so no future session re-argues them.
5. Adapt the six skills — keep the entry artifact / exit artifact / gate
   of each stage, swap the commands for your stack.
6. One reviewer agent per risk surface — run a deep audit first;
   its findings are the checklist.
7. Write your first story card.
8. Run it through `/1` → `/6`.

## Adapting it

The mechanisms are stack-agnostic; the *examples* are not. Swift rules,
`xcodebuild` commands, App Store checklists, and AWS deploy steps are
this app's — swap them for yours. What transfers unchanged: the plan as
contract, adversarial validation before code, specialists over
generalists, docs moving in the same commit as behavior, and a hook that
doesn't care how confident the agent sounds.

## License

MIT — see [LICENSE](LICENSE). Use it, fork it, ship with it.
