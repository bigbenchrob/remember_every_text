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

The MessageLens archive itself is **not** a cache. Its payloads are preservation
data and must remain outside every ordinary reset/rebuild operation. See the
canonical
[`Attachment Preservation Invariant`](ATTACHMENT-PRESERVATION-INVARIANT.md).

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

**Why overlay, not projection:** The decision to archive is user intent, not
source data. `working_ss.db` is a derived graph projection, and retired
`working.db` files are cleanup/diagnostic inventory only. Archive metadata
must survive graph rebuilds and must not depend on retired files.

### Provenance Values

| Value | Meaning |
|-------|---------|
| `archived` | Copied from live Messages Attachments during graph sync or archive compatibility lookup |
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
  ├─ 2. Expand live localPath from graph attachment evidence
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

### Import-Time and Graph-Sync Archiving

In the graph-era app path, `ChatDbChangeMonitor` archives newly imported live
graph source ranges and runs bounded graph attachment sweeps. Explicit
full/manual graph archive sweeps may still call
`AttachmentArchiveService.archiveAllAvailable()`. It processes graph attachment
facts with local paths when the archive is enabled.

`AttachmentArchiveService` is an orchestration boundary. It may decide when to
archive and report progress, but it should not own database queries or
filesystem mechanics directly. Graph candidate selection, archive record
persistence, recovery hints, archive directory resolution, and file copying are
behind named attachments feature ports.

For each attachment where:
- File exists at `localPath`
- No overlay record exists for this `(message_guid, import_attachment_id)` pair

Actions:
1. Compute SHA-256 hash (or use `sha256_hex` from import if available)
2. Copy into a recognizable temporary file beside the canonical destination
3. Flush, close, and verify exact size and SHA-256
4. Atomically install at `attachment_archive/{hash_prefix}/{hash}.{ext}` using
   no-overwrite semantics
5. Insert or reconcile the overlay `archived_attachments` row only after the
   payload exists
6. Verify resulting archive integrity

**Idempotency:** Already-archived pairs are skipped based on unique constraint.

### Preservation-Safe Installation

`AttachmentArchiveFileStore` is the sole canonical destination and physical
installation authority. Its verified installation primitive creates the temp
file in the destination directory and uses macOS POSIX `link(2)` to create the
final directory entry atomically. `link(2)` fails if that entry already exists;
it never replaces an existing payload. The writer then classifies the existing
file as identical or conflicting.

Temporary names contain `.messagelens-install-` and are never valid archive
payload names. Ordinary failures remove them. A process death may leave one
detectable temp file, but cannot expose it as a final attachment.

Metadata publication follows physical installation. If overlay reconciliation
fails after installation, the valid payload remains preservation data. Retry
finds the same content-addressed path, reports it already present, and
reconciles metadata without copying or overwriting.

> Historical attachment recovery must install payloads only through the
> canonical preservation-safe attachment writer. Do not copy directly into
> managed attachment storage.

The dormant MessageLens recovery installer additionally requires an active,
caller-specific `ArchiveMutationCapability` for
`attachmentReconciliation`. The mutation coordinator alone mints that proof.
It is valid only in its exact admitted async scope and cannot be retained for a
later install.

### Ongoing Archiving

The `ChatDbChangeMonitor` auto-sync cycle archives newly imported live graph
source ranges by calling `archiveGraphMessageSourceRange(...)`. It also runs
a bounded graph attachment sweep every 5 minutes via
`archiveNextGraphSweepChunk()` so files that appear later can be ingested.

Delayed retry treats a nonblank declared MIME type as the current eligibility
boundary for a conventional attachment. This includes images, video, audio,
PDF, text, and ordinary document MIME types. The downstream archive pipeline
remains type-agnostic: it resolves the current source path and archives any
eligible regular file.

NULL or blank MIME rows are not automatically retried. Current production
examples use `.pluginPayloadAttachment` paths and may represent opaque Apple
or extension payloads rather than durable user-visible attachments. They
remain visible in attachment evidence and inventory, but their file-
preservation semantics require a separate policy decision.

The resolver can also trigger on-demand archive ingestion when archive mode is
enabled and it sees a live file that is not yet archived.

### Concurrency

Bulk archive progress supports pause/cancel. Current file copy and hash work is
performed by the archive service; do not assume there is a separate isolate
boundary unless current code introduces one.

## File Inventory

| File | Role |
|------|------|
| `lib/features/attachments/application/attachment_archive_service_provider.dart` | Archive orchestration, progress, and policy flow |
| `lib/features/attachments/application/attachment_archive_file_store.dart` | File-copy, hash, home-expansion, and archive integrity file boundary |
| `lib/features/attachments/application/message_lens_attachment_recovery_installer.dart` | Dormant typed payload-install and metadata-reconciliation orchestration |
| `lib/features/attachments/application/verified_donor_attachment_payload.dart` | Read-only capability consumed instead of donor path strings |
| `lib/features/attachments/application/attachment_archive_write_store.dart` | Archive record, recovery hint, and integrity-row persistence boundary |
| `lib/features/attachments/application/graph_attachment_archive_candidate_reader.dart` | Graph attachment candidate selection boundary |
| `lib/features/attachments/application/attachment_resolver_provider.dart` | Multi-source resolution pipeline |
| `lib/features/attachments/application/archive_settings_provider.dart` | Archive directory, retention config |
| `lib/features/attachments/domain/entities/resolved_attachment.dart` | Resolution result with availability + provenance |
| `lib/features/attachments/domain/constants/attachment_provenance.dart` | Provenance enum |
| `lib/features/attachments/domain/constants/resolved_attachment_availability.dart` | Runtime display availability enum |
| `lib/features/attachments/infrastructure/repositories/overlay_attachment_archive_write_store.dart` | Overlay-backed archive write-store implementation |
| `lib/features/attachments/infrastructure/repositories/darwin_atomic_no_overwrite_file_installer.dart` | macOS `link(2)` atomic no-overwrite primitive |
| `lib/features/attachments/infrastructure/repositories/sqlite_message_lens_attachment_donor_evidence_reader.dart` | Read-only, fail-closed donor compatibility reader |
| `lib/features/attachments/infrastructure/repositories/import_ledger_message_lens_attachment_evidence_reader.dart` | Current evidence through canonical ledger/archive stores |
| `lib/essentials/db/infrastructure/.../overlay_database.dart` | `archived_attachments` table schema |

## Invariants

1. Archive metadata lives in overlay DB only — never in `working_ss.db` or retired `working.db`.
2. Graph `attachments` rows remain source projections — not durable file-store records.
3. Graph incremental sync uses source-range archiving plus periodic graph
   attachment sweeps. Delayed sweeps retry conventional attachments with
   declared MIME types and deliberately exclude opaque NULL/blank-MIME
   payloads pending policy. Explicit full/manual graph archive sweeps may still
   call `archiveAllAvailable()`.
4. The Messages Attachments folder is never written to.
5. Content-addressable naming provides natural deduplication.
6. The archive is additive — entries survive re-import and graph rebuilds.
   Archived payloads are preservation data and are never an ordinary reset,
   recovery, migration-cleanup, or test-cleanup target.
7. Archive-enabled resolution displays from the archive and treats live Messages paths as ingestion sources.
8. Archive service code must use feature ports for graph candidates, archive writes, settings, directory paths, and file work; Drift/overlay SQL belongs in infrastructure repositories.
9. Final payload installation must be atomic and no-overwrite. A prior
   existence check alone is not an installation guarantee.
10. Archive metadata must never claim success before the corresponding final
    payload exists.
11. MessageLens attachment recovery cannot invoke its installer without an
    active exact-scope `attachmentReconciliation` capability minted by the
    archive mutation coordinator.
