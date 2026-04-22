---
tier: project
scope: databases
owner: agent-per-project
last_reviewed: 2026-04-21
source_of_truth: doc
links:
       - ./00-all-databases-accessed.md
       - ./01-db-import.md
       - ./02-db-working.md
       - ./03-db-address-book.md
       - ./04-db-chat.md
       - ./05-db-overlay.md
       - ./07-overlay-database-independence.md
       - ./11-contact-to-chat-linking.md
       - ../20-DATA-IMPORT-MIGRATION/20-migration-orchestrator.md
       - ../20-DATA-IMPORT-MIGRATION/10-import-orchestrator.md
tests: []
---

# `group-import-working-db` — Import Ledger ↔ Working Projection Contract

`db-import` and `db-working` operate as a tightly coupled pipeline. This document captures the non-negotiable rules governing how data flows from macOS sources into the app projection.

## 1. Source → Import → Working Flow

```
macOS AddressBook (db-address-book)
            +
 macOS Messages (db-chat)
            ↓  import orchestrator
     db-import (source-derived ledger)
            ↓  migration orchestrator
     db-working (projection for UI)
```

- **Import orchestrator** (`../20-DATA-IMPORT-MIGRATION/10-import-orchestrator.md`) copies source-derived data into `db-import`, preserving source identifiers and batch metadata.
- **Migration orchestrator** (`../20-DATA-IMPORT-MIGRATION/20-migration-orchestrator.md`) projects ledger tables into Drift models with UI-friendly indexing.

## 2. ID Preservation Rules (**Do Not Break**)

1. **Contact IDs** (`Z_PK`) from AddressBook become `participants.id` in `db-working`. No remapping, no new sequences.
2. **Handle IDs** from the Messages ledger are mapped through `MigrationContext.handleIdCanonicalMap`; canonical rows use a stable source handle ID, and every raw source handle is preserved in `handles_canonical_to_alias`.
3. **Chat GUIDs / IDs** from Messages remain identical throughout ledger and projection tables.
4. **Message GUIDs / ROWIDs** remain traceable in `db-working.messages`; source rows without chat-message joins use the recovered-unlinked path.

If a proposed change requires remapping IDs outside the documented canonical handle map, stop and revisit this contract. Undocumented remapping introduces data drift and breaks downstream joins. See `./11-contact-to-chat-linking.md` for an end-to-end walkthrough of the contact → chat relationship.

## 3. Table Mapping Snapshot

| Working Table | Source Table | Notes |
| --- | --- | --- |
| `handles_canonical` | `db-import.handles` | Canonicalization groups raw handles and chooses a stable source handle ID for each canonical row. |
| `handles_canonical_to_alias` | Canonical map derived during migration | Records every raw source handle variant pointing to the canonical ID. |
| `participants` | `db-import.contacts` | Uses original AddressBook `Z_PK`. Drift class name: `WorkingParticipants`. |
| `handle_to_participant` | `db-import.contact_to_chat_handle` | Links canonical handles to participants with confidence scores. |
| `chat_to_handle` | `db-import.chat_to_handle` | Rebuilds memberships using the same handle IDs. |
| `messages` | `db-import.messages` | Preserves GUIDs/ROWIDs; adds derived columns only. |
| `recovered_unlinked_messages` | `db-import.recovered_unlinked_messages` | Preserves source rows that are not linked through normal chat-message joins. |
| `attachments` / `recovered_unlinked_attachments` | `db-import.attachments` plus normal/recovered attachment joins | Preserves attachment source identity and separates normal chat-linked rows from recovered rows. |
| `read_state` / `message_read_marks` | `db-import.messages` | Projects read timestamps and message-level read markers. |
| `global_message_index` / `message_index` / `contact_message_index` | Built from `db-working.messages` and related joins | Rebuilt after migration for timeline and search access. |

## 4. Lifecycle Expectations

- **Import ledger is importer-owned**: Runtime features never mutate `db-import`. Incremental import preserves prior rows; full/reimport flows may clear and rebuild source-derived ledger tables through import code while preserving import metadata.
- **Projection is disposable but mode-aware**: Full migration may clear and rebuild target tables; incremental migration skips truncation and applies migrator-specific insert/update semantics.
- **Write policy**: Runtime features never mutate `db-import`. Durable user intent never writes to `db-working`; provider-layer merges must respect the overlay independence rules.

## 5. Current Import Reality: Source Message Orphans

The macOS source database may contain `message` rows that do not appear in `chat_message_join`. MessageLens now preserves those rows on a dedicated recovered path rather than leaving them outside the app's data model.

- `chat.db.message` count can exceed thread-linked `db-import.messages`
- the orphan portion should appear in `db-import.recovered_unlinked_messages`
- migration should carry that preserved orphan set forward into `db-working.recovered_unlinked_messages`
- audit logs should distinguish thread-linked counts from recovered preserved counts

This is the practical implication of the current Apple data shape: source visibility in `chat.db.message` and thread visibility via `chat_message_join` are not the same thing.

## 6. Debugging Checklist

1. Confirm the row exists in `db-import` before suspecting migration bugs.
       For source orphan rows, check both `messages` and `recovered_unlinked_messages`.
2. Verify the corresponding row in `db-working` retains the same ID.
       For recovered rows, check `recovered_unlinked_messages` and `recovered_unlinked_attachments` rather than normal chat-linked tables.
3. Check `handle_to_participant` and `chat_to_handle` join paths using the preserved IDs.
4. Re-run the migration orchestrator if the projection is stale or corrupted.
5. Inspect `import_log` and `migrate_log` before manual SQL diffing; they already report source-vs-ledger-vs-working row deltas, text counts, and join-drop diagnostics.
6. If IDs differ at any step, halt—someone attempted to remap during migration.

## 7. Related Documents

- `01-db-import.md` — Ledger details and provider access.
- `02-db-working.md` — Projection schema and usage.
- `./11-contact-to-chat-linking.md` — Deep dive into handle/contact/chat linking.
- `../20-DATA-IMPORT-MIGRATION/02-import-migration-schema-reference.md` — Table-level schema definitions.
