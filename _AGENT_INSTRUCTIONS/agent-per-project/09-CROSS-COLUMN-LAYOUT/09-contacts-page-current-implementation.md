---
tier: project
scope: contacts-page-cross-column-layout
owner: agent-per-project
last_reviewed: 2026-07-26
source_of_truth: doc
links:
  - ./00-cross-column-layout-contract.md
  - ./07-column-specific-shared-track-boundaries.md
  - ../42-SPEC-SYSTEM/CANONICAL-ARCHITECTURE/30-panel-viewspec-system.md
tests:
  - ../../../test/essentials/navigation/presentation/layout/contacts_page_track_plan_test.dart
  - ../../../test/features/messages/presentation/view/contact_messages_evidence_view_test.dart
  - ../../../test/features/conversations/presentation/view/conversation_messages_view_test.dart
---

# Contacts Page: Current Cross-Column Layout

The Contacts page has one durable cross-column relationship:

```text
A1: Contacts sidebar top menu
A2: effective center-panel ViewSpec title, when one exists
A3: no occupant
```

The page resolves one shared Track A height from those occupants. The top menu
and effective center title therefore begin the page as peer identities.

## Effective Center Ownership

Contacts can lead to center presentations owned by different features:

- Messages supplies the title for contact message evidence and recovered
  contact evidence.
- Conversations supplies the title for a selected Conversation's message
  evidence.
- A2 has no occupant when there is no effective center ViewSpec.

Navigation owns the matrix placement. It does not construct or interpret these
feature presentations. Each effective ViewSpec owner prepares its own title
occupant from the same presentation inputs used by its rendered view.

## Native Flow After Track A

Both participating columns end their shared Track lifetime after Track A.

The sidebar resumes its native cassette flow, including:

- Change Contact;
- Contact identity and editing controls;
- message-scope and endpoint filters;
- evidence organization controls;
- heatmaps or Conversation collections.

The center panel resumes the native header and evidence flow owned by the
effective ViewSpec feature, including metrics, search controls, and message
evidence.

These are current occupants of the independent continuations. They do not
define the architecture.

## Why There Are No Later Shared Tracks

No durable geometric relationship exists between the Contacts sidebar controls
and the center presentation below their peer identities. Adding later empty
cells would make one column's transient content move the other column without
a truthful compositional reason.

The Contacts page therefore uses the same narrow shared-boundary principle as
Recovered Messages:

> Coordinate the peer page identities, then return each column to the layout
> system that owns its independent continuation.

## Implementation

The page composition is declared in:

- `lib/essentials/navigation/presentation/layout/contacts_page_track_plan.dart`

Feature-prepared occupants live with their ViewSpec owners:

- `lib/features/messages/presentation/layout/contacts_page_message_track_occupants.dart`
- `lib/features/conversations/presentation/layout/contacts_page_conversation_track_occupants.dart`

`MacosAppShell` selects the effective center ViewSpec, asks the appropriate
feature adapter to prepare A2, resolves the matrix, and distributes the
resolved plan. The sidebar seam declares Track A as its final shared Track.
