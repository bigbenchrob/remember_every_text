---
tier: feature
scope: implementation-plan
owner: agent-per-project
last_reviewed: 2026-04-30
source_of_truth: doc
links:
  - ./SEED.txt
  - ../../10-DATABASES/00-all-databases-accessed.md
  - ../../20-DATA-IMPORT-MIGRATION/10-import-orchestrator.md
  - ../../20-DATA-IMPORT-MIGRATION/20-migration-orchestrator.md
tests: []
feature: archive-ledger-provenance
status: proposed
created: 2026-04-30
---

# Archive Ledger Provenance Schema - Implementation Plan

## Purpose

This plan defines the schema transformation required to make `macos_import.db` the single canonical ledger for both live current Mac imports and historical archive imports.

It is a planning document only.

It does not authorize implementation yet.

The immediate problem is that the current ledger can ingest source-derived rows, but it cannot yet represent row provenance strongly enough to support the following safely in one canonical ledger:

- live current Mac data and historical archive data at the same time
- stable archive-source identity
- replayable per-run import batch identity
- source-specific archive deletion later
- clean dedupe and audit accounting across repeated imports
- migration that remains source-agnostic and reads only canonical ledger tables

## Architecture Summary

The app already follows the intended high-level pipeline:

```text
db-chat + db-address-book
  -> db-import (macos_import.db)
  -> db-working (working.db)
  -> provider reads merged with db-overlay
```

The import orchestrator writes source-derived rows into `macos_import.db` through table-specific importers. The migration orchestrator then projects those canonical ledger rows into `working.db`. `working.db` is disposable. `db-overlay` remains separate and user-intent only.

The locked archive-v2 requirement is not to create a second ledger or an archive-only projector. Historical archive rows must become normal canonical ledger rows with enough additive provenance to distinguish where they came from and how they should be replayed, audited, deduped, or removed later.

## Assumptions

1. This schema work will land in multiple small implementation slices rather than one large rewrite.
2. Historical archive import will flow only through the canonical import and migration orchestrators.
3. Existing importers currently rely on source-native `ROWID` values too directly and will need follow-up changes to stop treating them as global ledger identity.
4. Current `working.db` projections should continue to function if they ignore provenance columns at first.
5. During development, a local clean rebuild of `db-import` and `db-working` is acceptable after schema changes land, but the final schema bump must still define a deterministic migration/backfill strategy for existing ledgers.
6. AddressBook import remains part of the same canonical pipeline, but this provenance plan is primarily about message-ledger source identity and archive coexistence.

## Hard Invariants

1. `macos_import.db` remains the single canonical import ledger.
2. No `historical_archive_import.db` may be introduced.
3. Migration must read canonical ledger tables only.
4. Migration must never read attached archive databases or source archive folders.
5. `working.db` remains disposable and fully rebuildable from canonical ledger data.
6. `db-overlay` remains untouched by this feature.
7. Source-native `ROWID` values are traceability fields only. They must not remain global ledger identity.
8. UI success must mean canonical import, canonical migration, and rebuild/refresh all completed.
9. Archive-source deletion must be able to remove only archive-derived ledger data for one source without touching live current Mac rows.
10. The final canonical ledger timestamp storage format must be Unix epoch seconds stored as `INTEGER`.
11. Historical archive import execution must not be enabled until the upgraded provenance schema and surrogate canonical IDs are proven to preserve end-to-end current Mac onboarding, import, migration, and `working.db` population.

## Schema Inspection Summary

The current schema audit is based on the live DDL in `SqfliteImportDatabase`.

### Current Canonical Tables Audit

| Table                                    | Current role                                                 | Current primary key                                | Current unique constraints | Current explicit indexes                                                                                                                                                                                                                        |
| ---------------------------------------- | ------------------------------------------------------------ | -------------------------------------------------- | -------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `import_batches`                         | One row per import run                                       | `id`                                               | none                       | none                                                                                                                                                                                                                                            |
| `historical_archive_sources`             | Archive-folder registry and preflight/import summary storage | `source_chat_db`                                   | none beyond PK             | none                                                                                                                                                                                                                                            |
| `source_files`                           | Files recorded for a batch                                   | `id`                                               | `UNIQUE(path, sha256_hex)` | none                                                                                                                                                                                                                                            |
| `messages`                               | Canonical thread-linked messages                             | `id`                                               | `UNIQUE(guid)`             | `idx_messages_chat_date(chat_id, date_utc)`, `idx_messages_chat_active_date(chat_id, date_utc) WHERE is_ignored = 0`, `idx_messages_ignore(is_ignored)`, `idx_messages_assoc(associated_message_guid)`, `idx_messages_sender(sender_handle_id)` |
| `chats`                                  | Canonical chats                                              | `id`                                               | `UNIQUE(guid)`             | `idx_chats_ignore(is_ignored)`                                                                                                                                                                                                                  |
| `handles`                                | Canonical handles                                            | `id`                                               | none                       | `idx_handles_compound(compound_identifier)`, `idx_handles_norm(normalized_identifier)`, `idx_handles_ignore(is_ignored)`                                                                                                                        |
| `chat_to_message`                        | Chat-message join rows                                       | composite `PRIMARY KEY(chat_id, message_id)`       | none beyond PK             | `idx_chat_to_message_message(message_id)`                                                                                                                                                                                                       |
| `chat_to_handle`                         | Chat-handle join rows                                        | composite `PRIMARY KEY(chat_id, handle_id)`        | none beyond PK             | `idx_participants_handle(handle_id)`                                                                                                                                                                                                            |
| `attachments`                            | Canonical attachments                                        | `id`                                               | none                       | `idx_attach_created(created_at_utc)`                                                                                                                                                                                                            |
| `message_attachments`                    | Message-attachment join rows                                 | composite `PRIMARY KEY(message_id, attachment_id)` | none beyond PK             | `idx_message_attachments_attachment(attachment_id)`                                                                                                                                                                                             |
| `recovered_unlinked_messages`            | Canonical recovered message rows that are not chat-linked    | `id`                                               | `UNIQUE(guid)`             | `idx_recovered_unlinked_messages_date(date_utc)`, `idx_recovered_unlinked_messages_ignore(is_ignored)`, `idx_recovered_unlinked_messages_assoc(associated_message_guid)`, `idx_recovered_unlinked_messages_sender(sender_handle_id)`            |
| `recovered_unlinked_message_attachments` | Recovered-message attachment joins                           | composite `PRIMARY KEY(message_id, attachment_id)` | none beyond PK             | `idx_recovered_unlinked_message_attachments_attachment(attachment_id)`                                                                                                                                                                          |

### Current Audit Findings

1. Current major row tables already carry `batch_id`, but that field currently behaves more like "last assigned batch" than immutable provenance.
2. Current join tables do not consistently carry batch identity, which is acceptable only if parent-row provenance becomes authoritative and cascades remain sufficient.
3. Current tables preserve `source_rowid`, but importer logic still tends to pass native source IDs into canonical `id` columns, which blocks safe multi-source coexistence.
4. `historical_archive_sources` exists, but it is presently a workflow registry keyed by `source_chat_db`, not a full canonical source-identity backbone.
5. Canonical timestamps are still stored as `TEXT`, not `INTEGER` Unix epoch seconds.

## Core Design Decision

### Where provenance should live

The plan adopts this model:

1. **Direct source identity belongs on major canonical entity rows.**
2. **Direct batch identity also belongs on major canonical entity rows.**
3. **Broad source kind should be modeled canonically in a source registry and derived from source identity where possible.**
4. **Join tables should inherit provenance through their parent entity rows unless a specific operational need requires direct provenance.**

### Why batch-only provenance is not enough

Relying on `import_batch_id` alone is not sufficient because:

- re-importing the same source should be idempotent rather than duplicative
- a row's source identity must survive across multiple runs from the same source
- later archive-source deletion is logically a source-based operation, not merely a last-batch operation
- current code already reassigns existing rows to a newer batch, which proves batch alone cannot remain the authoritative row-provenance contract

### Final provenance rule

For major ledger rows, the canonical provenance contract should be:

- `source_id` identifies the stable source owner of the row
- `first_import_batch_id` records the batch that first inserted the row
- `last_import_batch_id` records the most recent successful batch that observed or refreshed the row
- `source_native_rowid` remains traceability only
- `source_kind` is derived from the canonical source registry, not duplicated on every row unless later diagnostics prove the denormalization is worth it

## Proposed Schema Deltas

## 1. Add a canonical source registry table

### New table: `ledger_sources`

Purpose:

- give both current Mac and historical archive imports a stable source record
- provide the authoritative `source_id` foreign key target for batches and major row tables

Proposed fields:

- `id INTEGER PRIMARY KEY`
- `source_kind TEXT NOT NULL CHECK(source_kind IN ('current_mac', 'historical_archive'))`
- `stable_key TEXT NOT NULL`
- `source_label TEXT NOT NULL`
- `chat_db_path TEXT`
- `attachments_path TEXT`
- `is_active INTEGER NOT NULL DEFAULT 1 CHECK(is_active IN (0,1))`
- `first_seen_at INTEGER NOT NULL`
- `last_seen_at INTEGER`
- `last_imported_at INTEGER`
- `notes TEXT`

Proposed constraints and indexes:

- `UNIQUE(source_kind, stable_key)`
- index on `(source_kind)`
- index on `(chat_db_path)` if profiling shows path lookups remain common

Representation rules:

- the current live Messages source gets exactly one `ledger_sources` row with `source_kind = 'current_mac'`
- each historical archive folder gets one `ledger_sources` row with `source_kind = 'historical_archive'`

## 2. Refactor `historical_archive_sources` into an archive-specific extension table

Purpose:

- keep archive-only workflow and preflight metadata without making it the universal source registry

Proposed changes:

- add `id INTEGER PRIMARY KEY`
- add `ledger_source_id INTEGER NOT NULL UNIQUE REFERENCES ledger_sources(id) ON DELETE CASCADE`
- change `source_chat_db` from primary key to `UNIQUE`
- convert archive timestamps and earliest/latest message dates to `INTEGER`

Proposed retained/renamed metadata:

- `folder_path`
- `source_label`
- `source_chat_db`
- `detected_attachments_path`
- `preflight_status`
- `preflight_detail`
- `message_count`
- `chat_count`
- `handle_count`
- `missing_guid_count`
- `earliest_message_at`
- `latest_message_at`
- `last_preflight_at`
- `last_imported_at`
- `last_import_batch_id`
- `last_import_success`
- `last_import_error`

This table remains archive-specific. It is not the primary provenance contract for row ownership.

## 3. Expand `import_batches` into a true run-level provenance and audit table

Purpose:

- record every canonical import run with durable batch identity and clear source ownership

Proposed new fields:

- `chat_source_id INTEGER NOT NULL REFERENCES ledger_sources(id) ON DELETE RESTRICT`
- `chat_source_kind TEXT NOT NULL CHECK(chat_source_kind IN ('current_mac', 'historical_archive'))`
- `status TEXT NOT NULL CHECK(status IN ('running', 'succeeded', 'failed', 'cancelled'))`
- `started_at INTEGER NOT NULL`
- `finished_at INTEGER`
- `source_label_snapshot TEXT`
- `error_summary TEXT`
- `rows_seen INTEGER`
- `rows_inserted INTEGER`
- `rows_updated INTEGER`
- `rows_deduplicated INTEGER`
- `rows_failed INTEGER`

Proposed compatibility handling:

- retain legacy `source_chat_db`, `source_addressbook`, `host_info_json`, and `notes` during transition
- backfill `chat_source_id` and `chat_source_kind` from those legacy fields

Indexes:

- `(chat_source_id, started_at DESC)`
- `(status)`
- `(chat_source_kind, started_at DESC)`

## 4. Convert major row tables to source-owned canonical entities

### `messages`

Current role:

- canonical thread-linked message rows

Proposed new columns:

- `source_id INTEGER NOT NULL REFERENCES ledger_sources(id) ON DELETE RESTRICT`
- `first_import_batch_id INTEGER NOT NULL REFERENCES import_batches(id) ON DELETE RESTRICT`
- `last_import_batch_id INTEGER NOT NULL REFERENCES import_batches(id) ON DELETE RESTRICT`
- `source_message_rowid INTEGER`

Proposed type change:

- `date_utc`, `date_read_utc`, `date_delivered_utc` become `INTEGER` epoch seconds

Proposed unique/index strategy:

- keep `UNIQUE(guid)` as the cross-source dedupe authority for normal canonical message rows
- add index on `(source_id, source_message_rowid)` for traceability and source-specific deletion diagnostics
- add index on `(last_import_batch_id)` if batch-level audit queries prove common

Migration impact:

- migrators can keep reading the same canonical message table
- no archive-specific branching required
- date readers must expect `INTEGER`

Live import impact:

- importer stops writing source `ROWID` into `id`
- canonical `id` becomes ledger-local surrogate identity

Archive import impact:

- archive rows live in the same table with distinct `source_id`
- dedupe is by `guid`, not by source-native `ROWID`

### `recovered_unlinked_messages`

Proposed changes mirror `messages`:

- `source_id`
- `first_import_batch_id`
- `last_import_batch_id`
- `source_message_rowid`
- date columns converted to `INTEGER`
- traceability index on `(source_id, source_message_rowid)`
- keep `UNIQUE(guid)` unless later recovered-message semantics prove a broader key is necessary

### `chats`

Proposed new columns:

- `source_id INTEGER NOT NULL REFERENCES ledger_sources(id) ON DELETE RESTRICT`
- `first_import_batch_id INTEGER NOT NULL REFERENCES import_batches(id) ON DELETE RESTRICT`
- `last_import_batch_id INTEGER NOT NULL REFERENCES import_batches(id) ON DELETE RESTRICT`
- `source_chat_rowid INTEGER`

Proposed type change:

- `created_at_utc`, `updated_at_utc` become `INTEGER`

Constraints and indexes:

- keep `UNIQUE(guid)` as canonical chat dedupe authority
- add index on `(source_id, source_chat_rowid)`

### `handles`

Proposed new columns:

- `source_id INTEGER NOT NULL REFERENCES ledger_sources(id) ON DELETE RESTRICT`
- `first_import_batch_id INTEGER NOT NULL REFERENCES import_batches(id) ON DELETE RESTRICT`
- `last_import_batch_id INTEGER NOT NULL REFERENCES import_batches(id) ON DELETE RESTRICT`
- `source_handle_rowid INTEGER`

Constraints and indexes:

- do not restore the old global uniqueness on raw identifier
- add index on `(source_id, source_handle_rowid)`
- keep existing normalized/compound lookup indexes

### `attachments`

Proposed new columns:

- `source_id INTEGER NOT NULL REFERENCES ledger_sources(id) ON DELETE RESTRICT`
- `first_import_batch_id INTEGER NOT NULL REFERENCES import_batches(id) ON DELETE RESTRICT`
- `last_import_batch_id INTEGER NOT NULL REFERENCES import_batches(id) ON DELETE RESTRICT`
- `source_attachment_rowid INTEGER`

Proposed type change:

- `created_at_utc` becomes `INTEGER`

Indexes:

- add index on `(source_id, source_attachment_rowid)`
- keep created-at index

## 5. Tables that should inherit provenance instead of storing it directly

### `chat_to_message`

- no direct provenance columns needed
- provenance derives from referenced `messages` and `chats`
- retain `source_rowid` only if it continues to help import diagnostics

### `chat_to_handle`

- no direct provenance columns needed
- provenance derives from referenced `chats` and `handles`

### `message_attachments`

- no direct provenance columns needed
- provenance derives from referenced `messages` and `attachments`

### `recovered_unlinked_message_attachments`

- no direct provenance columns needed
- provenance derives from referenced recovered messages and attachments

### `source_files`

- no direct source fields needed beyond `batch_id`
- provenance derives from `import_batches`

## Table-by-Table Proposed Impact Summary

| Table                                    | Need direct provenance? | Proposed change summary                                                                  | Migration logic affected?                                                 | Live import affected?                                  | Archive import affected? |
| ---------------------------------------- | ----------------------- | ---------------------------------------------------------------------------------------- | ------------------------------------------------------------------------- | ------------------------------------------------------ | ------------------------ |
| `import_batches`                         | yes                     | add canonical source linkage, status, counts, integer timestamps                         | no direct branching, but migrator diagnostics can query richer batch data | yes                                                    | yes                      |
| `historical_archive_sources`             | archive-only extension  | add integer PK and `ledger_source_id`; convert archive timestamps/count dates to integer | no                                                                        | no                                                     | yes                      |
| `source_files`                           | inherited via batch     | no provenance fields beyond batch                                                        | no                                                                        | minor                                                  | minor                    |
| `messages`                               | yes                     | add `source_id`, first/last batch IDs, `source_message_rowid`, integer dates             | yes, readers must accept integer dates                                    | yes                                                    | yes                      |
| `recovered_unlinked_messages`            | yes                     | mirror `messages` provenance shape                                                       | yes, readers must accept integer dates                                    | yes                                                    | yes                      |
| `chats`                                  | yes                     | add `source_id`, first/last batch IDs, `source_chat_rowid`, integer timestamps           | low                                                                       | yes                                                    | yes                      |
| `handles`                                | yes                     | add `source_id`, first/last batch IDs, `source_handle_rowid`                             | low                                                                       | yes                                                    | yes                      |
| `attachments`                            | yes                     | add `source_id`, first/last batch IDs, `source_attachment_rowid`, integer created date   | low                                                                       | yes                                                    | yes                      |
| `chat_to_message`                        | no                      | inherit via parent rows                                                                  | no                                                                        | yes, insert logic must stop assuming global source IDs | yes                      |
| `chat_to_handle`                         | no                      | inherit via parent rows                                                                  | no                                                                        | yes, insert logic must use canonical IDs               | yes                      |
| `message_attachments`                    | no                      | inherit via parent rows                                                                  | no                                                                        | yes, insert logic must use canonical IDs               | yes                      |
| `recovered_unlinked_message_attachments` | no                      | inherit via parent rows                                                                  | no                                                                        | yes, insert logic must use canonical IDs               | yes                      |

## Representation Model

### How current Mac rows are represented

- one canonical `ledger_sources` row represents the current live Messages source
- live-imported `messages`, `chats`, `handles`, `attachments`, and recovered rows point to that `source_id`
- their `first_import_batch_id` records the batch that first inserted them
- their `last_import_batch_id` records the most recent successful live import batch that observed them

### How archive rows are represented

- each archive folder receives one canonical `ledger_sources` row with `source_kind = 'historical_archive'`
- archive-specific metadata remains in `historical_archive_sources`
- imported archive rows point to that archive `source_id`
- archive re-import updates `last_import_batch_id` without duplicating canonical rows

## Import Batch to Source Identity Contract

Each import batch must point to exactly one chat-data source through `import_batches.chat_source_id`.

That source must point to one row in `ledger_sources`.

AddressBook provenance remains separately tracked through existing batch metadata and is not the authority for message-row provenance.

This keeps the message-side source contract clean while avoiding an unnecessary redesign of AddressBook semantics in the same slice.

## Import Logic Changes Required

1. Stop passing source-native `ROWID` values into canonical `id` fields.
2. Treat canonical `id` as ledger-local surrogate identity generated by SQLite.
3. Populate `source_id`, `first_import_batch_id`, and `last_import_batch_id` on major canonical entity rows.
4. Preserve native source `ROWID` values only in `source_*_rowid` fields.
5. Replace the current `assignExistingRecordsToBatch()` pattern with logic that updates only `last_import_batch_id` for rows that were re-observed from the same source.
6. Make join importers resolve through canonical row identity maps rather than assuming source IDs equal canonical IDs.
7. Keep `UNIQUE(guid)` as the primary dedupe authority for canonical messages and chats unless later implementation evidence requires a narrower key.
8. Record per-batch dedupe and failure counts on `import_batches`, not on the surviving canonical entity rows.

## Migration Logic Changes Required

1. Migration keeps reading the same canonical tables.
2. Migration does not branch on `source_kind` for normal projection.
3. Migration only needs to accept that timestamps are now `INTEGER` epoch seconds.
4. Provenance columns may initially be ignored by migrators unless a working-db feature explicitly requires them.
5. Full rebuild of `working.db` after import remains the rule for archive visibility.

## Reset / Rebuild Strategy

`working.db` rebuild remains simple:

- wipe or recreate `working.db`
- rerun canonical migration against `macos_import.db`
- both live current Mac rows and archive rows reappear because they live in the same canonical ledger tables

No rebuild step should inspect source archive folders or archive `chat.db` files.

## Future Archive Deletion Strategy

The required future control is:

- `Remove Imported Archive Data For This Source`

This plan supports it by making `source_id` the authoritative owner of archive-derived rows.

Deletion algorithm later:

1. resolve the archive `ledger_sources.id`
2. delete `attachments`, `recovered_unlinked_messages`, `messages`, `chats`, and `handles` owned by that `source_id` in FK-safe order
3. allow join tables to collapse by cascade where applicable
4. delete the archive's `historical_archive_sources` extension row if the product decision is to remove the source record itself
5. preserve the current live source row and all `source_kind = 'current_mac'` rows untouched

If later implementation reveals cross-source shared canonical rows, source-specific deletion must prefer ownership-based deletes over batch-only deletes. That is precisely why row-level `source_id` is part of this plan.

## Migration and Backfill Strategy

### Schema bump approach

This is a high-risk schema change and should be implemented as a dedicated `db-import` schema bump with explicit table recreation for affected tables.

### Backfill plan

1. create `ledger_sources`
2. insert one current Mac source row
3. insert one historical source row per existing `historical_archive_sources` entry
4. backfill `import_batches.chat_source_id` and `chat_source_kind` from existing `source_chat_db`
5. backfill major row tables:
   - current rows that came from the live chat database receive the current Mac source id
   - existing archive rows, if distinguishable through prior `source_chat_db` lineage, receive their archive source id
   - if legacy rows cannot be distinguished with confidence, development builds should require a clean canonical re-import rather than fabricate provenance
6. convert timestamp text to epoch seconds during table recreation

### Development-time practical rule

During development of this branch, a clean rebuild of `macos_import.db` and `working.db` is acceptable and likely desirable after the schema bump lands, because the current ledger shape is not trustworthy enough to backfill every provenance column without ambiguity.

The production migration path must still be documented and implemented, but developer iteration should not pretend the old ledger is cleanly mappable if it is not.

## Test Plan

Before real archive import wiring is treated as complete, the following tests must exist.

1. Existing current Mac import still produces valid canonical ledger rows.
2. Current Mac rows receive the current live `source_id` and batch linkage.
3. Archive rows can be inserted into the same canonical `messages`, `chats`, `handles`, `attachments`, and recovered tables.
4. Archive rows receive the correct archive `source_id`, `first_import_batch_id`, and `last_import_batch_id`.
5. Source-native rowids are preserved only in traceability columns and do not collide with canonical IDs.
6. GUID dedupe works at ledger insertion across live and archive imports.
7. Re-importing the same archive is idempotent and updates `last_import_batch_id` without duplicating canonical rows.
8. Join importers correctly resolve canonical IDs instead of assuming source-native IDs equal ledger IDs.
9. Migration reads canonical ledger rows without archive-specific branching.
10. Full reset/rebuild of `working.db` replays both live and archive-backed ledger rows from `macos_import.db`.
11. Archive-source deletion removes only rows owned by one archive `source_id` and does not touch current Mac rows.
12. No migration code reads from a `historical_archive_import.db` or source archive database.

### Explicit Release Gate Before Archive Wiring

Historical archive import execution must remain disabled until the following sequence is complete and verified:

1. upgrade `macos_import.db` to the new provenance schema
2. restore normal current Mac onboarding, canonical import, and canonical migration on that schema
3. prove that current live data still populates `working.db` end to end
4. only then enable archive import wiring

This gate is mandatory because archive import must not be allowed to mask a broken canonical live-data pipeline.

### Step 3 Manual Validation Note

On 2026-04-30, a manual clean-start validation was run after deleting all local database files except `user_overlays.db` and relaunching the app through onboarding, canonical import, and canonical migration completion.

- Databases validated: `~/Library/Application Support/com.bigbenchsoftware.MessageLens/macos_import.db`, `~/Library/Application Support/com.bigbenchsoftware.MessageLens/working.db`, and source `~/Library/Messages/chat.db`.
- Surrogate IDs: `source_*_rowid` was populated for all validated current rows. Divergence counts were `messages` 109679/109684, `handles` 245/246, `chats` 225/225, and `attachments` 34340/34340. The small equal-ID subset came from the clean rebuild starting both source and ledger rows at low integers, not from source-identity reuse.
- Join integrity: `chat_to_message` had 109684 rows with 0 orphan chats and 0 orphan messages. `message_attachments` had 33036 rows with 0 orphan messages and 0 orphan attachments.
- GUID uniqueness: `messages.guid` had 0 duplicate groups and 0 duplicate surplus rows.
- Basic counts: source `message` = 119337, ledger linked `messages` = 109684, ledger `recovered_unlinked_messages` = 9653, which reconciled exactly to the source total. Source and ledger `chats` both measured 225. Source and ledger `attachments` both measured 34340. No large-scale loss or duplication was observed.
- Working projection sanity: `working.db.messages` = 109684, matching linked ledger `messages`. A projected timeline sample with GUID `ADFDF5D8-F5F5-47E8-B9CD-FBF782BB388C` and text prefix `https://www.nsnews.com/local-news/driver-crashes-through-west-vancouver-liquor-store-9509234` was present in `working.db`, and an FTS search for `nsnews` returned that same projected row.

## Rollback Strategy

1. Keep the schema bump isolated on `Ftr.archive-ledger-provenance` until the plan is reviewed and implementation is validated.
2. Land the implementation in small slices so the schema bump, importer identity rewrite, and migration timestamp updates can be backed out independently before merge.
3. During development, if the provenance migration becomes unsafe, discard the dev ledger and rebuild from sources rather than trying to hand-repair ambiguous provenance.
4. Do not ship a partial state where batches understand source identity but major row tables still rely on source-native `ROWID` as canonical identity.

## Explicit Non-Goals

1. This plan does not redesign `working.db` schemas beyond whatever migration compatibility is required.
2. This plan does not change overlay semantics.
3. This plan does not solve every missing-GUID or source-anomaly policy question.
4. This plan does not redesign AddressBook provenance beyond keeping existing batch-level references compatible.
5. This plan does not add UI workflow polish beyond the provenance requirements already tracked elsewhere.
6. This plan does not make historical archive import succeed immediately. It defines the schema and contract work required before that wiring is safe.

## Recommended Delivery Order

1. Review and lock the provenance model in this document.
2. Implement the `db-import` schema bump and source registry first.
3. Rewrite importer identity handling so canonical IDs are no longer source-native IDs.
4. Restore and validate normal current Mac onboarding/import/migration on the upgraded schema.
5. Prove that current live data still populates `working.db` end to end.
6. Only after that gate passes, wire historical archive import execution.
7. Update batch accounting and row provenance writes needed for archive coexistence.
8. Update migration readers for integer timestamp handling.
9. Add source-specific deletion tests before enabling full archive import wiring.

This order keeps the highest-risk identity change ahead of UI-facing import enablement, which is the safest way to avoid another brittle archive-import spike.
