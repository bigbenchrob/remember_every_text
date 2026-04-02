# Living Attachments Archive Tests

## Unit Tests

### Resolution Pipeline

- Messages path exists → returns available with provenance messagesLive
- Messages path missing, archive record exists, archive file exists →
  returns available with provenance archived
- Messages path missing, archive record exists, archive file missing →
  returns missing (archive integrity failure)
- Messages path missing, no archive record → returns cloudOnly
- Attachment with null localPath → returns cloudOnly or missing
- Resolution does not throw when home directory env var is missing

### Availability State Mapping

- available status maps to image rendering
- cloudOnly status maps to iCloud explanation placeholder
- missing status maps to not-available placeholder
- loading state maps to shimmer/placeholder

### Content-Addressable Naming

- sha256Hex produces correct 2-char prefix and full-hash filename
- null sha256Hex falls back to importAttachmentId-based filename
- original file extension is preserved in archive filename
- duplicate hash produces same path (idempotent)

### Archive Service

- archiveAttachment copies file to correct content-addressable path
- archiveAttachment creates overlay record with correct fields
- archiveAttachment is idempotent — skips if overlay record exists
- archiveAttachment skips non-image mime types in Phase 1
- archiveAttachment handles missing source file gracefully (no throw)
- archiveAttachment computes sha256 at archive time when sha256Hex is null

### Overlay Schema

- archived_attachments table accepts valid insert
- attachment_guid uniqueness constraint prevents duplicates
- content_hash index supports efficient dedup lookup

## Provider Tests

### Resolution Provider

- provider returns available when Messages file exists
- provider returns available from archive when Messages file missing
- provider returns cloudOnly when no file exists anywhere
- provider re-resolves after import cycle invalidates working data
- provider does not query overlay if Messages file exists (fast path)

### Archive Service Provider

- import-time archiving processes only image/* attachments
- import-time archiving skips already-archived attachments
- import-time archiving respects enabled/disabled toggle
- on-demand archiving fires when resolution finds unarchived live file
- archiving writes only to overlay DB, never to working DB

### Settings Provider

- archive enabled toggle persists across app restart
- archive size computation returns correct byte count
- archive count matches overlay table row count
- clear archive deletes files and overlay records

## Integration Tests

### Import-to-Archive Flow

- full import cycle with archiving enabled archives image attachments
- full import cycle with archiving disabled archives nothing
- second import cycle does not re-archive already-archived files
- migration wipe and re-project does not affect overlay archive records

### Resolution After Eviction Simulation

- import attachments with files present → archive them
- delete files from simulated Messages path
- resolution provider returns available from archive
- UI renders images from archive path

## Manual Test Matrix

### Live Local Image

- import with image files present at Messages paths
- view message with image attachment

Expected:
- image renders normally
- no placeholder or error state
- if archiving enabled, file is copied to archive directory

### Archived Image After Eviction

- import with image files present
- verify files are archived
- simulate eviction by renaming/removing Messages file
- view message with that attachment

Expected:
- image renders from archive
- no "Image unavailable" text
- optional badge or provenance indicator (future)

### Cloud-Only Image

- attachment record exists in working DB
- no file at Messages path
- no archive record in overlay

Expected:
- placeholder: "Stored in iCloud — not downloaded to this Mac"
- optional "Open in Messages" action
- no crash, no empty space, no SizedBox.shrink()

### Missing Attachment

- attachment record with invalid/corrupt metadata
- no file anywhere, no viable recovery

Expected:
- placeholder: "Attachment not available locally"
- record still renders, not suppressed

### Settings: Enable Archiving

- open Settings
- enable attachment archiving
- trigger import

Expected:
- newly discovered local files are archived
- archive size and count update in Settings

### Settings: Disable Archiving

- open Settings
- disable attachment archiving
- trigger import

Expected:
- no new files archived
- existing archive remains intact (not deleted)

### Settings: Clear Archive

- open Settings with populated archive
- tap Clear Archive
- confirm dialog

Expected:
- archive directory emptied
- overlay records deleted
- archive size shows 0
- previously archived images now resolve as cloudOnly or missing

### Large Archive Initial Population

- enable archiving on a Mac with many local image attachments
- trigger import

Expected:
- archiving runs in background without blocking UI
- import completes before archiving finishes (archiving is async)
- progress or count visible in Settings
- no duplicate archive entries after multiple import cycles
