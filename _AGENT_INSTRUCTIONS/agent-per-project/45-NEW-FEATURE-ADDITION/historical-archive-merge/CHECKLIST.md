---
tier: feature
scope: checklist
owner: agent-per-project
last_reviewed: 2026-04-28
source_of_truth: doc
links:
  - ./PROPOSAL.md
  - ./DESIGN_NOTES.md
  - ./TESTS.md
  - ./PHASE_1_MINIMAL_SLICE
tests: []
feature: historical-archive-merge
status: proposed
created: 2026-04-28
---

# Checklist - Historical Archive Merge

## Phase 0 - Planning Alignment

- [ ] Confirm that the first implementation is limited to the Phase 1 minimal slice only
- [ ] Confirm that the feature is additive-only and not a replacement import
- [ ] Confirm that `message_guid` is the only dedupe key and that rows without a usable GUID are not heuristically merged
- [ ] Confirm `db-archive-import` as the durable upstream storage boundary for imported historical rows
- [ ] Confirm that archive-derived rows are never treated as `current_mac` and never co-mingled with the live polling stream
- [ ] Confirm that Phase 1 attachment handling is warning-only, not file-copy/import behavior

## Phase 1 - Data Contract And Schema

- [ ] Introduce `db-archive-import` as a dedicated durable storage surface for archive-derived rows
- [ ] Define archive-source partitioning so rows remain replayable and distinguishable at source level
- [ ] Add `source_provenance` and `import_batch_id` to the working message projection if not already present
- [ ] Ensure existing rows continue to behave as `current_mac` without requiring a risky bulk rewrite
- [ ] Verify that GUID lookup for dedupe uses an indexed or otherwise efficient path
- [ ] Define archive label and batch-ID generation rules for preflight and import results

## Phase 2 - Resolver And Preflight

- [ ] Create `HistoricalArchiveMergeResolver`
- [ ] Validate the selected folder and reject missing `chat.db`
- [ ] Open the external archive `chat.db` read-only
- [ ] Detect whether `Attachments/` exists and attach the correct warning text
- [ ] Tolerate minimal legacy schema differences during preflight
- [ ] Stream archive GUIDs through indexed existence checks rather than requiring a full in-memory GUID comparison
- [ ] Compute `HistoricalArchivePreflightSummary` with total, duplicates, new rows, date range, import readiness, and warnings

## Phase 3 - Merge Execution

- [ ] Generate an `import_batch_id` for each archive merge run
- [ ] Count `rows_without_guid_count` explicitly and surface it in the import result
- [ ] Insert only unseen messages
- [ ] Preserve existing rows unchanged
- [ ] Tag newly inserted rows with provenance and batch metadata
- [ ] Count and log failed rows without aborting the full merge unless the archive DB cannot be opened
- [ ] Return `HistoricalArchiveImportResult` with counts, warnings, and imported date range
- [ ] Verify re-import idempotency for the same archive
- [ ] Keep archive-row replay compatible with the normal migration -> working projection flow

## Phase 4 - Minimal UI Flow

- [ ] Add `Import Historical Archive` to Settings -> Support
- [ ] Add the initial cassette with description and `Choose Archive Folder`
- [ ] Add the preflight cassette with summary fields and additive warning text
- [ ] Add `Merge Into Timeline` and `Cancel` actions
- [ ] Add the result cassette with imported/skipped counts, `rows_without_guid_count`, and resulting timeline span

## Phase 5 - Logging And Verification

- [ ] Log archive path, label, counts, batch ID, failed rows, and earliest/latest dates
- [ ] Confirm logs never include message text
- [ ] Add automated tests for the required Phase 1 safety and idempotency cases
- [ ] Verify that timeline/search/heatmap consume archive-derived rows without changing ordering logic or adding archive-only UI paths
- [ ] Capture any required manual validation in `TESTS.md`
- [ ] Keep this checklist current during implementation

## Deferred Beyond Phase 1

- [ ] Attachment archive copying and reconciliation
- [ ] Per-source filters
- [ ] Archive removal / rollback
- [ ] Multi-archive management UI
- [ ] Fuzzy or heuristic dedupe
