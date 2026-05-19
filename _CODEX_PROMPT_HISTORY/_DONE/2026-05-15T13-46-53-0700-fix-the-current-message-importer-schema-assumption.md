---
created_at: 2026-05-15T13:46:53-07:00
title: "fix the current message importer schema assumption"
tags: []
source: codex_prompt_history.html
---

# fix the current message importer schema assumption

## Prompt

```text
Next task: fix the current message importer schema assumption, then verify the shadow loop converges again.

Context

The app-side polling test showed the shadow message import loop is stuck because MessageImporter is querying a non-existent Apple source column:

message.chat_id

The new source-contract docs under:

_AGENT_INSTRUCTIONS/agent-per-project/15-MACOS-SOURCE-DATABASES/

clarify:

* chat.db.message does NOT own chat_id
* message-to-chat membership belongs to chat_message_join
* importer logic must not infer source schema shape
* source-local rowids are provenance, not canonical app identity

Goal

Make the narrowest safe fix to MessageImporter.

Required behavior

Update MessageImporter so:

* it no longer queries message.chat_id
* it continues reading sender handle provenance from message.handle_id where available
* it inserts source_sender_handle_rowid from message.handle_id
* it inserts source_chat_rowid as NULL for now

Do NOT attempt to solve message-to-chat topology in this task.

Why source_chat_rowid = NULL for now

We do not yet have:

* ChatImporter
* chat_message_join importer
* topology-preserving relationship import
* prerequisite-aware execution orchestration
* canonical chat resolution

Until the chat/message join relationship becomes its own explicit concern slice, the message importer should preserve the absence of topology honestly rather than fabricating or inferring it.

Constraints

Do NOT:

* add chat_message_join import
* add ChatImporter
* add join importers
* add topology reconstruction
* add canonical chat resolution
* alter prerequisite-aware execution behavior
* wire prerequisite-aware decisions into execution
* alter polling cadence
* alter comparative validation
* alter endurance logging semantics

Do:

* remove the invalid source schema assumption
* keep the fix narrow
* preserve existing shadow import behavior
* preserve source_sender_handle_rowid
* keep source_chat_rowid nullable/null
* align importer behavior with source-contract docs

Tests

Update/add focused tests verifying:

* importer no longer queries message.chat_id
* imported rows preserve source_sender_handle_rowid
* imported rows have NULL source_chat_rowid
* existing import execution orchestrator behavior is unchanged
* current shadow polling/import convergence can recover after the fix

Verification

Run:

* dart analyze on changed files
* focused importer/orchestrator tests

Manual app verification after code changes:

1. Launch app.
2. Start shadow polling.
3. Confirm pending MessageSyncState.sourceAheadOfLedger resolves back to sourceAndLedgerCursorsMatch.
4. Confirm ImportDecision returns to doNothing.
5. Confirm PrerequisiteAwareMessageImportDecision may still show blockedPendingPrerequisites([handlesNotReady, chatsNotReady]).
6. Confirm that is diagnostic-only and does not block current validated execution path.

Report back with:

* exact query change made
* tests updated
* whether any other inferred source fields were discovered
* confirmation the importer now aligns with source-contract docs
* app/manual verification result if available
```

---

The importer fix is in place and re-verified.

Exact query change:

- Removed `chat_id AS source_chat_rowid` from `MessageImporter`’s `SELECT` against `chat.db.message`.
- The importer now writes:
  - `source_sender_handle_rowid` from `message.handle_id`
  - `source_chat_rowid: null`

Focused test updated:

- `message_importer_test.dart` now creates a source `message` table with no `chat_id` column.
- It verifies import succeeds, preserves `source_sender_handle_rowid`, and stores `source_chat_rowid` as `NULL`.

Verification passed:

- `dart analyze lib/essentials/incremental_update/application/messages/executors/message_importer.dart test/essentials/incremental_update/application/messages/executors/message_importer_test.dart test/essentials/incremental_update/application/messages/orchestrators/shadow_import_execution_orchestrator_test.dart`
- `flutter test test/essentials/incremental_update/application/messages/executors/message_importer_test.dart test/essentials/incremental_update/application/messages/orchestrators/shadow_import_execution_orchestrator_test.dart`

No other inferred source fields were found in this importer pass. The remaining source reads are direct `message` fields.

Manual app convergence verification was not performed in this run. The expected result after launching and starting shadow polling is that the prior `message.chat_id` SQL failure is gone, the shadow message import can proceed, and prerequisite-aware decision output may still show `blockedPendingPrerequisites([handlesNotReady, chatsNotReady])` as diagnostic-only.
