---
tier: feature
scope: proposal
owner: agent-per-project
last_reviewed: 2026-04-28
source_of_truth: doc
links:
  - ../../00-PROJECT/02-architecture-overview.md
  - ../../10-DATABASES/00-all-databases-accessed.md
  - ../../10-DATABASES/INVIOLATE_RULES.md
  - ../../20-DATA-IMPORT-MIGRATION/01-overview.md
  - ../../20-DATA-IMPORT-MIGRATION/10-import-orchestrator.md
  - ../../25-ONBOARDING-AND-ARCHIVE/00-overview.md
  - ./PHASE_1_MINIMAL_SLICE
  - ./seed.txt
  - ./CHECKLIST.md
  - ./DESIGN_NOTES.md
  - ./TESTS.md
tests: []
feature: historical-archive-merge
status: proposed
created: 2026-04-28
---

# Feature Proposal - Historical Archive Merge

**Proposed Branch**: `Ftr.arch-merge`
**Status**: Proposed
**Created**: 2026-04-28

---

## Overview

Add a user-initiated archive merge flow under Settings -> Support that can read an external Messages archive folder, analyze its `chat.db`, and merge only new messages into the MessageLens timeline.

The first implementation is intentionally limited to the minimal Phase 1 slice:

- choose an archive folder
- verify `chat.db` exists
- run preflight analysis
- show additive merge warnings and counts
- import only unseen messages by `message_guid`
- tag imported rows with provenance and batch metadata
- show a result summary

This feature is explicitly **not** a replacement import. It is an additive merge path for historical data.

## User Value

### Problem

Some users have older Messages archives outside the currently synced `~/Library/Messages/chat.db` dataset. Today MessageLens can only reflect the currently imported source history, so the timeline, search, and heatmap can stop short of the user's older archives.

### Phase 1 Outcome

After Phase 1, a user can point MessageLens at a copied historical Messages folder and safely add older messages into the existing timeline without deleting or replacing current data.

Expected user-facing result:

- the timeline extends backward when the archive contains older history
- existing messages are left untouched
- duplicate archive messages are skipped by GUID
- the user sees a clear preview before import and a summary after import

## Existing Architecture Summary

- MessageLens currently ingests macOS Messages and AddressBook data through an essentials-owned pipeline: source databases -> `db-import` -> `db-working` -> provider merge with `db-overlay`
- `db-working` is a projection consumed by the UI and can be rebuilt by migration; `db-overlay` holds user-intent state and must not be used for imported archive records
- the live `current_mac` path is already a distinct source path, so archive-derived rows must remain distinguishable from that ingestion stream rather than being treated as if they came from the current machine
- auto-sync already polls the live `chat.db` every 15 seconds, runs import + migration, and refreshes the UI without user action
- onboarding and support-style recovery flows already live in essentials-owned orchestration and can host a minimal historical-archive workflow without introducing a full archive manager UI
- current surfaces such as timeline, search, and heatmap already consume working-db-backed providers, so a correct merge path should enhance those features without special-case UI logic

## Assumptions

1. The first implementation is launched manually from Settings -> Support rather than from onboarding.
2. `message_guid` is the only allowed dedupe key; rows without a usable GUID cannot be heuristically merged.
3. Attachment handling in Phase 1 is informational only: detect whether `Attachments/` exists and warn, but do not copy or reconcile attachment files.
4. The minimal UI can be delivered as a small cassette sequence rather than a new archive-management subsystem.
5. Imported historical messages must remain durable across future app restarts and migration cycles.
6. Existing timeline/search/heatmap features should pick up merged history through existing data providers, not feature-specific UI exceptions.

## Hard Invariants

1. No existing message row may be deleted or overwritten.
2. Overlay DB must remain untouched; this feature never writes imported archive state into `db-overlay`.
3. Merge identity is `message_guid` only. No timestamp, text, sender, path, or fuzzy fallback is allowed.
4. The implementation must preserve record-level fidelity: rows are imported, skipped, or counted as failed/warned, but never silently dropped from the workflow.
5. Database access must go through the centralized providers and existing app-owned connection boundaries.
6. No message text may be written to logs.
7. Phase 1 must remain additive and idempotent: re-importing the same archive yields zero new inserts.
8. Archive-derived rows must never be treated as if they originated from `current_mac`.
9. Timeline ordering authority must remain unchanged; archive rows participate in the existing ordinal model without special-case ordering logic.

## Scope

### In Scope For Phase 1

1. Add a Support entry for `Import Historical Archive`.
2. Validate a selected folder and locate `chat.db`.
3. Open the external archive database read-only.
4. Compute `HistoricalArchivePreflightSummary`.
5. Merge only unseen messages by GUID.
6. Persist provenance and import batch metadata for newly imported rows.
7. Return a result summary and show it in the minimal UI flow.
8. Log archive path, label, counts, batch ID, failures, and date range without message content.
9. Add tests for preflight, duplicate skipping, new-row insertion, idempotency, unchanged existing rows, overlay untouched, and minimal legacy schema tolerance.

### Out Of Scope For Phase 1

- Attachment archive copying
- per-source filters
- archive removal or rollback
- a multi-archive manager UI
- fuzzy deduplication
- contact merge refinement beyond current importer requirements
- special-case timeline/search/heatmap UI behavior

## Proposed Direction

### Product Contract

Phase 1 should match the attached minimal slice exactly from the user's perspective:

1. Choose archive folder
2. See a preflight summary and additive warning
3. Confirm `Merge Into Timeline`
4. Receive an import result summary

### Minimal Safe Technical Direction

Even in the smallest slice, the implementation must respect the current data-pipeline contract:

- `db-working` is a disposable projection, so archive-only writes that live solely there would be lost on a future rebuild
- `db-overlay` is reserved for user intent, so archive records do not belong there
- existing `db-import` ingestion is the canonical live-source ledger, so archive rows must not be mixed into that logical polling stream or disguised as `current_mac`

Because of that, the Phase 1 implementation should introduce a **dedicated archive import database** as the durable upstream storage path for archive-derived rows.

Recommended Phase 1 storage model:

- external archive `chat.db` is opened read-only
- archive-derived rows are staged durably into `db-archive-import`
- migration or a focused projection step replays `db-archive-import` into `db-working`
- projected rows carry provenance and batch metadata so the UI can distinguish archive content without changing timeline ordering rules

This keeps archive data durable across rebuilds, replayable through the normal import -> migration -> working pipeline, and clearly distinguishable from `current_mac` ingestion.

That still satisfies the Phase 1 user flow while avoiding a fragile one-off write path that disappears on the next rebuild.

Non-negotiable exclusions for Phase 1:

- do not write archive rows only into `db-working`
- do not treat archive rows as `current_mac`
- do not co-mingle archive rows with the live auto-polling stream in existing `db-import`

### Requested Data Contracts

Phase 1 should produce two user-facing contracts:

- `HistoricalArchivePreflightSummary`
- `HistoricalArchiveImportResult`

`HistoricalArchiveImportResult` should explicitly include:

- `rows_without_guid_count`

And it should surface provenance in the working message projection with:

- `source_provenance`
- `import_batch_id`

Existing rows should continue to behave as `source_provenance = current_mac` unless a safe migration path makes explicit backfill trivial.

### Performance Constraint

Preflight should not assume a full in-memory GUID set comparison for large archives.

Phase 1 should prefer:

- streaming archive GUID inspection
- indexed existence checks against the app-owned history
- incremental duplicate/new counters

This keeps duplicate counting close to O(1)-ish lookup cost per row instead of a large memory-bound set comparison.

## Architecture Impact

### Areas Likely To Change

| Area                                 | Planned Change                                                                                                       |
| ------------------------------------ | -------------------------------------------------------------------------------------------------------------------- |
| Settings support flow                | Add a minimal `Import Historical Archive` cassette sequence                                                          |
| Historical archive application layer | Add a resolver/service for validation, preflight, and merge execution                                                |
| Database schema                      | Add provenance/batch metadata to the working message projection and introduce `db-archive-import` for archive rows  |
| Import/migration path                | Replay `db-archive-import` into working messages without changing overlay behavior or live polling semantics         |
| Logging                              | Add merge-specific structured logging without message content                                                        |
| Tests                                | Add resolver/data-flow tests plus minimal UI-flow coverage where practical                                           |

### Candidate Implementation Areas

- `lib/essentials/onboarding/` or `lib/features/settings/` support-flow wiring
- `lib/essentials/db/` or a new feature-scoped archive-merge application area for the resolver
- archive-import schema plus migration/projector files that own archive-row durability and projection
- tests under `test/essentials/` and `test/features/settings/`

## Risks

1. **Projection durability risk**
   A direct-to-working implementation would look minimal but would likely lose merged history on a later rebuild.

2. **Legacy schema variance risk**
   Older `chat.db` files may not expose the same columns as current sources, so Phase 1 must tolerate minimal extraction paths.

3. **GUID quality risk**
   Some source rows may have missing or malformed GUIDs. The feature must count and surface those cases rather than invent fallback identity.

4. **Scope creep risk**
   It will be tempting to add archive management, attachment copying, or source filters immediately. Phase 1 must stay limited to the additive merge proof.

## Open Questions To Resolve Before Implementation

1. Should rows without usable `message_guid` be counted as failed rows, warnings, or both in the final result contract?
2. Which existing support/settings cassette system entry point should own the three-step UI flow with the smallest diff?

## Recommendation

Proceed with implementation planning for the minimal Phase 1 slice only. Keep the UI small, the merge rule strict, and the persistence model anchored on a dedicated `db-archive-import` path so archive data survives rebuilds and remains distinct from `current_mac` ingestion.
