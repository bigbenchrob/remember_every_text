# Deterministic Historical Attachment Recovery Tests

## Current Conformance Note (2026-06-06)

This test plan is historical. Current tests should prove source-scoped
attachment identity mapping, graph `message_to_attachment` endpoint integrity,
overlay archive idempotence, and no heuristic path-tail matching.

## Unit Tests

### Historical Snapshot Reader

- chat.db missing → validation error, no DB opened
- Attachments folder missing → validation error
- chat.db exists + Attachments folder exists → reader opens successfully
- WAL/SHM present alongside chat.db → detected and reported
- WAL/SHM absent → warning generated, reader proceeds
- Enumeration returns all message↔attachment pairs with non-null message GUID
- Records with NULL message GUID are excluded from enumeration
- Records with empty/whitespace-only message GUID are excluded
- Historical ROWIDs are used only within the JOIN, not in output identity
- hist_attachment_guid correctly populated (including NULL cases)
- Deterministic path rewrite: historical prefix stripped, user folder prepended
- File existence check at resolved path returns correct file_found status
- Summary counts: total pairs, files found, files missing, null-path records
- DB connection closed after enumeration completes
- DB opened with SQLITE_OPEN_READONLY (no write operations possible)

### Cross-Snapshot Mapper

- Import DB empty → precondition failure, refusal with diagnostic
- Import DB populated → mapper proceeds

#### Primary GUID Match (Step 1)

- hist_attachment_guid matches import DB guid → correct import_attachment_id returned
- Matched attachment confirmed in working DB for same message_guid → MAPPED
- Matched attachment exists in import DB but under different message → MISMATCH, unmapped
- hist_attachment_guid has no match in import DB → unmapped with guid_mismatch reason
- Multiple import DB rows with same guid (should not happen) → treated as unmapped

#### Single-Attachment Fallback (Step 2)

- hist_attachment_guid IS NULL + exactly one historical attachment + exactly one current
  attachment → fallback succeeds, match_method = single_attachment_fallback
- hist_attachment_guid IS NULL + multiple historical attachments → fallback rejected,
  unmapped with guid_null_multi_attachment
- hist_attachment_guid IS NULL + one historical + multiple current → fallback rejected,
  unmapped with guid_null_multi_attachment
- hist_attachment_guid IS NULL + one historical + zero current → unmapped with
  guid_null_no_current_attachment
- hist_attachment_guid IS NOT NULL but doesn't match → Step 2 NOT attempted (not a
  NULL case), classified as guid_mismatch

#### No Further Fallback (Step 3)

- When Steps 1 and 2 both fail → record classified UNMAPPED, no further attempt
- transfer_name matching is never attempted
- file size + created_at matching is never attempted
- ordinal position matching is never attempted

#### Message-Side Mapping

- Historical message fact present in current graph → message matched
- Historical message fact absent from current graph → message_not_in_graph
- Message present but has zero attachments in current graph → reported correctly

#### Summary Output

- mapped_by_guid count matches actual GUID matches
- mapped_by_single_fallback count matches actual fallback matches
- unmapped_message_missing count is accurate
- unmapped_guid_mismatch count is accurate
- unmapped_ambiguous count is accurate

### Archive Writer

- SHA-256 hash computed correctly for source file
- File stored at correct content-addressable path: {sha256_prefix}/{sha256_hex}{ext}
- Idempotency: existing (message_guid, import_attachment_id) → skip, no duplicate
- Overlay row inserted with correct fields (including provenance =
  'imported_historical_snapshot')
- Post-copy integrity: re-hash matches original hash
- Copy failure → file counted as failed, no overlay row created
- Progress reporting: running counts of archived, skipped, failed, bytes
- Database access only through centralized providers (never direct instantiation)

## Provider Tests

### Snapshot Reader Provider

- Exposes reader results as async state
- Error state on invalid inputs
- Cancellation stops enumeration

### Cross-Snapshot Mapper Provider

- Consumes Phase 1 output correctly
- Source-scoped import/graph access uses the graph-era database providers and
  read boundaries.
- Retained overlay-compatible archive keys, if still needed, are resolved
  through a named compatibility bridge rather than a retained import provider.
- Precondition check uses actual source-scoped import/graph attachment state.

### Archive Writer Provider

- Overlay DB access via existing Drift overlay provider
- Archive directory via attachmentArchiveDirectoryProvider
- Does not write to working DB under any circumstances

## Integration Tests

### Test 1: Deterministic Happy Path

- Provide historical chat.db with known messages and attachments
- Provide matching Attachments folder with all files present
- Ensure source-scoped import facts and graph message/attachment edges contain
  matching records
- Run full pipeline: reader → mapper → writer
- Verify: all files archived, all overlay rows created, resolver serves correctly

### Test 2: Historical File Missing

- Historical DB says attachment exists at path X
- File absent from Attachments folder
- Verify: files_missing reported correctly, no overlay row for missing file

### Test 3: Message Not in Current Graph

- Historical message has no match in the current conversation graph
- Verify: record classified as unmapped with message_not_in_graph reason

### Test 4: Attachment GUID Mismatch

- Historical attachment GUID exists but does not match any source-scoped import
  or graph attachment row
- Verify: record classified as unmapped, no fallback attempted

### Test 5: GUID NULL — Single Attachment (Fallback Exercised)

- Historical attachment GUID is NULL
- Message has exactly one attachment on both historical and current side
- Verify: fallback maps correctly, match_method = single_attachment_fallback

### Test 6: GUID NULL — Multi Attachment (Fallback Rejected)

- Historical attachment GUID is NULL
- Message has multiple attachments on either side
- Verify: record classified as unmapped_ambiguous, no overlay row

### Test 7: Multi-Attachment Message (GUID Present)

- Message has 3 attachments, each with distinct GUID
- Verify: each maps independently, all three overlay rows created with correct
  import_attachment_ids

### Test 8: Idempotent Re-Run

- Run deterministic import once
- Run again with same inputs
- Verify: no duplicate overlay rows, skipped_already_archived matches first run's
  archived_new count

### Test 9: WAL-Aware Correctness

- Provide chat.db + chat.db-wal + chat.db-shm → WAL-only rows included
- Provide chat.db without WAL/SHM → import proceeds with warning

### Test 10: Graph Attachment Facts Missing Precondition

- Source-scoped import/graph attachment facts have no rows
- Verify: historical recovery refuses to start, diagnostic message displayed

### Test 11: Live Archive Regression

- Run historical recovery
- Verify: live archive mode still works independently
- Verify: archiveAllAvailable() still runs after migration
- Verify: resolver still prioritizes current local file over archive
- Verify: newly-local files (simulated iCloud re-download) are archived on next pass

### Test 12: Existing Overlay Preservation

- Pre-existing overlay rows from prior heuristic imports remain valid
- Resolver serves them normally after deterministic run
- Deterministic import does not corrupt or duplicate them

## Manual Test Matrix

### Deterministic Recovery — Clean Snapshot

- Select valid historical chat.db and matching Attachments folder
- Run recovery

Expected:
- Validation passes, import proceeds
- Progress indicator shows phase transitions
- Results display complete breakdown: examined, found, mapped, archived
- Archiver files resolvable in message views

### Deterministic Recovery — Partial Snapshot

- Select historical chat.db with some attachments missing from folder

Expected:
- Import proceeds, files_missing count accurate
- Mapped-but-missing files reported, no overlay rows for them
- Other valid files still archived normally

### Deterministic Recovery — Wrong Folder

- Select historical chat.db but point to wrong Attachments folder

Expected:
- Most/all files reported as missing
- Zero or near-zero archived
- Clear results showing the mismatch

### Cancel Mid-Import

- Start recovery, cancel during archiving phase

Expected:
- Cooperative cancellation stops processing
- Already-archived files remain valid (partial progress preserved)
- No corrupt overlay rows

### Import DB Not Populated

- Attempt recovery before any live import+migration

Expected:
- Clear diagnostic: "Current import data must be populated first"
- Recovery does not start
