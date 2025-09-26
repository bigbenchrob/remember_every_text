# Import DB Notes — iMessage Ingest Ledger

**Purpose:** A faithful, minimally normalized snapshot of macOS `chat.db` + AddressBook used as the immutable ingest ledger.
Keep provenance (`source_rowid`, `guid`) and batch tracking for deterministic re-projection.

## Key Entities

- `contacts`, `contact_channels` — optional AddressBook snapshot.
- `handles` — iMessage/SMS identities (service + address).
- `chats` and `chat_participants` — conversations and their members.
- `messages` — all messages (system, tapback carriers, stickers, etc.).
- `attachments` + `message_attachments` — files linked to messages.
- `reactions` — normalized tapbacks parsed from carrier messages.

## Batches & Provenance

- Every import run produces an `import_batches` row; all data rows should be traceable to a `batch_id`.
- Preserve Apple identifiers via `guid` and `source_rowid` where available.

## Mapping from macOS chat.db

- `handle` → `handles`
- `chat` → `chats`
- `chat_handle_join` → `chat_participants`
- `message` → `messages` (convert Apple epoch to UTC ISO8601)
- `attachment` → `attachments`
- `message_attachment_join` → `message_attachments`
- Reactions are parsed from special messages with `associated_message_guid`

## Agent Instructions

1. Upsert `chats` and `messages` by `guid` (unique).
2. Store `attributed_body_blob` raw; decoding happens later.
3. Normalize phone/email into `handles.normalized_address` (E.164/lowercase).
4. Maintain `batch_id` on all imported rows.
5. Optionally keep `chat_message_join_source` for audit reproducibility.
