# AI Generation Governance — Kid Storytime

> Most code in this repo is written by agents. These rules keep that code
> indistinguishable from a careful human's work, and keep agents from
> quietly breaking contracts that humans set.

## The prime directive

**An agent may not weaken a gate to pass it.** Tests, drift checks, caps,
and lint rules are changed only when the story plan explicitly says so,
with the reasoning recorded. Editing a threshold to make red turn green is
the one unforgivable move.

## Code must read human-written

The tells that fail review (each observed in this repo and since purged):

1. **Emoji-narration logging** — `print("✅ Story saved!")`. Use `Logger`,
   write log lines for the on-call reader, not the demo.
2. **Tutorial comments** — restating the next line in English. Comments
   carry *why*: the bug that motivated the code, the constraint that isn't
   visible in types. Model to copy: `BackendClient.swift`.
3. **MARK inflation** — a MARK per property cluster. Max 3 per file.
4. **Doc-comment ceremony on private helpers** — `/// - Parameter foo: the foo`.
5. **Self-congratulation** — "bulletproof", "crash-safe", "SINGLE SOURCE OF
   TRUTH" in headers. State facts; let the code earn adjectives.
6. **Defensive theater** — bounds-clamping values that are impossible by
   construction, `guard` on non-optionals, `count > 0` for `!isEmpty`.
7. **Mechanical parallel blocks** — ten near-identical accessors or eleven
   identical Combine sinks. Three repetitions demand an abstraction or a
   deliberate note explaining why not.

## Hallucination defenses

8. **No invented API.** Any SDK symbol the agent isn't certain exists gets
   verified against the real toolchain (build it) before the diff is
   presented. A compile error caught locally is fine; an invented AWS CLI
   flag in a deploy script is not.
9. **No invented facts in docs.** Numbers in documentation (counts, prices,
   limits, resource IDs) come from running the command, not from memory.
   The drift gate enforces the known set; new claims add new checks.
10. **Cite the source when porting.** Code adapted from a reference
    (Apple sample, AWS doc) notes the origin in the story plan, not inline.

## Contract discipline

11. **Cross-codebase constants ship with contract tests on both sides** in
    the same commit (prompt cap ↔ `quota.js`, tier numbers ↔ docs).
12. **Docs change with code, same commit.** A diff that changes behavior
    documented in docs/PRODUCT.md / docs/TESTS.md / docs/INFRASTRUCTURE.md / web/README.md
    without touching the doc fails review — and usually the drift gate.
13. **Xcode project integrity:** any added/moved/deleted iOS file updates
    `project.pbxproj` in the same change, and the gate's build step proves
    it. Never leave the project unbuildable in Xcode.

## Boundaries of autonomy

14. Agents act freely inside a story's approved plan. Outside it, these
    require an explicit human decision first:
    - spending money (domains, paid tiers, ad spend)
    - deleting AWS resources or data
    - changing prices, tier limits, or legal pages
    - force-pushing, history rewrites, `--no-verify` commits
15. **Escalate with a question, not a guess**, when the plan is ambiguous —
    and record the answer in `docs/decisions/` if it settles a rule.

## Review of AI output

16. AI-written diffs get the same /5 review as human diffs — plus the
    reviewer explicitly checks rules 1–7 above (the "does it read human"
    pass) and rule 8 (no invented API).
17. **Multi-agent review is the default for risk surfaces**: security,
    payments, App Store metadata. One model reviewing its own output is
    not review.
