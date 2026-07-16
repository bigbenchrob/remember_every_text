---
tier: project
scope: track-cell-column-band-wrapper
owner: agent-per-project
last_reviewed: 2026-07-16
source_of_truth: doc
links:
  - ./00-cross-column-layout-contract.md
  - ../../../lib/config/theme/widgets/layout/vertical_column_bands.dart
  - ../../../lib/config/theme/widgets/layout/app_panel_bands.dart
tests: []
---

# Track Cell Column Band Wrapper

The current cross-column alignment mechanics are implemented with one generic
wrapper widget:

- `TrackCellColumnBand`

They live in:

```text
lib/config/theme/widgets/layout/vertical_column_bands.dart
```

## Role

The wrapper renders one column cell within one ordinal track. It provides the
resolved outer height for that cell, optional internal padding, page-owned child
placement, and optional developer diagnostics.

It is intentionally small. It is not a full page frame and it is not a
business-semantic component. The `TrackId` supplied to it is geometric only.

## Why Wrappers Instead Of A Full Frame

Earlier design work explored a stricter multi-band page frame. That was too
rigid for MessageLens because the left sidebar is cassette-driven and
non-deterministic.

The current model is narrower:

```text
TrackCellColumnBand(trackId: A)
TrackCellColumnBand(trackId: B)
TrackCellColumnBand(trackId: C)
...
primary content below the page's chosen track sequence
```

Each column can use the same wrapper while still letting its own feature or
cassette system decide what content belongs inside each cell.

## TrackCellColumnBand

Purpose:

- renders one cell of an ordinal track
- consumes a resolved `TrackPlan` when available
- falls back to a supplied height when a page has not opted into track
  negotiation
- keeps the page coordinator free of feature-specific branches

Constructor concepts:

- `trackId`: ordinal coordinate, such as `TrackId.trackA`
- `fallbackHeight`: compatibility height used only without a resolved plan
- `padding`: internal presentation inset for the child
- `childPlacement`: placement of the child within the resolved allocation
- `allowBandExpansion`: compatibility escape hatch for older/sidebar paths

The wrapper does not know whether its child is a selector, title, metadata row,
Conversation Card, control group, or fixed-height spacing occupant.

## Child Placement

`ColumnBandChildPlacement` provides approved internal placement options:

- `topLeft`
- `centerLeft`
- `bottomLeft`
- `custom`

Prefer page-composition defaults first. Use explicit placement only when the
child’s natural presentation needs controlled internal placement inside the
resolved cell.

Do not move content by adding panel-specific top padding outside the wrapper.

## Debug Margins

The wrapper can show diagnostic colored borders in developer mode when
`columnBandDebugMarginsProvider` is enabled.

Current diagnostic colors are assigned by ordinal track, not by semantic role:

- Track A: red
- Track B: blue
- Track C: green
- Track D and later tracks: additional debug colors as assigned
- overflow warning or exceptional diagnostic state: diagnostic warning styling

These borders are diagnostic only. They should not be part of production visual
language.

## Relationship To app_panel_bands.dart

`lib/config/theme/widgets/layout/app_panel_bands.dart` still exists and contains
older/support primitives such as:

- `AppPanelBands`
- `AppPanelColumnFrame`
- `AppPanelFrameHeader`
- `AppPanelFixedBand`
- `AppPanelBandHeader`

Treat these as transitional support for existing code paths unless a specific
path still requires them.

For new cross-column layout work, prefer the explicit generic wrapper model:

```text
TrackCellColumnBand(trackId: ...)
content
```

If the older primitives are retired or revived, update this document and the
contract document so future agents do not have to infer the active model from
code history.
