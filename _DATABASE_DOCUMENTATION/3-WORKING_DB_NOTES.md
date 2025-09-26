# Working DB Notes — Projection Layer

**Purpose:** Fast, denormalized projection of chats and messages for the app UI.
Repositories target this DB; import and transformation logic live in services.

## Aggregates

- **Chats** and **Messages** are the only aggregates.
- Identities, participants, reactions, attachments are projections supporting the aggregates.

## Behaviors & Guarantees

- Triggers maintain `chats.last_message_at_utc`, `last_message_preview`, and `unread_count`.
- FTS5 virtual table `messages_fts` mirrors `messages(text)` with triggers.
- Reaction inserts automatically update `reaction_counts` and `messages.reaction_summary_json`.

## Agent Instructions

1. Upsert chats & messages by GUID.
2. Resolve `import.handles` → `identities` once; link via `identity_handle_links`.
3. Rebuild `chat_participants_proj` deterministically (stable `sort_key`).
4. After projecting a batch, update `projection_state` (`last_import_batch_id`).

## Generation

- Run `dart run build_runner build` to generate `*.g.dart` files for Drift.
