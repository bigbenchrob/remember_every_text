# Living Attachments Archive Proposal

## Problem

macOS treats `~/Library/Messages/Attachments` as a volatile cache. When
Messages in iCloud is active with storage optimization enabled, Apple silently
evicts local attachment files to free disk space. The database records in
chat.db remain intact, the directory structure may persist, but the files
themselves are gone.

Apple Messages can re-download evicted files on demand. MessageLens cannot.

This creates a fundamental mismatch:

- MessageLens assumes attachments are locally persistent files
- macOS treats them as a re-downloadable cache

Real-world impact observed: a user's Attachments folder shrank from 42 GB to
6 GB overnight. chat.db still references every attachment. MessageLens renders
"Image unavailable" for the majority of image messages.

## Goal

Introduce a MessageLens-managed attachment archive that:

- preserves locally available attachment files at import time so they remain
  accessible even after macOS evicts them from the Messages store
- explicitly models attachment availability state rather than treating
  missing files as broken
- resolves attachments through a prioritized multi-source pipeline
  (Messages path first, then archive, then cloud-only status)
- stores archive metadata in the overlay database, keeping the working
  database a pure projection of chat.db
- makes archiving opt-in, clearly explained, and storage-configurable
- replaces "Image unavailable" with state-aware messaging that communicates
  what happened and what the user can do

This transforms MessageLens from "a viewer of Apple's local cache" into
"a durable, user-owned archive and navigation layer for Messages data."

## Non-Goals

- replacing the import or migration pipelines
- writing files back into Apple's Attachments directory
- implementing iCloud re-download from within MessageLens
- archiving non-image attachment types in Phase 1
  (video and other types are future phases)
- building a full media browser or gallery view
- modifying the working database schema to hold archive metadata

## Product Direction

### User-facing feature name

"Preserve Attachments Locally"

### User-facing explanation

> macOS may remove local copies of your older Messages attachments to save
> disk space. MessageLens can preserve its own local copy so your images
> remain available here even if macOS removes them later.

### Modes

1. **Standard Mode** (default) — use only currently available local
   attachments; no archiving
2. **Archive Mode** (opt-in) — MessageLens copies attachment files into its
   own archive as they are discovered locally during import

### Opt-in prompt

During onboarding or first import, present the user with a clear explanation
of what archiving does, how much storage it may consume (based on current
Attachments folder size), and allow them to enable or skip it. The choice
should be revisitable in Settings.

## Core Principles

### 1. The Messages Attachments Folder Is a Cache

`~/Library/Messages/Attachments` is mutable, non-authoritative, and subject
to eviction. It must never be treated as durable storage.

### 2. Attachment Identity Must Be Decoupled from File Path

`localPath` in chat.db can change after iCloud re-download. It must be
treated as cached location metadata, not identity. Identity is the
attachment's ROWID/GUID from chat.db, preserved as `importAttachmentId` in
the working database.

### 3. MessageLens Must Own Its Archive

The archive must be app-controlled, durable, independent of Apple's storage
decisions, and never overwritten by system processes.

### 4. Archiving Must Be Explicit and User-Authorized

Because this feature consumes storage, it must be opt-in, clearly explained,
and configurable (scope, storage budget, retention).

### 5. Resolution Must Be Multi-Source

Widgets must not depend on a single file path. A resolution provider must
try Messages path, then archive path, then report cloud-only or missing.

### 6. Archive Metadata Is User Intent — Overlay DB Only

The decision to preserve an attachment is a user action, not source data.
Archive metadata (archive path, archived-at timestamp, provenance, content
hash) belongs in the overlay database. The working database remains a pure
projection of chat.db, rebuilt entirely on every migration. Providers merge
working + overlay at read time, overlay wins on conflict.

## Attachment Availability Model

Every attachment exists in one of these states at resolution time:

| State | Meaning |
|---|---|
| `available` | File found — resolved from Messages path or archive |
| `cloudOnly` | Known in chat.db, no local file anywhere |
| `missing` | No file, no viable recovery path |

Provenance (where the resolved file came from) is tracked as metadata on
the overlay record, not as a status dimension:

| Provenance | Meaning |
|---|---|
| `messagesLive` | Resolved from current `~/Library/Messages/Attachments` |
| `archived` | Resolved from MessageLens archive |
| `importedHistorical` | Recovered from a user-supplied backup (Phase 2) |

This reconciles with the existing `AttachmentStatus` enum, extending it
with `cloudOnly` rather than replacing the enum entirely.

## Architecture Overview

### Two Sources of Truth

1. **Messages Store** (volatile) — `~/Library/Messages/Attachments`
2. **MessageLens Archive** (durable) — `~/Library/Application Support/com.bigbenchsoftware.MessageLens/attachment_archive/`

### Resolution Pipeline

A Riverpod provider resolves an attachment's file by trying sources in order:

1. Attempt `localPath` from working DB (expanded from `~/`)
2. If file missing → attempt archive path from overlay DB
3. If still missing → report `cloudOnly` or `missing`
4. Optionally offer "Open in Messages" as a user action

This provider replaces the inline `file.existsSync()` calls currently
embedded in `ImageMessageTile` and `VideoMessageTile`.

### Archive Storage Strategy

Content-addressable storage using the `sha256Hex` already computed during
import:

```
attachment_archive/
└── {first-2-chars-of-hash}/
    └── {full-sha256}.{original-extension}
```

Benefits:
- Natural deduplication (same file sent twice → one archive copy)
- Path stability (never changes regardless of Apple path churn)
- Simple integrity verification (hash the file, compare to name)

When `sha256Hex` is null (legacy imports before hashing was added), fall
back to `{importAttachmentId}.{ext}` as the archive filename.

### Database Split

**Working DB (`attachments` table)** — unchanged:
- Remains a pure projection of chat.db
- `localPath` refreshed every import cycle
- `sha256Hex` populated during import

**Overlay DB (new `archived_attachments` table)**:
- `attachment_guid` (TEXT, unique) — stable link to working DB
- `archive_relative_path` (TEXT) — path within `attachment_archive/`
- `archived_at` (TEXT, ISO 8601)
- `file_size_bytes` (INTEGER)
- `content_hash` (TEXT) — sha256, doubles as filename
- `provenance` (TEXT) — `archived` | `imported_historical`
- `original_local_path` (TEXT) — the Messages path at archive time

**Merge provider**: combines working attachment record + overlay archive
record at read time. If both exist, overlay wins.

### Archiving Trigger: Import-Time

Primary ingestion hook — during each import/migration cycle, after working
DB is projected:

1. Scan working `attachments` where file exists at `localPath`
2. For each file not already in the archive (check by hash or guid)
3. Copy file into content-addressable archive
4. Write overlay record

This is the simplest, most reliable trigger and naturally captures both
existing and new attachments.

### On-Demand Archiving (Secondary)

When a user views an attachment that is live at its Messages path but not
yet archived: archive it immediately. This catches files that appeared
between import cycles (e.g., iCloud re-download).

## Phasing

### Phase 1 — Core Archive Infrastructure

- Overlay table for archive metadata
- Content-addressable archive directory management
- Import-time archiving of image attachments
- Resolution provider (Messages path → archive → cloud-only)
- Update `ImageMessageTile` to use resolution provider
- State-aware unavailability messaging in the UI
- Opt-in toggle in Settings with storage display

### Phase 2 — Historical Import (Time Machine Recovery)

- User points MessageLens at a folder (recovered Attachments backup)
- App walks folder, computes hashes, matches to known attachment records
- Copies matched files into content-addressable archive
- Creates overlay records with `provenance: imported_historical`

### Phase 3 — Extended Media Types

- Extend archiving to video attachments
- Extend to other file types if user opts in
- Storage budget enforcement and retention policies

## Anti-Patterns (Strictly Forbidden)

1. Treating `localPath` as immutable or as identity
2. Relying solely on Messages folder for rendering
3. Overwriting Apple's Attachments directory
4. Storing archive metadata on working DB tables (overlay only)
5. Silent archiving without user consent
6. Presenting cloud-only attachments as "broken"
7. Dual-writing to both overlay and working DB
8. Suppressing attachment records that have missing files

## Existing Pipeline — No Changes Needed

The seed.txt raised concerns about stale paths and append-only imports.
The existing pipeline already handles this:

- Import DB is rebuilt from a fresh chat.db snapshot each cycle
- Migration wipes and re-projects working from import
- `localPath` is refreshed automatically every import
- Path churn after iCloud re-download is picked up on next import

No special "update path" or "upsert" logic is required.

## Success Criteria

After Phase 1:

- Attachments archived during import remain viewable after macOS eviction
- "Image unavailable" is replaced with state-aware messaging
- Users understand why an attachment is unavailable and what state it is in
- Archive growth is controlled, transparent, and opt-in
- No stale-path rendering issues remain
- Working DB is untouched; all archive metadata is in overlay
- Resolution pipeline is testable via provider, not embedded in widgets

## Deliverables

- `DESIGN_NOTES.md` — architecture, domain model, database schema, provider
  design
- `CHECKLIST.md` — phased implementation work
- `TESTS.md` — unit, provider, and manual test scenarios
