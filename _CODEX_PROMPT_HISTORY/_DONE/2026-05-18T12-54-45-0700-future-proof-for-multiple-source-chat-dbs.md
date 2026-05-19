---
created_at: 2026-05-18T12:54:45-07:00
title: "Future proof for multiple source chat.dbs"
tags: []
source: codex_prompt_history.html
---

# Future proof for multiple source chat.dbs

## Prompt

```text
Next task: future-proof import cursor semantics for multiple chat.db sources.

Context

The shadow incremental-update pipeline is now stable and uses:

* PipelineOrchestrator
* ordered StageControllers
* source-scoped ledger fields
* cursor-driven continuation semantics
* diagnostic count divergence semantics

Current behavior is still single-source:

source_id = live-chat-db

But future archived source-folder import will introduce multiple chat.db sources, each with its own local ROWID sequence.

Important architectural rule

There is no global MAX ROWID across multiple Apple source databases.

ROWID is source-local.

Continuation cursors must therefore be scoped by:

source_id
source_table
source_rowid

Goal

Refactor current single-source cursor usage into multi-source-shaped APIs, while preserving current behavior.

Do NOT implement archive import yet.

Desired outcome

Current behavior should remain:

live-chat-db only

But internally, cursor queries should already be source-scoped.

Example:

Instead of:

MAX(source_rowid) FROM messages

use:

MAX(source_rowid) FROM messages
WHERE source_id = ‘live-chat-db’

or equivalent source-scoped API.

Scope

Apply this to current shadow import concerns:

* messages
* handles
* chats

Suggested model

Introduce a small source cursor model if useful, for example:

SourceTableCursor:

* sourceId
* sourceTable
* maxSourceRowId
* rowCount

or equivalent.

Keep it lightweight.

Do not overbuild a source registry yet unless absolutely necessary.

Source constants

If not already centralized, define constants for the current live source:

sourceId: live-chat-db
sourceKind: live_chat_db

Avoid scattering string literals further.

Repository/query changes

Update import-ledger snapshot repositories and importer continuation queries so they are scoped by source_id.

Examples:

* message ledger max source_rowid should be scoped to live-chat-db
* handle ledger max source_rowid should be scoped to live-chat-db
* chat ledger max source_rowid should be scoped to live-chat-db

If source_table is not physically present in each table, table context may be implicit in the repository/importer. Do not force schema churn just to add source_table columns.

Importer changes

Update importers so their “start after source rowid” value is source-scoped.

Critical future-proofing test:

If ledger contains:

live-chat-db source_rowid = 148528
archive-test source_rowid = 999999

then the live importer must continue from 148528, not 999999.

Add equivalent tests for:

* messages
* handles
* chats

Constraints

Do NOT:

* implement archive source import
* add source registry behavior
* add multi-source UI
* add graph execution
* change polling cadence
* change stage ordering
* change import/migration behavior
* change ImportDecision semantics
* change count divergence semantics
* add source_table columns unless already justified

Do:

* preserve current runtime behavior
* keep changes narrow
* make cursor semantics source-scoped
* add tests proving fake second sources do not affect live continuation
* centralize source identity constants if practical

Tests

Add/update focused tests verifying:

* message importer continuation ignores higher source_rowid from another source
* handle importer continuation ignores higher source_rowid from another source
* chat importer continuation ignores higher source_rowid from another source
* snapshot repositories report live-chat-db cursor/count only
* current single-source behavior remains unchanged

Verification

Run:

* dart analyze on changed files
* focused importer/repository tests for messages, handles, chats
* existing stage controller/pipeline tests if affected

Report back with:

* model/constants added
* repositories changed
* importer continuation changes
* tests added
* confirmation behavior remains single-source but multi-source-safe
```

---

Implemented the multi-source-safe cursor refactor for shadow import concerns.

Changed:

- Added centralized live source identity:
  [source_identity.dart](/Users/rob/Development/FlutterProjects/remember_every_text/lib/essentials/incremental_update/domain/models/source_identity.dart)
  - `sourceId: live-chat-db`
  - `sourceKind: live_chat_db`

Updated repositories:

- [import_ledger_message_repository.dart](/Users/rob/Development/FlutterProjects/remember_every_text/lib/essentials/incremental_update/infrastructure/import_ledger_message_repository.dart)
- [import_ledger_handle_repository.dart](/Users/rob/Development/FlutterProjects/remember_every_text/lib/essentials/incremental_update/infrastructure/import_ledger_handle_repository.dart)
- [import_ledger_chat_repository.dart](/Users/rob/Development/FlutterProjects/remember_every_text/lib/essentials/incremental_update/infrastructure/import_ledger_chat_repository.dart)

They now scope `MAX(source_rowid)` and counts by `source_id = live-chat-db`. Chat still excludes non-source placeholder rows via `source_rowid IS NOT NULL`.

Updated importers:

- [message_importer.dart](/Users/rob/Development/FlutterProjects/remember_every_text/lib/essentials/incremental_update/application/messages/executors/message_importer.dart)
- [handle_importer.dart](/Users/rob/Development/FlutterProjects/remember_every_text/lib/essentials/incremental_update/application/handles/importers/handle_importer.dart)
- [chat_importer.dart](/Users/rob/Development/FlutterProjects/remember_every_text/lib/essentials/incremental_update/application/chats/importers/chat_importer.dart)

They now use the centralized live source constants, and their descriptor continuation strategy now says it is scoped by `source_id`.

Tests added/updated:

- Repository tests now verify snapshots ignore a fake `archive-test` source with a higher `source_rowid`.
- Importer tests now verify message/handle/chat continuation starts from the live source cursor, not the higher archive cursor.
- Descriptor tests updated for source-scoped continuation wording.

Verification:

- `flutter test` passed for focused message/handle/chat repository, importer, and descriptor tests: `21 passed`.
- `dart analyze` passed on all touched files: no issues.

Behavior remains single-source at runtime, but cursor semantics are now multi-source-safe. No archive import, source registry, schema change, polling change, migration change, or production behavior change was introduced.
