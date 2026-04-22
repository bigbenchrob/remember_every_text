---
tier: project
scope: data-import-migration
owner: agent-per-project
last_reviewed: 2026-04-21
source_of_truth: code
links:
  - ./01-overview.md
  - ./10-import-orchestrator.md
  - ./20-migration-orchestrator.md
  - ../10-DATABASES/10-group-import-working.md
tests: []
---

# Incremental Mode Flag

This document explains the current `incrementalMode` contract in the migration system.

## TL;DR

- `incrementalMode: true` means migration preserves existing `working.db` rows and skips the orchestrator table-truncation step.
- `incrementalMode: false` means full projection rebuild: migrator target tables are cleared, then rebuilt from `macos_import.db`.
- `ChatDbChangeMonitor` always runs migration with `incrementalMode: true` after a successful automatic import.
- Incremental migration must not invalidate `driftWorkingDatabaseProvider`; it bumps `messageDataVersionProvider` after success.
- Full onboarding/manual rebuild behavior is owned by `DbImportControlViewModel.startMigration()` and related onboarding flows.

## Why The Flag Exists

Full migration clears target working tables before rebuilding the projection. That is correct for initial import, full reset, and deliberate recovery, but it is too expensive and disruptive for background sync when the app is already displaying a populated message store.

Incremental mode was introduced to avoid:

- slow full-table deletes with foreign-key cascades on large message tables
- unnecessary replacement of stable projection rows
- Drift connection invalidation while UI queries are in flight

## Current Propagation

### Automatic Background Sync

```
ChatDbChangeMonitor
  -> orchestratedLedgerImportServiceProvider.runImport()
  -> attachmentArchiveServiceProvider.archiveImportedBatch(batchId)
  -> handlesMigrationServiceProvider.run(incrementalMode: true)
  -> messageDataVersionProvider.bump()
```

The monitor does not query the working message count to decide the mode. The automatic path is explicitly incremental.

### Full / Manual Paths

Manual onboarding and import-control flows call into `DbImportControlViewModel.startImport()` and `startMigration(...)`. Those flows are responsible for choosing full rebuild behavior when the user is doing initial setup, reset, or recovery.

Do not infer manual/full behavior from the monitor path. They are separate entry points with different operational requirements.

## Orchestrator Contract

`MigrationContextSqlite` carries the `incrementalMode` flag. `MigrationOrchestrator._prepareWorking()` enforces the shared behavior:

- `dryRun: true` skips table truncation and copy writes.
- `incrementalMode: true` skips table truncation.
- `incrementalMode: false` clears each migrator's `targetTables` before phases run.

Migrators must then apply table-appropriate copy and validation behavior. Do not assume every migrator uses the same `INSERT OR IGNORE` pattern; inspect the relevant migrator before changing semantics.

## Refresh Contract

Incremental sync must keep the existing Drift working database connection open.

Prohibited in the incremental path:

```dart
ref.invalidate(driftWorkingDatabaseProvider);
```

Required pattern:

```dart
ref.read(messageDataVersionProvider.notifier).bump();
```

Why: invalidating `driftWorkingDatabaseProvider` closes the Drift isolate connection and can break active UI queries with "connection was closed" errors. Drift streams and explicit data-version signals should carry the refresh instead.

## Search And Index Rebuilds

`HandlesMigrationService` runs synthetic post-orchestrator steps after the table migrators:

1. rebuild global/per-chat/per-contact message indexes
2. recreate message-index triggers
3. call `searchIndexOrchestrator.rebuildAll()`

This happens for the service run regardless of whether the caller selected full or incremental migration. If a future optimization narrows rebuild scope, update this document and `20-migration-orchestrator.md`.

## Historical Context

Older notes described automatic mode selection by querying `working.db` message counts before migration and invalidating the Drift provider only for full mode. The current monitor path no longer follows that shape:

- it primes and polls from `MAX(ROWID)` against `chat.db`
- it imports by high-water marks
- it archives the imported batch before migration
- it passes `incrementalMode: true` directly
- it bumps `messageDataVersionProvider` after success

Treat older count-based or provider-invalidation examples as historical implementation notes, not current guidance.

## Troubleshooting

If new messages are not appearing:

1. Check `ChatDbMonitor` logs for MAX(ROWID) detection and import/migration errors.
2. Check `import_log` for imported message counts, extractor health, and source-vs-ledger deltas.
3. Check `migrate_log` for projection counts, index rebuilds, and search rebuild failures.
4. Confirm the relevant UI provider observes `messageDataVersionProvider` or a Drift stream that reacts to the changed data.

If incremental migration is slow:

1. Confirm the log contains `Incremental mode: skipping table truncation.`
2. Inspect the specific migrator that is slow; do not assume all migrators use the same SQL strategy.
3. Check for lingering import database attachments or SQLite locks reported by `ensureImportReady` / `ensureImportClean`.

If a "connection was closed" loop appears:

1. Search for `ref.invalidate(driftWorkingDatabaseProvider)` in the completion path.
2. Remove it from incremental flows.
3. Use provider-specific invalidation or `messageDataVersionProvider.bump()` instead.

## Related Reading

- `./01-overview.md` - High-level import/migration pipeline.
- `./10-import-orchestrator.md` - Automatic monitor and import service behavior.
- `./20-migration-orchestrator.md` - Migrator dependency ordering and post-migration synthetic steps.
- `../10-DATABASES/10-group-import-working.md` - Schema contracts between import and working DBs.
