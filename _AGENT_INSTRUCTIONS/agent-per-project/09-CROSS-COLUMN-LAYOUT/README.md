---
tier: project
scope: cross-column-layout
owner: agent-per-project
last_reviewed: 2026-07-16
source_of_truth: doc
links:
  - ./00-cross-column-layout-contract.md
  - ./01-column-band-wrappers.md
  - ./02-sidebar-cassette-content-start-seam.md
  - ./03-search-page-current-implementation.md
  - ./04-design-history-and-cross-references.md
  - ./05-anatomy-of-track-cell-rendering.md
  - ../07-CENTER-PANEL-LAYOUTS/README.md
  - ../08-SIDEBAR-LAYOUTS/README.md
  - ../95-WALK-UI-TREE/15-X-COLUMN-LAYOUT/README.md
tests: []
---

# Cross-Column Layout

This folder is the canonical home for MessageLens cross-column vertical
alignment.

Use it when the question is:

> How do the left sidebar, center panel, and right/end panel line up
> vertically?

This is a page-level layout topic. It does not belong solely to center-panel
layout or sidebar layout. Those folders document how individual regions compose
their own content. This folder documents how peer regions coordinate their
vertical rhythm across the window.

## Core Principle

The page owns cross-column alignment.

Components own their presentation inside the space assigned to them.

The page-level contract establishes a shared visual grammar. Individual panels
do not invent their own vertical hierarchy; they express the shared grammar
using content appropriate to their lens.

## What This Folder Owns

- the durable cross-column alignment contract
- the page matrix, resolved geometry, and complete-cell rendering mechanics
- the sidebar cassette content-start seam
- current Search-page application of the contract
- links to the UI-walk and feature-package history that produced the design

## What This Folder Does Not Own

- the internal visual design of center-panel message evidence
- the full sidebar cassette system
- feature-specific business meaning
- Conversation Card presentation
- search, message, contact, or conversation data flow

Those belong in the relevant feature, sidebar, center-panel, or spec-system
documentation.

## Canonical Reading Order

1. [`00-cross-column-layout-contract.md`](00-cross-column-layout-contract.md)
   explains the invariant.
2. [`01-column-band-wrappers.md`](01-column-band-wrappers.md) explains the
   active matrix and `TrackCellView` mechanics. Its filename preserves an old
   link; its content describes the current system.
3. [`02-sidebar-cassette-content-start-seam.md`](02-sidebar-cassette-content-start-seam.md)
   explains how the sidebar participates without surrendering cassette
   ownership.
4. [`03-search-page-current-implementation.md`](03-search-page-current-implementation.md)
   records the current applied Search-page state.
5. [`04-design-history-and-cross-references.md`](04-design-history-and-cross-references.md)
   points to the UI-walk and feature-package history.
6. [`05-anatomy-of-track-cell-rendering.md`](05-anatomy-of-track-cell-rendering.md)
   explains the concrete rendering chain from feature preparation through
   complete `CellId` rendering.

## Relationship To UI Walk

`95-WALK-UI-TREE/15-X-COLUMN-LAYOUT/` is historical design and review context.
It records how the layout grammar emerged.

This folder is the durable mechanical contract.

Future tuning should update this folder when the mechanics or invariants
change. UI-walk documents may still record surface-specific observations, but
they should link back here instead of becoming the only explanation of how
cross-column alignment works.
