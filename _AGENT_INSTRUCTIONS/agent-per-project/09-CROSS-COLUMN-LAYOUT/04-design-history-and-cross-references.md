---
tier: project
scope: cross-column-layout-history
owner: agent-per-project
last_reviewed: 2026-07-14
source_of_truth: doc
links:
  - ./README.md
  - ../95-WALK-UI-TREE/15-X-COLUMN-LAYOUT/README.md
  - ../95-WALK-UI-TREE/15-X-COLUMN-LAYOUT/CONVERSATION_OWNERSHIP_AUDIT.md
  - ../95-WALK-UI-TREE/15-X-COLUMN-LAYOUT/CONVERSATION_OWNERSHIP_REPAIR.md
  - ../45-NEW-FEATURE-ADDITION/03-INTRODUCE-SIDEBAR-CONTENT-SEAM/PROPOSAL.md
  - ../45-NEW-FEATURE-ADDITION/03-INTRODUCE-SIDEBAR-CONTENT-SEAM/DESIGN_NOTES.md
tests: []
---

# Design History And Cross References

This document points to the historical material that produced the current
cross-column layout contract.

The history is useful, but it is not the primary place to look for the
mechanical rule. The canonical rule lives in this folder.

## UI Walk: X-Column Layout

Historical design/review folder:

```text
95-WALK-UI-TREE/15-X-COLUMN-LAYOUT/
```

Use it for:

- the original Search-page observations
- why widget nudging was rejected
- why the page should own layout
- the shift from rigid multi-band frame to title/context wrapper model
- conversation panel ownership notes that emerged during layout work

Do not treat it as the only current source of truth for cross-column mechanics.

## Sidebar Content Seam Work Package

Historical feature-package folder:

```text
45-NEW-FEATURE-ADDITION/03-INTRODUCE-SIDEBAR-CONTENT-SEAM/
```

Use it for:

- the initial seam proposal
- naming rationale for `preferredContentStart`
- risks of dynamic height measurement
- why the cassette system should remain autonomous

The durable seam contract is summarized in:

```text
09-CROSS-COLUMN-LAYOUT/02-sidebar-cassette-content-start-seam.md
```

## Conversation Ownership Repair

During layout work, the right panel’s ownership became important.

Search does not own the Conversation panel. Search requests a Conversation
excerpt; Conversation UI renders it.

Historical references:

- `95-WALK-UI-TREE/15-X-COLUMN-LAYOUT/CONVERSATION_OWNERSHIP_AUDIT.md`
- `95-WALK-UI-TREE/15-X-COLUMN-LAYOUT/CONVERSATION_OWNERSHIP_REPAIR.md`

Current feature ownership reference:

- `40-FEATURES/conversations/README.md`

## Related Layout Folders

Use these for local region rules:

- `07-CENTER-PANEL-LAYOUTS/` for center-panel report/control-panel layout
- `08-SIDEBAR-LAYOUTS/` for sidebar cassette and control-stack layout

Use this folder for cross-column coordination between those regions.

## Maintenance Rule

When future UI-walk work changes how columns align, update:

1. `09-CROSS-COLUMN-LAYOUT/`
2. any affected local layout docs
3. the originating UI-walk review document

Do not leave the only explanation buried inside a completed UI review.
