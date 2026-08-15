---
tier: project
scope: unfamiliar-sources-cross-column-layout
owner: agent-per-project
last_reviewed: 2026-07-26
source_of_truth: doc
links:
  - ./00-cross-column-layout-contract.md
  - ./02-sidebar-cassette-content-start-seam.md
  - ./07-column-specific-shared-track-boundaries.md
  - ../45-NEW-FEATURE-ADDITION/10-UNKNOWN_SOURCES/PROPOSAL.md
tests:
  - ../../../test/essentials/navigation/presentation/layout/unfamiliar_sources_page_track_plan_test.dart
  - ../../../test/essentials/navigation/application/panel_widget_providers_test.dart
---

# Unfamiliar Sources Page Current Implementation

The unfamiliar-source page applies the cross-column matrix to a two-column
composition:

```text
source-review sidebar | selected-source message evidence
```

The matrix coordinates the pre-content region. The cassette system continues
to own the remaining sidebar controls and source list, while Messages owns the
complete selected-source center-panel presentation.

## Ownership Chain

The ownership chain is intentional:

- Navigation owns the page matrix and the placement of prepared occupants.
- `MacosAppShell` gathers current page state, asks features for their prepared
  occupants, and invokes matrix composition and resolution.
- Messages owns the complete center-panel handle lens: source identity
  presentation, evidence metrics, source-scoped search controls, review-action
  presentation, and the Message evidence body.
- Handles supplies the canonical source facts and handle-review actions that
  the Messages presentation consumes. Contacts supplies contact creation and
  linking operations where those actions cross into Contact ownership.

This does not make Navigation an owner of handle or Message semantics. It also
does not require Handles to construct a Messages-owned evidence surface. The
feature-prepared occupant is the boundary: Messages translates approved
feature presentation into dimensional claims; Navigation places and resolves
those occupants.

## Current Occupancy

This table records occupancy only. Track letters are ordinal coordinates and
carry no semantic meaning.

| Cell | Sidebar | Center panel | Right panel |
| --- | --- | --- | --- |
| A | source-review top menu | persistent identity projected from the active investigation | empty |
| B | empty | selected source subject; empty while idle | empty |
| C | empty | source subject-to-metrics spacing occupant contributes 6 px when selected | empty |
| D | empty | source date span and message count | empty |
| E | empty | source metrics-to-search spacing occupant contributes 8 px | empty |
| F | empty | source-scoped search controls | empty |
| G | empty | source search-to-actions spacing occupant contributes 8 px | empty |
| H | empty | triage actions and optional create-contact detail | empty |
| I | empty | center header-to-evidence spacing occupant contributes 16 px | empty |
| Content | investigation controls and source list continue after Column 1's Track A allocation | idle investigation orientation or selected source message evidence continues after I2 | empty |

When no source is selected, A2 contains the real investigation-derived panel
identity. B2 and the source-specific metrics, search controls, actions, and
their adjacent spacing occupants are honestly absent. The evidence region
contains the Messages-owned orientation presentation for the active
investigation. The page still owns one matrix, but Navigation declares that
Column 1 participates through Track A. Its remaining cassette chain therefore
continues independently of transient center geometry.

This is deliberately not a minimum-height mechanism. The active investigation
has a truthful identity and visible orientation even without a selected
source, so Track geometry continues to resolve from occupants rather than
artificial reservations. The Matrix coordinates shared header geometry; it
does not lay out local explanatory prose in the evidence region.

## Composition Authority

`unfamiliar_sources_page_track_plan.dart` builds the page matrix from:

- the sidebar top-menu occupant;
- feature-owned selected-source occupants prepared by Messages;
- ordinary fixed-height occupants in C2, E2, G2, and I2.

The page resolves one plan and distributes it through
`ResolvedTrackLayoutMatrixScope`. Header cells in the center panel and matrix
cells in the sidebar consume that same plan. Neither renderer infers peer
geometry.

Visible center-panel content appears exactly once in the matrix. Feature-owned
occupants calculate natural claims from the same presentation data used to
construct their approved presentation widgets.

The source metrics occupant uses one shared finite-width calculation for its
claim and presentation. It renders the date span and count on one row when they
fit, or on two rows when they do not; the two-row claim includes the 4 px
inter-run spacing. It does not rely on a `Wrap` whose eventual run count is
unknown to Track resolution.

## Shared Session State

The selected-source header and the evidence body consume one handle-lens
session keyed by canonical handle ID. That session owns only local evidence
interaction state such as query, search mode, action progress, and optional
create-contact detail.

This shared state is necessary because the matrix constructs header
presentations at page-composition level while the evidence body remains in the
Messages feature view. It does not transfer feature semantics to Navigation or
the track system.

## Sidebar Continuation

Only the top menu occupies A1. Navigation page composition declares Track A as
the final Track shared with Column 1. The cassette coordinator then renders the
investigation controls and selected investigation's source list after the
resolved Track A allocation.

Because the independent cassette flow follows Track A directly, the seam
preserves the cassette coordinator's existing section rhythm. The transition
from the app-level top menu to the grouped filter controls is therefore spaced
by the sidebar cassette system, not by an empty Track, feature padding, or a
page-specific spacer.

Column 2 independently continues through B2-I2. I2 contains the fixed-height
occupant that contributes 16 px between the center header and its evidence.
This is not a semantic property of Track I; it is the current page
composition's purpose for the occupant in I2.

This preserves only the truthful shared relationship:

```text
A1: source-review top menu
A2: persistent center-panel identity

after Column 1's Track A allocation:
  independent sidebar cassette flow

after I2:
  independent center evidence
```

The generic sidebar renderer knows only the page-declared ordinal boundary. It
does not know which trailing cassette is an investigation selector, endpoint
filter, disposition control, or source list. The cassette system does not know
what occupies the center cells.

## Verification Invariants

- A1 and A2 share the same resolved height.
- Column 1 participates through Track A; B1 through I1 are not emitted before
  the independent cassette chain.
- Resuming the independent cassette chain preserves its coordinator-resolved
  top spacing; the Track seam does not reset it.
- B2, D2, F2, and H2 remain selected-source center-only presentation occupants.
- C, E, and G resolve from purpose-labelled fixed-height occupants between
  adjacent center-panel presentations. I resolves from the
  center-header-to-evidence spacing occupant in I2. These express reviewed page
  composition without embedding discretionary padding in occupied
  presentation tracks.
- I resolves to 16 px because I2 contributes an ordinary fixed-height occupant,
  but column 1 does not render I1 before its cassette flow.
- Selected-source B2-H2 geometry cannot move the sidebar investigation controls
  or source list.
- Changing source-review intent invalidates incompatible center evidence through
  investigation provenance; layout does not perform that cleanup.
- An active investigation without a compatible source resolves a real A2
  identity occupant and a real orientation presentation in the evidence
  region; it never relies on minimum Track heights or invisible fillers.
- No panel-local top padding repairs cross-column alignment.
