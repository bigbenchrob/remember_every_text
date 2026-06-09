# Deterministic Historical Attachment Recovery Design Notes

## Current Conformance Note (2026-06-06)

These design notes preserve the deterministic no-heuristics rule. Their
three-layer import/working bridge is superseded by graph-era mapping:
historical snapshot facts should map to source-scoped import facts and graph
attachment/message edges, with overlay archive records remaining the durable
user-owned file metadata.

## Summary

Replace the heuristic historical recovery intake with a deterministic
three-layer mapping flow. The historical chat.db provides authoritative
message↔attachment relationships. The current import DB bridges Apple's
`attachment.guid` to the runtime `import_attachment_id`. Archive files are
written to the existing content-addressable store with overlay rows carrying
provenance `imported_historical_snapshot`.

## Hard Invariants

- Working DB is never written to by historical recovery
- Overlay DB receives archive metadata only (no structural schema change)
- Historical snapshot is opened `SQLITE_OPEN_READONLY` — never mutated
- Historical ROWIDs are join-traversal-only within the snapshot; they never
  escape into overlay identity or runtime linkage
- No record is silently dropped — unmapped records are counted and reported
- No heuristic fallback exists (GUID match or bounded single-attachment
  fallback only; no path-tail, transfer_name, basename, or ordinal matching)
- `archiveAllAvailable()` is preserved unchanged — the archive remains living

## Three-Layer Read Topology

During historical recovery, three data layers are read (all read-only during
the mapping phase):

```
Layer 1: Historical snapshot DB (user-provided, SQLITE_OPEN_READONLY)
  Source of: attachment.guid, message.guid, attachment.filename,
             message_attachment_join relationships

Layer 2: Current import DB (via sqfliteImportDatabaseProvider)
  Source of: attachments.guid → attachments.id bridge
  ONLY layer holding BOTH Apple's attachment.guid AND the id
  that becomes import_attachment_id in working DB

Layer 3: Current working DB + overlay (via existing providers)
  Source of: (message_guid, import_attachment_id) runtime identity
  Target of: overlay archived_attachments row insertion
```

### Precondition

The current import DB must be populated from at least one live
import+migration cycle. If empty/absent, historical recovery refuses
with a clear diagnostic.

## Attachment Identity Mapping

### The Problem

Apple's `attachment.guid` is preserved in the import DB but is NOT projected
into the working DB. The working DB uses `import_attachment_id` (= import DB
`attachments.id`). The overlay keys on `(message_guid, import_attachment_id)`.

Therefore, mapping a historical attachment to its current overlay key requires
bridging through the import DB: `historical attachment.guid` → `import DB
attachments.guid` → `import DB attachments.id` → `working DB
import_attachment_id`.

### Primary Match (Step 1)

For `(hist_message_guid, hist_attachment_guid)`:

1. Query import DB: `SELECT id FROM attachments WHERE guid = :hist_attachment_guid`
2. If exactly one row → candidate `import_attachment_id`
3. Verify the pair exists in working DB:
   `SELECT 1 FROM attachments WHERE message_guid = :hist_message_guid AND import_attachment_id = :id`
4. Confirmed → MAPPED with `match_method = 'guid_match'`

### Single-Attachment Fallback (Step 2)

Permitted ONLY when ALL three conditions hold:

1. `hist_attachment_guid` IS NULL (not different — NULL)
2. Historical message has EXACTLY ONE attachment (from `message_attachment_join`)
3. Current working DB has EXACTLY ONE attachment for that `message_guid`

If all three: the single current `import_attachment_id` is the match.
`match_method = 'single_attachment_fallback'`

If ANY condition fails: record is UNMAPPED.

### No Further Fallback (Step 3)

There is no Step 3. Explicitly prohibited: transfer_name matching, file
size + created_at matching, ordinal position matching, string similarity.

## File Resolution (Deterministic Path Rewrite)

For each historical row with `hist_local_path`:

1. Strip the historical root prefix (`~/Library/Messages/Attachments/`)
2. Append relative remainder to user-selected historical Attachments folder
3. Test file existence at that exact path
4. Result: found (with full resolved path) or missing

No searching, no basename guessing, no path-tail matching.

## Archive Writing

Reuses existing content-addressable infrastructure:

1. SHA-256 hash source file
2. Store at `{sha256_prefix}/{sha256_hex}{extension}` in archive directory
3. Idempotency: skip if `(message_guid, import_attachment_id)` exists in overlay
4. Insert overlay row:
   - `message_guid`, `import_attachment_id`
   - `archive_relative_path`, `archived_at_utc`, `file_size_bytes`
   - `content_hash` (SHA-256)
   - `provenance = 'imported_historical_snapshot'`
   - `original_local_path` (historical path for diagnostics)
5. Verify integrity post-copy (re-hash comparison)

## Schema Impact

### Overlay DB (`user_overlays.db`)

Table `archived_attachments` — NO STRUCTURAL CHANGE.
New provenance value: `'imported_historical_snapshot'` (TEXT field, no
migration needed — just a new conventional value alongside existing
`'archived'` and `'imported_historical'`).

### Working DB (`working.db`)

NO CHANGES.

### Import DB (`import.db`)

NO CHANGES (read-only during historical recovery).

## Data Structures

### HistoricalAttachmentRecord (Phase 1 output)

```
hist_message_guid: String
hist_attachment_guid: String?
hist_local_path: String?
resolved_file_path: String? (null if file not found)
file_found: bool
hist_transfer_name: String?
hist_mime_type: String?
hist_uti: String?
hist_file_size: int?
hist_is_outgoing: bool
```

### MappedAttachmentRecord (Phase 2 output)

```
hist_message_guid: String
current_message_guid: String
current_import_attachment_id: int
resolved_file_path: String
match_method: 'guid_match' | 'single_attachment_fallback'
hist_attachment_guid: String?
hist_local_path: String?
```

### UnmappedReason (enum)

```
message_not_in_working
guid_mismatch
guid_null_multi_attachment
guid_null_no_current_attachment
file_not_found
```

## File Inventory

### Delete

- `lib/features/attachments/application/historical_import_provider.dart`

### Create

- `lib/features/attachments/application/historical_snapshot_reader.dart`
- `lib/features/attachments/application/cross_snapshot_mapper.dart`

### Modify

- `lib/features/contacts/presentation/cassettes/settings/attachment_archive_settings_content.dart`
  (Phase 0: remove heuristic UI; Phase 4: add deterministic UI)

### Preserved Unchanged

- `lib/features/attachments/application/attachment_archive_service_provider.dart`
- `lib/features/messages/presentation/view_model/shared/hydration/attachment_info_loader.dart`
- `lib/essentials/db/infrastructure/data_sources/local/overlay/overlay_database.dart`
- `lib/essentials/db/feature_level_providers.dart`
- All importers (`lib/essentials/db_importers/`)
- All migrators (`lib/essentials/db_migrate/`)

## Assumptions

1. Apple's `message.guid` is stable across chat.db snapshots from the same
   iCloud account/device.
2. Apple's `attachment.guid` is stable in the same manner.
3. The live import pass copies `attachment.guid` into import DB `attachments.guid`
   (verified by schema inspection).
4. Import DB `attachments.id` is preserved as working DB
   `attachments.import_attachment_id` (verified in `attachments_migrator.dart`).
5. Very old records may have NULL `attachment.guid` — the single-attachment
   fallback handles this bounded case.

## Risks

1. **GUID rotation** — If Apple ever reassigns attachment GUIDs, mapping fails
   for affected records. Mitigation: reported as unmapped, not silently wrong.
2. **Cross-account snapshots** — If historical snapshot is from a different
   iCloud account, GUIDs won't match. Mitigation: most records unmapped; clear count.
3. **NULL-GUID multi-attach** — Unmappable by design. Mitigation: reported as
   `unmapped_ambiguous`.
4. **WAL-absent snapshots** — May miss recent transactions. Mitigation: warning
   displayed, reported as `files_missing`.

## Living Archive Continuation

The archive remains living, not a frozen onboarding snapshot. Phases 0–5 do
NOT modify the live archive path. `archiveAllAvailable()` continues to run
after migration, catching newly-local files (including iCloud re-downloads).

Acceptable future expansion (deferred):
- Archive-on-resolution: opportunistically archive when resolver finds an
  unarchived live file
- Background/incremental mechanism if import-cycle frequency is insufficient
