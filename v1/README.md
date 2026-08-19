# Agentic SDLC Starter Kit

This is a copyable repository skeleton, not a framework. Replace every `<placeholder>` and `TODO` with facts and commands from your project before invoking the skills.

## Choose the instruction entry point

- Claude Code: keep `CLAUDE.md`. Its `@AGENTS.md` import loads the canonical constitution and it may add only Claude-specific loading notes.
- Multiple coding agents: keep `AGENTS.md` as the canonical shared instructions and retain the small `CLAUDE.md` adapter.
- Another single harness: use its recognized project instruction filename and port the contents of `AGENTS.md`.

Do not retain two independent constitutions. They will drift.

## Install

1. Copy this folder's contents into a repository that already has a real test suite.
2. Fill in `AGENTS.md`, rule files, `docs/SDLC.md`, and the scripts. Keep `CLAUDE.md` as a thin adapter if you use Claude Code.
3. Add real product, test, infrastructure, deployment, and component documentation.
4. Configure the repository toolchain step in `.github/workflows/sdlc-gate.yml` or port it to your CI system.
5. Run `bash scripts/sdlc-gate.sh --fast` until it is green.
6. Run `bash scripts/install-hooks.sh` once per clone.
7. Protect the default branch or ruleset, require the CI gate, and configure code-owner review for instruction, gate, workflow, dependency, test-policy, and deploy-control files.
8. Configure the coding-agent sandbox, allowed tools, filesystem scope, network egress, and task-scoped credentials for your threat model.
9. Write `docs/backlog/STORY-001-<slug>.md` from the template and complete its ready checklist.
10. Invoke `/plan-task` and run one real story through all seven stages.
11. Confirm the required CI check blocks a deliberately broken change and that the agent cannot silently change the check that defines success.

## Safety

- The template gate fails until its TODO test commands are replaced.
- Local Git hooks are bypassable and not copied by clone. Mirror the gate in CI for team use.
- Markdown instructions, skills, reviewers, hooks, tests, and CI are control-plane code, not a security boundary by themselves. Protect their definitions from unilateral agent changes.
- Treat issue text, pull requests, logs, web content, documents, tool output, and cross-agent handoffs as untrusted until verified.
- Do not put secrets, production credentials, or live infrastructure IDs in agent files.
- Keep deployment and destructive permissions away from development stages. Prefer sandboxed execution, controlled egress, and short-lived task-scoped credentials.
- A passing agent-written test is necessary evidence, not independent proof. Review test diffs and require counterexamples for changed critical tests.
- Do not copy another organization's rules. Derive rules, risk tiers, and reviewers from your product's failures and obligations.

## What the public kit includes

- a short portable constitution plus a Claude adapter;
- story readiness, risk tier, human checkpoint, change-record, and Definition of Done templates;
- seven unnumbered, verb-led skills with explicit inputs, artifacts, stop conditions, and evidence-named states;
- architecture, security, design, naming, and testing rules;
- read-only architecture, security, documentation, and test-quality reviewers;
- local and CI gate examples, including change-record and Markdown-link checks, that fail closed until configured.
- control-plane, untrusted-input, scoped-authority, test-integrity, process-evaluation, and measurement guidance for hardening beyond a solo version one.

## Before team use

The starter kit establishes Level 2 of the maturity model in `docs/SDLC.md`: a working repository-native evidence lifecycle. Team use requires Level 3 controls appropriate to the product's threat model: required remote CI, protected process files, sandboxing, scoped credentials and egress, process evaluations, telemetry, and protected deployment authority.

Create `.github/CODEOWNERS` with your real accountable team or user, then protect the file itself and require code-owner review. A starting pattern is:

```text
/AGENTS.md                         @your-control-owner
/CLAUDE.md                         @your-control-owner
/.claude/                          @your-control-owner
/scripts/                          @your-control-owner
/.github/workflows/                @your-control-owner
/docs/rules/                       @your-control-owner
/docs/TESTS.md                     @your-test-owner
/<dependency-manifest>             @your-dependency-owner
/<dependency-lockfile>             @your-dependency-owner
/<deployment-config-path>          @your-deployment-owner
/.github/CODEOWNERS                @your-control-owner
```

CODEOWNERS requests review; repository rules must make that review and the `sdlc-gate` status check mandatory. Replace every placeholder before relying on this control.
