---
tier: feature
scope: tests
owner: agent-per-project
last_reviewed: 2026-04-28
source_of_truth: doc
links:
  - ./PROPOSAL.md
  - ./CHECKLIST.md
  - ./PHASE_1_MINIMAL_SLICE
tests: []
feature: historical-archive-merge
status: proposed
created: 2026-04-28
---

# Test Plan - Historical Archive Merge

## Resolver And Preflight Tests

- [ ] Valid folder containing `chat.db` produces a `HistoricalArchivePreflightSummary`
- [ ] Missing `chat.db` is rejected with `can_import = false` and a clear warning
- [ ] Minimal legacy schema does not crash preflight
- [ ] Archive with `Attachments/` present emits the "attachment import is not part of this first version" warning
- [ ] Archive without `Attachments/` emits the "messages can still be imported" warning
- [ ] Preflight reports total, duplicate, new, and date-range counts correctly for a partially overlapping archive
- [ ] Preflight computes duplicate/new counts through streaming indexed lookup rather than requiring a full archive GUID set in memory

## Merge Execution Tests

- [ ] Duplicate GUIDs are skipped
- [ ] New GUID rows are inserted
- [ ] Re-importing the same archive is idempotent and reports zero new rows
- [ ] Existing working rows remain unchanged after merge
- [ ] Rows without usable GUIDs increment both `rows_failed` and `rows_without_guid_count`, and are not heuristically merged
- [ ] Row-level failures are counted without aborting the full merge when the archive DB itself is readable
- [ ] Failure to open the archive DB stops the run cleanly

## Data Integrity Tests

- [ ] Overlay DB is untouched throughout preflight and merge
- [ ] Archive-derived rows are persisted in `db-archive-import` rather than only in `db-working`
- [ ] Archive-derived rows remain distinguishable from `current_mac` ingestion
- [ ] No existing row is deleted
- [ ] No existing row is overwritten
- [ ] New rows are tagged with `source_provenance` and `import_batch_id`
- [ ] Existing rows continue to resolve as `current_mac` semantics without requiring risky backfill behavior

## Integration Tests

- [ ] Successful merge extends the timeline query surface with older imported rows
- [ ] Importing an archive that predates all current data becomes the new earliest timeline anchor
- [ ] Successful merge extends search coverage across imported rows
- [ ] Successful merge extends the heatmap range automatically through existing providers
- [ ] Timeline/search/heatmap ordering logic remains unchanged and does not special-case archive rows
- [ ] The Settings -> Support flow can move from initial -> preflight -> result using immutable summary/result payloads

## Logging Tests

- [ ] Merge logs include archive path, label, counts, batch ID, and date range
- [ ] Merge logs do not include message text

## Manual Validation

- [ ] Select a copied historical Messages folder and verify the preflight numbers look plausible
- [ ] Confirm the additive warning text is shown before import
- [ ] Import an archive with known overlap and verify duplicates are skipped
- [ ] Import an archive older than all current data and verify it becomes the earliest visible timeline anchor
- [ ] Re-run the same archive and verify zero new messages are added
- [ ] Inspect timeline/search/heatmap manually to confirm older history is now visible
