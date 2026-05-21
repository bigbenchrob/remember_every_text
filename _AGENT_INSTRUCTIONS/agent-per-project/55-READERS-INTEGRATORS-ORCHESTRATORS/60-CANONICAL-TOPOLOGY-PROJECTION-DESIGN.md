# 60 - Canonical Topology Projection Design

## Purpose

This document records the current design for projecting preserved Apple source topology into working projection topology.

It supersedes earlier endpoint-resolution options based on GUID matching, source-to-working mapping tables, or merge-collapsed canonical endpoints.

The current identity rule is defined in:

- [`64-SOURCE-SCOPED-ROW-KEY-STRATEGY.md`](64-SOURCE-SCOPED-ROW-KEY-STRATEGY.md)

Core rule:

```text
SourceScopedRowKey is the canonical working-row identity
for source-derived projected rows.
```

---

## Current Validated State

The shadow pipeline currently preserves source topology before migration/projection:

- `chat.db.chat_message_join` is observed as source topology.
- `macos_import_shadow.db.chat_message_joins` preserves source-scoped topology facts.
- `ChatMessageJoinImporter` imports topology rows idempotently and resumably.
- `ChatMessageJoinStageController` runs before message migration/projection in `PipelineOrchestrator`.

Relationship projection into `working_shadow.db` remains deferred.

---

## Source Topology Facts

The shadow ledger preserves `chat_message_join` as source truth.

Each ledger row represents a source-local relationship row:

```text
source_id
source_kind
source_rowid
source_chat_rowid
source_message_rowid
```

Meaning:

- `source_id` identifies the source database instance, such as `live-chat-db`.
- `source_kind` identifies the source type, such as `live_chat_db`.
- `source_rowid` is the source-local `chat_message_join.ROWID`.
- `source_chat_rowid` is the source-local `chat.ROWID`.
- `source_message_rowid` is the source-local `message.ROWID`.

---

## Projection Problem

In one source database, Apple relationship topology is already correct:

```text
chat_message_join.chat_id = chat.ROWID
chat_message_join.message_id = message.ROWID
```

Multiple sources break the raw-rowid shortcut because:

```text
source A rowid 42 != source B rowid 42
```

`SourceScopedRowKey` restores the same simplicity at a multi-source-safe level.

---

## Join Endpoint Projection Rule

Every source-local relationship endpoint must be transformed into the corresponding `SourceScopedRowKey` before entering working projection.

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

This applies to:

- `chat_message_join`
- `chat_handle_join`
- `message_attachment_join`
- message reply relationships
- message reaction relationships
- future topology tables

---

## Working Relationship Shape

The first source-derived working topology slice should prefer direct occurrence-preserving endpoint ids.

Example:

```text
working_chat_message_relationships
  chat_id
  message_id
  source_join_row_key
```

Where:

```text
chat_id = chat_source_scoped_row_key
message_id = message_source_scoped_row_key
source_join_row_key = chat_message_join_source_scoped_row_key
```

The exact table name and columns remain implementation details, but endpoint semantics should not vary.

---

## What This Avoids

This strategy avoids:

- canonical endpoint remapping layers
- relationship lookup tables for ordinary source-derived endpoints
- ambiguous projection joins
- source-collision bugs
- merge-collapse identity instability
- making GUIDs carry endpoint identity semantics

---

## Provenance

Provenance is preserved by construction.

Because endpoint ids are `SourceScopedRowKey` values, each working relationship endpoint remains traceable to:

```text
source_id
source_table
source_rowid
```

The relationship row itself should also remain traceable to the source relationship row when the source provides a stable row coordinate.

---

## Placeholder Chat Implication

The current shadow message migration path still uses a placeholder working chat:

```text
id = -1
guid = __shadow_incremental_update_placeholder_chat__
```

That placeholder is a structural shim only.

It must not satisfy source topology endpoint projection.

It can be removed or bypassed only after source-derived chat and message endpoints exist with `SourceScopedRowKey` ids.

---

## Semantic Grouping Is Above This Layer

A source-derived relationship projection may later be grouped, deduplicated, or interpreted by higher-level views.

Examples:

```text
logical_message_group_id
duplicate_cluster_id
semantic_merge_view
conversation_group_id
```

Those concepts must not replace occurrence-preserving endpoint ids.

---

## Recommended Next Slice

Recommended next implementation slice:

```text
read-only SourceScopedRowKey endpoint projection preview
```

The preview should compute:

```text
source chat row → chat_source_scoped_row_keyv
source message row → message_source_scoped_row_key
source relationship row → projected endpoint pair
```

and report whether those source-scoped working endpoint rows exist.

No mutation is required for that preview.

---

## Non-Goals

This design does not define:

- UI relationship behavior
- search relationship behavior
- semantic deduplication
- canonicalized conversation collapse
- attachment file archival behavior
- graph execution planning
- production promotion

---

## Invariants

```text
Working topology endpoints must be SourceScopedRowKey values.
```

```text
Source topology rows should project mechanically once their source-derived endpoints exist.
```

```text
Placeholder structural chats must not become source topology evidence.
```

```text
Semantic merge behavior must live above occurrence-preserving working topology.
```
