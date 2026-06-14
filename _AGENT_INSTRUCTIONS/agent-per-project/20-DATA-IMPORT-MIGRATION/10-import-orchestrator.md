---
tier: project
scope: data-import-migration
owner: agent-per-project
last_reviewed: 2026-06-08
source_of_truth: code
links:
  - ./01-overview.md
  - ./02-import-migration-schema-reference.md
  - ./11-rust-message-extractor.md
  - ./15-table-importers.md
  - ../10-DATABASES/01-db-import.md
  - ../10-DATABASES/10-group-import-working.md
---

# Import Orchestrator

> Current conformance note (2026-06-08): ordinary live sync is source-scoped
> graph build, not retained historical import/migration. The old retained
> `ImportOrchestrator` implementation has been removed from active app code.
> This page combines the current `ChatDbChangeMonitor` runbook with historical
> retained importer mechanics. Treat the monitor sections as current live-sync
> guidance and the retained importer sections as old-log/retained-storage
> interpretation only.

## 🔥 Automatic Polling (ChatDbChangeMonitor)

**Imports are triggered automatically** — no manual intervention required.

The app includes a `ChatDbChangeMonitor` provider that continuously watches macOS `chat.db` for new messages:

| Aspect | Detail |
|--------|--------|
| **Provider** | `chatDbChangeMonitorProvider` (keepAlive: true) |
| **Location** | `lib/essentials/conversation_graph/application/monitor/chat_db_change_monitor_provider.dart` |
| **Poll interval** | Every **15 seconds** |
| **Detection method** | Compares `MAX(ROWID)` from `message` table against stored value |
| **Trigger** | When ROWID increases, schedules debounced import (350ms debounce) |

### Auto-Import Flow

```
┌─────────────────────────────────────────────────────────────────────┐
│  ChatDbChangeMonitor (runs in background)                           │
├─────────────────────────────────────────────────────────────────────┤
│  1. Timer fires every 15 seconds                                    │
│  2. Read MAX(ROWID) from ~/Library/Messages/chat.db                 │
│  3. Compare with lastMaxRowId stored in state                       │
│  4. If increased → schedule probe (350ms debounce)                  │
│  5. Probe runs:                                                     │
│     a. run source-scoped graph build lifecycle                      │
│     b. archiveGraphMessageSourceRange(...) for new attachments      │
│     c. bump graph/message data version providers                    │
└─────────────────────────────────────────────────────────────────────┘
```

### Wiring

The monitor is activated in `main.dart` via:
```dart
ref.watch(chatDbChangeMonitorProvider);
```

This ensures the monitor starts at app launch and runs continuously. It is macOS-only and also performs a startup catch-up check so messages that arrived while the app was closed do not wait for the first 15-second polling tick.

### Implications for Debugging

- **New messages appear automatically** within ~15-20 seconds of arrival
- **If messages aren't showing**, the monitor or graph build may have encountered an error; check `ChatDbMonitor` logs and the Conversation Graph status panel first
- **Manual import is only needed** for initial setup or recovery scenarios
- **Do not invalidate database providers from the live graph path**. The monitor keeps active graph readers alive and bumps graph/message data-version providers after successful graph build.

---

## Purpose
- Preserve the historical retained importer mechanics for old logs and
  architecture archaeology.
- Make clear that new source ingestion belongs to source-scoped import and graph
  build services, not to the deleted retained import orchestrator.
- Prevent future work from reintroducing retained ledger import as an ordinary
  product path.

## Location
- Retired retained orchestrator: `lib/essentials/db_importers/application/orchestrator/import_orchestrator.dart`
- Retired shared context: `lib/essentials/db_importers/infrastructure/sqlite/import_context_sqlite.dart`
- Retired base importer helpers: `lib/essentials/db_importers/domain/base_table_importer.dart`
- Retired importer contract: `lib/essentials/db_importers/domain/i_importers.dart/table_importer.dart`
- Retired progress events: `lib/essentials/db_importers/domain/states/table_import_progress.dart`
- Retired Riverpod wiring: `lib/essentials/db_importers/feature_level_providers.dart`
- Retired service registry: `lib/essentials/db_importers/application/services/orchestrated_ledger_import_service.dart`

These retained paths are intentionally not present in the current source tree.
Current live import/build code is source-scoped and graph-backed.

## Execution Model
1. **Importer registry** - The orchestrator receives a list of `TableImporter` instances (one per ledger table) and keeps them in `_importers` as an unmodifiable list.
2. **Dependency sorting** - `_sorted()` runs a Kahn topological sort over each importer's `dependsOn`. Any unresolved cycle throws before work begins, preventing partial runs.
3. **Phase lifecycle** - For every importer the orchestrator executes:
  - `validatePrereqs(ctx)` - must not mutate data; catches duplicate IDs, broken foreign keys, invalid enums, missing sources.
  - `copy(ctx)` - importer-owned deterministic SQL. Skipped automatically when `ImportContext.dryRun` is true.
  - `postValidate(ctx)` - confirms row counts, FK integrity, and any importer-specific invariants.
4. **Progress events** - `_runPhase()` publishes `TableImportProgressEvent`s (`started`, `succeeded`, `failed`) with human-friendly names via `BaseTableImporter.displayName`. Retained diagnostic UI view models may surface these updates in the import control panel.
5. **Structured logging** - Every phase prints a timestamped banner (`=== [ISO8601] importer :: phase ===`) through `ImportContext.info()`, giving a chronological trace in console logs and batch notes.
6. **Filesystem audit report** - At the end of each run the orchestrated service writes `import_log` in the MessageLens app-support directory, capturing source counts, ledger counts, rich-text extraction stats, and source-vs-destination deltas.
7. **Dry-run support** - Validation and post-validation still execute while copy is skipped, enabling "check everything" workflows on user machines without mutating the ledger.

## Import Context Facts
- Exposes the `SqfliteImportDatabase`, live `chat.db` / AddressBook handles, active `batchId`, and an optional `MessageExtractorPort`.
- Stores previously imported max ROWIDs so append importers can detect true deltas.
- Includes a scratchpad map for importer-to-importer coordination (e.g., sharing statistics or staging paths).
- Detects truncated or incomplete imported baselines and can force a full reimport by clearing previous max-row cursors before importer execution.

## Importer Responsibilities
- Own one logical retained ledger table (or tight cluster) and copy rows from macOS sources into `macos_import.db` without altering source primary keys.
- Enrich rows with derived columns when needed, but do not invent cross-table relationships; retained historical relationship projection happens during migration, while production graph topology is built in the source-scoped graph lifecycle.
- Use `BaseTableImporter` helpers (`count`, `expectTrueOrThrow`, `expectZeroOrThrow`) to keep validation consistent.
- Emit progress names that help the UI explain which portion of the pipeline is running.

## Message Import Specifics

- Chat-linked source rows are staged into the normal `messages` ledger path.
- Source `message` rows that lack a `chat_message_join` mapping are now preserved on a dedicated recovery path instead of being left outside the app entirely.
- The current ledger split is:
  - `messages` for thread-linked rows
  - `recovered_unlinked_messages` for source rows that remain materially present but are no longer reachable through normal chat linkage
- Attachment joins and rich-text extraction now operate on both paths.
- This distinction matters operationally: a source row can be absent from the visible conversation graph while still surviving in `chat.db` with meaningful payloads.
- When rich-text extraction succeeds, the importer updates text-bearing rows on both the normal and recovered paths so later migration and diagnostics do not continue reporting them as `attachment-only`, `unknown`, or otherwise misleadingly sparse.

## Error Handling
- Any exception from an importer phase causes `_runPhase()` to emit a failure event, log the error context, and rethrow so the orchestrator stops immediately.
- Downstream consumers should surface the failure message and encourage reviewing importer-specific logs for details.
- If the run completes but the data looks wrong, inspect `import_log` before querying tables manually. In practice it is the fastest way to distinguish extractor failure, source orphan rows, and schema/count mismatches.

## When Adding Importers

Do not add retained importers for ordinary app behavior. New source
facts should usually be modeled in `macos_import_ss.db` and projected into
`working_ss.db`. If an explicit archive/recovery compatibility task truly
requires retained `macos_import.db` behavior, write a reviewed graph-era plan
first and update this page with the new concrete implementation path.
