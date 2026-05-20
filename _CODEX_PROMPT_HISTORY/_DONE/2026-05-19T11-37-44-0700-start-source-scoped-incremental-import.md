---
created_at: 2026-05-19T11:37:44-07:00
title: "Start source scoped incremental import"
tags: []
source: codex_prompt_history.html
---

# Start source scoped incremental import

## Prompt

```text
We are going to set up a parallel incremental import flow to the incremental_import (shadow) flow, using revised database schemas and incorporating source scoped ids everywhere we  can. I have set up the folder here: lib/essentials/incremental_update_ss

First prompt:

Use this as the first Codex prompt:

Implement the first source-scoped import proof slice.
Context:
We are on branch Ftr:ss-move.
A new isolated proof area exists:
lib/essentials/incremental_update_ss/
Use production-shaped class/file names inside this folder. Do not prefix classes/files with Ss unless needed for temporary DB filenames.
Goal:
Create the first working macos_import_ss.db proof with messages only.
Scope:
- No integration with existing incremental_update/
- No changes to existing shadow pipeline
- No working_ss.db yet
- No polling
- No StageController
- No dev panel
- No topology projection yet
Implement:
1. SourceScopedRowKey helper
Location:
lib/essentials/incremental_update_ss/domain/source_scoped_row_key.dart
Requirements:
- deterministic collision-free packing of numeric source_id + source_rowid into one INTEGER
- documented bounds
- tests for uniqueness and basic packing behavior
- do not call this a hash
2. macos_import_ss.db provider
Location:
lib/essentials/incremental_update_ss/infrastructure/import_database_provider.dart
Create:
- source_registry
- import_batches
- messages
3. messages schema
Use:
CREATE TABLE messages (
  ss_id INTEGER PRIMARY KEY,
  source_id INTEGER NOT NULL,
  source_rowid INTEGER NOT NULL,
  guid TEXT NOT NULL,
  sender_handle_ss_id INTEGER,
  is_from_me INTEGER NOT NULL CHECK (is_from_me IN (0, 1)),
  date_utc TEXT,
  date_read_utc TEXT,
  date_delivered_utc TEXT,
  text TEXT,
  attributed_body_blob BLOB,
  associated_message_guid TEXT,
  thread_originator_guid TEXT,
  reply_to_guid TEXT,
  batch_id INTEGER NOT NULL,
  UNIQUE(source_id, source_rowid),
  UNIQUE(guid)
);
4. MessageImporter
Location:
lib/essentials/incremental_update_ss/application/messages/message_importer.dart
Responsibilities:
- read from Apple chat.db.message
- write to macos_import_ss.db.messages
- use source_id numeric 1 for live-chat-db for now
- ss_id = SourceScopedRowKey.pack(sourceId: 1, sourceRowId: message.ROWID)
- sender_handle_ss_id = pack(1, handle_id) when handle_id > 0, otherwise NULL
- convert Apple dates using existing project date conversion utility if available
- preserve only fields in the schema above
- be idempotent
- continue from MAX(source_rowid) WHERE source_id = 1
5. Tests
Add focused tests for:
- database schema creation
- SourceScopedRowKey packing
- importer inserts messages
- importer is idempotent
- source-scoped continuation ignores rows from another source_id
- sender_handle_ss_id is packed when handle_id > 0
- sender_handle_ss_id is null when handle_id is 0
Verification:
- dart analyze on changed files
- focused tests only
Response style:
Keep response under 12 lines.
Report:
- files added
- schema created
- tests run
- any blockers
```
