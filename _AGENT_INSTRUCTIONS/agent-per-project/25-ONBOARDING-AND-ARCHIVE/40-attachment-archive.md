# Living Attachments Archive

## Problem

macOS treats `~/Library/Messages/Attachments` as a volatile cache. When
Messages in iCloud is active with storage optimization, Apple silently evicts
local attachment files to free disk space. The database records in `chat.db`
remain intact, directory structures may persist, but the actual files vanish.

Apple Messages can re-download evicted files on demand. MessageLens cannot.

This creates a fundamental mismatch: MessageLens assumes attachments are
locally persistent files; macOS treats them as a re-downloadable cache.

## Solution: App-Owned Archive

MessageLens maintains its own durable copy of attachment files in
content-addressable storage, independent of Apple's eviction decisions.

### Core Principle

The Messages Attachments folder is treated as a cache — useful when available,
but never trusted as permanent. When archive mode is enabled, the MessageLens
archive is the display source; live Messages files are ingestion sources.

## Architecture

### Storage Layout

Root: `~/Library/Application Support/com.bigbenchsoftware.MessageLens/attachment_archive/`

```
attachment_archive/
├── a1/
│   └── a1b2c3d4...full-sha256...e5f6.jpg
├── f0/
│   └── f09a12...full-sha256...8bc3.png
└── _by_id/
    └── 12345.heic          (fallback when sha256_hex is null)
```

**Content addressing:** Files are named by their SHA-256 hash with a
2-character prefix subdirectory to prevent filesystem performance degradation.
This provides natural deduplication — the same file sent twice maps to one
archive copy.

**Fallback:** When `sha256_hex` is null (legacy imports before hashing was
added), the file is stored as `{import_attachment_id}.{extension}` in the
`_by_id/` subdirectory.

### Overlay Database Schema

Table: `archived_attachments` in `user_overlays.db`

| Column | Type | Purpose |
|--------|------|---------|
| `id` | INTEGER PK | Auto-increment |
| `message_guid` | TEXT NOT NULL | Parent message GUID |
| `import_attachment_id` | INTEGER NOT NULL | Original `chat.db` ROWID |
| `archive_relative_path` | TEXT NOT NULL | Path within `attachment_archive/` |
| `archived_at_utc` | TEXT NOT NULL | ISO 8601 archive timestamp |
| `file_size_bytes` | INTEGER NOT NULL | Archived file size |
| `content_hash` | TEXT | SHA-256 hex (also used as filename) |
| `provenance` | TEXT NOT NULL | `'archived'` or `'imported_historical_snapshot'` |
| `original_local_path` | TEXT | Messages path at archive time (audit) |

**Unique constraint:** `(message_guid, import_attachment_id)`

**Why overlay, not working:** The decision to archive is user intent, not
source data. The working database is a pure projection of `chat.db`, rebuilt
on every migration cycle. Archive metadata must survive migration rebuilds.

### Provenance Values

| Value | Meaning |
|-------|---------|
| `archived` | Copied from live Messages Attachments during import/migration |
| `imported_historical_snapshot` | Recovered from a Time Machine or backup snapshot |

### Current Caveat: Attachment Provenance Naming

Attachment provenance naming is currently inconsistent:

* deterministic recovery writes `imported_historical_snapshot`
* the overlay schema comment and resolver logic may still reference
  `imported_historical`
* this inconsistency is known and should not be relied on for branching logic

The current docs use the value written by the recovery provider. Resolver
normalization should be reviewed in follow-up.

## Resolution Pipeline

When a widget needs to display an attachment, it uses the resolution provider
instead of inline `File.existsSync()` calls.

Archive-enabled mode:

```
AttachmentResolverProvider(attachment)
  │
  ├─ 1. Query overlay archived_attachments
  │   └─ Check file exists at attachment_archive/...
  │       ├─ YES → available (provenance: archived)
  │       └─ NO → continue
  │
  ├─ 2. Expand live localPath from working DB
  │   └─ Check file exists at ~/Library/Messages/Attachments/...
  │       ├─ YES + import_attachment_id → trigger archive ingestion,
  │       │   return pendingArchive
  │       ├─ YES without archive key → unavailableAwaitingRecovery
  │       └─ NO → continue
  │
  └─ 3. No displayable archive file
      ├─ has local path or import_attachment_id → unavailableAwaitingRecovery
      └─ no viable key/path → nonRecoverable
```

Live-only mode, when the archive is disabled, can display directly from the
Messages path and otherwise returns the same recoverability states.

### Availability States

| State | Meaning | UI treatment |
|-------|---------|-------------|
| `pendingArchive` | Live file exists and archive ingestion has been triggered | Show pending/recovery state until archive-backed display is ready |
| `available` | A displayable file exists under the current source policy | Render normally |
| `unavailableAwaitingRecovery` | Not displayable now, but recovery or later local availability may make it displayable | Show recoverable unavailable state |
| `nonRecoverable` | No viable live or archive recovery key/path | Show terminal unavailable state |

**Rule:** No attachment record is ever suppressed because its file is missing.
The record renders with an appropriate availability state. See
[`10-DATABASES/INVIOLATE_RULES.md`](../10-DATABASES/INVIOLATE_RULES.md) Rule 2.

## Archive Service

### Import-Time (Bulk) Archiving

After a successful full migration, `DbImportControlViewModel` launches
`AttachmentArchiveService.archiveAllAvailable()` fire-and-forget. It processes
working attachments with local paths when the archive is enabled.

For each attachment where:
- File exists at `localPath`
- No overlay record exists for this `(message_guid, import_attachment_id)` pair

Actions:
1. Compute SHA-256 hash (or use `sha256_hex` from import if available)
2. Copy file to `attachment_archive/{hash_prefix}/{hash}.{ext}`
3. Insert overlay `archived_attachments` row
4. Verify integrity post-copy (re-hash comparison)

**Idempotency:** Already-archived pairs are skipped based on unique constraint.

### Ongoing Archiving

The `ChatDbChangeMonitor` auto-sync cycle archives newly imported batches before
incremental migration by calling `archiveImportedBatch(batchId:)`. It also runs
a bounded working-attachment sweep every 5 minutes via
`archiveNextWorkingSweepChunk()` so files that appear later can be ingested.

The resolver can also trigger on-demand archive ingestion when archive mode is
enabled and it sees a live file that is not yet archived.

### Concurrency

Bulk archive progress supports pause/cancel. Current file copy and hash work is
performed by the archive service; do not assume there is a separate isolate
boundary unless current code introduces one.

## File Inventory

| File | Role |
|------|------|
| `lib/features/attachments/application/attachment_archive_service_provider.dart` | Archive copy, hash, overlay write |
| `lib/features/attachments/application/attachment_resolver_provider.dart` | Multi-source resolution pipeline |
| `lib/features/attachments/application/archive_settings_provider.dart` | Archive directory, retention config |
| `lib/features/attachments/domain/entities/resolved_attachment.dart` | Resolution result with availability + provenance |
| `lib/features/attachments/domain/constants/attachment_provenance.dart` | Provenance enum |
| `lib/features/attachments/domain/constants/resolved_attachment_availability.dart` | Runtime display availability enum |
| `lib/essentials/db/infrastructure/.../overlay_database.dart` | `archived_attachments` table schema |

## Invariants

1. Archive metadata lives in overlay DB only — never in working DB.
2. Working DB `attachments` table is unchanged — pure `chat.db` projection.
3. `archiveAllAvailable()` is launched after successful full migrations; incremental sync uses batch archiving plus periodic sweeps.
4. The Messages Attachments folder is never written to.
5. Content-addressable naming provides natural deduplication.
6. The archive is additive — entries survive re-import and migration rebuilds.
7. Archive-enabled resolution displays from the archive and treats live Messages paths as ingestion sources.
