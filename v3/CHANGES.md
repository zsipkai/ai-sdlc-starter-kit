# v3 — Changes from v2

v2 gave you cost control. v3 adds **the cross-family second opinion**:
one reviewer from a different model family at each verification gate,
on every story of STANDARD risk or higher — because reviewers from one
family share that family's blind spots, and a flat-fee chat
subscription makes the extra top-tier judge free.

## New

- **Rule 16** in `docs/rules/model-routing-rules.md` — the whole policy:
  - applies at /validate-design and /clear-review, `Risk: STANDARD`+
  - the second family's **top** model only (rule 4 — verification never
    downsizes — crosses families)
  - findings enter the normal severity-ranked consolidation as `X-n`
    rows; **judge, never gate** — the deciding gates stay mechanical
  - zero marginal cost on a flat-fee subscription; the same pack goes
    to the other family's API when copy-paste stops scaling
  - the pack doubles as an isolation test of the change record
  - skips on eligible records are declared in the verdict, never silent
  - (the Batch API note moves to "add as rule 17 when a non-interactive
    workload exists")
- **`scripts/second-opinion.sh`** — builds one self-contained prompt
  pack per stage: reviewer charter + change record (+ diff for review),
  written to `build/`. Human pastes it out, pastes findings back — or
  `--auto` sends the pack to the second family's API and captures the
  findings unattended (`OPENAI_API_KEY` from the environment;
  `SECOND_OPINION_MODEL` pins the model, default a top GPT-class
  snapshot; cents per review vs the free paste).

## Changed

- `validate-design/SKILL.md` — new procedure step 10: the design-stage
  second opinion (pack → foreign top model → `X-n` findings).
- `clear-review/SKILL.md` — new procedure step 3: the review-stage
  second opinion, before consolidation.
- `docs/SDLC.md` — the routing section explains the judge fan-out
  across vendors in three sentences.
- `docs/changeRecords/CHANGE-RECORD-TEMPLATE.md` — both verdicts gain a
  "Second opinion (rule 16 — Risk ≠ LOW)" evidence slot: family and
  model used, findings — or the skip, declared.
- `README.md` — "How the second opinion works" section.

## Fixed (rider)

- `validate-design/SKILL.md` had two steps numbered 11; renumbered, and
  the fresh-session handoff moved to the final step where it belongs.
