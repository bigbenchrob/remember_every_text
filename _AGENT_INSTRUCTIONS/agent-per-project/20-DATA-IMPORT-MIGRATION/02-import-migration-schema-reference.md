---
tier: project
scope: data-import-migration
owner: agent-per-project
last_reviewed: 2026-04-21
source_of_truth: code
links:
  - ./01-overview.md
  - ./10-import-orchestrator.md
  - ./20-migration-orchestrator.md
  - ../10-DATABASES/00-all-databases-accessed.md
  - ../10-DATABASES/01-db-import.md
  - ../10-DATABASES/02-db-working.md
  - ../10-DATABASES/10-group-import-working.md
  - ../10-DATABASES/11-contact-to-chat-linking.md
tests: []
---

# Database Schema Reference

Authoritative table lists for the import and working SQLite databases this project maintains. Consult this note before running ad-hoc SQL or modifying importers/migrators.

## Boundary Summary

- `macos_import.db` is the source-derived import ledger. It records batches, source file provenance, imported source rows, recovered unlinked rows, and import diagnostics. It is mutated only by import code.
- `working.db` is the runtime projection consumed by providers, search/index rebuilds, and rendering. It is rebuilt from the import ledger by migration code.
- `user_overlays.db` is outside this folder's schema list. It stores durable user intent and archive/recovery metadata; import and migration must not move user intent into `working.db`.

## macos_import.db (Ingest Ledger)

Location: `~/Library/Application Support/com.bigbenchsoftware.MessageLens/macos_import.db`
Schema source: `lib/essentials/db/infrastructure/data_sources/local/import/sqflite_import_database.dart`

| Table | Purpose / Notes |
| ----- | --------------- |
| `schema_migrations` | Applied sqflite migration versions. |
| `import_batches` | Provenance for each ingest run (source paths, timestamps). |
| `source_files` | Checksums and metadata for every imported source file. |
| `import_logs` | Structured log events captured during ingest. |
| `contacts` | AddressBook `ZABCDRECORD` projection (preserves `Z_PK`). |
| `contact_phone_email` | Normalised phone/email values linked by `ZOWNER`. |
| `contact_to_chat_handle` | AddressBook/contact-channel matches to imported chat handles. |
| `handles` | Raw chat.db handles (`ROWID` preserved in `id`). |
| `chats` | Raw chat.db chats (`ROWID` preserved). |
| `chat_to_handle` | Bridge joining chats and handles (chat_handle_join). |
| `messages` | Full message rows including attributed bodies. |
| `recovered_unlinked_messages` | Source `message` rows that survive in `chat.db` but are not linked through `chat_message_join`. |
| `chat_to_message` | Chat and message join table (mirrors Apple linking). |
| `attachments` | Attachment metadata imported from chat.db. |
| `message_attachments` | Join table linking messages and attachments. |
| `recovered_unlinked_message_attachments` | Join table linking recovered unlinked messages to attachments. |
| `reactions` | Parsed tapback events (carrier and target metadata). |
| `message_links` | Extracted URL spans from messages. |

### Ledger Rules of Thumb
- Treat imported data as source-derived, not user-editable. Full/reimport flows may clear and rebuild ledger tables through `ClearLedgerImporter`; incremental flows preserve prior imported rows and add new rows by high-water marks.
- Always insert within a recorded `import_batches` row so provenance is traceable.
- Before attaching this database in external tools, stop the Flutter app to avoid locking conflicts.

## working.db (Projection / Runtime)

Location: `~/Library/Application Support/com.bigbenchsoftware.MessageLens/working.db`
Schema source: `lib/essentials/db/infrastructure/data_sources/local/working/working_database.dart`

| Table | Purpose / Notes |
| ----- | --------------- |
| `schema_migrations` | Drift migration history. |
| `projection_state` | Singleton row tracking last projected batch and cursors. |
| `app_settings` | Key/value pairs for runtime configuration. |
| `handles_canonical` | Future-facing canonical handle store (one per endpoint). |
| `participants` | Contacts/participants that appear in conversations. Drift class name is `WorkingParticipants`, but the SQL table is `participants`. |
| `handle_to_participant` | Confidence-scored mapping of handles and participants. |
| `handles_canonical_to_alias` | Alias records linking raw handles to canonical entries. |
| `chat_to_handle` | Chat membership resolved to canonical handles. |
| `chats` | Conversation metadata for presentation (last message, counts). |
| `messages` | Fully normalised message timeline consumed by widgets. |
| `recovered_unlinked_messages` | Projected recovered source rows kept separate from normal chat timelines. |
| `global_message_index` | Stable ordinal index across all messages. |
| `message_index` | Per-chat/per-message ordinal index used by timeline queries. |
| `contact_message_index` | Per-contact message ordinal index. |
| `attachments` | Projected attachment metadata (paths, hashes, direction). |
| `recovered_unlinked_attachments` | Projected attachment metadata for recovered unlinked messages. |
| `reactions` | Canonicalised reactions linked to handle IDs. |
| `reaction_counts` | Cached tallies per message for quick display. |
| `read_state` | Chat-level read markers. |
| `message_read_marks` | Per-message read receipts. |
| `supabase_sync_state` | Checkpoints for outbound sync processes. |
| `supabase_sync_logs` | Audit log for sync attempts. |

### Projection Rules of Thumb
- Population is deterministic from `macos_import.db`. Full migration clears migrator target tables before projection; incremental migration skips truncation and relies on migrator-specific insert/update semantics.
- Never modify rows manually; instead adjust the corresponding migrator and re-run projection.
- Any schema change must be reflected here and in the Drift definitions inside `working_database.dart`.

## Quick Checks
- Need table DDL? Run `dart run drift_dev schema dump` or inspect the schema files listed above.
- Unsure if a column exists? Search in the schema source files rather than guessing - both databases are versioned and enforced by migrations.
- See `./20-migration-orchestrator.md` for operational steps before and after schema changes.
