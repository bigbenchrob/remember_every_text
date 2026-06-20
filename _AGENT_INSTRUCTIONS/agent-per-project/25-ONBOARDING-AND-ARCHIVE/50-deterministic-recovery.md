# Deterministic Historical Attachment Recovery

## Background

When a user has a Time Machine backup or manual backup that includes both the
historical `chat.db` and the matching `Attachments` folder, MessageLens can
recover files that Apple has since evicted from local storage.

An initial heuristic approach — matching files by path-tail coincidence and
SHA-256 hash — was proven fundamentally broken by forensic analysis:

| Failure mode | Impact |
|-------------|--------|
| Sent-attachment directory conventions change (`at_0_` GUID prefix) | Path-tail matching breaks |
| `sha256_hex` frequently NULL in retained historical working projections | Hash matching disabled there |
| Common filenames (`IMG_1234.jpeg`) | False-positive ambiguity |
| **Observed success rate** | **~40%** |

The heuristic system was replaced with a deterministic three-layer mapping flow.
The current implementation maps through source-scoped graph identity first.
Retained `macos_import.db` / `working.db` identity is historical cleanup
context only, not the ordinary recovery direction.

## Three-Layer Read Topology

```
Layer 1: Historical snapshot DB (user-provided)
  ├─ Opened SQLITE_OPEN_READONLY — never mutated
  ├─ Source of: attachment.guid, message.guid, message↔attachment joins
  └─ Provides authoritative relationships from the era of the backup

Layer 2: Current source-scoped import DB (via importDatabaseProvider)
  ├─ Source of: attachments.guid → attachment ss_id bridge
  ├─ Preserves Apple's attachment.guid plus source_id/source_rowid
  └─ Must be populated from at least one source-scoped graph build

Layer 3: Current conversation graph + overlay
  ├─ Source of: message ss_id, attachment ss_id, and message_to_attachment edges
  └─ Target of: overlay archived_attachments row insertion
```

**Precondition:** The current source-scoped import DB and conversation graph
must contain data from at least one graph build. If empty or absent, recovery
refuses with a diagnostic explaining why.

## Identity Mapping

### The Problem

Apple's `attachment.guid` is preserved in the source-scoped import DB.
The conversation graph uses canonical `ss_id` endpoints and
`message_to_attachment` topology. The overlay archive table still keys on the
existing compatibility pair `(message_guid, import_attachment_id)`, where
`import_attachment_id` is currently the live-source attachment ROWID unpacked
from the attachment `ss_id`.

Mapping a historical attachment to its current overlay key therefore bridges:

```
historical message/attachment GUIDs
  -> source-scoped import attachment ss_id
  -> graph message_to_attachment edge
  -> overlay-compatible (message_guid, import_attachment_id)
```

This keeps current recovery aligned with graph topology while preserving
existing archive metadata compatibility.

### Step 1: GUID Match (Primary)

For each `(hist_message_guid, hist_attachment_guid)` pair from the snapshot:

1. Query source-scoped import DB for attachment `ss_id` by
   `(source_id, hist_attachment_guid)`
2. Query the conversation graph for current message `ss_id` by source-scoped
   message GUID
3. Verify the pair in graph topology through `message_to_attachment`
4. Confirmed → **MAPPED** with `match_method = 'guid_match'`

### Step 2: Single-Attachment Fallback

Permitted ONLY when ALL three conditions hold:

1. `hist_attachment_guid` IS NULL (not different — specifically NULL)
2. Historical message has exactly ONE attachment (from `message_attachment_join`)
3. Current graph topology has exactly ONE attachment for that message

If all three → the single `import_attachment_id` is the match.
`match_method = 'single_attachment_fallback'`

If ANY condition fails → UNMAPPED.

### No Step 3

There is no further fallback. Explicitly prohibited:

- Transfer name matching
- File size + creation date matching
- Ordinal position matching
- Path-tail matching
- String similarity of any kind

Records that cannot be mapped via Step 1 or Step 2 are reported as unmapped
with a specific reason.

## Unmapped Reasons

| Reason | Cause |
|--------|-------|
| `message_not_in_working` | Historical `message.guid` not found in the current graph. The enum name is retained for compatibility. |
| `guid_mismatch` | GUID doesn't match any source-scoped import attachment record |
| `guid_message_mismatch` | GUID matched an import row, but graph topology does not connect it to the expected current message |
| `guid_null_multi_attachment` | NULL GUID + multiple attachments (ambiguous) |
| `guid_null_no_current_attachment` | NULL GUID + no current attachment for that message |
| `file_not_found` | Mapped successfully but file missing from backup folder |

## File Resolution

For each mapped historical row with `hist_local_path`:

1. Strip the historical root prefix (`~/Library/Messages/Attachments/`)
2. Append relative remainder to user-selected historical Attachments folder
3. Test file existence at that exact path
4. Result: found (with full resolved path) or missing

**No searching, no guessing.** The path rewrite is deterministic.

## Archive Writing

Reuses the existing content-addressable infrastructure:

1. SHA-256 hash source file
2. Store at `{hash_prefix}/{hash_hex}.{extension}` in archive directory
3. Idempotency: skip if `(message_guid, import_attachment_id)` already exists in overlay
4. Insert overlay row with `provenance = 'imported_historical_snapshot'`
5. Verify integrity post-copy (re-hash comparison)

## Recovery Phases

The `DeterministicRecoveryProvider` tracks progress through phases:

| Phase | Description |
|-------|-------------|
| `idle` | Not running |
| `validating` | Checking snapshot DB and import DB preconditions |
| `readingSnapshot` | Enumerating message↔attachment pairs from historical DB |
| `mapping` | Cross-snapshot GUID mapping through import DB bridge |
| `archiving` | Copying files and writing overlay rows |
| `complete` | Done — results available |
| `error` | Validation or recovery failed before completion |

## Results Model

```
DeterministicRecoveryResult:
  totalHistoricalPairs: int     — total message↔attachment pairs in snapshot
  filesFound: int               — files physically present in backup folder
  filesMissing: int             — files absent from backup folder
  nullPathRecords: int          — historical rows with no local path
  mappedByGuid: int             — matched via GUID (Step 1)
  mappedBySingleFallback: int   — matched via single-attachment fallback (Step 2)
  unmappedMessageMissing: int
  unmappedGuidMismatch: int     — includes message-mismatch cases
  unmappedAmbiguous: int
  unmappedNoCurrentAttachment: int
  unmappedFileMissing: int
  archivedNew: int              — new archive entries written
  skippedAlreadyArchived: int   — skipped (idempotent)
  archiveFailed: int
  totalBytesArchived: int       — storage consumed
  walDetected: bool
  shmDetected: bool
```

## User-Facing Flow

1. User navigates to Settings → Attachment Archive → "Recover from Backup"
2. User selects historical `chat.db` file
3. User selects matching `Attachments` folder
4. System validates both inputs
5. Progress display shows phases and counts
6. Results summary shows complete breakdown of outcomes

## File Inventory

| File | Role |
|------|------|
| `lib/features/attachments/application/deterministic_recovery_provider.dart` | Multi-phase recovery orchestration |
| `lib/features/attachments/application/historical_snapshot_reader.dart` | Read-only historical `chat.db` enumeration |
| `lib/features/attachments/application/graph_cross_snapshot_mapper.dart` | Historical snapshot → source-scoped import → graph topology mapper |
| `lib/features/attachments/application/attachment_archive_service_provider.dart` | Shared archive write infrastructure |

## Invariants

1. Historical snapshot is opened `SQLITE_OPEN_READONLY` — never mutated.
2. Historical ROWIDs are join-traversal-only — they never escape into overlay or runtime identity.
3. Conversation graph projection and retained working files are never written
   to by recovery.
4. Overlay receives archive metadata only — no structural schema changes.
5. No heuristic fallback exists.
6. Unmapped records are counted and reported, never silently dropped.
7. `archiveAllAvailable()` remains unchanged — the living archive is preserved.
8. Idempotent re-run creates no duplicates.

## Current Caveat: Attachment Provenance Naming

Attachment provenance naming is currently inconsistent:

* deterministic recovery writes `imported_historical_snapshot`
* the overlay schema comment and resolver logic may still reference
  `imported_historical`
* this inconsistency is known and should not be relied on for branching logic

Treat the recovery provider's written value as current behavior, but review
provenance normalization before relying on historical provenance for UI
branching.
