---
created_at: 2026-05-15T14:48:37-07:00
title: "Implement chat importer"
tags: []
source: codex_prompt_history.html
---

# Implement chat importer

## Prompt

```text
Next architectural slice: implement ChatImporter as the second real prerequisite-bearing importer.

Context

The architecture now has:

* validated message import/migration loop
* working HandleImporter
* prerequisite-aware message policy semantics
* source-contract docs
* read-only chat observation/reconciliation slice
* independent prerequisite convergence inside a single polling loop

The HandleImporter milestone successfully proved:

live source
→ shadow ledger
→ semantic reconciliation
→ prerequisite satisfaction
→ downstream policy update

Current behavior now correctly transitions from:

blockedPendingPrerequisites([handlesNotReady, chatsNotReady])

to:

blockedPendingPrerequisites([chatsNotReady])

after handle convergence.

The next goal is to implement ChatImporter so chat convergence can occur independently too.

Goal

Implement a narrow ChatImporter:

live chat.db.chat
→ macos_import_shadow.db.chats

Only.

No joins.
No topology reconstruction.
No message/chat relationship ownership yet.

Desired result

Before import:

ChatImportDecision.considerIncrementalImport

After import:

ChatImportDecision.doNothing
ChatSyncState.sourceAndLedgerCursorsMatch

Then prerequisite-aware message policy should eventually become:

prerequisites satisfied

or equivalent no-blocker state.

Scope

Add execution for chats only.

No graph orchestration yet.

Use production-shaped naming.

Suggested structure

application/chats/importers/chat_importer.dart
application/chats/importers/chat_importer_provider.dart

or equivalent existing folder conventions.

ChatImporter responsibilities

The importer should:

* read new rows from live chat.db.chat
* write rows into macos_import_shadow.db.chats
* preserve source_id
* preserve source_kind
* preserve source_rowid
* preserve app-relevant chat fields documented in source-contract docs
* be resumable by MAX(source_rowid)
* be idempotent
* emit a narrow ChatImportResult

Keep imported fields intentionally narrow and provenance-focused.

Suggested initial fields

Only fields already relevant/documented.

Examples:

* ROWID as source_rowid
* guid if present
* chat_identifier if present
* service_name if present
* display_name if present

Do NOT infer undocumented semantics.

Do NOT attempt:

* participant resolution
* canonical chat grouping
* relationship ownership reconstruction
* topology synthesis

ImporterDescriptor

Add ChatImporter.descriptor.

Suggested values:

importerName: chat_importer
sourceTables: [‘chat’]
targetTables: [‘chats’]
prerequisites: []
continuationStrategy: MAX(chats.source_rowid)
idempotenceStrategy: INSERT OR IGNORE / conflict ignore
validationStrategy: cursor/count convergence validation

Execution orchestration

Add the minimal narrow execution orchestration needed to run ChatImporter when:

ChatImportDecision.considerIncrementalImport

Keep this analogous to HandleImporter orchestration.

Do NOT build generic graph execution.

Polling integration

Integrate chat refresh/import into the existing polling loop carefully.

Maintain correct invalidation boundaries:

invalidate chat reader providers only
derived providers recompute naturally

Avoid invalidating semantic providers directly unless necessary and tested.

Diagnostics

Add chat visibility to:

* endurance log summary
* tick events

Dev panel visibility optional unless straightforward.

Prerequisite-aware message policy

After ChatImporter converges, prerequisite-aware message policy should eventually indicate:

* prerequisites satisfied
    or
* no blockers

while current validated execution behavior remains unchanged.

Constraints

DO NOT:

* add join importers
* add chat_handle_join import
* add chat_message_join import
* add topology reconstruction
* add graph orchestration
* add topological sorting
* wire prerequisite-aware policy into execution authority
* alter MessageImporter semantics
* alter production DB behavior
* add canonical chat resolution
* add projection changes for chats

DO:

* keep ChatImporter narrow
* preserve provenance
* preserve resumability
* preserve idempotence
* preserve architecture symmetry
* add focused tests

Tests

Add focused tests for:

* ChatImporter imports rows from source chat table
* source_rowid/source_id/source_kind preserved
* imported chat fields preserved
* repeated import is idempotent
* chat execution orchestrator invokes importer exactly once for considerIncrementalImport
* doNothing skips execution
* ledgerAheadOfSource blocks execution
* prerequisite-aware message policy drops chatsNotReady after convergence if practical

Verification

Run:

* dart analyze on changed files
* focused chat importer/orchestrator tests
* existing handle/message tests if touched

Manual app verification

1. Launch app.
2. Start shadow polling.
3. Confirm ChatImportDecision initially requests import if chats are behind.
4. Confirm ChatImporter runs.
5. Confirm chat convergence reaches sourceAndLedgerCursorsMatch.
6. Confirm prerequisite-aware message blockers disappear entirely.
7. Confirm message import/migration behavior remains healthy.

Report back with:

* files added/changed
* exact chat fields imported
* descriptor values
* polling integration details
* tests added
* manual app verification results if available
```

---

Implemented the narrow ChatImporter slice.

Added

ChatImporter + ChatImportResult
chatImporterProvider
ChatImportExecutionOrchestrator
chatImportExecutionOrchestratorProvider
Focused importer/orchestrator/descriptor tests
Schema
Bumped SqfliteImportDatabase schema to 9 and added nullable chat provenance columns:

chats.source_id TEXT
chats.source_kind TEXT
Upgrade uses safe “add if missing” logic.

Fields imported
live chat.db.chat → macos_import_shadow.db.chats:

ROWID → id, source_rowid
source_id → live-chat-db
source_kind → live_chat_db
guid → guid
service_name or service → service
display_name or chat_identifier → display_name
is_group → 0
batch_id
No joins, participant resolution, message/chat topology, or canonical chat resolution were added.

Descriptor
ChatImporter.descriptor:

importerName: chat_importer
sourceTables: ['chat']
targetTables: ['chats']
prerequisites: []
continuationStrategy: MAX(chats.source_rowid)
idempotenceStrategy: INSERT OR IGNORE / conflict ignore
validationStrategy: cursor/count convergence validation
Polling integration
The polling loop now refreshes chats before handles/messages:

Invalidates only liveChatDbChatSnapshotProvider and importLedgerChatSnapshotProvider
Reads derived chat delta + decision
Runs ChatImportExecutionOrchestrator only for ChatImportDecision.considerIncrementalImport
Re-invalidates chat reader providers after chat import so derived providers recompute naturally
Prerequisite-aware message policy remains diagnostic-only and still does not control execution.

Verification
Passed:

dart analyze <focused changed targets>
flutter test test/essentials/db/infrastructure/data_sources/local/import/sqflite_import_database_test.dart test/essentials/incremental_update/application/chats/importers/chat_importer_test.dart test/essentials/incremental_update/application/chats/importers/chat_importer_descriptor_test.dart test/essentials/incremental_update/application/chats/orchestrators/chat_import_execution_orchestrator_test.dart test/essentials/incremental_update/application/handles/importers/handle_importer_test.dart test/essentials/incremental_update/application/handles/orchestrators/handle_import_execution_orchestrator_test.dart test/essentials/incremental_update/application/messages/status/shadow_polling_endurance_log_writer_test.dart
flutter test test/essentials/incremental_update/application/chats/integrators/chat_provider_behavior_test.dart test/essentials/incremental_update/application/chats/integrators/chat_import_decision_integrator_test.dart test/essentials/incremental_update/application/chats/integrators/chat_snapshot_delta_integrator_test.dart test/essentials/incremental_update/application/chats/integrators/chat_sync_state_integrator_test.dart
Manual app verification was not run in this turn. Production behavior was not changed, and the new importer writes only to the shadow import database path supplied by the dev provider.

14 files changed
+828
-9
Undo

Review

lib/essentials/db/infrastructure/data_sources/local/import/sqflite_import_database.dart
lib/essentials/incremental_update/application/chats/importers/chat_importer.dart
lib/essentials/incremental_update/application/chats/importers/chat_importer_provider.dart
lib/essentials/incremental_update/application/chats/orchestrators/chat_import_execution_orchestrator.dart
lib/essentials/incremental_update/application/chats/orchestrators/chat_import_execution_orchestrator_provider.dart
lib/essentials/incremental_update/application/messages/orchestrators/sync_state_polling_orchestrator.dart
lib/essentials/incremental_update/application/messages/status/shadow_incremental_update_status_provider.dart
lib/essentials/incremental_update/application/messages/status/shadow_polling_endurance_log_writer.dart
lib/essentials/incremental_update/presentation/shadow_incremental_update_status_sheet.dart
test/essentials/incremental_update/application/messages/status/shadow_polling_endurance_log_writer_test.dart
test/essentials/db/infrastructure/data_sources/local/import/sqflite_import_database_test.dart
test/essentials/incremental_update/application/chats/importers/chat_importer_test.dart
test/essentials/incremental_update/application/chats/importers/chat_importer_descriptor_test.dart
test/essentials/incremental_update/application/chats/orchestrators/chat_import_execution_orchestrator_test.dart
