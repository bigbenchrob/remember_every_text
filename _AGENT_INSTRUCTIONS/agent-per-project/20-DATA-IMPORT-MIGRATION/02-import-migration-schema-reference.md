---
tier: project
scope: data-import-migration
owner: agent-per-project
last_reviewed: 2026-06-08
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

# Retained Legacy Database Schema Reference

Historical table lists for retained legacy import and working SQLite databases.
Consult this note when interpreting old user data folders or retained
diagnostics. Do not use it as an authoring guide for ordinary graph-era
features.

> Current conformance note (2026-06-08): ordinary app data now uses
> `macos_import_ss.db` and `working_ss.db` through the source-scoped
> conversation graph. Fresh `macos_import.db` files contain only
> `schema_migrations` and `historical_archive_sources`; retained `working.db`
> has no central app provider. The broader tables below may exist in historical
> user data folders only.

## Boundary Summary

- `macos_import_ss.db` is the production source-scoped import ledger for ordinary app data.
- `working_ss.db` is the production conversation graph projection consumed by graph readers and the Message Evidence Spine.
- `macos_import.db` is retained archive-source metadata storage in fresh
  graph-era files; old files may still contain historical ledger tables.
- `working.db` is retained file/schema storage only; old files may still contain
  historical projection tables.
- `user_overlays.db` stores durable user intent and archive/recovery metadata; neither graph projection nor retained legacy migration may move user intent into working tables.

## macos_import.db (Retained Legacy Ingest Ledger)

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
- Treat old imported data as historical source-derived inventory, not
  user-editable app truth.
- Do not add ordinary app features that depend on old retained ledger tables.
- Before attaching this database in external tools, stop the Flutter app to
  avoid locking conflicts.

## working.db (Retained Legacy Projection)

Location: `~/Library/Application Support/com.bigbenchsoftware.MessageLens/working.db`
Schema source: historical retained Drift schema, now removed from active app
code. Existing `working.db` files may still contain these tables.

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
| `global_message_index` | Retained legacy ordinal-index table. Ordinary global timeline navigation now uses graph evidence skeletons. |
| `message_index` | Retained legacy per-chat ordinal-index table. Ordinary conversation timelines now use graph evidence skeletons. |
| `contact_message_index` | Retained legacy per-contact ordinal-index table. Ordinary contact heatmaps/timelines now use graph evidence skeletons. |
| `attachments` | Projected attachment metadata (paths, hashes, direction). |
| `recovered_unlinked_attachments` | Projected attachment metadata for recovered unlinked messages. |
| `reactions` | Canonicalised reactions linked to handle IDs. |
| `reaction_counts` | Cached tallies per message for quick display. |
| `read_state` | Chat-level read markers. |
| `message_read_marks` | Per-message read receipts. |
| `supabase_sync_state` | Checkpoints for outbound sync processes. |
| `supabase_sync_logs` | Audit log for sync attempts. |

### Retained Projection Rules of Thumb
- Historical population was deterministic from `macos_import.db`. Full
  migration cleared migrator target tables before projection; incremental
  migration skipped truncation and relied on migrator-specific insert/update
  semantics.
- Never modify rows manually. If old retained storage needs recovery, design an
  explicit graph-era compatibility path rather than editing historical tables.
- Do not add new ordinary schema to retained `working.db`; current projection
  schema changes belong to the conversation graph database.

## Quick Checks
- Need table DDL? Run `dart run drift_dev schema dump` or inspect the schema files listed above.
- Unsure if a column exists? Search in the schema source files rather than guessing - both databases are versioned and enforced by migrations.
- See `./20-migration-orchestrator.md` only for historical retained projection
  behavior.
