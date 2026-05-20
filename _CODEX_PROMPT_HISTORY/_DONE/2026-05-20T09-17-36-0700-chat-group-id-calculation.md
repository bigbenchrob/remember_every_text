---
created_at: 2026-05-20T09:17:36-07:00
title: "chat group_id calculation"
tags: []
source: codex_prompt_history.html
---

# chat group_id calculation

## Prompt

```text
Use this prompt:

Refine SS chat schema/import/projection semantics.
Context:
We are on branch Ftr:ss-move in the isolated source-scoped proof area:
lib/essentials/incremental_update_ss/
Current issue:
The SS chat importer/schema currently includes an `is_group` field sourced from `row['is_group']`, but Apple `chat.db.chat` has no `is_group` column. `_boolInt(row['is_group'])` is silently masking this by converting NULL/missing input to 0.
That is wrong.
Architecture rule:
- import_ss.db preserves source facts/provenance
- working_ss.db stores app-ready canonical graph semantics
- SourceScopedRowKey is canonical working row identity
- source-local relationship endpoints project to ss_id endpoints
Required changes:
1. Remove ersatz import `is_group`
Remove `is_group` from:
- macos_import_ss.db.chats schema
- chat import insert logic
- any import_ss chat tests expecting it
Do not derive `is_group` inside the importer.
2. Preserve real Apple group metadata in import_ss.chats
Add these source fields to macos_import_ss.db.chats:
```sql
group_id TEXT,
original_group_id TEXT

Import them directly from Apple chat.db.chat:

chat.group_id
chat.original_group_id

These are source metadata/provenance, not canonical app identity.

Keep/import these chat fields:

ss_id INTEGER PRIMARY KEY,
source_id INTEGER NOT NULL,
source_rowid INTEGER NOT NULL,
guid TEXT NOT NULL,
service TEXT,
group_id TEXT,
original_group_id TEXT,
last_read_message_at_utc TEXT,
batch_id INTEGER NOT NULL,
UNIQUE(source_id, source_rowid)

Keep a non-unique index on guid if already present.

Do not add display_name.

3. Keep working_ss.chats.is_group, but derive it

working_ss.db.chats should keep:

is_group INTEGER NOT NULL CHECK (is_group IN (0, 1))

But this is an app semantic field, not a source field.

Derive it during projection.

Preferred derivation for this slice:

is_group = true when chat has more than one associated handle in source chat_handle_join

Use Apple source topology if available:

SELECT COUNT(*)
FROM chat_handle_join
WHERE chat_id = ?

Then:

handle_count > 1 → is_group = 1
else → is_group = 0

If current projection code cannot easily access live chat.db, use a very small focused helper/query. Do not invent Apple columns.

4. Keep working_ss.chats lean

Working schema should be conceptually:

CREATE TABLE chats (
  ss_id INTEGER PRIMARY KEY,
  guid TEXT,
  service TEXT,
  is_group INTEGER NOT NULL CHECK (is_group IN (0, 1)),
  last_read_message_at_utc TEXT
);

No:

* source_id
* source_rowid
* group_id
* original_group_id
* batch_id
* display_name

Those belong in import_ss or are dropped.

5. Tests

Add/update focused tests for:

* import_ss.chats no longer has is_group
* import_ss.chats preserves group_id and original_group_id
* chat importer does not read row[‘is_group’]
* working_ss.chats has derived is_group
* is_group is 1 when source chat_handle_join has more than one handle
* is_group is 0 when source chat_handle_join has one or zero handles
* projection preserves chat ss_id unchanged
* projection remains idempotent

6. Constraints

Do NOT:

* chase Apple secret group codes
* parse chat.properties
* use guid pattern as the primary group rule
* use group_id as app identity
* add display_name
* add broad abstractions
* change message import/projection
* change topology projection beyond what is necessary for chat is_group derivation

Do:

* fix the masked nonexistent-column bug
* preserve meaningful source group metadata
* derive app group semantics from participant topology
* keep the SS schemas lean

Verification:

* dart analyze on changed files
* focused SS chat/import/projection tests

Response style:
Keep response under 12 lines.
Report only:

* files changed
* schema changes
* import/projection changes
* tests run
* blockers if any
```
