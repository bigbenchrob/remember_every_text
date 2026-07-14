# Deterministic Historical Attachment Recovery Checklist

## Current Conformance Note (2026-06-06)

This checklist is historical. Future deterministic recovery implementation
should target source-scoped graph attachment identity and the current archive
recovery identity plan. Do not implement new retained `working.db` attachment
mapping steps from this checklist without explicit archive/recovery review.

## Phase 0 — Remove Heuristic Historical Importer

- [ ] DELETE `lib/features/attachments/application/historical_import_provider.dart`
- [ ] MODIFY `attachment_archive_settings_content.dart` — remove `_HistoricalImportSection` widget and "Import from Backup…" button
- [ ] Remove any dead references to `historicalImportProvider` across codebase
- [ ] Update settings/debug text that implies folder-only recovery is supported
- [ ] Verify app compiles and runs without removed code
- [ ] Verify live archive mode is completely unaffected
- [ ] Verify existing overlay `archived_attachments` rows from prior heuristic runs remain untouched

## Phase 1 — Build Deterministic Snapshot Reader

- [ ] CREATE `lib/features/attachments/application/historical_snapshot_reader.dart`
- [ ] Implement input validation: chat.db exists, Attachments folder exists, WAL/SHM detection
- [ ] Open historical chat.db with `SQLITE_OPEN_READONLY` flag (separate connection, not app's import DB)
- [ ] Implement enumeration query: `message_attachment_join` → `message` → `attachment` JOIN
- [ ] Filter: `m.guid IS NOT NULL AND LENGTH(TRIM(m.guid)) > 0`
- [ ] Implement deterministic file path resolution: prefix replacement (no searching, no guessing)
- [ ] Test file existence at resolved path
- [ ] Return `HistoricalAttachmentRecord` structs with all fields
- [ ] Return summary counts: total pairs, files found, files missing, null-path records
- [ ] Close historical DB connection after enumeration completes
- [ ] Handle WAL-only rows correctly (SQLite incorporates WAL on read-only open)
- [ ] Handle WAL/SHM absent case with warning

## Phase 2 — Build Cross-Snapshot Mapper

- [ ] CREATE `lib/features/attachments/application/cross_snapshot_mapper.dart`
- [ ] Implement precondition check: source-scoped import facts and graph
      message/attachment edges must be populated for the selected source
- [ ] Implement message-side mapping: historical source message fact →
      graph `message_ss_id`
- [ ] Implement Step 1 — Primary match: historical attachment source fact →
      graph `attachment_ss_id`
- [ ] Verify matched attachment belongs to the correct graph message edge
- [ ] Implement Step 2 — Fallback (NULL GUID only): three conditions must ALL hold
  - [ ] `hist_attachment_guid` IS NULL
  - [ ] Historical message has EXACTLY ONE attachment
  - [ ] Current graph has EXACTLY ONE attachment for that message scope
- [ ] Implement Step 3 — No further fallback (classify as UNMAPPED)
- [ ] Return `MappedAttachmentRecord` structs with `match_method` field
- [ ] Return unmapped records with specific `unmapped_reason` enum values
- [ ] Return summary counts: mapped by GUID, mapped by fallback, unmapped by category
- [ ] No heuristic matching of any kind (transfer_name, file size, basename, ordinal)

## Phase 3 — Wire Archive Writer

- [ ] Reuse existing content-addressable archive infrastructure
- [ ] SHA-256 hash source files
- [ ] Store files at `{sha256_prefix}/{sha256_hex}{extension}` in archive directory
- [ ] Idempotency check: skip if graph-native or retained overlay-compatible
      archive key already exists
- [ ] Insert overlay row with provenance `imported_historical_snapshot`
- [ ] Verify integrity after copy (re-hash and compare)
- [ ] Access databases only through centralized graph/source-scoped/overlay
      providers and named retained compatibility bridges
- [ ] Report progress: files archived, skipped, failed, bytes archived
- [ ] Return final archive report

## Phase 4 — Build Deterministic Recovery UI

- [ ] Add deterministic recovery section to `attachment_archive_settings_content.dart`
- [ ] Implement "Select Historical Database…" file picker for chat.db
- [ ] Implement "Select Historical Attachments Folder…" folder picker
- [ ] Require both inputs before enabling import button
- [ ] Auto-detect WAL/SHM alongside selected chat.db
- [ ] Pre-import validation: chat.db valid, Attachments folder exists,
      source-scoped graph attachment facts populated
- [ ] Display WAL/SHM absence warning when applicable
- [ ] Phase indicator during import (reading snapshot / mapping / archiving)
- [ ] Progress count within each phase
- [ ] Cancel button (cooperative cancellation)
- [ ] Results display with complete breakdown:
  - [ ] Historical pairs examined, files found/missing
  - [ ] Mapped (GUID match / single-attachment fallback)
  - [ ] Unmapped (message missing / GUID mismatch / ambiguous)
  - [ ] Already archived (skipped) / newly archived / errors
  - [ ] Total bytes archived
- [ ] Product wording: "Recover attachments from a historical Messages backup"
- [ ] Preserve existing live archive toggle/status UI unchanged

## Phase 5 — Testing and Validation

- [ ] Test 1: Deterministic happy path — clean match, archive, resolve
- [ ] Test 2: Historical file missing — reported correctly, no overlay row
- [ ] Test 3: Message not in current graph — unmapped, reported
- [ ] Test 4: Attachment GUID mismatch — unmapped, no fallback
- [ ] Test 5: GUID NULL + single attachment — fallback exercised correctly
- [ ] Test 6: GUID NULL + multi attachment — fallback rejected, unmapped
- [ ] Test 7: Multi-attachment message with GUIDs — each maps independently
- [ ] Test 8: Idempotent re-run — no duplicates, correct skip counts
- [ ] Test 9: WAL-aware correctness — WAL rows included; WAL absent → warning
- [ ] Test 10: Import DB empty precondition — refusal with diagnostic
- [ ] Test 11: Live archive regression — `archiveAllAvailable()` still works
- [ ] Test 12: Existing overlay preservation — prior heuristic rows remain valid

## Completion

- [ ] All phases pass manual and automated verification
- [ ] Zero analyzer warnings
- [ ] No regressions in existing test suite
- [ ] Write `STATUS.md`
- [ ] Move feature documentation to `40-FEATURES/` when shipped
