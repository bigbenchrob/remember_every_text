---
created_at: 2026-05-18T13:32:14-07:00
title: "Chat-message join observation slice"
tags: []
source: codex_prompt_history.html
---

# Chat-message join observation slice

## Prompt

```text
Here’s the next prompt. This is an important transition because chat_message_join is the first true topology-bearing structure in the pipeline.

Next task: implement the read-only chat_message_join observation/reconciliation slice.

Context

The shadow incremental-update pipeline is now stable and includes:

* PipelineOrchestrator
* ordered StageControllers
* source-scoped cursor semantics
* handle/chat/message import
* migration
* comparative validation
* diagnostic-only count divergence semantics

The next architectural concern is topology observation.

Important architectural clarification

Apple chat.db.message does NOT directly own canonical chat membership.

True message-to-chat topology lives in:

chat_message_join

This is the first topology-bearing relationship slice.

Goal

Implement a mutation-free observation/reconciliation slice for chat_message_join.

This slice should:

* observe source topology facts
* observe shadow-ledger topology facts
* derive topology sync state
* derive topology import decisions
* expose diagnostic semantics

BUT:

Do NOT implement topology import yet.

Do NOT resolve canonical relationships yet.

Do NOT modify existing message/chat linkage behavior yet.

Desired semantics

This slice should answer questions like:

* is the source topology ahead of the ledger topology?
* are topology cursors converged?
* would topology import eventually be required?

without yet mutating any topology state.

Suggested naming

Use terminology that clearly reflects topology semantics rather than pretending this is a normal table import.

Possible naming direction:

ChatMessageJoinSnapshot
ChatMessageJoinSnapshotDelta
ChatMessageJoinSyncState
ChatMessageJoinImportDecision

or equivalent.

Important source-scoped rules

All observation must already be multi-source-safe.

Use existing source identity constants:

source_id
source_kind

No global ROWID assumptions.

Observed facts

Likely observations include:

live chat.db.chat_message_join:

* MAX(ROWID) if available
* row count
* maybe max(message_id)
* maybe max(chat_id)

shadow ledger:

* topology-related rows/counts if present
* or initially empty/not implemented semantics

Important boundary

This is observational only.

Do NOT:

* add topology import execution
* add topology migration
* modify MessageImporter
* replace placeholder chat behavior
* infer canonical memberships
* mutate working DB relationships
* alter search behavior
* alter UI topology semantics

If shadow topology tables do not yet exist,
it is acceptable for this first slice to derive a stable “not yet imported” state using explicit semantics.

Architecture goal

We are intentionally separating:

topology observation
from
topology mutation

before introducing relationship import behavior.

This mirrors the earlier handle/chat observation-first approach.

Suggested structure

Follow the existing concern pattern:

application/chat_message_joins/

* readers/
* integrators/
* orchestrators/ (only if needed)

domain/models/

* topology snapshot models

domain/sealed_unions/

* topology sync state
* topology import decision

infrastructure/

* source repositories
* ledger repositories

Keep the slice narrow and mutation-free.

Potential semantic states

Something like:

ChatMessageJoinSyncState:

* sourceAndLedgerTopologyMatch
* sourceTopologyAheadOfLedger
* ledgerTopologyAheadOfSource
* topologyNotYetImported

Import decision equivalents:

* doNothing
* considerTopologyImport
* blockAndReportLedgerAhead

or equivalent.

Do NOT overbuild.

Tests

Add focused tests covering:

* source topology observation
* ledger topology observation
* topology delta derivation
* topology sync-state derivation
* topology import-decision derivation
* source-scoped cursor semantics
* fake archive source does not affect live source topology observation

Verification

Run:

* dart analyze on changed files
* focused topology observation tests

Report back with:

* files/models added
* semantic states introduced
* topology observations chosen
* whether any shadow topology schema was required
* confirmation this slice remains mutation-free
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
