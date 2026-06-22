---
tier: project
scope: databases
owner: agent-per-project
last_reviewed: 2026-06-20
source_of_truth: doc
links:
  - ./00-all-databases-accessed.md
  - ./01-db-import.md
  - ./10-group-import-working.md
  - ../15-MACOS-SOURCE-DATABASES/00-overview.md
  - ../15-MACOS-SOURCE-DATABASES/10-chat-db-orphan-messages.md
  - ../20-DATA-IMPORT-MIGRATION/02-import-migration-schema-reference.md
tests: []
---

# `db-chat` — macOS Messages Source (`chat.db`)

`db-chat` is Apple Messages' live sqlite database. It provides chat, handle, attachment, and message source data that seeds the source-scoped import ledger and conversation graph.

- **Alias**: `db-chat`
- **Physical File**: `~/Library/Messages/chat.db`
- **Primary Consumer**: Source-scoped import and monitor infrastructure (read-only)

## Location & Access

| Item | Value |
| --- | --- |
| Path | `~/Library/Messages/chat.db` |
| Access pattern | Resolved via `PathsHelper.messagesDatabasePath` inside the import infrastructure |
| Permissions | Requires Full Disk Access |

Feature and presentation code must not open `chat.db` directly. The import and monitoring infrastructure opens it read-only through `PathsHelper` to detect new rows and copy source data into `db-import-ss`, where graph projectors can safely project it forward. Named archive/recovery workflows may also open selected historical `chat.db` snapshots read-only; that access must remain a recovery boundary, not an ordinary feature read.

## Important Reality Check

Direct source-db inspection showed that `chat.db` contains a substantial population of message rows that are not linked by `chat_message_join`.

These orphan rows can still contain:

- plain text
- `attributedBody` rich text blobs
- attachment joins
- real handle linkage

Do not assume `message` plus `chat_message_join` gives a complete picture of all potentially meaningful source content. See `../15-MACOS-SOURCE-DATABASES/10-chat-db-orphan-messages.md`.

## Tables Consumed During Import

| Table | Purpose |
| --- | --- |
| `chat` | Chat metadata, GUIDs, style, service. |
| `handle` | Raw handle records (phone/email/service tuples). |
| `chat_handle_join` | Many-to-many linkage between chats and handles. |
| `message` | Message payloads, GUIDs, timestamps, delivery info. |
| `chat_message_join` | Mapping needed to associate messages with chats. |
| `attachment` / `message_attachment_join` | Attachments tied to messages. |

Source-scoped importers persist these tables into ledger equivalents (`chats`, `handles`, `messages`, recovered/orphan message facts, `chat_to_handle`, `chat_to_message`, `attachments`, `message_attachments`) while preserving source identifiers and deriving canonical `ss_id` endpoints for graph projection. Retired historical `db-import` files may contain equivalent facts from the retired importer era, but they are cleanup inventory only and must not be treated as an active compatibility import path.

## Usage Rules

1. **Never mutate** `chat.db`. Copy data into source-scoped import and operate on the ledger/graph instead.
2. **Respect ROWIDs/GUIDs**: Preserve source facts and derive `ss_id` from source IDs; GUIDs remain metadata/bridge fields, not canonical identity.
3. **WAL discipline**: Close all application handles before running manual SQLite tooling to avoid write-ahead-log conflicts.
4. **Testing**: Provide fixture copies of `chat.db` when exercising import logic; avoid touching the live file in automated tests.

## Cross-References

- `00-all-databases-accessed.md` — Current source-scoped graph and retired storage aliases.
- `01-db-import.md` — Retired import ledger schema seeded from `chat.db`.
- `10-group-import-working.md` — Retired import/working contract and source-scoped replacement note.
- `../20-DATA-IMPORT-MIGRATION/02-import-migration-schema-reference.md` — Retired ledger table definitions.
- `../15-MACOS-SOURCE-DATABASES/README.md` — Source-database behavior and reverse-engineering notes.
