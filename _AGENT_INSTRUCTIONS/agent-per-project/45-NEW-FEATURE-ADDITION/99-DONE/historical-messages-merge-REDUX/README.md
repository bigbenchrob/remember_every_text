---
tier: feature
scope: historical-archive-merge
owner: agent-per-project
last_reviewed: 2026-06-22
source_of_truth: historical-record
links:
  - ./SPIKE_RETROSPECTIVE.md
  - ./V2_ARCHITECTURE_PLAN.md
  - ../../55-READERS-INTEGRATORS-ORCHESTRATORS/82-SOURCE-SCOPED-ARCHIVE-IMPORT-CUTOVER-PLAN.md
  - ../../55-READERS-INTEGRATORS-ORCHESTRATORS/83-LEGACY-DATABASE-RETIREMENT-ASSESSMENT.md
tests: []
---

# Historical Messages Merge Redux

This folder is preserved as historical architecture research.

The useful surviving principle is:

> Historical archive data is a second source that must join the canonical app
> data path before it becomes ordinary message evidence.

The concrete pipeline language inside these documents is superseded wherever it
refers to retained `db-import`, retained `working.db`, retained migration,
retained projection, or provider-visible `working.db` state.

Current graph-era target:

```text
historical chat.db / backup source
  -> source-scoped import + provenance
  -> conversation graph projection
  -> Message Evidence Spine
  -> overlay intent
```

Do not use this folder to reintroduce retained `macos_import.db` or `working.db`
as active archive-import, projection, search, UI, or readiness infrastructure.
Those files are retired cleanup/diagnostic inventory only.
