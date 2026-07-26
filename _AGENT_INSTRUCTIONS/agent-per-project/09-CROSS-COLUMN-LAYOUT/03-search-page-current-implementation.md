---
tier: project
scope: search-page-cross-column-layout
owner: agent-per-project
last_reviewed: 2026-07-19
source_of_truth: doc
links:
  - ./00-cross-column-layout-contract.md
  - ./01-column-band-wrappers.md
  - ./02-sidebar-cassette-content-start-seam.md
  - ./07-column-specific-shared-track-boundaries.md
  - ../95-WALK-UI-TREE/10-Messages-Sidebar/Message-Evidence-Center-Panel/README.md
tests: []
---

# Search Page Current Implementation

The Search page is the first practical application of the cross-column layout
contract.

It presents three peer workspaces:

```text
Search all messages | All messages | Conversation excerpt
```

The layout goal is not pixel-identical internal header content. The goal is a
shared vertical cadence:

```text
Track A
Track B
Track C
Track D
Track E
Track F
primary content
```

## Current Mapping

This table records current Search-page occupancy. It does not assign semantic
roles to the tracks.

| Cell | Left sidebar | Center panel | Right panel |
| --- | --- | --- | --- |
| A | Search all messages selector | All messages title | Conversation excerpt title |
| B | empty | result date range and message count | Conversation Card |
| C | empty | search controls | anchor-message month/year orientation |
| D | fixed-height occupant contributes 2 px | empty | empty |
| E | empty | Search Investigation Status | empty |
| F | fixed-height occupant contributes 16 px | empty | empty |
| Content | heatmap/navigation | search result messages | conversation excerpt messages |

## Resting Reservations

The Search composition also declares minimum geometry for cells whose live
content is optional or whose row must retain its intended resting cadence:

| Cell | Minimum source | Purpose |
| --- | --- | --- |
| B3 | canonical Conversation Card presentation metrics | Keeps Track B at the one-row card minimum before or after the right panel is present; a taller live card still expands it. |
| E2 | one-line Search Investigation Status typography and integrated activity-indicator diameter | Preserves stable status-row geometry from initial composition without embedding vertical spacing. |

A3 needs no reservation because the Conversation excerpt title occupant is always part
of the Search matrix. C3 needs no reservation because the always-present C2
Search controls already establish enough resting height for its optional
single-line month/year orientation.

These values are not placeholders and do not alter live claims. Each comes from
the same feature-owned presentation contract used by the eventual occupant.

## Current Layout Status

The Search-page matrix is implemented and verified. The title, metadata,
controls, investigation status, Conversation Card, temporal orientation, and final
fixed-height separation occupy explicit cells. Cell alignment and the ordinary
fixed-height occupant provide the reviewed cadence without panel-local repair
padding.

The E2 occupant aligns its description with the visible Search-field edge
through the feature-owned leading-slot and field-chrome contracts used by the
C2 controls. It may add a delayed activity indicator and `Searching...` without
changing Track occupancy or natural height. In the current composition D1
contributes 2 px between C and E, while F1 contributes the final 16 px before
the content-start seam. These are ordinary occupants; the tracks have no
semantic role.

Future visual tuning should remain a matrix edit, a truthful presentation
metric correction, or an occupant-presentation change. It must not restore the
retired wrapper path or add panel-level offsets outside resolved cells.

## Right Conversation Panel

The right panel is a Conversation lens, not a Search-owned context widget.

Search requests a Conversation excerpt around a chosen message. Conversation
UI renders the panel:

```text
Conversation excerpt
Conversation Card
anchor-message month/year orientation
conversation excerpt messages
```

The month/year line is temporal orientation, not message metadata. It answers
where the user has arrived in the Conversation timeline before the excerpt
begins. Its `title3` presentation is intentionally subordinate to the panel's
`title1` identity while remaining stronger than the caption-styled excerpt
text that previously described the excerpt window. It uses the existing
system-orange comparison accent at 84%
opacity: here orange identifies the temporal value organizing the excerpt, not
a warning or a generic date. No divider rules are used; hierarchy comes from
color, typography, and the existing matrix rhythm.

E3 is deliberately empty. The panel identity and temporal orientation already
make the bounded excerpt legible, so the former `21-message excerpt...` caption
no longer contributes useful information or geometry.

This ownership repair matters for layout because the right panel now
participates as a peer Conversation workspace, not as a special Search widget.

## Left Sidebar

The left sidebar remains cassette-driven.

The Search sidebar currently uses:

- A1 through F1 as complete `TrackCellView(CellId)` renderers supplied by the
  page matrix
- `SidebarCassetteLayoutAnchor.preferredContentStart` on the global heatmap
  cassette

Navigation explicitly declares F as this column's final shared Track. That
boundary is part of Search page composition; it is not inferred because F1 is
occupied or because the following cassette is a heatmap. The sidebar resumes
its native cassette flow after F1 even if another page composition later gives
peer columns a longer shared lifetime.

The A1 occupant's dimensional claim covers only the closed top-menu control.
Its transient option panel is presented in an anchored overlay. Opening the
menu therefore does not change A1's claim, resolved height, or the cassette
flow below it. Interactive controls placed in Track cells must follow the same
rule when their expanded presentation extends beyond their natural closed
bounds.

That lets the heatmap begin at the shared content start without hard-coding
heatmap knowledge into the page skeleton.

## Verification Expectations

When checking this surface manually:

- developer debug margins should show ordinal track cells aligned across
  columns
- each track should occupy the same vertical envelope across columns
- opening the right panel should not compress or expand Tracks B or E when its
  live occupants fit within their resting reservations
- content taller than a reservation should expand its Track, and removing that
  content should return the Track to its reserved resting height
- primary content should begin immediately after the page's pre-content track
  sequence
- content should not be moved down by ad hoc panel padding
- disabling debug margins should leave the same perceived layout rhythm

If one panel's content starts lower than the others, inspect matrix occupancy,
resolved claims, cell alignment, and the sidebar seam before changing local
widget padding.
