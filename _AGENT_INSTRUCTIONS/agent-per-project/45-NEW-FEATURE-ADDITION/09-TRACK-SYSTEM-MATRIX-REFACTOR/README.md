---
tier: project
scope: track-system-matrix-refactor
owner: agent-per-project
last_reviewed: 2026-07-16
source_of_truth: doc
links:
  - ./01-CURRENT-TRACK-SYSTEM-ANATOMY.md
  - ./02-AUTHORITATIVE-PAGE-TRACK-LAYOUT-MATRIX-PROPOSAL.md
  - ./03-PAGE-TRACK-LAYOUT-MATRIX-MIGRATION-PLAN.md
  - ./04-PAGE-TRACK-LAYOUT-MATRIX-IMPLEMENTATION.md
  - ./01-SEED-DOCUMENTS/01%20%E2%80%94%20CURRENT%20TRACK%20SYSTEM%20ANATOMY.md
  - ./01-SEED-DOCUMENTS/02%20%E2%80%94%20AUTHORITATIVE%20TRACK-CELL%20MATRIX%20PROPOSAL.md
  - ./01-SEED-DOCUMENTS/03%20%E2%80%94%20TRACK-CELL%20MATRIX%20MIGRATION%20PLAN.md
  - ./01-SEED-DOCUMENTS/04%20%E2%80%94%20TRACK-CELL%20MATRIX%20IMPLEMENTATION.md
tests:
  - test/config/theme/widgets/layout/page_track_layout_matrix_test.dart
  - test/config/theme/widgets/layout/resolved_track_layout_matrix_test.dart
  - test/config/theme/widgets/layout/cross_column_track_plan_test.dart
  - test/essentials/navigation/presentation/layout/search_page_track_plan_test.dart
  - test/features/messages/presentation/view_model/global_messages_evidence_presentation_provider_test.dart
---

# Track System Matrix Refactor

This package replaces the Search page's row-only Track requirement plan with
one authoritative two-dimensional page composition.

The architectural objective is:

```text
PageTrackLayoutMatrix
    -> complete CellIds
    -> placement-independent TrackOccupants
    -> OccupantDimensionalClaims
    -> ResolvedTrackLayoutMatrix
    -> CellId-based rendering
```

The `PageTrackLayoutMatrix` is the missing composition authority. It makes page
layout discoverable and editable in one place without moving feature-owned
presentation into generic Track infrastructure.

## Package Status

```text
Diagnosis: complete
Architecture: complete
Migration plan: complete
Implementation record: complete
Source implementation: all five Search-page phases verified; one matrix
  resolves and renders all three Track regions by complete `CellId`; the
  row-only compatibility system is removed; feature-derived minimum cell
  reservations preserve resting geometry before optional right-panel occupants
  appear; focused, architecture, full-suite, analyzer, and live visual/lifecycle
  verification pass
```

Documents 01–03 preserve the governing diagnosis, architecture, and migration
plan. Document 04 is the completed implementation and evidence record.

## Working Order

1. [`01-CURRENT-TRACK-SYSTEM-ANATOMY.md`](01-CURRENT-TRACK-SYSTEM-ANATOMY.md)
   records the concise current-state diagnosis and migration direction.
2. [`02-AUTHORITATIVE-PAGE-TRACK-LAYOUT-MATRIX-PROPOSAL.md`](02-AUTHORITATIVE-PAGE-TRACK-LAYOUT-MATRIX-PROPOSAL.md)
   defines the canonical target architecture.
3. [`03-PAGE-TRACK-LAYOUT-MATRIX-MIGRATION-PLAN.md`](03-PAGE-TRACK-LAYOUT-MATRIX-MIGRATION-PLAN.md)
   converts that architecture into five verified migration phases.
4. [`04-PAGE-TRACK-LAYOUT-MATRIX-IMPLEMENTATION.md`](04-PAGE-TRACK-LAYOUT-MATRIX-IMPLEMENTATION.md)
   is the living implementation record and completion authority.

The files in [`01-SEED-DOCUMENTS/`](01-SEED-DOCUMENTS/) are source guidance.
They preserve the original constraints and reasoning but are not themselves an
implementation record.

## Scope

This refactor is limited to the Search-page Track region. It does not introduce
a universal page-layout framework, migrate other MessageLens pages, or redesign
Search, Messages, Conversations, or the sidebar cassette system.

Other pages remain future, separately reviewed adoption work. They are not an
unfinished part of this package.
