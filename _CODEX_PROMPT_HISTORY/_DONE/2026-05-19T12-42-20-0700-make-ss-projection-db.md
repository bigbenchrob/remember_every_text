---
created_at: 2026-05-19T12:42:20-07:00
title: "Make ss projection db"
tags: []
source: codex_prompt_history.html
---

# Make ss projection db

## Prompt

```text
Copy this into Codex:

Implement the first working_ss.db projection proof for messages.
Context:
We are on branch Ftr:ss-move.
The new isolated proof area is:
lib/essentials/incremental_update_ss/
The first source-scoped import proof exists or is being finalized:
- macos_import_ss.db
- messages table
- SourceScopedRowKey
- MessageImporter
Architecture rule:
SourceScopedRowKey is canonical working-row identity for source-derived projected rows.
Goal:
Create the smallest possible working projection proof:
macos_import_ss.db.messages
→ working_ss.db.messages
The purpose is to prove that ss_id survives projection unchanged.
Scope:
- messages only
- no handles table yet
- no chats table yet
- no topology
- no polling
- no StageController
- no dev panel
- no integration with existing incremental_update/
- no GUID remapping
- no canonicalization
- no dedupe
- no relationship projection
Implement:
1. working_ss.db provider
Location:
lib/essentials/incremental_update_ss/infrastructure/working_database_provider.dart
Create working_ss.db with only:
CREATE TABLE messages (
  ss_id INTEGER PRIMARY KEY,
  guid TEXT,
  sender_handle_ss_id INTEGER,
  is_from_me INTEGER NOT NULL CHECK (is_from_me IN (0, 1)),
  date_utc TEXT,
  text TEXT,
  attributed_body_blob BLOB,
  associated_message_guid TEXT,
  thread_originator_guid TEXT,
  reply_to_guid TEXT
);
2. Message projector
Location:
lib/essentials/incremental_update_ss/application/messages/message_projector.dart
Responsibilities:
- read from macos_import_ss.db.messages
- write to working_ss.db.messages
- preserve ss_id unchanged
- insert only the fields present in working_ss.db.messages
- be idempotent
- do not use guid for identity
- do not perform remapping
- do not alter import DB
3. Tests
Add focused tests for:
- working_ss.db schema creation
- projection inserts messages
- projection preserves ss_id exactly
- projection is idempotent
- duplicate guid values do not block projection if ss_id differs
- working table does not contain source_id or source_rowid
4. Optional tiny diagnostic helper if easy
A simple read/query helper is acceptable if useful for tests, but do not add UI.
Verification:
- dart analyze on changed files
- focused tests only
Response style:
Keep response under 12 lines.
Report only:
- files added/changed
- schema created
- tests run
- blockers if any
```
