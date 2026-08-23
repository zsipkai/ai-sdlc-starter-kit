# Change Records

Create one `STORY-NNN.md` file from `CHANGE-RECORD-TEMPLATE.md` for every meaningful change.

The record progresses through:

`PLANNED -> DESIGN-VALIDATED -> DEVELOPED -> ACCEPTANCE-TEST-PROVEN -> REVIEW-CLEARED -> REGRESSION-TEST-PROVEN -> DEPLOYED`

Each command appends its required evidence. Keep superseded assumptions, failed approaches, blocker resolutions, exceptions, and deployment receipts. A `DEPLOYED` record is a permanent audit artifact and is never deleted merely because the story closed.

The record also captures the conditions under which evidence was produced: harness and model metadata when available, external context and trust class, declared and actual file scope, dependency changes, tools, filesystem, network and credential authority, budget, and the exact deployment candidate or artifact.
