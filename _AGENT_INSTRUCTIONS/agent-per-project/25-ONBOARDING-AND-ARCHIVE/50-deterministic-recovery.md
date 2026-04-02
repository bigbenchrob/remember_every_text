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
| `sha256_hex` frequently NULL in working DB | Hash matching disabled |
| Common filenames (`IMG_1234.jpeg`) | False-positive ambiguity |
| **Observed success rate** | **~40%** |

The heuristic system was replaced with a deterministic three-layer mapping flow.

## Three-Layer Read Topology

```
Layer 1: Historical snapshot DB (user-provided)
  ├─ Opened SQLITE_OPEN_READONLY — never mutated
  ├─ Source of: attachment.guid, message.guid, message↔attachment joins
  └─ Provides authoritative relationships from the era of the backup

Layer 2: Current import DB (via sqfliteImportDatabaseProvider)
  ├─ Source of: attachments.guid → attachments.id bridge
  ├─ ONLY layer holding BOTH Apple's attachment.guid
  │   AND the id that becomes import_attachment_id in working DB
  └─ Must be populated from at least one live import cycle

Layer 3: Current working DB + overlay
  ├─ Source of: (message_guid, import_attachment_id) runtime identity
  └─ Target of: overlay archived_attachments row insertion
```

**Precondition:** The current import DB must contain data from at least one
live import/migration cycle. If empty or absent, recovery refuses with a
diagnostic explaining why.

## Identity Mapping

### The Problem

Apple's `attachment.guid` is preserved in the import DB but is NOT projected
into the working DB. The working DB uses `import_attachment_id` (= import DB
`attachments.id`). The overlay keys on `(message_guid, import_attachment_id)`.

Mapping a historical attachment to its current overlay key requires bridging
through the import DB.

### Step 1: GUID Match (Primary)

For each `(hist_message_guid, hist_attachment_guid)` pair from the snapshot:

1. Query import DB: `SELECT id FROM attachments WHERE guid = :hist_attachment_guid`
2. If exactly one row → candidate `import_attachment_id`
3. Verify the pair in working DB:
   `SELECT 1 FROM attachments WHERE message_guid = :hist_message_guid AND import_attachment_id = :id`
4. Confirmed → **MAPPED** with `match_method = 'guid_match'`

### Step 2: Single-Attachment Fallback

Permitted ONLY when ALL three conditions hold:

1. `hist_attachment_guid` IS NULL (not different — specifically NULL)
2. Historical message has exactly ONE attachment (from `message_attachment_join`)
3. Current working DB has exactly ONE attachment for that `message_guid`

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
| `message_not_in_working` | Historical `message.guid` not found in current working DB |
| `guid_mismatch` | GUID doesn't match any import DB record |
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

## Results Model

```
DeterministicRecoveryResult:
  totalHistoricalPairs: int     — total message↔attachment pairs in snapshot
  filesFound: int               — files physically present in backup folder
  filesMissing: int             — files absent from backup folder
  mappedByGuid: int             — matched via GUID (Step 1)
  mappedBySingleFallback: int   — matched via single-attachment fallback (Step 2)
  unmappedVariants: Map<UnmappedReason, int>  — breakdown by reason
  archivedNew: int              — new archive entries written
  alreadyArchived: int          — skipped (idempotent)
  totalBytesArchived: int       — storage consumed
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
| `lib/features/attachments/application/attachment_archive_service_provider.dart` | Shared archive write infrastructure |

## Invariants

1. Historical snapshot is opened `SQLITE_OPEN_READONLY` — never mutated.
2. Historical ROWIDs are join-traversal-only — they never escape into overlay or runtime identity.
3. Working DB is never written to by recovery.
4. Overlay receives archive metadata only — no structural schema changes.
5. No heuristic fallback exists.
6. Unmapped records are counted and reported, never silently dropped.
7. `archiveAllAvailable()` remains unchanged — the living archive is preserved.
8. Idempotent re-run creates no duplicates.
