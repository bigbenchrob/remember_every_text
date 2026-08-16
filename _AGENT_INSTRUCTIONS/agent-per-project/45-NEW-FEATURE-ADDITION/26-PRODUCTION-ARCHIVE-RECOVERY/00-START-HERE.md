---
tier: project
scope: production-archive-recovery
owner: agent-per-project
last_reviewed: 2026-08-16
source_of_truth: doc
links:
  - ../../25-ONBOARDING-AND-ARCHIVE/ATTACHMENT-PRESERVATION-INVARIANT.md
  - ../../50-ENVIRONMENT-SAFETY/00-overview.md
tests: []
---

# Production Archive Recovery

> **The March 2026 MessageLens archive is a read-only donor. The current
> MessageLens archive is production. The initial investigation is read-only and
> authorizes mutation of neither.**

> **Archived attachment payloads are preservation data and must be treated like
> gold.**

## Emergency Objective

Safely make the current production MessageLens archive contain everything
valuable preserved in the March 2026 MessageLens Application Support archive,
especially historical Messages records and preserved archived image attachment
payloads.

The March 2026 saved folder contains both:

- historical Messages data reaching farther back than the current production
  archive, including records ultimately dating to approximately 2011; and
- archived image attachment payloads preserved before Apple later evicted some
  local originals to iCloud.

Recovering this known donor archive into this known current production archive
is the immediate priority. This is not yet a generalized product feature.

## Safety Boundary

The first phase is forensic inventory only. It authorizes no write, copy,
rename, normalization, repair, migration, database opening in writable mode,
or other mutation of either archive.

No recovery operation may casually overwrite, delete, normalize, regenerate,
relocate, or otherwise mutate archived payloads. If two files eventually claim
the same logical destination but differ in bytes, that collision must be
surfaced explicitly. Silent overwrite is prohibited.

## First Investigative Question

The next task must answer, read-only:

> What exactly exists in the March 2026 donor archive, what exists in the
> current production archive, how do they overlap, and what is the safest
> one-way union seam?

That investigation will need to identify:

- database files present in each archive;
- which stores contain the historical message facts needed for recovery;
- date ranges and approximate record counts;
- attachment archive structure, identity, and linkage;
- overlap between donor and production;
- authoritative and preservation stores;
- safely rebuildable derived stores; and
- existing ingestion code that may support a later bounded recovery.

This scaffold does not perform that inventory.

## Sequence

```text
FIRST
    recover the known March 2026 archive safely into the current production
    archive

LATER
    use that experience as evidence for a generalized archive-ingestion
    feature
```

## Explicit Non-Goals

Do not yet design or implement:

- public archive-import UI;
- generalized archive discovery;
- arbitrary historical-folder ingestion;
- multi-user workflows;
- migration wizards;
- recovery scripts;
- database merging; or
- attachment copying.

The next operative task is strictly the read-only donor/current archive
inventory.
