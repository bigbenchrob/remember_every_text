---
tier: project
scope: page-track-layout-matrix-implementation-record
owner: agent-per-project
last_reviewed: 2026-07-16
source_of_truth: doc
status: complete
links:
  - ./README.md
  - ./01-CURRENT-TRACK-SYSTEM-ANATOMY.md
  - ./02-AUTHORITATIVE-PAGE-TRACK-LAYOUT-MATRIX-PROPOSAL.md
  - ./03-PAGE-TRACK-LAYOUT-MATRIX-MIGRATION-PLAN.md
  - ./01-SEED-DOCUMENTS/04%20%E2%80%94%20TRACK-CELL%20MATRIX%20IMPLEMENTATION.md
tests:
  - test/config/theme/widgets/layout/page_track_layout_matrix_test.dart
  - test/config/theme/widgets/layout/resolved_track_layout_matrix_test.dart
  - test/config/theme/widgets/layout/cross_column_track_plan_test.dart
  - test/essentials/navigation/presentation/layout/search_page_track_plan_test.dart
---

# PageTrackLayoutMatrix Implementation Record

## Purpose

This is the living implementation and evidence record for the Search-page
`PageTrackLayoutMatrix` migration.

It does not redefine the architecture or migration sequence. Implementation is
governed, in order, by:

1. [`01-CURRENT-TRACK-SYSTEM-ANATOMY.md`](01-CURRENT-TRACK-SYSTEM-ANATOMY.md)
2. [`02-AUTHORITATIVE-PAGE-TRACK-LAYOUT-MATRIX-PROPOSAL.md`](02-AUTHORITATIVE-PAGE-TRACK-LAYOUT-MATRIX-PROPOSAL.md)
3. [`03-PAGE-TRACK-LAYOUT-MATRIX-MIGRATION-PLAN.md`](03-PAGE-TRACK-LAYOUT-MATRIX-MIGRATION-PLAN.md)

This document records what was actually implemented, verified, retired, or
deferred.

## Current Status

```text
Architecture: approved
Migration plan: approved
Source implementation: automated migration and retirement complete; minimum
  resting-geometry reservations implemented and manually verified
Current phase: all five phases verified for the Search page
Compatibility retirement: complete; no retired row-only Dart API remains
```

Do not mark a phase complete until its code, tests, analyzer result, manual
verification, and scheduled retirement work are recorded here.

## Governing Invariants

- The Search page owns exactly one `PageTrackLayoutMatrix`.
- Every visible Track-region element appears exactly once in that matrix.
- The page owns cell placement through the matrix.
- Each matrix cell owns occupant placement and vertical alignment within its
  coordinate.
- Tracks and columns remain ordinal and semantically neutral.
- Feature presentation owns presentation widget definitions.
- `TrackOccupant` owns dimensional calculation and delegates construction of
  the approved feature presentation.
- Dimensional claims use the same presentation contract and inputs as the
  rendered presentation.
- The resolver alone owns geometry.
- `TrackCellView` is intentionally unintelligent.
- The complete intended matrix is derived from page state before participating
  panels render.
- Matrix cells may preserve resting geometry through explicit
  `minimumReservedHeight`; live claims remain truthful and expand beyond it.
- Layout tuning becomes editing one matrix.

## Phase Dashboard

| Phase | Scope | Status | Evidence |
| --- | --- | --- | --- |
| 1 | Matrix identity and infrastructure | Verified | 8 focused tests; 17 compatibility tests; analyzer clean |
| 2 | Search-page matrix and temporary row-plan bridge | Verified | Matrix composition complete; bridge retired on schedule; closed/open right-panel lifecycle manually verified |
| 3 | Placement-independent occupants and dimensional claims | Verified | Feature-owned prepared presentations now produce placement-independent claims and presentation; 68 focused tests passed; analyzer clean |
| 4 | Complete matrix resolution and `CellId` rendering | Verified | All three Search Track regions render by `CellId` from one matrix; lifecycle, resizing, diagnostics, and matrix-only B3 tuning manually verified |
| 5 | Compatibility retirement and final proof | Verified | Row-only compatibility removed; 350 architecture tests, all 1,321 repository tests, analyzer, and final live menu/navigation verification passed |

Allowed statuses are:

```text
Not started
In progress
Verified
Blocked
```

`Verified` means the phase's `Done Means` criterion in Document 03 is
satisfied. `Blocked` requires a recorded architectural contradiction,
ownership conflict, data risk, or inability to preserve a runnable app.

## Baseline Before Migration

Record the verified implementation baseline before Phase 1 begins.

| Item | Baseline evidence |
| --- | --- |
| Current branch and commit | `Ftr.layout-tracks` at baseline commit `401872f0` |
| Current Search-page matrix appearance | Unchanged by Phase 1; no active rendering path imports the new matrix infrastructure |
| Search without right panel | Unchanged by Phase 1 |
| Search with Conversation excerpt | Unchanged by Phase 1 |
| Initial-load geometry behavior | Unchanged by Phase 1 |
| Window-resize behavior | Unchanged by Phase 1 |
| Developer Track diagnostics | Unchanged by Phase 1 |
| Focused test result | Existing `cross_column_track_plan_test.dart`: 17 passed before Phase 1 |
| Analyzer result | No issues before Phase 1 |

## Phase 1 Record — Matrix Identity And Infrastructure

**Status:** Verified

Record:

- final `TrackColumnId` API;
- final `CellId` API and diagnostic format;
- matrix and matrix-cell type locations;
- semantic-neutrality verification;
- files changed;
- focused tests;
- analyzer result;
- manual no-visual-change verification;
- deviations from Document 03.

Implemented in:

- `lib/config/theme/widgets/layout/page_track_layout_matrix.dart`
- `test/config/theme/widgets/layout/page_track_layout_matrix_test.dart`

Final infrastructure:

- `TrackColumnId` provides three ordinal, semantically neutral column IDs.
- `CellId` combines `TrackId` and `TrackColumnId`; diagnostics render as `A1`
  through `E3` without assigning meaning to either axis.
- `MatrixCell` makes every occupied or empty coordinate explicit and records
  page-owned vertical alignment and an optional diagnostic label.
- `PageTrackLayoutMatrix` validates non-empty unique axes, rejects duplicate
  and out-of-axis cells, requires every coordinate exactly once, and exposes
  cells in canonical row-major order.

Verification on 2026-07-16:

- `flutter test test/config/theme/widgets/layout/page_track_layout_matrix_test.dart --reporter compact`
  passed all 8 tests.
- `flutter test test/config/theme/widgets/layout/cross_column_track_plan_test.dart --reporter compact`
  passed all 17 compatibility tests.
- `flutter analyze` reported no issues.
- Repository reference scan confirmed that no active rendering source imports
  the new infrastructure, so Phase 1 cannot alter the current UI.

No deviations from Document 03 were required.

## Phase 2 Record — Search-Page Matrix And Temporary Bridge

**Status:** Verified

Record:

- the page-state input used to compose the intended matrix;
- the one matrix construction location;
- complete occupied and empty Search-page cells;
- the temporary matrix-to-row-plan adapter;
- proof that all participating subtrees receive one derived plan;
- initial/loading/ready Conversation presentation behavior;
- files changed;
- focused tests;
- analyzer result;
- manual verification;
- deviations from Document 03.

Implemented in:

- `lib/essentials/navigation/presentation/layout/search_page_track_plan.dart`
- `lib/essentials/navigation/presentation/layout/search_page_conversation_track_occupants.dart`
- `lib/essentials/navigation/presentation/view/macos_app_shell.dart`
- `lib/essentials/navigation/presentation/view/workspace_layout.dart`
- `test/essentials/navigation/presentation/layout/search_page_track_plan_test.dart`

Implementation history:

- `MacosAppShell` prepares the Search-page composition once from current page
  state: the Search top-menu mode, current theme presentation contracts, the
  effective right-panel spec, and any ready Conversation excerpt presentation.
- `SearchPageTrackOccupants` gives the page named inputs without transferring
  feature presentation ownership into generic matrix infrastructure.
- `buildSearchPageTrackLayoutMatrix` declares all 18 Search-page cells exactly
  once, including explicit empty cells. It accepts no unordered occupant bag
  and no `additionalOccupants` escape hatch.
- `deriveSearchPageTemporaryRowPlan` temporarily derived the legacy row-height
  plan solely from occupied matrix cells. It was removed in Phase 5 after all
  participating renderers migrated to complete `CellId`.
- One temporary `ResolvedTrackPlanScope` originally distributed that bridge
  through the `MacosWindow`. It was replaced by the immutable
  `ResolvedTrackLayoutMatrixScope` and deleted in Phase 5.
- Conversation excerpt preparation returns named optional card and label
  occupants. When the right spec or prepared signature is unavailable, B3 and
  E3 are explicit empty cells; once ready, the next page composition occupies
  those cells.

Verification on 2026-07-16:

- `flutter test test/config/theme/widgets/layout/page_track_layout_matrix_test.dart test/config/theme/widgets/layout/cross_column_track_plan_test.dart test/essentials/navigation/presentation/layout/search_page_track_plan_test.dart --reporter compact`
  passed all 29 tests.
- `flutter analyze` reported no issues.
- `git diff --check` passed.
- The architecture suite reached 349 checks with one unrelated, pre-existing
  failure: raw diagnostic `Color(0x...)` literals in
  `vertical_column_bands.dart`. It reported no matrix-refactor violation.
- A repository scan found one active Search-page `ResolvedTrackPlanScope`, in
  `macos_app_shell.dart`, and no remaining `resolveSearchPageTrackPlan` or
  `additionalOccupants` references.

Manual verification subsequently covered Search without an end panel, Search
with a Conversation excerpt, initial-to-ready geometry, responsive panel
resizing, and developer Track diagnostics. A dedicated dark-mode visual pass
was not repeated during this close-out; Track geometry is theme-independent and
the themed presentation paths remain covered by the broader app verification.

No architectural deviation from Document 03 was required. The exact async
presentation lifecycle remains an implementation observation for Phase 4;
Phase 2 does not claim that matrix resolution itself is complete.

## Phase 3 Record — Placement-Independent Occupants And Claims

**Status:** Verified

Record:

- final `PresentationConstraints` contract;
- final `OccupantDimensionalClaim` contract;
- occupant-by-occupant migration evidence;
- proof that claims and rendered presentations use one presentation contract;
- placement-only fields, constructors, and subclasses removed;
- files changed;
- focused tests;
- analyzer result;
- manual verification;
- deviations from Document 03.

Implemented in:

- `lib/config/theme/widgets/layout/cross_column_track_plan.dart`
- `lib/essentials/navigation/presentation/layout/search_page_track_plan.dart`
- `lib/features/sidebar_utilities/application/sidebar_cassette_spec/widget_builders/top_chat_menu_widget.dart`
- `lib/features/conversations/presentation/widgets/conversation_signature_card.dart`
- `lib/features/conversations/presentation/widgets/conversation_signature_card_track_occupant.dart`
- `lib/features/messages/presentation/widgets/message_evidence/message_evidence_header_track_metrics.dart`
- `lib/features/conversations/presentation/view/conversation_excerpt_panel_track_metrics.dart`
- the focused tests listed in this document's front matter

Implemented contract:

- `TrackOccupant` contains no Track, column, cell, alignment, or page identity.
  The page matrix is the sole placement authority.
- `PresentationConstraints` carries available width, text scaling, text
  direction, and locale without exposing `BuildContext` to dimensional logic.
- `OccupantDimensionalClaim` carries only the currently justified dimensions:
  `naturalHeight`, `preferredWidth`, and `minimumWidth`.
- `TextTrackOccupant` derives height and preferred width with `TextPainter`
  from the same text and style used to build its presentation.
- `TopMenuTrackOccupant` derives its fixed natural height from the shared top
  menu presentation contract.
- `ConversationSignatureCardTrackOccupant` derives natural height and
  canonical preferred/minimum width from
  `ConversationSignatureCardPresentationMetrics`, the same contract used by
  the card presentation.
- `FixedHeightTrackOccupant` is placement-independent and represents its own
  fixed presentation truth without a semantic Track role.
- During migration, the temporary row-plan adapter converted claims from
  occupied matrix cells into legacy row requirements. The adapter and legacy
  requirement type were deleted in Phase 5; occupants now contribute only
  `OccupantDimensionalClaim` values to matrix resolution.

Verification on 2026-07-16:

- `flutter test test/config/theme/widgets/layout/page_track_layout_matrix_test.dart test/config/theme/widgets/layout/cross_column_track_plan_test.dart test/essentials/navigation/presentation/layout/search_page_track_plan_test.dart test/features/conversations/presentation/widgets/conversation_signature_card_test.dart --reporter compact`
  passed all 42 tests.
- `flutter analyze` reported no issues.
- The architecture suite again reached 349 checks with only the unrelated,
  pre-existing raw diagnostic-color failure in
  `vertical_column_bands.dart`; it reported no new matrix-refactor boundary
  failure.
- A repository scan found no remaining `TrackRequirementContext`, occupant
  `requirement(...)`, `ResolvedTrackPlan.fromOccupants`, or occupant-owned
  `TrackId` API.

Phase 4 subsequently made the cell renderer invoke each approved feature
presentation and removed duplicate legacy selection. No placement or
presentation compatibility boundary remains, so Phase 3 is verified.

## Phase 4 Record — Complete Resolution And Cell Rendering

**Status:** Verified

Record:

- final resolver API;
- final `ResolvedTrackLayoutMatrix` API;
- final distribution/scope mechanism;
- final `TrackCellView` API;
- renderer migration by `CellId`;
- proof that all three columns consume one resolved matrix;
- lifecycle investigation finding and correction;
- files changed;
- focused tests;
- analyzer result;
- manual verification;
- deviations from Document 03.

Implemented in:

- `lib/config/theme/widgets/layout/resolved_track_layout_matrix.dart`
- `lib/essentials/navigation/presentation/layout/search_page_track_plan.dart`
- `lib/essentials/navigation/presentation/view/macos_app_shell.dart`
- `test/config/theme/widgets/layout/resolved_track_layout_matrix_test.dart`

Current implementation:

- `ResolvedTrackLayoutMatrix.resolve` consumes the complete page matrix and
  presentation constraints, obtains one dimensional claim per occupied cell,
  and resolves each ordinal Track to the maximum claimed natural height.
- Every `ResolvedTrackCell` retains its complete `CellId`, resolved shared
  height, page-owned alignment, opaque occupant, dimensional claim, available
  width, and optional diagnostic label. Empty cells retain the same shared
  geometry without manufacturing occupants.
- One `ResolvedTrackLayoutMatrixScope` now wraps the Search page. The temporary
  row-plan scope has been removed from shell distribution.
- `TrackCellView` identifies itself only by `CellId`, reads the corresponding
  resolved cell, applies its recorded vertical alignment, and delegates
  presentation construction to the occupant. It does not calculate geometry,
  select an occupant, or infer placement.
- Claims are calculated once by the resolved matrix. The temporary
  matrix-to-row-plan adapter and `SearchPageTrackComposition.temporaryRowPlan`
  have been removed now that all active Search Track renderers consume cells.
- Messages prepares the Search title, metadata, controls, and supporting
  context as feature-owned occupants. Conversations prepares the title,
  optional canonical Conversation Card, and temporal orientation. The page
  receives those occupants as opaque composition inputs.
- The Search sidebar, center message-evidence header, and right Conversation
  excerpt frame now render their A-F cells directly through
  `TrackCellView(CellId(...))`. None of those active matrix paths selects its
  occupant or alignment locally.
- The sidebar matrix path replaces only the former row wrappers. The cassette
  rack still owns cassette selection and chaining, and ordinary cassette
  content resumes after F1.

Verification on 2026-07-16 after live renderer migration:

- `flutter test test/config/theme/widgets/layout/cross_column_track_plan_test.dart test/config/theme/widgets/layout/page_track_layout_matrix_test.dart test/config/theme/widgets/layout/resolved_track_layout_matrix_test.dart test/essentials/navigation/presentation/layout/search_page_track_plan_test.dart test/essentials/navigation/application/panel_widget_providers_test.dart test/features/conversations/presentation/widgets/conversation_signature_card_test.dart test/features/conversations/presentation/view/conversation_excerpt_panel_view_test.dart`
  passed all 68 tests.
- `flutter analyze` reported no issues.
- Resolved-matrix tests prove maximum-height negotiation, retained claims,
  shared geometry for empty cells, and page-owned bottom alignment through a
  `CellId` renderer.
- The sidebar test proves that A1-F1 are matrix-rendered while the existing
  cassette chain continues below the Track region.

### Prepared Message-Evidence Presentation Boundary

The matrix must be composed before the center source view renders, but page
layout must not initiate source-specific evidence reads. The active Search path
therefore consumes one Messages-owned prepared presentation boundary:

- `globalMessagesEvidencePresentationProvider` owns the global and searched
  skeleton requests, selected evidence scope, and derived header labels;
- `GlobalMessagesEvidenceView` consumes that prepared state to render the
  evidence timeline;
- Search-page Messages occupants consume the same prepared labels and search
  session state;
- page composition receives opaque occupants and never reads the evidence
  spine directly.

This correction removed the skeleton request from
`search_page_message_evidence_track_occupants.dart`. The focused architecture
tripwire now permits the named prepared-presentation boundary rather than a
layout adapter. Its focused test passed, the provider behavior test passed, all
68 matrix/evidence tests passed, and `flutter analyze` reported no issues. A
subsequent full architecture run reached 349 passing checks and only the known
raw diagnostic-color failure in `vertical_column_bands.dart`; the previous
skeleton-boundary failure is resolved.

Manual verification confirmed that the closed-page matrix preserves intended
resting geometry, the live Conversation Card expands only its shared Track
when necessary, resizing preserves canonical card width and centering, and
developer diagnostics expose one aligned allocation per Track. Moving the card
from C3 to B3 required one matrix edit and immediately produced the expected
composition, validating the central layout-tuning objective.
Width-contract follow-up:

- The former wrapped E3 Conversation excerpt label used the canonical content
  width shared with the Conversation signature card, keeping its claim and
  presentation derived from one contract while that occupant existed.
- The label has since been retired from the current composition because the
  Conversation excerpt title and temporal orientation provide sufficient
  context. E3 is now explicitly empty.
- The `macos_ui` end sidebar remains resizable but does not expose its live
  width through `MacosWindowScope`. A future fluid-width Track occupant must
  therefore introduce an app-owned geometry boundary before it can claim
  truthful resize-sensitive dimensions; it must not restore infinite-width
  calculation or post-frame measurement.

The current Search matrix therefore has no ambient-width-sensitive occupant:
one-line text and fixed controls have height independent of available width,
while the Conversation card uses its canonical feature-owned width. An
app-owned per-column geometry boundary remains a
future prerequisite for adding any genuinely fluid-width occupant, not a
hidden requirement of the current matrix.

A 2026-07-16 consumer audit found no production construction of
`ResolvedTrackPlanScope`. The remaining consumers were then separated by
responsibility:

- the active Search path already rendered through complete `CellId` values;
- the ordinary sidebar top-menu cassette now renders its feature presentation
  directly outside matrix pages;
- non-matrix Messages and Conversations fallbacks now use ordinary
  presentation composition rather than row-plan wrappers;
- row-plan-only tests were removed after equivalent matrix and occupant tests
  were confirmed.

The dormant `TrackRequirement`, `ResolvedTrackPlan`,
`ResolvedTrackPlanScope`, `TrackOccupantView`, `TrackCellColumnBand`, and
`VerticalColumnBand` APIs have been deleted. A repository scan finds no Dart
reference to the retired row-only system.

## Phase 5 Record — Retirement And Final Proof

**Status:** Verified

Record:

- Compatibility mechanisms removed: row-plan model, scope, renderer, wrapper,
  and wrapper-only tests.
- Repository reference scan: no Dart reference remains to the retired APIs.
- Focused verification: 23 matrix, occupant, composition, and Conversation
  excerpt tests passed.
- Architecture verification: all 350 tripwires passed. Deleting the retired
  diagnostic wrapper also removed the earlier raw-color failure.
- Full repository verification: all 1,321 tests passed at close-out. An earlier
  full run
  exposed three non-Search evidence-header overflows caused by retaining fixed
  legacy band heights in ordinary fallback composition, plus one stale North
  American phone-format expectation. The fallback now sizes naturally without
  restoring Track authority, and the expectation matches the approved display
  format.
- Analyzer: no issues.
- Canonical documentation promotion: complete.
- Final manual Search-page verification: passed for initial layout, right-panel
  lifecycle, responsive resizing, developer diagnostics, matrix-only B3
  rearrangement, and top-menu interaction.
- Deviations from Document 03: none.

**Completion evidence:** Complete for the Search-page migration.

### Minimum Resting Geometry Correction

Manual Search-page verification exposed a lifecycle defect after compatibility
retirement: C3 and D3 had no live occupants before the Conversation panel
opened, so Tracks C and D collapsed and the center panel reflowed when those
occupants later appeared.

The correction adds `minimumReservedHeight` to `MatrixCell`. Resolution now
uses the larger of that reservation and the occupant's unchanged live
`naturalHeight`. No placeholder occupant is created.

Search-page reservations are prepared from feature-owned presentation
contracts. The card reservation moved with its occupant when the page
composition was tuned from C3 to B3:

- B3 reserves the smallest approved canonical Conversation Card presentation;
- E2 reserves the natural height of the one-line Search Investigation Status
  presentation, including its integrated activity-indicator diameter but no
  discretionary spacing;
- E3 is empty and unreserved;
- A3 remains occupied by its Conversation excerpt title presentation and needs no reservation;
- C3 remains empty and unreserved.

The Conversations and Messages features calculate these minima from the same
styles, text scaling, direction, locale, canonical widths, card spacing, glyph
metrics, and control size used by live presentation. The page merely assigns
the resulting values to matrix cells.

Focused verification covers zero defaults, invalid values, reserved empty and
occupied cells, claims below/equal to/above reservations, shared peer geometry,
return to resting geometry after removal, and Search-page open/closed lifecycle
states. All 29 focused layout tests, all 350 architecture tests, the complete
1,321-test repository suite, and analyzer pass. Renewed manual checks also pass
for initial geometry, optional right-panel lifecycle, responsive resizing,
developer diagnostics, matrix-only B3 tuning, and top-menu interaction.

## Final Search-Page Matrix

Populate this table from the shipped source. Do not infer it from screenshots or
historical design notes.

| Track | Column 1 | Column 2 | Column 3 |
| --- | --- | --- | --- |
| A | A1: `TopMenuTrackOccupant`, center, `Search top menu` | A2: `TextTrackOccupant`, center, `All messages title` | A3: `TextTrackOccupant`, center, `Conversation excerpt title` |
| B | B1: empty | B2: `TextTrackOccupant`, top, `Message result metadata` | B3: optional `ConversationSignatureCardTrackOccupant`, top, `Conversation signature card`; minimum reserved from the canonical minimum card presentation |
| C | C1: empty | C2: `MessageEvidenceSearchControlsTrackOccupant`, center, `Message search controls` | C3: empty |
| D | D1: `FixedHeightTrackOccupant(height: 2)`, top, `Fixed spacing` | D2: empty | D3: empty |
| E | E1: empty | E2: `SearchInvestigationStatusTrackOccupant`, top, `Search investigation status`; minimum reserved from its stable one-line presentation contract | E3: empty |
| F | F1: `FixedHeightTrackOccupant(height: 16)`, top, `Fixed spacing` | F2: empty | F3: empty |

For each occupied cell, record:

- `CellId`;
- occupant type;
- vertical alignment;
- diagnostic label, if present.

Labels explain the current composition to humans. They never affect geometry.

## Compatibility Retirement Ledger

| Transitional mechanism | Introduced or retained in | Retirement phase | Status | Evidence |
| --- | --- | --- | --- | --- |
| Matrix-to-row-plan adapter | Phase 2 | Phase 5 | Removed | `deriveSearchPageTemporaryRowPlan`, `temporaryRowPlan`, and shell row-plan distribution deleted after all active Search renderers migrated |
| Unordered occupant bag | Baseline | Phase 2 | Removed | Replaced by explicit matrix cells and named page inputs |
| `additionalOccupants` | Baseline | Phase 2 | Removed | Optional occupants have named matrix positions |
| Row-only renderer lookups | Baseline | Phase 5 | Removed | Sidebar, center, and right Track regions render by complete `CellId`; dead fallback branches and row-only tests deleted |
| Duplicate local alignment | Baseline | Phase 4/5 | Removed | Search matrix cells own alignment; non-matrix fallbacks use ordinary presentation composition rather than Track authority |
| Placement-only occupant APIs | Baseline | Phase 3/5 | Removed from occupant contract | No occupant owns `TrackId`, column, `CellId`, page, or alignment; final legacy-renderer audit remains in Phase 5 |
| Obsolete row-plan scope and APIs | Baseline | Phase 5 | Removed | No Dart reference remains to `TrackRequirement`, `ResolvedTrackPlan`, `ResolvedTrackPlanScope`, `TrackOccupantView`, `TrackCellColumnBand`, or `VerticalColumnBand` |

Do not add a transitional mechanism without assigning its retirement phase in
this ledger.

## Verification Ledger

| Verification | Phase 1 | Phase 2 | Phase 3 | Phase 4 | Phase 5 |
| --- | --- | --- | --- | --- | --- |
| Focused tests | 8 matrix + 17 compatibility tests passed | 29 matrix/composition/row-plan tests passed | 42 matrix/claim/card tests passed; contract later completed by prepared feature occupants | 68 matrix/resolution/renderer/sidebar/card/excerpt tests plus 1 prepared-presentation provider test passed | 23 final matrix/occupant/composition/excerpt tests passed |
| Architecture tests | N/A | No new failure; one pre-existing raw diagnostic-color failure | No new failure; same pre-existing diagnostic-color failure | Prepared-presentation skeleton boundary passed; full suite still has the pre-existing raw diagnostic-color failure | All 350 passed; retired diagnostic wrapper removed the previous failure |
| Full repository tests | N/A | N/A | N/A | N/A | All 1,313 passed after ordinary fallback headers were made content-sized and one stale phone-format expectation was corrected |
| `flutter analyze` | No issues | No issues | No issues | No issues | No issues |
| Search without right panel | No visual change | Matrix present | Cell rendering active | Verified | Verified |
| Search with right panel | No visual change | Matrix present | Cell rendering active | Verified | Verified |
| Initial load | No visual change | Intended matrix composed | Reservation lifecycle active | Verified | Verified |
| Window resize | No visual change | Shared plan retained | Canonical width retained | Verified | Verified |
| Light and dark mode | No visual change | Theme-neutral geometry | Theme-neutral geometry | Automated paths pass | Dedicated final visual pass not repeated |
| Developer diagnostics | No visual change | Matrix inspectable | Complete cells inspectable | Verified | Verified |

Record exact commands, outcomes, and material manual observations when each
cell is updated. Report unrelated pre-existing failures separately.

## Decisions And Deviations

Record only implementation decisions not already settled by Documents 02 and
03.

| Date | Phase | Decision or deviation | Reason | Architectural impact |
| --- | --- | --- | --- | --- |
| 2026-07-16 | 4 | Resolve and distribute the immutable matrix before migrating live renderers. | Proves geometry and `CellId` consumption independently while avoiding placeholder feature presentations. | Preserves the matrix as composition authority; the row-plan bridge remains explicitly temporary. |
| 2026-07-16 | 4 | Prepare global evidence state once in a Messages-owned presentation provider. | Matrix composition and the source view both need the same labels and search state, while layout must not initiate evidence reads. | Preserves Messages ownership and gives page composition only opaque occupants. |
| 2026-07-16 | 4 | Add page-owned `minimumReservedHeight` to cells that participate in resting composition before optional content is ready. | Manual lifecycle verification showed C3/D3 absence collapsing shared geometry and reflowing center evidence when the panel opened. | Preserves truthful live claims and reactive expansion while making initial and closed-panel geometry stable without placeholders or padding. |
| 2026-07-16 | 5 | Present the A1 top menu's expanded options in an anchored overlay while its occupant claims only the closed trigger. | Inline expansion overflowed the resolved Track cell and blocked menu selection. | Preserves truthful Track geometry: transient expanded presentation does not mutate matrix occupancy or claims. |

Do not silently alter the approved architecture. A genuine contradiction must
be recorded and reviewed before proceeding.

## Deferred Work

The implementation does not include:

- matrices for other pages;
- arbitrary column counts;
- sidebar cassette auto-placement;
- horizontal cell alignment;
- cell spanning or merging;
- custom RenderObjects;
- post-frame measurement;
- unrelated Search or Conversation redesign;
- broad wrapper retirement outside the migrated Search-page path.

These are future feature slices, not incomplete work in this package. In
particular, Contacts and other multi-column pages must receive their own page
composition review before adopting a matrix.

## Close-Out Assessment

The Search-page experiment is approved and complete. It validated the intended
architecture in live use:

- one page matrix makes cross-column placement discoverable;
- feature-owned occupants provide truthful presentation dimensions;
- page-owned reservations prevent asynchronous optional content from
  collapsing resting geometry;
- a live occupant may expand a shared Track beyond its reservation without
  imperative repair;
- moving the Conversation Card from C3 to B3 was a single composition edit;
- transient expanded controls use overlays rather than mutating Track
  geometry; and
- the retired row-only plan, scope, wrappers, and duplicate placement paths are
  gone.

Future pages should reuse the architecture only after their own intended
matrix is reviewed. This package does not authorize a mechanical app-wide
migration.

## Final Completion Gate

Implementation is complete only when all of the following are true:

- [x] All five phases are `Verified`.
- [x] One Search-page `PageTrackLayoutMatrix` is the complete composition
      authority.
- [x] Every visible Track-region element appears exactly once in the matrix.
- [x] All occupants are placement-independent.
- [x] All claims derive solely from approved presentation contracts and current
      presentation constraints.
- [x] One immutable `ResolvedTrackLayoutMatrix` supplies all three columns.
- [x] All Track-region renderers use complete `CellId`.
- [x] Intended page geometry exists before participating panels render.
- [x] Optional Search cells return to feature-derived minimum reservations when
      live occupants are absent.
- [x] The compatibility retirement ledger contains no remaining mechanism.
- [x] Focused tests, architecture tests, and analyzer pass.
- [x] Manual Search-page verification is recorded.
- [x] The final matrix table matches source.
- [x] Canonical Cross-Column Layout documentation describes the implemented
      system rather than the retired row-only path.

Do not claim that other MessageLens pages use the matrix. This record proves
only the Search-page migration.
