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
message↔attachment relationships. Graph-era recovery maps those facts to
source-scoped message/attachment identity first; retained overlay-compatible
archive keys are a bridge only where existing archive metadata still requires
them. Archive files are written to the existing content-addressable store with
overlay rows carrying provenance `imported_historical_snapshot`.

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

Layer 2: Current source-scoped import DB / graph attachment facts
  Source of: attachment source facts and source-scoped attachment identity
  Supersedes the retired import DB bridge once graph attachment projection is
  available for the selected source.

Layer 3: Current conversation graph + overlay
  Source of: canonical message_ss_id / attachment_ss_id runtime identity, plus
             retained overlay-compatible archive keys during the transition
  Target of: overlay archived_attachments row insertion
```

### Precondition

The source-scoped import DB and conversation graph must be populated for the
selected source. If graph/source-scoped attachment facts are unavailable,
historical recovery must refuse with a clear diagnostic rather than falling
back to retained import/projection authority.

## Attachment Identity Mapping

### The Problem

Apple's `attachment.guid` was historically bridged through retained
`macos_import.db` and retained `working.db`. In the graph era, canonical
message/attachment identity is source-scoped; retained
`(message_guid, import_attachment_id)` overlay keys are compatibility keys, not
the app's ordinary identity model.

Therefore, mapping a historical attachment should prefer source-scoped graph
identity: historical source facts → source-scoped import facts → graph
`message_ss_id` / `attachment_ss_id`, with a named retained overlay bridge only
where existing archive metadata still requires `(message_guid,
import_attachment_id)`.

### Primary Match (Step 1)

For `(hist_message_guid, hist_attachment_guid)`:

1. Resolve the historical source attachment to a source-scoped graph attachment
   occurrence when available.
2. Verify the graph message/attachment edge exists.
3. If existing archive metadata still requires retained overlay-compatible
   keys, resolve those through the named archive compatibility bridge.
4. Confirmed → MAPPED with an explicit graph/bridge match method.

### Single-Attachment Fallback (Step 2)

Permitted ONLY when ALL three conditions hold:

1. `hist_attachment_guid` IS NULL (not different — NULL)
2. Historical message has EXACTLY ONE attachment (from `message_attachment_join`)
3. Current graph has EXACTLY ONE attachment for that message scope

If all three: the single current graph attachment occurrence is the match.
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
