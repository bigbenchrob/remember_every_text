# Living Attachments Archive Design Notes

## Summary

The living attachments archive introduces a durable, app-controlled copy of
Messages attachment files alongside a multi-source resolution pipeline. Archive
metadata lives in the overlay database. The working database remains untouched.
Widgets resolve attachments through a provider instead of inline filesystem
checks.

## Hard Invariants

- Working DB is a pure projection of chat.db — no archive columns added
- Archive metadata is user intent — written only to overlay DB
- Overlay DB is never read by migration and never snapshot/restored
- Providers merge working + overlay at read time; overlay wins on conflict
- No attachment record is suppressed, hidden, or filtered because its file
  is missing — the record renders with an appropriate availability state
- The Messages Attachments folder is never written to by MessageLens
- Archiving is opt-in and requires explicit user authorization
- ViewSpec remains the only routing mechanism for any new UI surfaces

## Existing Attachment Pipeline (Unchanged)

### Import

`AttachmentsImporter` queries Apple's `attachment` table in chat.db and
inserts rows into `import.attachments`. `MessageAttachmentsImporter` populates
the `import.message_attachments` join table. Columns captured: guid,
transfer_name, uti, mime_type, total_bytes, is_sticker, is_outgoing,
created_date, filename (local_path).

### Migration

`AttachmentsMigrator` projects from import to working via:

```sql
INSERT INTO attachments (messageGuid, importAttachmentId, localPath, ...)
SELECT wm.guid, a.id, a.local_path, ...
FROM import.message_attachments ma
JOIN import.attachments a ON a.id = ma.attachment_id
JOIN messages wm ON wm.id = ma.message_id
LEFT JOIN attachments existing ...
WHERE existing.id IS NULL;
```

This runs after messages migration. Working `localPath` is refreshed from
import every cycle.

### Rendering (Current)

`ImageMessageTile` calls `attachment.resolvedLocalPath()` which expands
`~/` → `$HOME`, then `File(resolvedPath).existsSync()`. If false, renders
`Text('Image unavailable')`.

This inline check will be replaced by the resolution provider.

## Domain Model

### New Types

```
AttachmentAvailability (enum)
  - available
  - cloudOnly
  - missing

AttachmentProvenance (enum)
  - messagesLive
  - archived
  - importedHistorical

ResolvedAttachment (freezed)
  - AttachmentInfo attachmentInfo
  - AttachmentAvailability availability
  - AttachmentProvenance? provenance
  - File? resolvedFile
```

### Existing Types Extended

`AttachmentStatus` enum — add `cloudOnly` variant. The existing `available`,
`missing`, and `failed` variants remain. `pending` and `downloading` remain
for future use.

## Overlay Database Schema

New table in `user_overlays.db`:

```sql
CREATE TABLE archived_attachments (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  attachment_guid TEXT NOT NULL UNIQUE,
  archive_relative_path TEXT NOT NULL,
  archived_at TEXT NOT NULL,
  file_size_bytes INTEGER NOT NULL,
  content_hash TEXT,
  provenance TEXT NOT NULL DEFAULT 'archived',
  original_local_path TEXT
);

CREATE INDEX idx_archived_attachments_guid
  ON archived_attachments (attachment_guid);

CREATE INDEX idx_archived_attachments_hash
  ON archived_attachments (content_hash);
```

Key decisions:

- `attachment_guid` is the stable identifier joining to
  `working.attachments.messageGuid + importAttachmentId`. The exact join
  strategy needs to be finalized — likely the GUID from chat.db's
  attachment table (available as the guid stored during import).
- `archive_relative_path` is relative to the archive root directory, not
  absolute, making the archive relocatable.
- `content_hash` is sha256, matching the `sha256Hex` field already computed
  during import. Used for deduplication and as the archive filename.
- `provenance` distinguishes between files archived during normal import
  vs. recovered from a historical backup.

## Archive Directory Layout

Root: `~/Library/Application Support/com.bigbenchsoftware.MessageLens/attachment_archive/`

```
attachment_archive/
├── ab/
│   └── ab3f7c...full-hash...d41e.jpg
├── f0/
│   └── f09a12...full-hash...8bc3.png
└── _by_id/
    └── 12345.heic    (fallback when sha256Hex is null)
```

The 2-character prefix subdirectory prevents filesystem performance
degradation from too many files in one directory. The `_by_id/` subdirectory
is the fallback for attachments imported before content hashing was added.

## Resolution Provider

```
attachmentResolverProvider(WorkingAttachment attachment)
  → AsyncValue<ResolvedAttachment>
```

Pipeline:

1. Expand `attachment.localPath` via `resolvedLocalPath()`
2. Check `File(expandedPath).exists()`
   - If yes → return `available` with `provenance: messagesLive`
   - Optionally trigger on-demand archiving if not yet archived
3. Query overlay `archived_attachments` by attachment guid
   - If found → build path from archive root + `archive_relative_path`
   - Check `File(archivePath).exists()`
   - If yes → return `available` with `provenance: archived`
4. If neither → return `cloudOnly` (if attachment record exists in DB)
   or `missing` (if record itself is anomalous)

This provider replaces all inline `existsSync()` calls in message tiles.

### Provider Dependencies

- `driftWorkingDatabaseProvider` — to read attachment records
- `driftOverlayDatabaseProvider` — to read archive metadata
- filesystem access — to check file existence

### Caching Consideration

Resolution results should be cached per attachment for the lifetime of the
widget that displays them. The provider's natural Riverpod caching
(keyed by attachment) handles this. Re-resolution occurs when the provider
is re-read (e.g., after an import cycle invalidates working data).

## Archiving Service

### Import-Time Archiving

A service invoked after migration completes:

```
AttachmentArchiveService
  - archiveNewAttachments(List<WorkingAttachment> attachments)
```

For each attachment where:
- `mimeType` starts with `image/` (Phase 1)
- File exists at `localPath`
- No overlay record exists for this attachment guid

Action:
1. Compute sha256 if not already available
2. Copy file to `attachment_archive/{hash_prefix}/{hash}.{ext}`
3. Insert overlay record

### On-Demand Archiving

When the resolution provider finds a file at its Messages path that is not
yet archived:

1. Trigger archiving in the background
2. Return `available` with `provenance: messagesLive` immediately
3. Next resolution will find the archive record

### Concurrency

Archiving should not block the UI. Use `Isolate.run` or equivalent for
file copy + hash computation. The overlay write should happen on the main
isolate via the standard provider path.

## UI Changes

### Image Message Tile

Replace:
```dart
final exists = file?.existsSync() ?? false;
// ...
if (exists) Image.file(file!) else Text('Image unavailable')
```

With consumption of the resolution provider:
```dart
final resolved = ref.watch(attachmentResolverProvider(attachment));
resolved.when(
  data: (r) => switch (r.availability) {
    available => Image.file(r.resolvedFile!),
    cloudOnly => _CloudOnlyPlaceholder(),
    missing => _MissingPlaceholder(),
  },
  loading: () => _LoadingPlaceholder(),
  error: (e, s) => _ErrorPlaceholder(error: e),
)
```

### State-Aware Placeholders

| State | Display |
|---|---|
| `available` | Render the image normally |
| `cloudOnly` | "Stored in iCloud — not downloaded to this Mac" with optional "Open in Messages" action |
| `missing` | "Attachment not available locally" |
| `loading` | Subtle shimmer or placeholder box |

### Settings Panel

New section under Settings:

- **Enable/disable** attachment archiving toggle
- **Current archive size** display (computed from directory)
- **Number of archived attachments** (count from overlay table)
- **Scope selector**: images only (Phase 1) / all attachments (future)
- **Clear archive** action (with confirmation)

## Relationship to Existing Systems

### Import Pipeline — No Changes

The import pipeline rebuilds from fresh chat.db each cycle. `localPath` is
refreshed automatically. No modifications needed.

### Migration Pipeline — No Changes

Migration wipes and re-projects working DB. Archive metadata in overlay is
completely independent and survives migration cycles by design.

### Overlay Database — Extended

One new table (`archived_attachments`). Accessed via the standard
`driftOverlayDatabaseProvider`. Follows all existing overlay rules.

### Navigation — Minimal Changes

The Settings panel already exists. Archive configuration lives there as a
new section. No new ViewSpec variants are needed for Phase 1.

Phase 2 (historical import) may introduce a brief wizard-style flow for
folder selection, but that can be designed when the time comes.

## Phase 2 Preview: Historical Import

User supplies a folder (e.g., a Time Machine recovery of
`~/Library/Messages/Attachments`). The app:

1. Walks the folder recursively
2. For each file, computes sha256
3. Matches against known attachment records by hash or by path structure
4. Copies matched files into the content-addressable archive
5. Creates overlay records with `provenance: imported_historical`
6. Reports results: matched count, unmatched count, total size

This is architecturally clean: it writes only to the archive directory and
overlay DB, never touching working DB or import DB.

## Risks

### 1. Storage Growth

Mitigated by: opt-in, storage display, scope limiting (images only Phase 1),
clear archive action, potential future retention policies.

### 2. Hash Unavailability

Some working attachment records may have `sha256Hex = null` (imported before
hashing was added). Mitigated by: fallback to `importAttachmentId` as
archive filename, recomputing hash at archive time when possible.

### 3. Import Cycle Timing

If an import cycle runs while archiving is in progress, the archiving service
must handle gracefully. Mitigated by: archiving is idempotent (check-then-
copy), overlay writes are independent of working DB state.

### 4. Large Initial Archive

A user with 40+ GB of attachments who enables archiving will trigger a large
initial copy. Mitigated by: background processing, progress indication,
ability to cancel/pause (future), gradual archiving across import cycles
rather than one bulk operation.
