---
tier: project
scope: production-archive-recovery
owner: agent-per-project
last_reviewed: 2026-08-22
source_of_truth: release-readiness-record
---

# Feature 26 Final Release Readiness And Conformance

## Decision

**READY WITH DEFERRED NON-BLOCKERS.**

Historical Archives conforms to its settled two-arm product contract and is
ready to close as Feature 26. This pass found no schema, migration, source
identity, lineage, timestamp, mutation-authority, preservation, or Track
blocker.

The real-format evidence remains the previously completed staging and
controlled-loss validation. No archive mutation or destructive rehearsal was
repeated during this pass.

## Final Invariants

### Mac Messages

- `HistoricalArchiveSourceIdentity` is the single durable source identity.
- Imported membership comes from source registration and source-scoped facts,
  not labels or paths used as presentation.
- Overlap does not erase source provenance.
- Removal affects only the selected source.
- The donor Messages folder remains read-only input.

### MessageLens

- A selected MessageLens folder is an ephemeral recovery donor.
- Its path is a locator, not durable identity, and no synthetic UUID is made.
- Same-lineage admission and exact message/attachment correspondence are
  mandatory.
- Filesystem evidence determines whether a payload is physically present.
- The canonical preservation-safe no-overwrite writer is the only payload
  installation authority.
- Recovery requires the exact `attachmentReconciliation` capability and is
  safe to retry.
- Donor messages, graph data, overlays, and source membership are never
  imported.

### Shared architecture

- The D1 sealed presentation state is the only workflow representation.
- Async results must still own the current presentation occurrence before they
  may affect presentation or begin work.
- The D2 A-I center Track skeleton is stable; variable sidebar lists continue
  in native flow.
- Messages lineage and durable source identity remain separate proofs.
- `ArchiveMutationCoordinator` remains the prescribed process-local mutation
  authority.
- `DateConverter` remains the only Apple timestamp conversion authority.
- Orange means referential correspondence, blue means selected object, and
  Directed Instrumentation reports real work.

## Corrections Made

### Abandoned-session admission

The Mac Messages import painted its operation state and then awaited a frame
before requesting mutation authority. It did not revalidate ownership after
that await. An abandoned presentation could therefore have entered the
mutation coordinator after the user had left the workflow.

The workflow now proves it still owns the importing presentation immediately
before coordinator admission. A focused regression test abandons the
presentation during the frame barrier and proves that neither the coordinator
nor graph import service is called.

### Candidate metadata persistence

Folder inspection already guarded stale preflight and lineage results, but it
did not revalidate ownership immediately before source metadata persistence.
The workflow now checks the inspection occurrence and presentation session at
that boundary. A focused regression test abandons the session while lineage
verification is pending and proves that no metadata is written.

### Captured operational evidence

Once import is admitted, service inputs and failure metadata now come from the
captured candidate presentation data. They no longer reread mutable current UI
state while the operation is running.

### Superseded UI removal

The old generic Historical Archives control panel was unreachable because all
sealed states already project to hub, selected-source, or Narrator surfaces.
Its Execution Gate, Preflight Summary, Dry Run Summary, developer controls,
Activity Log, Progress, and Result Summary widgets were deleted. An impossible
unprojected state now fails at the projection boundary rather than reviving a
second UI architecture.

The source-specific chooser labels now replace the stale generic “Choose
Another Folder” wording.

### Accessibility

The feature-local custom action button and Details disclosure now publish
button, enabled/expanded, and label semantics. The two sidebar folder choosers
also publish explicit button semantics. Existing text status, source
cartouches, segmented control semantics, reduced-motion behavior, and
non-color status communication remain intact.

## Audit Results

- No hard-coded staging, donor, `/tmp`, or controlled-loss paths are reachable
  from product code.
- The controlled-loss helper remains a separate read-only development tool.
- No private Apple epoch arithmetic exists outside `DateConverter`.
- No duplicate source-scoped row-key bit arithmetic was found.
- MessageLens preflight remains hash-free and bounded; execution retains fresh
  integrity and SHA-256 proof.
- Donor SQLite adapters remain read-only and donor files are never migrated.
- Attachment installation remains payload-first, metadata-second, atomic, and
  no-overwrite under exact mutation capability.
- Mac Messages sources remain durable; MessageLens donors remain ephemeral.
- No schema or persistence-format change was made.
- SHA-256 comparison found no byte-identical duplicate Prompt files in the
  Feature 26 prompt folder.

Useful production diagnostics, typed workflow evidence, and the separate
controlled-loss validation tool were retained. They are not temporary UI
scaffolding.

## Deferred Non-Blockers

1. The generated Drift API still exposes writable methods for frozen legacy
   subtype tables. Feature 26 does not call or depend on those methods, and
   mechanically removing them requires an unjustified schema-level change.
2. The Historical Archives workflow coordinator is large. Splitting it may
   improve maintainability, but its current ownership and dependency direction
   are valid; a split would be structural refactoring rather than release
   correction.

Neither item weakens the released Historical Archives contract.

## Verification

- Focused workflow tests: passed, including abandoned import and abandoned
  lineage-persistence regressions.
- Focused panel tests: passed.
- Historical Archives architecture tripwires: passed.
- Complete Flutter suite: **1,951 tests passed**.
- `flutter analyze`: no issues.
- `dart format`: clean.
- `git diff --check`: clean.
- `flutter build macos --debug`: succeeded and produced
  `MessageLens Development.app`.

The macOS build retained the existing Xcode empty-build-number diagnostic and
the `volume_controller` privacy-manifest processing warning. Both are external
build warnings and did not prevent a successful artifact.

## Closure

Feature 26 is complete under the documented product contract. New source
types, broader donor semantics, schema redesign, or additional recovery
capabilities require a new feature decision rather than extension of this
release-readiness pass.
