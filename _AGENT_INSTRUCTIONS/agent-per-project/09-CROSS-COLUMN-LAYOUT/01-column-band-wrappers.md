---
tier: project
scope: column-band-wrappers
owner: agent-per-project
last_reviewed: 2026-07-14
source_of_truth: doc
links:
  - ./00-cross-column-layout-contract.md
  - ../../../lib/config/theme/widgets/layout/vertical_column_bands.dart
  - ../../../lib/config/theme/widgets/layout/app_panel_bands.dart
tests: []
---

# Column Band Wrappers

The current cross-column alignment mechanics are implemented with two wrapper
widgets:

- `TitleColumnBand`
- `ContextColumnBand`

They live in:

```text
lib/config/theme/widgets/layout/vertical_column_bands.dart
```

## Role

The wrappers own fixed outer dimensions. They also provide default internal
padding, child placement, and optional developer diagnostics.

They are intentionally small. They are not a full page frame and they are not a
business-semantic component.

## Why Wrappers Instead Of A Full Frame

Earlier design work explored a stricter multi-band page frame. That was too
rigid for MessageLens because the left sidebar is cassette-driven and
non-deterministic.

The current model is narrower:

```text
TitleColumnBand
ContextColumnBand
primary content below
```

Each column can use the same wrappers while still letting its own feature or
cassette system decide what content belongs inside each band.

## TitleColumnBand

Purpose:

- wraps panel identity
- aligns the top selector/menu/title region across participating columns

Current defaults:

- height: `72`
- padding: `EdgeInsets.fromLTRB(32, 24, 32, 0)`
- child placement: top-left
- diagnostic border: red

Sidebar usage may pass sidebar-specific padding while preserving the same outer
height.

## ContextColumnBand

Purpose:

- wraps pre-content context, scope, controls, or primary object summary
- fixes the content-start y-position below it

Current defaults:

- height: `166`
- padding: `EdgeInsets.fromLTRB(32, 10, 32, 0)`
- child placement: top-left
- diagnostic border: blue

Sidebar usage may pass sidebar-specific padding while preserving the same outer
height.

## Child Placement

`ColumnBandChildPlacement` provides approved internal placement options:

- `topLeft`
- `centerLeft`
- `bottomLeft`
- `custom`

Prefer wrapper defaults first. Use explicit placement only when the child’s
natural presentation needs controlled internal placement inside the fixed
envelope.

Do not move content by adding panel-specific top padding outside the wrapper.

## Debug Margins

The wrappers can show diagnostic colored borders in developer mode when
`columnBandDebugMarginsProvider` is enabled.

Semantics:

- red: title band
- blue: context band
- orange: overflow warning or exceptional diagnostic state

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

For new cross-column layout work, prefer the explicit wrapper model:

```text
TitleColumnBand
ContextColumnBand
content
```

If the older primitives are retired or revived, update this document and the
contract document so future agents do not have to infer the active model from
code history.
