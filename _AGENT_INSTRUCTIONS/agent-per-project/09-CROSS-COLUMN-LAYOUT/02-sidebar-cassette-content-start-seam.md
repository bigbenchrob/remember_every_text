---
tier: project
scope: sidebar-content-start-seam
owner: agent-per-project
last_reviewed: 2026-07-24
source_of_truth: doc
links:
  - ./00-cross-column-layout-contract.md
  - ./01-column-band-wrappers.md
  - ./07-column-specific-shared-track-boundaries.md
  - ../08-SIDEBAR-LAYOUTS/README.md
  - ../42-SPEC-SYSTEM/CANONICAL-ARCHITECTURE/20-sidebar-cassette-system.md
  - ../45-NEW-FEATURE-ADDITION/03-INTRODUCE-SIDEBAR-CONTENT-SEAM/PROPOSAL.md
  - ../45-NEW-FEATURE-ADDITION/03-INTRODUCE-SIDEBAR-CONTENT-SEAM/DESIGN_NOTES.md
tests:
  - ../../../test/essentials/navigation/application/panel_widget_providers_test.dart
---

# Sidebar Cassette Content-Start Seam

The sidebar cassette system already solves a flexible layout problem:

```text
feature-owned cassette specs -> resolved cassette chain -> sidebar rendering
```

Cross-column layout solves a different problem:

```text
left content start == center content start == right content start
```

The sidebar should not be rewritten to obey center-panel layout. Instead, it
exposes a semantic seam that the page-level layout can align.

## Current Mechanism

The cassette payload model includes:

```dart
enum SidebarCassetteLayoutAnchor {
  none,
  preferredContentStart,
}
```

This lives on `SidebarCassettePayload` as `layoutAnchor`.

Meaning:

- `none`: ordinary cassette in the chain
- `preferredContentStart`: this cassette is the preferred primary content start
  for page-level alignment

## Current Sidebar Layout Behavior

When a page participates in the cross-column seam:

1. the app-control/top-menu cassette is represented by the occupant placed at
   A1 in that page's matrix
2. Navigation page composition declares the last Track row shared with the
   sidebar before its independent cassette flow resumes
3. the sidebar renders column-1 cells through that declared boundary by
   complete `CellId`
4. empty cells contain no occupant or claim, but may preserve explicit
   page-owned resting geometry and still receive the Track height resolved from
   all peer cells
5. any remaining app-control cassettes and the content-start cassette chain
   render below the page's pre-content track sequence

The boundary is page-specific and column-specific. It may include every
pre-content row when a real cross-column relationship exists, or end after A
when later rows describe only another column's local presentation. The generic
sidebar renderer consumes an explicit ordinal boundary; it does not infer the
boundary from feature meaning, cassette type, current occupancy, or a run of
empty cells.

This sidebar seam is one application of the general
[column-specific shared Track boundary](07-column-specific-shared-track-boundaries.md).
The final Track on the page does not force the sidebar to remain in shared
geometry for that entire lifetime.

When the sidebar leaves that shared geometry, the
[Native-Flow Ownership Restoration](07-column-specific-shared-track-boundaries.md#native-flow-ownership-restoration)
principle applies. The cassette chain resumes ownership of its complete native
layout policy, including ordinary leading rhythm, unless page composition
explicitly records that the shared region already supplied the transition.

## Example: Search All Messages

The current Search All Messages sidebar resolves into:

```text
Track cell A1:
  Search all messages selector

Track cell B1 or later sidebar pre-content cell:
  short heatmap orientation text

Content start:
  global messages heatmap/navigation cassette

Below content:
  usage guidance/footer text
```

The heatmap is not hard-coded into the track system. It participates in sidebar
content-start placement because its cassette payload declares:

```dart
SidebarCassetteLayoutAnchor.preferredContentStart
```

For contact-specific heatmaps, the same resolver currently does not mark the
heatmap as a global cross-column content start. That distinction belongs to the
feature resolver, not to the page skeleton.

## Why This Matters

The invariant is not:

```text
the heatmap starts here
```

The invariant is:

```text
the sidebar exposes a content-start seam
```

That lets any future sidebar configuration participate without teaching the
page skeleton about heatmaps, contact selectors, tag filters, or future
discovery widgets.

## Example: Unfamiliar Sources

The unfamiliar-source page declares a deliberately narrow shared region:

```text
A1:
  source-review top menu

After A1:
  investigation, endpoint-kind, and disposition controls
  selected investigation's source list

Meanwhile in column 2:
  B2 through H2 contain selected-source details and controls when applicable

I2:
  fixed-height center-header-to-evidence spacing occupant
```

The cassette coordinator still owns the order and rendering of those controls
and lists. Only A1 and A2 are persistent page-level peers. Selected-source
subject, metrics, search, and actions are transient center details and do not
delay the sidebar cassette chain. Ordinary fixed-height occupants in C2, E2,
G2, and I2 remain center composition geometry; they do not give those tracks
semantic roles.

This is not an unfamiliar-source branch inside a generic widget. Navigation's
page composition declares A as the last shared sidebar row, and the generic
renderer resumes the cassette flow after that coordinate.

## Deferred Autonomous Behavior

The current seam is conservative. It does not pre-measure arbitrary cassette
heights.

Future behavior may allow cassettes to declare preferred heights or compact
variants so the coordinator can decide whether a pre-content cassette fits
inside a chosen pre-content track cell.

Do not add post-frame measurement repair loops casually. Dynamic measurement
risks jitter, rebuild loops, localization failures, and fragile layout
dependencies.

If autonomous fitting becomes necessary, prefer:

- declared preferred heights
- explicit compact variants
- max-line limits for pre-content text
- moving extended guidance below content

## Ownership Rules

Navigation page composition owns cross-column anchors and each sidebar's last
shared Track boundary.

The sidebar cassette coordinator owns cassette chaining and sidebar rendering.

Feature resolvers own whether their payload should identify a cassette as
`preferredContentStart`.

Individual cassette widgets must not know about center-panel or right-panel
geometry.
