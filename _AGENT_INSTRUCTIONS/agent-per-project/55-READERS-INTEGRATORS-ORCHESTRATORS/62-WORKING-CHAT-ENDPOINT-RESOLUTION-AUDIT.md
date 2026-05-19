# 62 - Working Chat Endpoint Resolution Audit

## Purpose

This document records the current working-chat endpoint audit after adopting `SourceScopedRowKey` as canonical working-row identity for source-derived projected rows.

The earlier `ledger chat → working chat` GUID-resolution framing is superseded.

Current rule:

```text
working.chats.id = chat_source_scoped_row_key
```

for source-derived projected chat rows.

---

## Current Observed State

Read-only local audit of the current shadow databases showed:

```text
working_shadow.db.chats
  total rows: 1
  only row:
    id = -1
    guid = __shadow_incremental_update_placeholder_chat__
    service = Unknown

working_shadow.db.messages
  total rows: 132412
  distinct chat_id values: 1
  min chat_id = -1
  max chat_id = -1

macos_import_shadow.db.chats
  source-backed live-chat-db rows: 241

macos_import_shadow.db.chat_message_joins
  source-backed live-chat-db topology rows: 111728

bounded topology projection preview
  missingWorkingChat: 250
```

Interpretation:

- source chats have been imported into the shadow ledger
- source topology has been imported into the shadow ledger
- working messages have been migrated
- source-derived working chats have not yet been projected
- every shadow working message currently points to the placeholder chat

The preview result is expected.

---

## Working Chat Schema

`working_shadow.db.chats` uses the existing `WorkingChats` schema:

```text
id
guid
service
is_group
last_message_at_utc
last_sender_handle_id
last_message_preview
unread_count
pinned
archived
muted_until_utc
favourite
created_at_utc
updated_at_utc
is_ignored
```

Current uniqueness:

```text
UNIQUE(guid)
```

The source-scoped identity direction means `id` should become the source-derived endpoint identity for projected source chats:

```text
id = chat_source_scoped_row_key
```

`guid` remains source metadata and possible semantic grouping input. It is not the base endpoint identity.

---

## Placeholder Chat Meaning

The placeholder chat enters the shadow working projection in `ShadowMessageMigrationExecutor`.

It exists only to satisfy the current `messages.chat_id → chats.id` foreign key while message migration remains intentionally narrow.

It is not:

- source truth
- source topology evidence
- a source-derived chat
- a valid resolved endpoint for source topology

Future removal or bypass should happen only after:

- source-derived working chats exist
- source-derived working messages use source-scoped ids
- topology endpoint preview resolves
- relationship projection no longer relies on placeholder chat identity

---

## Ledger Chat Facts

The shadow ledger `chats` table currently preserves source-backed rows with:

```text
id
source_rowid
source_id
source_kind
guid
service
display_name
created_at_utc
updated_at_utc
batch_id
```

Useful source-derived endpoint coordinate:

```text
source_id + source_rowid
```

Projected working endpoint:

```text
chat_source_scoped_row_key = pack(source_id, source_rowid)
```

Metadata such as `guid`, `service`, `display_name`, `created_at_utc`, and `updated_at_utc` may be preserved and used for diagnostics, display, or semantic grouping. It must not replace the endpoint identity.

---

## SourceScopedRowKey Revision

This audit originally evaluated endpoint resolution through:

```text
ledger chat guid → working chat guid
```

and possible source-to-working mapping tables.

That approach is superseded for ordinary source-derived endpoints.

The projected working chat endpoint for a source chat row should be:

```text
working.chats.id = chat_source_scoped_row_key
```

not:

```text
ledger chat guid → working chat guid
```

and not:

```text
source_id + source_chat_rowid → mapping table → working_chat_id
```

as the ordinary endpoint identity path.

---

## Join Endpoint Projection Implication

Once source-derived working chats and messages use `SourceScopedRowKey` ids, source-local topology can project mechanically.

Source topology:

```text
source_id = 2
source_chat_rowid = 7
source_message_rowid = 42
```

Working topology:

```text
chat_id = pack(2, 7)
message_id = pack(2, 42)
```

This restores the single-source simplicity:

```text
source relationships are already correct
```

while making endpoints multi-source-safe.

---

## Recommended Next Slice

Recommended next code slice:

```text
read-only SourceScopedRowKey endpoint projection preview
```

The preview should compute, without mutation:

```text
source chat row → chat_source_scoped_row_key
source message row → message_source_scoped_row_key
source relationship row → projected endpoint pair
```

and report whether those source-scoped working endpoint rows exist.

If mutation is chosen after that:

1. Add a narrow source-derived chat projection stage that writes `working.chats.id = chat_source_scoped_row_key`.
2. Keep placeholder chat behavior until source-derived message/chat endpoints are proven.
3. Project `chat_message_join` only after both endpoints exist.
4. Do not introduce semantic merge or canonical remapping behavior.

---

## Multi-Source Implications

Live and archive sources may contain:

- same source chat row IDs with different meanings
- same conversation represented by different chat GUIDs
- changed participants over time
- split or merged Apple source chat rows

Therefore:

- raw source row IDs cannot be working chat IDs
- GUID matching should not be endpoint identity
- semantic grouping should be observable above the base working row layer
- conflicts should not be hidden inside projection mutation

---

## Risks

- Copying legacy chat migration behavior directly may reintroduce single-source raw-id assumptions.
- Mapping by chat GUID alone may fail for archive/live divergence.
- Updating message `chat_id` before source-scoped endpoints are stable can hide unresolved topology defects.
- Removing the placeholder too early can destabilize message projection.

---

## Invariants

```text
Working chat endpoint projection must use SourceScopedRowKey, not raw source ROWID.
```

```text
Placeholder working chats must not satisfy source topology endpoint resolution.
```

```text
Working chat projection must preserve source occurrence identity directly.
```

```text
Topology relationship projection must wait until both message and chat endpoints are resolvable.
```
