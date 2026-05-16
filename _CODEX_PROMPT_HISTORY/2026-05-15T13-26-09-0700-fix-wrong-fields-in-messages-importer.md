---
created_at: 2026-05-15T13:26:09-07:00
title: "Fix wrong fields in messages importer"
tags: []
source: codex_prompt_history.html
---

# Fix wrong fields in messages importer

## Prompt

```text
We now have formal source-contract documentation for Apple source databases under:

_AGENT_INSTRUCTIONS/agent-per-project/15-MACOS-SOURCE-DATABASES/

The docs explicitly clarify that:

* chat.db.message does NOT own chat_id
* message-to-chat membership belongs to chat_message_join
* Apple DBs are external source contracts
* importer logic must not infer source schema shape
* source-local rowids are provenance, not canonical app identity

The current runtime failure comes from MessageImporter attempting to read:

* message.chat_id

which does not exist in the observed Apple schema.

Goal

Fix the current MessageImporter failure in the narrowest, safest, architecture-correct way.

Important architectural direction

Do NOT attempt to “solve” message-to-chat topology yet.

We do NOT yet have:

* ChatImporter
* chat_message_join importer
* topology-preserving relationship import
* prerequisite-aware execution orchestration

Therefore the current MessageImporter must remain:

* narrow
* provenance-safe
* topology-honest

Task

Update MessageImporter so it stops inferring message.chat_id.

For now:

* continue preserving source_sender_handle_rowid from message.handle_id where present
* set source_chat_rowid to NULL during message import

Do NOT fabricate chat membership.

Do NOT infer topology.

Do NOT attempt to join through chat_message_join yet.

That relationship-preserving concern will become its own future importer slice.

Architectural rationale

A message importer that invents or infers topology before join import exists is violating the source-contract architecture.

Until relationship-preserving topology import exists as an explicit concern slice:

* preserve message provenance
* preserve sender-handle provenance
* preserve absence of topology honestly

The importer should remain intentionally incomplete rather than semantically misleading.

Constraints

DO NOT:

* add chat_message_join import
* add ChatImporter
* add join importers
* add topology reconstruction
* add canonical chat resolution
* alter prerequisite-aware execution behavior
* alter polling cadence
* alter comparative validation
* alter endurance logging semantics

DO:

* remove invalid schema assumptions
* preserve current validated message import behavior
* preserve current observability
* keep the fix narrow and explicit

Tests

Update/add focused tests verifying:

* importer no longer queries nonexistent message.chat_id
* imported rows preserve source_sender_handle_rowid
* imported rows safely preserve NULL source_chat_rowid
* polling/import convergence works again
* no execution behavior regressions

Verification

Run:

* dart analyze on changed files
* focused importer/orchestrator tests

Please also report:

* exact query change made
* whether any other inferred source fields were discovered
* whether the importer now aligns with the new source-contract docs
```

---

Fixed the MessageImporter source-schema failure narrowly.

Exact query change:

Removed chat_id AS source_chat_rowid from the chat.db.message SELECT.
The query now reads only:
ROWID AS source_rowid
handle_id AS source_sender_handle_rowid
guid
service
is_from_me
text
Import behavior change:

source_sender_handle_rowid is still preserved from message.handle_id.
source_chat_rowid is now explicitly written as null.
No chat topology is fabricated or inferred.
Test update:

The focused importer test now creates a source message table with no chat_id column.
It verifies import succeeds, source_sender_handle_rowid == 42, and source_chat_rowid == null.
Other inferred source fields discovered:

None in this importer during this pass. The remaining queried fields are direct message fields.
Verification passed:

dart analyze on message_importer.dart, importer test, and import orchestrator test
focused flutter test for importer and ShadowImportExecutionOrchestrator
This now aligns with the new source-contract docs: message chat membership remains absent until a future explicit chat_message_join topology-preserving importer exists.

2 files changed
+8
-13
Undo

Review

lib/essentials/incremental_update/application/messages/executors/message_importer.dart
test/essentials/incremental_update/application/messages/executors/message_importer_test.dart
