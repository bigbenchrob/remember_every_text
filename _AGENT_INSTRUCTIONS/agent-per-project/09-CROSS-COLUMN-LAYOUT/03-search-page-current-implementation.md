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
| B | empty | result date range and message count | empty |
| C | empty | search controls | Conversation Card |
| D | empty | supporting search context text | excerpt description |
| E | resolved fixed-height allocation | fixed-height occupant contributes the shared allocation | resolved fixed-height allocation |
| Content | heatmap/navigation | search result messages | conversation excerpt messages |

## Known Current Tuning Point

The current implementation proves the cross-column alignment concept, but
some internal placement still needs tuning.

The known issue captured from current UI review:

- center search controls can feel pressed too close to the message content
  below

This should be solved inside the track-cell wrapper or by explicit page-owned
cell alignment, not by adding panel-level top padding outside the track cells.

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

- `TrackCellColumnBand` around the top menu/selector
- optional `TrackCellColumnBand` allocations above the sidebar content-start
  cassette when required by the page composition
- `SidebarCassetteLayoutAnchor.preferredContentStart` on the global heatmap
  cassette

That lets the heatmap begin at the shared content start without hard-coding
heatmap knowledge into the page skeleton.

## Verification Expectations

When checking this surface manually:

- developer debug margins should show ordinal track cells aligned across
  columns
- each track should occupy the same vertical envelope across columns
- primary content should begin immediately after the page's pre-content track
  sequence
- content should not be moved down by ad hoc panel padding
- disabling debug margins should leave the same perceived layout rhythm

If one panel’s content starts lower than the others, inspect the wrapper usage
and sidebar seam before changing local widget padding.
