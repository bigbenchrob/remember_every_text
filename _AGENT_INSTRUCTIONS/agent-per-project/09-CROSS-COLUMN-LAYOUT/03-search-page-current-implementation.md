---
tier: project
scope: search-page-cross-column-layout
owner: agent-per-project
last_reviewed: 2026-07-16
source_of_truth: doc
links:
  - ./00-cross-column-layout-contract.md
  - ./01-column-band-wrappers.md
  - ./02-sidebar-cassette-content-start-seam.md
  - ../95-WALK-UI-TREE/10-Messages-Sidebar/Message-Evidence-Center-Panel/README.md
tests: []
---

# Search Page Current Implementation

The Search page is the first practical application of the cross-column layout
contract.

It presents three peer workspaces:

```text
Search all messages | All messages | Conversation
```

The layout goal is not pixel-identical internal header content. The goal is a
shared vertical cadence:

```text
Track A
Track B
Track C
Track D
Track E
primary content
```

## Current Mapping

This table records current Search-page occupancy. It does not assign semantic
roles to the tracks.

| Cell | Left sidebar | Center panel | Right panel |
| --- | --- | --- | --- |
| A | Search all messages selector | All messages title | Conversation title |
| B | empty | result date range and message count | Conversation Card |
| C | empty | search controls | empty |
| D | empty | supporting search context text | excerpt description |
| E | resolved fixed-height allocation | fixed-height occupant contributes the shared allocation | resolved fixed-height allocation |
| Content | heatmap/navigation | search result messages | conversation excerpt messages |

## Resting Reservations

The Search composition also declares minimum geometry for cells whose live
content is optional or whose row must retain its intended resting cadence:

| Cell | Minimum source | Purpose |
| --- | --- | --- |
| B3 | canonical Conversation Card presentation metrics | Keeps Track B at the one-row card minimum before or after the right panel is present; a taller live card still expands it. |
| D2 | exact one-line supporting-context typography and outer inset | Preserves the supporting-context row's intended height from initial composition. |
| D3 | exact one-line excerpt-label typography at canonical content width | Keeps Track D stable while the optional excerpt label is absent; wrapped live text may expand it. |

A3 needs no reservation because the Conversation title occupant is always part
of the Search matrix. C3 deliberately remains at zero because no future
occupant contract currently justifies reserved geometry there.

These values are not placeholders and do not alter live claims. Each comes from
the same feature-owned presentation contract used by the eventual occupant.

## Current Layout Status

The Search-page matrix is implemented and verified. The title, metadata,
controls, supporting context, Conversation Card, excerpt label, and final
fixed-height separation occupy explicit cells. Cell alignment and the ordinary
fixed-height occupant provide the reviewed cadence without panel-local repair
padding.

Future visual tuning should remain a matrix edit, a truthful presentation
metric correction, or an occupant-presentation change. It must not restore the
retired wrapper path or add panel-level offsets outside resolved cells.

## Right Conversation Panel

The right panel is a Conversation lens, not a Search-owned context widget.

Search requests a Conversation excerpt around a chosen message. Conversation
UI renders the panel:

```text
Conversation
Conversation Card
excerpt description
conversation excerpt messages
```

This ownership repair matters for layout because the right panel now
participates as a peer Conversation workspace, not as a special Search widget.

## Left Sidebar

The left sidebar remains cassette-driven.

The Search sidebar currently uses:

- A1 through E1 as complete `TrackCellView(CellId)` renderers supplied by the
  page matrix
- `SidebarCassetteLayoutAnchor.preferredContentStart` on the global heatmap
  cassette

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
- opening the right panel should not compress or expand Tracks B or D when its
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
