# Naming Conventions and Best Practices

Names are contracts when tests, storage, APIs, telemetry, or other systems depend on them.

## Code

1. Types use domain nouns. Avoid generic names such as `Manager2`, `Helper`, or `Processor` without a specific capability.
2. Boolean names read as assertions.
3. Functions use an action and domain object.
4. One naming scheme exists per concept. Do not introduce synonyms for established terms.

## Durable identifiers

Document exact patterns for:

- API routes and versions;
- database tables and fields;
- storage keys;
- accessibility identifiers;
- events and metrics;
- environment variables;
- cloud resources;
- test names;
- ADR, story, branch, and change-record filenames.

Any rename updates every consumer and its tests in the same change.

## Stories

- ADR: `ADR-NNN-kebab-slug.md`
- Story: `STORY-NNN-kebab-slug.md`
- Change record: `STORY-NNN.md`
- Branch: `story/STORY-NNN-kebab-slug`

Numbers are never reused or renumbered after publication.
