---
created_at: 2026-05-20T07:31:08-07:00
title: "Refine chat table schema"
tags: []
source: codex_prompt_history.html
---

# Refine chat table schema

## Prompt

```text
Refine the SS chat schemas to align with the finalized source-scoped architecture.

Context

The message schemas now follow the correct architectural split:

import_ss.db
= provenance + source facts
working_ss.db
= canonical app graph

chats should now follow the same pattern.

Current issue

macos_import_ss.db.chats currently contains only:

ss_id
guid
display_name

This is inconsistent with the finalized import-ledger philosophy.

Also, display_name appears mostly NULL in real data and does not appear to carry meaningful canonical identity semantics.

Goal

Refine the chat schemas to mirror the message architecture.

Requested changes

1. Refine macos_import_ss.db.chats

Replace the current schema with something conceptually like:

CREATE TABLE chats (
  ss_id INTEGER PRIMARY KEY,
  source_id INTEGER NOT NULL,
  source_rowid INTEGER NOT NULL,
  guid TEXT NOT NULL,
  service TEXT,
  is_group INTEGER NOT NULL CHECK (is_group IN (0, 1)),
  last_read_message_at_utc TEXT,
  batch_id INTEGER NOT NULL,
  UNIQUE(source_id, source_rowid)
);
CREATE INDEX idx_chats_guid ON chats(guid);

Notes:

* keep guid as provenance/interop metadata only
* do NOT make guid UNIQUE
* preserve source_id/source_rowid in import ledger
* use existing date conversion utilities if already available
* derive is_group appropriately from Apple chat schema if available

2. Remove display_name

Drop:

display_name

from import_ss and working_ss unless there is demonstrated meaningful populated behavior.

Current evidence suggests it is mostly NULL/noise.

3. Refine working_ss.db.chats

Working projection should become lean:

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
* batch_id

Those belong only in import_ss.

4. Projection behavior

Projection should:

* preserve ss_id unchanged
* preserve guid only as metadata/bridge field
* not use guid as canonical identity
* remain idempotent

5. Tests

Add/update focused tests for:

* import chat schema creation
* working chat schema creation
* source_id/source_rowid preserved in import_ss
* source_id/source_rowid absent from working_ss
* guid not UNIQUE
* projection preserves ss_id
* projection remains idempotent

Constraints

Do NOT:

* redesign topology
* redesign chat projection architecture
* add new abstractions
* add polling complexity
* introduce canonical remapping

Do:

* align chats with finalized SS architecture
* keep schemas lean
* preserve provenance correctly
* maintain occurrence-preserving identity model

Response style

Keep response under 12 lines.

Report only:

* files changed
* schema changes
* projection changes
* tests run
* blockers if any
```
