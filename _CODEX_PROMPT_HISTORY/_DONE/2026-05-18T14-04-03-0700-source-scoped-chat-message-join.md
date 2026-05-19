---
created_at: 2026-05-18T14:04:03-07:00
title: "source-scoped chat_message_join"
tags: []
source: codex_prompt_history.html
---

# source-scoped chat_message_join

## Prompt

```text
Next task: add a source-scoped chat_message_join topology ledger schema and importer.

Context

The read-only chat_message_join observation/reconciliation slice now exists.

It can observe source topology facts from Apple chat.db.chat_message_join, but the shadow import ledger does not yet have a source-scoped topology table.

Current semantic result is therefore correctly:

ChatMessageJoinSyncState.topologyNotYetImported

Goal

Introduce a source-scoped topology ledger for message-to-chat relationships and implement a narrow topology importer.

Important architectural rule

This task preserves source topology only.

Do NOT resolve canonical chat membership yet.

Do NOT modify working projection semantics yet.

Do NOT replace placeholder chat behavior yet.

We are preserving source truth first. Projection/app truth comes later.

Desired ledger shape

Add a source-scoped shadow import ledger table for chat_message_join facts.

Suggested table name:

chat_message_joins

or similar, consistent with existing naming.

It should preserve at least:

* id
* source_id
* source_kind
* source_rowid
* source_chat_rowid
* source_message_rowid
* batch_id

Recommended uniqueness:

* unique source provenance key, likely:
    UNIQUE(source_id, source_rowid)

Do not use source chat_id / message_id as canonical app IDs.

They are source-local relationship endpoints.

Importer

Add a narrow production-shaped importer:

ChatMessageJoinImporter

Suggested location:

application/chat_message_joins/importers/

Responsibilities:

* read new rows from live chat.db.chat_message_join
* write source topology rows into macos_import_shadow.db.chat_message_joins
* preserve source_id
* preserve source_kind
* preserve source_rowid
* preserve source_chat_rowid
* preserve source_message_rowid
* be resumable by source-scoped MAX(source_rowid)
* be idempotent
* return a narrow ChatMessageJoinImportResult

Do not infer canonical relationships.

Do not touch working_shadow.db.

Descriptor

Add ChatMessageJoinImporter.descriptor.

Suggested values:

* importerName: chat_message_join_importer
* sourceTables: [chat_message_join]
* targetTables: [chat_message_joins]
* prerequisites: [chat_importer, message_importer] or equivalent metadata only
* continuationStrategy: MAX(chat_message_joins.source_rowid) scoped by source_id
* idempotenceStrategy: INSERT OR IGNORE / conflict ignore on source provenance
* validationStrategy: cursor/count topology convergence validation

Execution orchestration

Add narrow execution orchestration analogous to handles/chats.

Suggested:

* ChatMessageJoinImportExecutionOrchestrator

Run only when:

ChatMessageJoinImportDecision.considerTopologyImport

Do not build graph orchestration.

Do not wire into the main pipeline yet unless the slice remains very small and explicitly safe. Prefer importer + orchestrator tests first.

StageController

Do NOT add ChatMessageJoinStageController in this task unless everything above is complete and still small.

This task is about establishing the source-scoped topology ledger + importer.

Pipeline integration can be a later slice.

Constraints

Do NOT:

* resolve canonical chat/message relationships
* modify MessageImporter
* modify MessageMigrationStageController
* write topology into working_shadow.db
* alter UI/search behavior
* replace placeholder chat behavior
* add graph orchestration
* add topological sorting
* alter existing message import execution authority
* alter production behavior

Do:

* preserve source topology exactly
* keep source row IDs source-scoped
* keep importer resumable and idempotent
* keep mutation confined to macos_import_shadow.db
* add focused tests

Tests

Add/update focused tests for:

* schema creation includes source-scoped topology ledger table
* upgrade path adds the table safely
* importer reads chat_message_join.ROWID, chat_id, message_id
* importer writes source topology provenance correctly
* importer continuation is source-scoped
* fake archive source with higher source_rowid does not affect live continuation
* repeated import is idempotent
* import decision transitions from considerTopologyImport to doNothing after import if repository support is complete
* no working DB or production DB mutation occurs

Verification

Run:

* dart analyze on changed files
* focused topology schema/importer/orchestrator tests
* existing topology observation tests

Report back with:

* schema added
* exact fields preserved
* importer descriptor
* whether execution orchestration was added
* whether pipeline integration was deferred
* tests run
```

---

Implemented the read-only `chat_message_join` topology observation/reconciliation slice.

Added:

- Domain models:
  - `ChatMessageJoinSnapshot`
  - `ChatMessageJoinSnapshotDelta`
- Domain sealed unions:
  - `ChatMessageJoinSyncState`
    - `sourceAndLedgerTopologyMatch`
    - `sourceTopologyAheadOfLedger`
    - `ledgerTopologyAheadOfSource`
    - `topologyNotYetImported`
  - `ChatMessageJoinImportDecision`
    - `doNothing`
    - `considerTopologyImport`
    - `blockAndReportLedgerAhead`
- Readers/providers under:
  - [application/chat_message_joins/readers](/Users/rob/Development/FlutterProjects/remember_every_text/lib/essentials/incremental_update/application/chat_message_joins/readers)
- Integrators/providers under:
  - [application/chat_message_joins/integrators](/Users/rob/Development/FlutterProjects/remember_every_text/lib/essentials/incremental_update/application/chat_message_joins/integrators)
- Source/ledger repositories:
  - [chat_db_chat_message_join_repository.dart](/Users/rob/Development/FlutterProjects/remember_every_text/lib/essentials/incremental_update/infrastructure/chat_db_chat_message_join_repository.dart)
  - [import_ledger_chat_message_join_repository.dart](/Users/rob/Development/FlutterProjects/remember_every_text/lib/essentials/incremental_update/infrastructure/import_ledger_chat_message_join_repository.dart)

Topology facts observed:

- `MAX(ROWID)` from source `chat_message_join`
- row count
- `MAX(message_id)`
- `MAX(chat_id)`

Ledger behavior:

- No shadow topology schema change was made.
- Current `chat_to_message` is not source-scoped, so the ledger repository reports `sourceScopedObservationAvailable: false`.
- That derives `ChatMessageJoinSyncState.topologyNotYetImported`, then `ChatMessageJoinImportDecision.considerTopologyImport`.
- If a future source-scoped ledger topology table exists, the repository already scopes by `source_id = live-chat-db`.

Tests added:

- Source topology observation.
- Ledger topology unavailable when current ledger table is not source-scoped.
- Fake archive source with higher `source_rowid` does not affect live topology observation when source-scoped columns exist.
- Delta, sync-state, and decision derivation.

Verification:

- `dart run build_runner build --delete-conflicting-outputs`
- `flutter test` focused topology tests: all passed.
- `dart analyze` on changed topology files/tests: no issues.

This slice is mutation-free: no topology import, no schema migration, no message/chat linkage changes, no pipeline wiring, and no production behavior changes.
