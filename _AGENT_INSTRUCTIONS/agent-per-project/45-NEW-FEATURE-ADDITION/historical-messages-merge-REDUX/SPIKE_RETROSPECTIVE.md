---
tier: feature
scope: retrospective
owner: agent-per-project
last_reviewed: 2026-04-29
source_of_truth: synthesis
links:
  - ./spike-retrospective-seed.txt
tests: []
---

# Spike Retrospective — Historical Archive Merge

This note documents what the `historical archive merge` branch proved, what became brittle, and what must be carried forward into a future v2 plan.

This is intentionally a spike retrospective, not a new proposal.

## What Worked

The spike established several facts that matter.

- The historical archive `chat.db` can be opened and read.
- Archive rows can be staged durably into a dedicated ledger database.
- Archive and live messages can appear together in the existing heatmap and timeline surfaces.
- GUID-based deduplication is viable and necessary.
- Participant and handle reconstruction is required for archive rows to behave like real conversation data.
- Projection into `working.db` is required for normal visibility across the existing app surfaces.

The most important successful proof point was not merely that archive rows could be parsed. It was that archive content and live content could coexist inside the normal timeline/heatmap experience once archive rows were projected into the app's canonical working data path.

## What Failed Or Became Brittle

The spike also showed that the current branch became too fragile to keep iterating on safely.

- The archive import schema drifted too far from the established import and working schemas.
- Date values were converted too early into ISO strings instead of staying numeric until the canonical conversion layer.
- Attach and detach lifecycle handling became a recurring SQLite locking hazard.
- Staging and projection accounting were conflated, which made success and failure states misleading.
- The UI could report success or progress before projection into `working.db` was actually proven.
- The contact picker and heatmap could become unresponsive during partial merge states, especially while the maintenance lock was held.
- Too many narrow fixes accumulated inside the archive merge service and surrounding orchestration, which made the flow harder to reason about after each patch.

The branch did not fail because the archive idea was invalid. It failed because the prototype increasingly depended on exceptions, special-case bookkeeping, and service-level patching to bridge a structural mismatch between archive staging and the canonical import-to-working pipeline.

## Non-Negotiable Lessons

These are the lessons the spike made non-optional.

- Historical archive data is a second import source, not a recovery table.
- The durable archive schema should mirror the canonical import ledger wherever practical instead of inventing a materially different intermediate shape.
- Date conversion must stay centralized and numeric until presentation or the canonical conversion boundary.
- Archive rows must remain replayable into `working.db` after reset and rebuild cycles.
- Staging success is not the same thing as timeline success.
- Result accounting must track staged, projected, skipped, and failed separately.
- No UI or provider workaround should read directly from the archive database just to make archive content visible.

The key architectural lesson is that the app only became trustworthy when archive data entered the same canonical path that normal message visibility already depends on. Every attempt to soften that rule increased brittleness.

## Unknowns To Resolve In V2 Planning

The spike narrowed the real planning questions without resolving them.

- The exact durable archive import schema is still undecided.
- It remains unresolved whether archive import should reuse the existing import-ledger schema directly or live in a parallel `db-archive-import` that mirrors it closely.
- The migration or projector boundary still needs a precise definition.
- Reset and rebuild behavior remains unresolved.
- Index rebuild strategy remains unresolved.
- Attach and detach lifecycle management likely needs a reusable utility or a different operational model.
- The provenance model still needs a durable, canonical shape.

These are not implementation details. They are the design decisions that determine whether archive import can become a durable part of the system instead of a permanent special case.

## Evidence From The Spike

### Final Observed Successful Case

The spike reached a meaningful proof-of-value state:

- archive rows were read from the historical `chat.db`
- staged durably into `historical_archive_import.db`
- deduplicated against live GUIDs
- projected into `working.db`
- and then rendered together with live data in the app's normal timeline and heatmap surfaces

That successful case proved the feature is product-relevant. Historical messages do not need a separate viewer to be useful. They become useful when they join the normal app surfaces through the canonical working-data path.

### Gap Analysis Result

The gap between `proof of concept` and `production-safe feature` became clear by the end of the branch.

- Reading archive data was not the hard part.
- Durable staging was not the hard part.
- The hard part was keeping archive data aligned with the existing import and working schemas closely enough that projection, reset, rebuild, indexing, and UI refresh semantics all remained deterministic.

In other words, the spike proved the value proposition and disproved the current branch structure.

### Known Instability Symptoms

Several instability symptoms were repeatedly observed during the spike.

- Manual merge could appear to do nothing even while archive rows were being added to `historical_archive_import.db.messages`.
- Repeated clicks could create overlapping imports before single-flight protection was added.
- Projection could fail with SQLite locking symptoms, including `database is locked`.
- Import preflight could fail with `IMPORT_DB_LOCKED` while detaching `import_preflight`.
- The sidebar could remain stuck on `Merging Into Timeline` or similar working-state text.
- The contact picker could become empty while the maintenance lock remained held.
- The heatmap and timeline could become effectively unavailable during partial merge states.
- Batch checkpoints showed runs stalling at `phase=projection-transaction-starting`.
- The final observed latest batch ended with a projection failure note containing `CouldNotRollBackException` after the connection had already closed.
- A separate startup race also surfaced `DatabaseException(error database_closed)` under execution owner `chat-db-monitor`.

These symptoms matter because they show the system was not merely incomplete. It was entering states where success reporting, projection state, database lifecycle, and UI availability could drift out of sync.

### Specific Files And Functions Touched

The spike concentrated most of its complexity in a few files.

- `lib/features/settings/application/historical_archive_merge/historical_archive_merge_service_provider.dart`
- `lib/essentials/sidebar/application/sidebar_action_dispatcher.dart`
- `lib/essentials/db_migrate/infrastructure/sqlite/migration_context_sqlite.dart`
- `lib/essentials/db_importers/application/monitor/chat_db_change_monitor_provider.dart`
- `test/features/settings/application/historical_archive_merge/historical_archive_merge_service_provider_test.dart`
- `test/essentials/db_migrate/infrastructure/sqlite/migration_context_sqlite_test.dart`

Within the archive merge service, the spike especially revolved around these functions:

- `_runArchiveImport`
- `_projectArchiveBatchIntoWorking`
- `_recordProjectionCheckpoint`
- `_loadExistingWorkingGuids`
- `_loadExistingWorkingChatIdsByGuid`
- `_resolveWorkingArchiveHandleId`
- `_ensureWorkingArchiveHandle`
- `_projectArchiveChatParticipants`

In the surrounding orchestration, the branch also relied on:

- `_runHistoricalArchiveImport` in the sidebar action dispatcher
- `_verifyImportAttachable` and `_clearLingeringImportAttachments` in the SQLite migration context

This file list is useful because it shows where the spike's complexity actually accumulated: not in a small importer, but across service logic, projection orchestration, attach or detach handling, and UI state management.

## Bottom Line

This branch proved that historical archive merge is worth building and that projection into `working.db` can make archive history visible in the normal MessageLens experience.

It also proved that the current spike architecture is untenable.

The durable lesson is not `archive merge failed`. The durable lesson is that archive merge only becomes stable if it is treated as a first-class import source aligned with the canonical import and working pipeline, with projection success measured separately from staging success and without UI shortcuts around the working database.
