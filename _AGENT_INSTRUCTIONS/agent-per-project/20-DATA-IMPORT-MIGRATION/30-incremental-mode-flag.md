---
tier: project
scope: data-import-migration
owner: agent-per-project
last_reviewed: 2026-06-08
source_of_truth: code
links:
  - ./01-overview.md
  - ./10-import-orchestrator.md
  - ./20-migration-orchestrator.md
  - ../10-DATABASES/10-group-import-working.md
tests: []
---

# Retained Legacy Incremental Mode Flag

This document explains the retained legacy `incrementalMode` contract in the `db_migrate` projection system. It is not the production live-sync mechanism for ordinary app data.

## TL;DR

- `incrementalMode: true` means retained legacy projection preserves existing `working.db` rows and skips the orchestrator table-truncation step.
- `incrementalMode: false` means full retained projection rebuild: migrator target tables are cleared, then rebuilt from `macos_import.db`.
- `ChatDbChangeMonitor` no longer runs retained legacy migration for live sync. It runs the source-scoped graph build lifecycle.
- Retained incremental projection must not invalidate active Drift working database connections.
- First-run/reimport app setup is graph-owned through the conversation graph build controller; retained legacy projection is archive/recovery compatibility.

## Why The Flag Exists

Full retained legacy migration clears target working tables before rebuilding the projection. That remains useful for explicit archive/recovery compatibility, but it is too expensive and conceptually wrong for graph-era background sync when the app is already displaying a populated graph message store.

Incremental mode was introduced to avoid:

- slow full-table deletes with foreign-key cascades on large message tables
- unnecessary replacement of stable projection rows
- Drift connection invalidation while UI queries are in flight

## Current Propagation

### Automatic Background Sync

```
ChatDbChangeMonitor
  -> source-scoped graph build lifecycle
  -> attachmentArchiveServiceProvider.archiveGraphMessageSourceRange(...)
  -> graph/message data version bump
```

The monitor does not query the legacy working message count and does not choose a retained migration mode. The automatic path is graph-incremental by source row cursor.

### Full / Manual Paths

Graph onboarding and reimport call the conversation graph build controller. Historical archive/recovery workflows may still invoke retained archive-compatible projection rebuilds through their named compatibility service.

Do not infer manual/full behavior from the monitor path. They are separate entry points with different operational requirements.

## Historical Orchestrator Contract

The retired `MigrationContextSqlite` carried the `incrementalMode` flag.
`MigrationOrchestrator._prepareWorking()` enforced the shared behavior:

- `dryRun: true` skips table truncation and copy writes.
- `incrementalMode: true` skips table truncation.
- `incrementalMode: false` clears each migrator's `targetTables` before phases run.

Migrators then applied table-appropriate copy and validation behavior. Treat
this as historical retained projection behavior, not current graph guidance.

## Refresh Contract

Retained incremental projection must keep the existing Drift working database connection open.

Prohibited in the incremental path:

```dart
ref.invalidate(driftWorkingDatabaseProvider);
```

Required pattern:

```dart
ref.read(messageDataVersionProvider.notifier).bump();
```

Why: invalidating `driftWorkingDatabaseProvider` closes the Drift isolate connection and can break active compatibility readers with "connection was closed" errors. Drift streams and explicit data-version signals should carry the refresh instead.

## Search And Index Rebuilds

`HandlesMigrationService` runs synthetic post-orchestrator steps after the table migrators:

1. rebuild global/per-chat/per-contact message indexes
2. recreate message-index triggers
3. call `searchIndexOrchestrator.rebuildAll()`

This describes retained legacy service behavior. Ordinary graph search now selects graph `message_ss_id` evidence through the graph search/evidence spine, not legacy working indexes. If retained projection behavior changes, update this document and `20-migration-orchestrator.md`.

## Historical Context

Older notes described automatic mode selection by querying `working.db` message counts before migration and invalidating the Drift provider only for full mode. The current monitor path no longer follows that shape:

- it primes and polls from `MAX(ROWID)` against `chat.db`
- it runs the source-scoped graph build lifecycle by high-water marks
- it archives newly imported live graph source ranges
- it bumps graph/message data version providers after success

Treat older count-based or provider-invalidation examples as historical implementation notes, not current guidance.

## Troubleshooting

If new graph messages are not appearing:

1. Check `ChatDbMonitor` logs for MAX(ROWID) detection and graph build errors.
2. Check the Conversation Graph status panel for imported/projected counts and stage timings.
3. Confirm the relevant UI provider observes graph/message data-version signals or Drift graph streams.

If retained incremental projection is slow:

1. Confirm the log contains `Incremental mode: skipping table truncation.`
2. Inspect the specific migrator that is slow; do not assume all migrators use the same SQL strategy.
3. Check for lingering import database attachments or SQLite locks reported by `ensureImportReady` / `ensureImportClean`.

If a "connection was closed" loop appears:

1. Search for `ref.invalidate(driftWorkingDatabaseProvider)` in the completion path.
2. Remove it from incremental flows.
3. Use provider-specific invalidation or `messageDataVersionProvider.bump()` instead.

## Related Reading

- `./01-overview.md` - Source import and graph build overview.
- `./10-import-orchestrator.md` - Monitor context and retained import service behavior.
- `./20-migration-orchestrator.md` - Migrator dependency ordering and post-migration synthetic steps.
- `../10-DATABASES/10-group-import-working.md` - Schema contracts between import and working DBs.
