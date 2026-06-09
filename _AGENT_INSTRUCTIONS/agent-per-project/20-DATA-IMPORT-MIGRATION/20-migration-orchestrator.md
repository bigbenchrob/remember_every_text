---
tier: project
scope: data-import-migration
owner: agent-per-project
last_reviewed: 2026-06-08
source_of_truth: code
links:
  - ./01-overview.md
  - ./02-import-migration-schema-reference.md
  - ./10-import-orchestrator.md
  - ./25-table-migrators.md
  - ../10-DATABASES/02-db-working.md
---

# Retained Legacy Migration Orchestrator

> Current conformance note (2026-06-08): this document describes the historical
> retained `db_migrate` projection path from `macos_import.db` to legacy
> `working.db`. The old implementation has been removed from active app code.
> Ordinary app reads and live sync now use the source-scoped conversation graph.
> Do not treat this orchestrator as the production data spine for new feature
> work.

## Purpose
- Preserve the historical retained projection mechanics for interpreting old
  logs and old `working.db` files.
- Document the ID-preservation rules that shaped old retained storage.
- Make clear that recovered/orphan evidence now belongs to the source-scoped
  graph path rather than a live retained projection.

## Entry Points
- Retired orchestrator: `lib/essentials/db_migrate/application/orchestrator/migration_orchestrator.dart`
- Retired service wrapper: `lib/essentials/db_migrate/application/orchestrator/handles_migration_service.dart`
- Retired base migrator helpers: `lib/essentials/db_migrate/domain/base_table_migrator.dart`
- Retired migrator contract: `lib/essentials/db_migrate/domain/i_migrators.dart/table_migrator.dart`
- Retired progress events: `lib/essentials/db_migrate/domain/states/table_migration_progress.dart`

These retained paths are intentionally not present in the current source tree.
Current projection code is source-scoped and graph-backed.

## Historical Execution Model
1. **HandlesMigrationService** assembled the registered migrators and instantiated `MigrationOrchestrator`. The historical registry included handles, chats, chat membership, participants, handle-to-participant links, messages, recovered unlinked messages, attachments, recovered unlinked attachments, reactions, reaction counts, message read marks, and read state.
2. **Preparation** - `MigrationOrchestrator._prepareWorking()` enabled foreign keys. In full mode it truncated each migrator's target tables in reverse target-table order; in incremental mode it skipped truncation. User-managed overrides remained in `user_overlays.db` and were never copied into `working.db`.
3. **Dependency sorting** - `_sorted()` runs a Kahn algorithm across every migrator's `dependsOn`. Cycles throw immediately.
4. **Phase lifecycle** - For each migrator the orchestrator executed:
  - `validatePrereqs(ctx)` - no writes allowed; run anti-joins, integrity checks, duplicate detection.
  - `copy(ctx)` - deterministic projection SQL from the ledger into `working.db`. Skipped automatically in dry-run mode.
  - `postValidate(ctx)` - verify row counts, FK integrity, and canonical-map expectations.
5. **Health checks** - `ctx.ensureImportReady()` and `ctx.ensureImportClean()` guard each phase to catch lingering `ATTACH` statements or locked sqlite handles.
6. **Progress reporting** - `TableMigrationProgressEvent`s surfaced clear phase names to retained diagnostic/compatibility surfaces.
7. **Post-orchestrator synthetic steps** - `HandlesMigrationService` rebuilt working message indexes, recreated message-index triggers, then called `searchIndexOrchestrator.rebuildAll()`.

## Historical Migrator Responsibilities
- Move rows only from the corresponding ledger table to the working table(s). Migration may canonicalize identity/participant projections, but it must not invent source facts or user intent.
- Use canonical ID maps supplied by `MigrationContext` (e.g., `handleIdCanonicalMap`) rather than recalculating merges.
- Keep copy logic idempotent across full and incremental runs so reruns do not duplicate projection rows.
- Apply consistent validation using `BaseTableMigrator` helpers (`count`, `expectTrueOrThrow`, `expectZeroOrThrow`).

## Recovered Message Projection Specifics

- Recovered unlinked rows are projected into dedicated working tables rather than merged into `messages` with a fabricated `chat_id`.
- Attachment hydration for recovered rows is likewise kept on a separate projection path.
- Contact-scoped recovered browsing may later add conservative best-guess context in the provider/UI layer, but migration itself must remain a faithful projection of ledger facts.
- This separation is deliberate: migration preserves what survived in the source databases; any conversational reconstruction remains an app-side interpretation layered on top.

## Error Handling
- Migrator phase failures are logged with the phase label, a failed progress event is emitted, import attachment state is cleaned up, and the error is rethrown so the orchestrator halts immediately.
- `HandlesMigrationService` catches the failure, writes a best-effort `migrate_log`, and returns a failed `DbMigrationResult`.

## When Adding Migrators

Do not add retained legacy migrators for ordinary app behavior. New ordinary
projection belongs in the source-scoped graph import/projector path. If an
explicit archive/recovery compatibility task truly requires retained
`working.db` projection behavior, write a reviewed graph-era plan first and
update this page with the new concrete implementation path.
