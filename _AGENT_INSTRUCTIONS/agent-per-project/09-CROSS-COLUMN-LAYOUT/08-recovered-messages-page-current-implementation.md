---
tier: project
scope: recovered-messages-cross-column-layout
owner: agent-per-project
last_reviewed: 2026-07-26
source_of_truth: doc
links:
  - ./00-cross-column-layout-contract.md
  - ./01-column-band-wrappers.md
  - ./07-column-specific-shared-track-boundaries.md
  - ../42-SPEC-SYSTEM/CANONICAL-ARCHITECTURE/30-panel-viewspec-system.md
tests:
  - ../../../test/essentials/navigation/presentation/layout/recovered_messages_page_track_plan_test.dart
  - ../../../test/essentials/navigation/application/panel_widget_providers_test.dart
  - ../../../test/features/messages/presentation/view/recovered_messages_evidence_view_test.dart
---

# Recovered Messages Page: Current Cross-Column Layout

Recovered Deleted Messages and Recovered No-Handle Messages share one
cross-column relationship:

```text
A1: sidebar top menu
A2: recovered-message center-panel title
A3: no occupant
```

The page matrix contains only Track A. This is intentional.

The sidebar resumes its native cassette flow immediately after A1. Its
explanatory cassette, controls, and any later content retain the ordering,
spacing, and overflow behavior owned by the cassette system.

The center panel resumes its Messages-owned native header flow immediately
after A2. Supporting context, date and count information, search controls,
status, and recovered-message evidence are not shared with sidebar content and
therefore do not occupy later page Tracks.

## Why The Shared Region Ends At A

The top menu and center title are persistent page-level peers. The later
sidebar and center content have no durable horizontal relationship.

Extending the shared region with empty cells would falsely couple the sidebar
to center-panel details. Adding fixed reservations would hide the same false
relationship behind geometry. Ending both shared lifetimes at Track A keeps the
matrix truthful while allowing each established local layout system to resume
all of its responsibilities.

## Ownership

- Navigation owns the recovered-message page matrix and A1/A2 placement.
- `MacosAppShell` prepares and resolves the matrix.
- The sidebar cassette system owns its native continuation after A1.
- Messages owns the recovered-message title occupant and the complete center
  presentation after A2.
- The Track resolver owns only the shared Track A geometry.

The same matrix composition supports both recovered-message variants. Their
feature-owned presentation data supplies the appropriate title and explanatory
copy without changing the page geometry contract.

## Implementation

- Page matrix:
  `lib/essentials/navigation/presentation/layout/recovered_messages_page_track_plan.dart`
- Messages occupants:
  `lib/features/messages/presentation/layout/recovered_messages_page_track_occupants.dart`
- Recovered presentation contract:
  `lib/features/messages/presentation/view_model/recovered_evidence_presentation.dart`
- Center rendering:
  `lib/features/messages/presentation/view/recovered_messages_evidence_view.dart`
- Sidebar boundary:
  `lib/essentials/navigation/application/panel_widget_providers.dart`

The recovered center header renders its shared A2 cell first, then continues
through the ordinary Messages evidence-header layout. That continuation is not
a second page matrix and does not bypass shared geometry; it begins only after
the page's declared shared region has ended.
