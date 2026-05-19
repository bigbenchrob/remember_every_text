---
created_at: 2026-05-15T14:20:49-07:00
title: "Implement HandleImporter"
tags: []
source: codex_prompt_history.html
---

# Implement HandleImporter

## Prompt

```text
Next architectural slice: implement the first real prerequisite importer, HandleImporter.

Context

The shadow incremental-update architecture now has:

* validated message import/migration loop
* source-contract docs for Apple source DBs
* fixed MessageImporter source schema assumptions
* portable MessageImporter naming
* ImporterDescriptor metadata
* source-scoped message relationship fields
* read-only handle observation/reconciliation slice
* read-only chat observation/reconciliation slice
* prerequisite-aware message policy visible as diagnostics only

Current prerequisite-aware message policy may show:

blockedPendingPrerequisites([handlesNotReady, chatsNotReady])

The goal of this slice is to implement the first prerequisite importer so that handles can catch up independently.

Goal

Implement a narrow HandleImporter:

live chat.db.handle
→ macos_import_shadow.db.handles

Only.

No chats.
No joins.
No messages changes.
No graph orchestration.
No topological sorting.

Desired closed loop

Before import:

HandleImportDecision.considerIncrementalImport

After import:

HandleImportDecision.doNothing
HandleSyncState.sourceAndLedgerCursorsMatch

Then prerequisite-aware message policy should eventually drop:

handlesNotReady

while still possibly retaining:

chatsNotReady

Scope

Add execution for handles only.

Suggested structure

Use production-shaped naming, not shadow-specific naming, for the portable importer:

application/handles/importers/handle_importer.dart
application/handles/importers/handle_importer_provider.dart

or equivalent existing folder conventions.

Keep shadow/dev naming only for orchestration/environment if needed.

HandleImporter responsibilities

The importer should:

* read new rows from live chat.db.handle
* write rows into macos_import_shadow.db.handles
* preserve source_id
* preserve source_kind
* preserve source_rowid
* preserve app-relevant handle fields documented in 15-MACOS-SOURCE-DATABASES/10-CHAT-DB.md
* be resumable by MAX(source_rowid)
* be idempotent
* emit a narrow HandleImportResult

Likely app-relevant fields:

* ROWID as source_rowid
* id as handle value
* service if present
* country if present

Do not infer undocumented source fields.

Consult source-contract docs.

ImporterDescriptor

Add a descriptor for HandleImporter.

Suggested values:

importerName: handle_importer
sourceTables: [‘handle’]
targetTables: [‘handles’]
prerequisites: []
continuationStrategy: MAX(handles.source_rowid)
idempotenceStrategy: INSERT OR IGNORE / conflict ignore on already-imported source rows
validationStrategy: cursor/count convergence validation

Execution orchestration

Add the minimal handle execution orchestration needed to run the importer when:

HandleImportDecision.considerIncrementalImport

Do not build generic graph orchestration.

Keep this specific and narrow, analogous to current message import execution orchestration.

The orchestrator should:

* observe HandleImportDecision
* run HandleImporter only when policy allows
* block/no-op on doNothing
* block/report on ledgerAheadOfSource
* avoid overlapping execution

Polling integration

Integrate handle refresh/import into the existing shadow polling flow in the smallest clear way.

Important: reader invalidation boundary should remain correct.

Polling should invalidate handle reader snapshot providers when refreshing handle state.

Derived handle providers should recompute naturally.

Do not invalidate semantic providers directly unless there is a specific tested reason.

Diagnostics

Add handle import decision/state/delta visibility to:

* tick events
* endurance log summary

Dev panel visibility is optional in this slice unless straightforward.

Prerequisite-aware message policy

After handle import runs, prerequisite-aware message decision should reflect updated handle readiness.

Expected eventual behavior:

blockedPendingPrerequisites([chatsNotReady])

rather than:

blockedPendingPrerequisites([handlesNotReady, chatsNotReady])

assuming chats remain behind.

Constraints

DO NOT:

* add ChatImporter
* add chat_handle_join importer
* add message/chat topology import
* add importer graph execution
* add topological sorting
* alter production behavior
* write to production DBs
* alter MessageImporter semantics
* wire prerequisite-aware message decision into execution authority
* add canonical handle/contact resolution
* touch AddressBook import
* add projection changes for handles

DO:

* keep HandleImporter narrow
* keep writes confined to macos_import_shadow.db
* preserve source-scoped provenance
* preserve idempotence
* preserve resumability
* add focused tests

Tests

Add focused tests for:

* HandleImporter imports rows from a source handle table
* source_rowid/source_id/source_kind are preserved
* handle value is preserved
* optional service/country fields are handled safely
* repeated import is idempotent
* handle import execution orchestrator invokes importer exactly once for considerIncrementalImport
* doNothing skips execution
* ledgerAheadOfSource blocks execution
* handle provider chain resolves after import if practical

Verification

Run:

* dart analyze on changed files
* focused handle importer/orchestrator tests
* existing message importer/orchestrator tests if touched

Manual app verification

1. Launch app.
2. Start shadow polling.
3. Confirm handle decision starts as considerIncrementalImport if shadow handles are behind.
4. Confirm HandleImporter runs.
5. Confirm handle state settles to sourceAndLedgerCursorsMatch.
6. Confirm prerequisite-aware message blockers drop handlesNotReady, leaving chatsNotReady if chats are still behind.
7. Confirm message import/migration behavior remains healthy.

Report back with:

* files added/changed
* exact handle fields imported
* descriptor values
* how handle execution is integrated into polling
* tests added
* manual app verification result if available
```

---

Implemented the first real prerequisite importer slice for handles.

Added/changed

handle_importer.dart
handle_importer_provider.dart
handle_import_execution_orchestrator.dart
handle_import_execution_orchestrator_provider.dart
sqflite_import_database.dart
sync_state_polling_orchestrator.dart
Status/endurance visibility files for handle state and decision.
Focused tests under test/essentials/incremental_update/application/handles/....
Handle fields imported
The importer reads:

SELECT ROWID AS source_rowid, \*
FROM handle
WHERE ROWID > ?
ORDER BY ROWID ASC
LIMIT ?
It writes to macos_import_shadow.db.handles only:

ROWID → id, source_rowid
source_id → live-chat-db
source_kind → live_chat_db
id → raw_identifier
normalized handle value → normalized_identifier
computed compound value → compound_identifier
service if present, otherwise Unknown
country if present
batch_id
I added nullable source_id / source_kind columns to the import-ledger handles schema and bumped the sqflite schema version to 8. The upgrade path adds those columns only if missing, so older rebuild-style migrations do not collide.

Descriptor
HandleImporter.descriptor is:

importerName: handle_importer
sourceTables: ['handle']
targetTables: ['handles']
prerequisites: []
continuationStrategy: MAX(handles.source_rowid)
idempotenceStrategy: INSERT OR IGNORE / conflict ignore on already-imported source rows
validationStrategy: cursor/count convergence validation
Polling integration
The existing shadow polling flow now refreshes handles first by invalidating only:

liveChatDbHandleSnapshotProvider
importLedgerHandleSnapshotProvider
Then it reads the derived handle delta/decision and runs HandleImportExecutionOrchestrator only for HandleImportDecision.considerIncrementalImport. doNothing and blockAndReportLedgerAhead do not execute.

Prerequisite-aware message policy is still diagnostic-only. It does not govern message execution.

Verification
Passed:

dart analyze <changed focused targets>
flutter test test/essentials/db/infrastructure/data_sources/local/import/sqflite_import_database_test.dart test/essentials/incremental_update/application/handles/importers/handle_importer_test.dart test/essentials/incremental_update/application/handles/importers/handle_importer_descriptor_test.dart test/essentials/incremental_update/application/handles/orchestrators/handle_import_execution_orchestrator_test.dart test/essentials/incremental_update/application/messages/status/shadow_polling_endurance_log_writer_test.dart
flutter test test/essentials/incremental_update/application/messages/executors/message_importer_test.dart test/essentials/incremental_update/application/messages/orchestrators/shadow_import_execution_orchestrator_test.dart
I did not run the manual macOS app polling verification in this turn. Production DB providers and legacy import/migration orchestration were not changed or reused.

14 files changed
+871
-16
Undo

Review

lib/essentials/db/infrastructure/data_sources/local/import/sqflite_import_database.dart
lib/essentials/incremental_update/application/handles/importers/handle_importer.dart
lib/essentials/incremental_update/application/handles/importers/handle_importer_provider.dart
lib/essentials/incremental_update/application/handles/orchestrators/handle_import_execution_orchestrator.dart
lib/essentials/incremental_update/application/handles/orchestrators/handle_import_execution_orchestrator_provider.dart
lib/essentials/incremental_update/application/messages/orchestrators/sync_state_polling_orchestrator.dart
lib/essentials/incremental_update/application/messages/status/shadow_incremental_update_status_provider.dart
lib/essentials/incremental_update/application/messages/status/shadow_polling_endurance_log_writer.dart
lib/essentials/incremental_update/presentation/shadow_incremental_update_status_sheet.dart
test/essentials/incremental_update/application/messages/status/shadow_polling_endurance_log_writer_test.dart
test/essentials/incremental_update/application/handles/importers/handle_importer_descriptor_test.dart
test/essentials/incremental_update/application/handles/importers/handle_importer_test.dart
test/essentials/incremental_update/application/handles/orchestrators/handle_import_execution_orchestrator_test.dart
test/essentials/db/infrastructure/data_sources/local/import/sqflite_import_database_test.dart
