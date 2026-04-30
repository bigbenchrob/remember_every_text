---
tier: feature
scope: implementation-plan
owner: agent-per-project
last_reviewed: 2026-04-29
source_of_truth: doc
links:
  - ./V2_ARCHITECTURE_PLAN.md
  - ./CHECKLIST.md
  - ./SPIKE_RETROSPECTIVE.md
tests: []
feature: historical-messages-merge-redux
status: proposed
created: 2026-04-29
---

# Historical Messages Merge Redux - Implementation Plan

## Purpose

This plan translates the locked v2 architecture and checklist into an execution sequence.

It is not a redesign document. It assumes the following decisions are already fixed:

- archive rows are written into the existing canonical `db-import` ledger
- timestamps are normalized to Unix epoch seconds as `INTEGER`
- GUID dedupe happens at ledger insertion
- migration reads only canonical ledger tables and never attached/external databases
- archive import triggers a full canonical migration cycle
- provider-visible `working.db` state is atomic
- the durable Historical Archives workflow surface ships before real archive import wiring

## Architecture Summary

The target runtime path is:

```text
historical chat.db
  -> preflight analysis
  -> canonical ledger ingestion in db-import
  -> full canonical migration
  -> index/search rebuild
  -> app-visible refresh
```

The UI never performs import logic directly. It observes durable workflow state authored by the service layer.

## Assumptions

1. The work will land in multiple small PRs or tightly scoped implementation slices.
2. The durable workflow surface is treated as part of the safety system, not just presentation.
3. Existing import and migration orchestrators remain the canonical owners of ledger and working projection responsibilities.
4. No schema version or persistence contract should change without a separately reviewed schema migration decision.
5. The app must remain testable between phases, even if some phases initially use fake or no-op workflow transitions.

## Hard Invariants

1. No archive-only projector may be introduced.
2. No UI/provider path may read archive staging data directly to make messages visible.
3. Ledger ingestion must be atomic per batch.
4. Every archive import run must have a unique `import_batch_id` applied to all ledger rows from that run.
5. Re-importing the same source must be idempotent.
6. Preflight must not depend on `ATTACH`/`DETACH`.
7. Migration must be restartable from a clean state without manual DB intervention.
8. Long-running phases must remain observable without freezing unrelated UI outside maintenance-lock scope.

## Delivery Order

The implementation sequence is intentionally front-loaded with observability and control-surface work.

### Phase 1 - Durable Workflow Shell

#### Goal

Ship the stable `Settings -> Support -> Historical Archives` entry and the sidebar/center-panel workflow shell before real archive import logic is enabled.

#### Work

- add the durable Settings entry
- add sidebar info cards and known-archives list shell
- add center-panel sections for folder selection, preflight, import, progress, and result summary
- introduce the durable workflow state model used by the surface

#### Exit Gate

- the archive workflow is reachable through stable navigation
- the workflow sections exist without needing real archive ingestion
- the UI remains purely observer/controller logic

### Phase 2 - Folder Selection And Known-Archives Model

#### Goal

Make archive source selection and source persistence visible before any real import is performed.

#### Work

- implement folder picking
- persist selected folder and known-archive metadata
- surface `chat.db` and `Attachments/` presence plus proposed source label
- make known archives render durably in the sidebar and workflow surface

#### Exit Gate

- users can add/select archive folders and see them later without running import
- archive-source state is durable and inspectable

### Phase 3 - Preflight Analysis

#### Goal

Provide trustworthy read-only evidence about an archive source before any ledger writes happen.

#### Work

- implement preflight analysis through direct source reads or isolated connections
- avoid `ATTACH`/`DETACH`
- compute message/chat/handle counts, earliest/latest dates, missing GUID counts, likely duplicates, and likely new rows
- enforce `Begin Import` enablement rules from workflow state

#### Exit Gate

- preflight produces stable, inspectable results
- preflight remains read-only
- no ledger or working writes occur during this phase

### Phase 4 - Progress Model And No-Op Validation

#### Goal

Validate the workflow state machine before real ingestion and migration are connected.

#### Work

- implement canonical progress phases and statuses
- add fake/no-op transitions for workflow validation
- verify long-running phase reporting does not freeze unrelated UI outside maintenance-lock scope

#### Optional Extension

If it proves useful, add a dry-run mode that simulates ledger insertion, dedupe, and projected counts without committing canonical rows.

Dry run must remain evidence-only. It must not substitute for real result accounting.

#### Exit Gate

- workflow progress is visible and testable end to end without real ingestion
- progress state differentiates ledger, migration, rebuild, and visibility refresh boundaries

### Phase 5 - Canonical Ledger Ingestion

#### Goal

Ingest archive source rows into the existing canonical ledger safely and repeatably.

#### Work

- normalize source rows into canonical ledger shape
- allocate a unique `import_batch_id` per run
- write ledger rows atomically per batch
- apply GUID dedupe at insertion time
- record provenance and accounting data for accepted/skipped/deduplicated/failed rows
- enforce idempotent re-import behavior for the same source

#### Exit Gate

- ledger ingestion is atomic per batch
- rerunning the same import does not duplicate or mutate existing canonical rows
- all rows from a run are traceable by `import_batch_id`

### Phase 6 - Full Canonical Migration

#### Goal

Project archive-backed ledger rows through the normal migration orchestrator with no archive-specific projection shortcut.

#### Work

- trigger full migration after successful ledger ingestion
- ensure migrators read only canonical `db-import` tables
- keep provider-visible `working.db` state atomic
- make failure recovery restartable from a clean state without manual repair

#### Exit Gate

- archive import triggers full canonical migration every time
- migration can be rerun cleanly after failure
- no partial `working.db` state leaks into provider reads

### Phase 7 - Index Rebuild And App Visibility Refresh

#### Goal

Complete the post-migration work required for trustworthy app visibility.

#### Work

- rebuild indexes/search/heatmap support tables
- refresh app-visible data and result state only after canonical post-migration work completes
- surface whether historical messages are visible in normal app surfaces

#### Exit Gate

- success can only occur after rebuild and refresh complete
- workflow state clearly distinguishes migration success from app-visible completion

### Phase 8 - Result Accounting And Durable History

#### Goal

Make every archive run explainable after the fact.

#### Work

- show source label, folder path, earliest/latest dates, staged/imported/projected/skipped/deduplicated/failed counts
- preserve durable result history for archive sources where appropriate
- keep ledger success separate from app-visible success in user-facing copy

#### Exit Gate

- results remain auditable without SQLite inspection
- failure location is visible at the workflow level

### Phase 9 - Concurrency, Locking, And Failure Recovery

#### Goal

Integrate archive import safely with the rest of the app’s import/migration lifecycle.

#### Work

- apply single-flight rules
- share the canonical execution gate with import/migration/reset work
- limit maintenance-lock scope to the true critical section
- keep long-running progress visible without freezing unrelated UI outside lock scope
- ensure all failure/cancellation paths release gates and locks deterministically

#### Exit Gate

- no frozen or ambiguous workflow states remain
- blocked/gated states are reported truthfully
- restart after failure requires no manual DB intervention

## Verification Strategy

Implementation should be validated in the same order as delivery.

1. Workflow-shell tests before real archive ingestion.
2. Preflight tests before ledger writes.
3. Ledger atomicity, `import_batch_id`, dedupe, timestamp, provenance, and idempotency tests before migration wiring.
4. Full-migration and restartability tests before index/rebuild refresh wiring.
5. Result-accounting and UI-success tests after the full path is connected.

## Candidate Work Slicing

The safest slicing is:

1. workflow shell and durable navigation
2. selected-folder and known-archives state
3. preflight-only analysis
4. progress-state model and fake/no-op phase execution
5. ledger ingestion
6. full migration trigger and restartability
7. index rebuild and app-visible refresh
8. result accounting and audit polish

## Bottom Line

The implementation plan starts with observability on purpose.

The previous spike failed partly because import state was too opaque. V2 should therefore become visible and testable before it becomes powerful.
