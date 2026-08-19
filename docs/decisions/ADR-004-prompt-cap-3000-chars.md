# ADR-004 — Story prompts are capped at 3000 chars, mirrored and contract-tested

- **Date:** 2026-05-09
- **Status:** Accepted
- **Surfaces:** iOS / backend

## Context
A prompt-template polish grew the rendered prompt to 3539 chars; the
backend's 413 cap (3000) rejected every story generation — a live outage
found by manual testing, not by any automated check.

## Decision
`LIMITS.perRequest.maxPromptChars = 3000` stays the backend ceiling. The
iOS template must render under it with worst-case inputs (long name +
long custom lesson + 20-min length), proven by
`test_prompt_staysUnderBackendMaxPromptChars` and its section-prompt
sibling. The cap value itself is pinned by a backend contract test whose
failure message names the iOS mirror.

## Consequences
Easy: prompt edits fail in unit tests, not production. Hard: template
growth must be paid for with compression elsewhere. Forbidden: raising
either side alone. Tripwire: drift gate check #3 plus both contract tests.
