# Source-Scoped SS Graph Checkpoint

## Purpose

This document records the current source-scoped graph architecture proven on branch `Ftr:ss-move`.

The purpose is to freeze the core rules before further implementation accumulates.

## Core Identity Rule

`ss_id` is the canonical working-row identity for source-derived projected rows.

It is derived from:

```text
(source_id, source_rowid)
```

using deterministic, collision-free integer packing.

`ss_id` is not a hash.

## Database Split

### `macos_import_ss.db`

The import database preserves source facts and provenance.

It may contain:

- `ss_id`
- `source_id`
- `source_rowid`
- source metadata
- `batch_id`

### `working_ss.db`

The working database contains the lean app graph.

It should not contain:

- `source_id`
- `source_rowid`
- `batch_id`

Those stay in the import ledger.

## GUID Rule

GUIDs are metadata and bridge fields.

GUIDs are not canonical identity.

Do not use GUID uniqueness as a working-graph identity rule.

## Relationship Rule

Working graph relationships use `ss_id` endpoints.

Examples:

- `messages.sender_handle_ss_id`
- `messages.associated_message_ss_id`
- `chat_to_message.chat_ss_id`
- `chat_to_message.message_ss_id`
- `chat_to_handle.chat_ss_id`
- `chat_to_handle.handle_ss_id`

Source-local foreign keys are transformed into `ss_id` endpoints before entering `working_ss.db`.

## Group Chat Rule

Group-chat semantics are derived from topology.

Current rule:

```text
participant_count > 1
```

where participant count is derived from:

```text
working_ss.chat_to_handle
```

Do not import a fake `is_group` field from Apple `chat.db.chat`; no such source column exists.

## Current Proven SS Graph

The current proof graph includes:

- messages
- chats
- handles
- `chat_to_message`
- `chat_to_handle`

The graph has proven:

- incremental import
- working projection
- idempotence
- zero duplicate working edges
- chat summaries
- group-chat detection

## Current Architecture Summary

The current SS graph flow is:

```text
chat.db source facts
→ macos_import_ss.db source/provenance ledger
→ working_ss.db canonical app graph
```

The key simplification is:

```text
source-scoped occurrence identity survives projection unchanged
```

This avoids:

- GUID identity
- endpoint remapping
- canonical merge layers
- source ROWID collisions

Semantic grouping, deduplication, contact matching, and polished UX remain future layers above the SS graph.
