---
tier: project
scope: sidebar-content-start-seam
owner: agent-per-project
last_reviewed: 2026-07-16
source_of_truth: doc
links:
  - ./00-cross-column-layout-contract.md
  - ./01-column-band-wrappers.md
  - ../08-SIDEBAR-LAYOUTS/README.md
  - ../42-SPEC-SYSTEM/CANONICAL-ARCHITECTURE/20-sidebar-cassette-system.md
  - ../45-NEW-FEATURE-ADDITION/03-INTRODUCE-SIDEBAR-CONTENT-SEAM/PROPOSAL.md
  - ../45-NEW-FEATURE-ADDITION/03-INTRODUCE-SIDEBAR-CONTENT-SEAM/DESIGN_NOTES.md
tests: []
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
   A1 in the Search-page matrix
2. the sidebar renders A1 through E1 by complete `CellId`
3. empty cells contain no occupant or claim, but may preserve explicit
   page-owned resting geometry and still receive the Track height resolved from
   all peer cells
4. content-start cassettes and all later cassettes render below the page's
   pre-content track sequence

This means the content-start cassette begins at the same vertical point as the
center and right panel content.

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

The page skeleton owns cross-column anchors.

The sidebar cassette coordinator owns cassette chaining and sidebar rendering.

Feature resolvers own whether their payload should identify a cassette as
`preferredContentStart`.

Individual cassette widgets must not know about center-panel or right-panel
geometry.
