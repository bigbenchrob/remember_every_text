# Deterministic Historical Attachment Recovery Proposal

## Problem

The heuristic historical recovery flow — matching backup Attachments files to
working DB records via path-tail coincidence and SHA-256 hash — fails in
real-world scenarios even when the correct file is present in the backup.

Root cause (proven by forensic analysis — see `FORENSIC_FAILURE_ANALYSIS_A.txt`
in `living-attachments-archive/`):

- Sent-attachment directory conventions (`at_0_` GUID prefix) change the path
  structure between the historical and current chat.db, breaking path-tail
  matching.
- `sha256_hex` is frequently NULL in the working DB, disabling hash-based
  matching entirely.
- Common filenames (e.g. `IMG_1234.jpeg`) create false-positive ambiguity.

The heuristic system is fundamentally incapable of deterministic mapping and
must be replaced.

## Goal

Replace the heuristic historical importer with a deterministic snapshot-based
recovery system that:

- reads a matched historical Messages snapshot (chat.db + Attachments folder)
- reconstructs message↔attachment relationships from the historical DB joins
  (not from file-system heuristics)
- maps historical records to current MessageLens runtime identity using
  attachment GUIDs through the import DB bridge layer
- copies resolved files into the existing content-addressable archive store
- writes overlay rows with provenance `imported_historical_snapshot`
- reports detailed results including every unmapped record and the reason

The existing live archive infrastructure (archive directory, overlay schema,
resolver pipeline, `archiveAllAvailable()`) is preserved unchanged.

## Non-Goals

- Modifying the live archive or import/migration pipelines
- Expanding real-time or background archiving behavior
- Recovering attachments from an Attachments folder without a matching DB
- Heuristic, fuzzy, or probabilistic matching of any kind
- Writing to the working database
- Modifying the overlay database schema (only a new provenance value)

## Scope

### In Scope

- Remove the heuristic historical importer (code and UI)
- Build a deterministic snapshot reader (read-only historical chat.db)
- Build a cross-snapshot mapper (GUID match via import DB bridge,
  bounded single-attachment fallback for NULL-GUID records)
- Wire archive writer using existing content-addressable store
- Build a deterministic recovery UI with validation, progress, and results
- Test coverage for all mapping paths and edge cases
- Preserve the living archive guarantee (`archiveAllAvailable()` untouched)

### Out of Scope

- Folder-only recovery as a product feature (permanently removed)
- Heuristic path-tail or filename-based recovery (permanently removed)
- Real-time filesystem watcher or background polling
- Immediate archiving on iCloud re-download

## Core Principles

1. **Historical snapshot is read-only** — opened `SQLITE_OPEN_READONLY`,
   never mutated, checkpointed, or vacuumed.

2. **Three-layer read topology** — Historical DB → Import DB (bridge) →
   Working DB + Overlay. Import DB holds both Apple's `attachment.guid` and
   `attachments.id` (which becomes `import_attachment_id` in working DB).

3. **Identity isolation** — Historical ROWIDs are traversal-only within
   the snapshot join; they never escape into overlay or runtime identity.

4. **No heuristic fallback** — GUID match is primary, single-attachment
   fallback is bounded (NULL GUID + exactly one attachment on both sides),
   and there is no Step 3.

5. **Overlay/working separation is inviolable** — Recovery writes only to
   overlay `archived_attachments`. Working DB is never touched.

6. **Record fidelity** — Unmapped records are counted and reported, never
   silently dropped.

7. **Living archive preserved** — `archiveAllAvailable()` continues to run
   after each import/migration cycle, ensuring newly-local attachments
   (including iCloud re-downloads) are archived.

## Success Criteria

- [ ] Heuristic historical importer fully removed (code + UI)
- [ ] Deterministic recovery correctly archives files from a matched snapshot
- [ ] GUID-based mapping works for the common case
- [ ] Single-attachment fallback works for NULL-GUID records
- [ ] Multi-attachment NULL-GUID records are reported as unmapped (not guessed)
- [ ] Idempotent re-run creates no duplicates
- [ ] Live archive mode is completely unaffected
- [ ] Existing overlay rows from prior heuristic runs remain valid
- [ ] Results UI shows complete breakdown of all outcomes
- [ ] Import DB empty → clear refusal with diagnostic

## Governing Documents

- `seed.txt` — Feature seed concept
- `response-to-plan-concerns.txt` — Owner directives 1–10 + living archive addendum
- `implementation-plan.txt` — Formal phased implementation plan
- `FORENSIC_FAILURE_ANALYSIS_A.txt` (in `living-attachments-archive/`) — Root cause evidence
