---
tier: project
scope: macos-source-databases
owner: agent-per-project
last_reviewed: 2026-04-21
source_of_truth: doc
links:
  - ./README.md
  - ./10-chat-db-orphan-messages.md
  - ./20-external-tools-and-rust-crates.md
  - ./apple-typedstream-format-reference.md
  - ../10-DATABASES/04-db-chat.md
tests: []
---

# macOS Source Database Overview

The app’s import pipeline depends on Apple-managed sqlite databases whose internal data model is richer and messier than the app’s thread-oriented projection model.

This document explains source-database interpretation only. Source observations describe what has been seen in Apple-owned data; they do not guarantee future source behavior or define durable MessageLens semantics. The current MessageLens pipeline is documented in `../10-DATABASES/`, `../20-DATA-IMPORT-MIGRATION/`, and `../25-ONBOARDING-AND-ARCHIVE/`; do not use this source overview to bypass those database, migration, or archive boundaries.

## Current Focus

The most important source database is:

- `~/Library/Messages/chat.db`

This database contains:

- chats and chat membership (`chat`, `chat_handle_join`)
- handles (`handle`)
- message rows (`message`)
- chat linkage (`chat_message_join`)
- attachment linkage (`attachment`, `message_attachment_join`)

`chat.db` does not contain MessageLens working `participants`. Participants are a working-db projection built during migration from source handles, AddressBook-derived contact data, and handle-to-participant mapping logic.

## Key Insight

`chat.db` is not equivalent to “messages currently visible in the Messages app conversation list”.

Direct inspection in this repository showed that `chat.db` contains a substantial orphan message population:

- records present in `message`
- often linked to real handles
- often carrying plain text, rich text blobs, or attachment joins
- but lacking a `chat_message_join` row

These observations justify importer coverage and diagnostics. They are not schema guarantees; the durable meaning of imported data is established only after the import pipeline classifies and preserves it.

That means source truth in `chat.db` must be treated as:

- richer than a thread-linked-only projection model
- potentially more complete than thread-linked views
- internally inconsistent from the perspective of a simple `message -> chat` assumption

## Design Implication

When MessageLens flags, quarantines, or displays a source record outside the normal timeline, that must be an explicit product decision, not an accidental consequence of assuming Apple’s schema is perfectly normalized.

## Current App Mapping

The current pipeline preserves source shape while separating thread-linked and recovered content:

1. `chat.db.message` rows with a `chat_message_join` mapping are imported into `macos_import.db.messages`.
2. `chat.db.message` rows without a `chat_message_join` mapping are imported into `macos_import.db.recovered_unlinked_messages`.
3. `message_attachment_join` rows are split into `message_attachments` or `recovered_unlinked_message_attachments` according to the imported message path.
4. Migration projects normal rows into working `messages` / `attachments` and recovered rows into working `recovered_unlinked_messages` / `recovered_unlinked_attachments`.
5. The UI must keep recovered-unlinked content visibly distinct from normal chat timelines unless a future documented migration boundary changes that contract.

Do not fabricate normal chat membership for source rows that lack `chat_message_join`. Preserving the absence of topology is part of the data model.

## Attachment Path Semantics

Apple `attachment.filename` is imported as MessageLens `local_path`. Treat it as a source path hint and audit value, not as durable availability:

- iCloud and macOS storage optimization may remove local files while leaving source rows and paths in `chat.db`.
- Attachment files may appear later, disappear later, or move according to Apple behavior outside MessageLens control.
- The app must render attachment records even when the file is unavailable.
- Durable attachment preservation belongs to the overlay-backed archive and deterministic recovery pipeline, not to the source path itself.

MessageLens never writes back to Apple’s Messages attachment directories.

## Ongoing Sync Boundary

`ChatDbChangeMonitor` reads `~/Library/Messages/chat.db` read-only and polls `MAX(ROWID)` from `message`. On change it runs incremental import, archives the imported attachment batch, runs incremental migration, and bumps message data version. It must not be treated as a source of presentation orchestration or as permission for feature code to open `chat.db` directly.

## Related Topics

- For orphan-source-message findings, see `10-chat-db-orphan-messages.md`.
- For `attributedBody` decoding, see `apple-typedstream-format-reference.md`.
- For external ecosystem tools that parse `chat.db`, see `20-external-tools-and-rust-crates.md`.
