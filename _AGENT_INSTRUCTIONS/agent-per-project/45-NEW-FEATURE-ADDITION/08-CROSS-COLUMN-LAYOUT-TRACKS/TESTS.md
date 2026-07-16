---
tier: project
scope: tests
owner: agent-per-project
last_reviewed: 2026-07-16
source_of_truth: proposal
status: c3-conversation-card-occupant-implemented
links:
  - ./CHECKLIST.md
  - ../../09-CROSS-COLUMN-LAYOUT/03-search-page-current-implementation.md
tests: []
---

# Tests: Cross-Column Layout Tracks

This document describes validation strategy for the track model. The current
Search-page composition uses occupants in A1/A2/A3, B2, C2, and optionally C3
when the right Conversation excerpt is visible; later content cells and
cassette participation remain future work.

## Implemented Track A / Track B / Track C Tests

Focused test coverage exists at:

`test/config/theme/widgets/layout/cross_column_track_plan_test.dart`

It verifies:

- `ResolvedTrackPlan` resolves a track to the maximum declared height
  requirement;
- `ResolvedTrackPlan` resolves separate Track A and Track B requirements;
- `MessageEvidenceSearchControlsTrackOccupant` lets C2 declare the Message
  Evidence search-control row requirement through the ordinary occupant
  interface;
- `MessageEvidenceSupportingContextTrackOccupant` lets D2 declare the Message
  Evidence supporting-context row requirement through the ordinary occupant
  interface;
- a `FixedHeightTrackOccupant` can contribute an ordinary 16 px E-track
  allocation;
- `TrackCellColumnBand` honors the resolved C-track allocation for empty
  cells;
- `TrackCellColumnBand` can bottom-align content inside a resolved track cell;
- missing tracks fall back to the wrapper default;
- `TrackCellColumnBand(trackId: TrackId.trackA)` consumes a scoped resolved
  Track A height;
- `TrackCellColumnBand(trackId: TrackId.trackA)` preserves its fallback height
  without a resolved track plan;
- `TrackCellColumnBand(trackId: TrackId.trackB)` consumes a scoped resolved
  Track B height;
- `TrackCellColumnBand(trackId: TrackId.trackB)` preserves its fallback height
  without a resolved track plan.

Focused Conversation Card coverage exists at:

`test/features/conversations/presentation/widgets/conversation_signature_card_test.dart`

It verifies:

- one-row glyph natural height comes from shared presentation metrics;
- multi-row glyph height increases under finite-width constraints;
- `ConversationSignatureCardTrackOccupant` requirements increase as glyph
  height increases;
- `ConversationSignatureCardTrackOccupant` requirements use the canonical card
  width rather than the ambient right-panel or container width;
- rendered `ConversationSignatureCard` height matches the calculated natural
  requirement;
- rendered `ConversationSignatureCard` width remains canonical inside wider
  containers;
- finite width changes glyph row count at the metrics level.

These tests prove the first two vertical slices without depending on the full
Search page widget tree.

## Unit Tests

Track-plan model tests should cover:

- resolved height equals the maximum declared height requirement for each track;
- C-track height originates from one `FixedHeightTrackOccupant`, not a direct
  plan override;
- C-track height can also originate from a variable-height C3
  `ConversationSignatureCardTrackOccupant` when present;
- empty participants do not break resolution;
- missing optional tracks use documented fallback behavior;
- multiple columns can declare different height requirements;
- resolved plans are deterministic.

Future Track Cell Alignment tests should cover:

- top, center, and bottom alignment place the occupant differently inside the
  same resolved allocation;
- changing alignment does not change `TrackRequirement`;
- changing alignment does not change resolved track height;
- alignment belongs to the page-composition cell placement, not the
  `TrackOccupant`;
- no padding or fixed-height requirement is introduced merely to achieve
  alignment.

## Widget Tests

Search-page widget tests should verify:

- center and right title regions receive the same resolved Track A height;
- sidebar top menu receives the same resolved Track A height;
- center metadata, empty sidebar allocation, and empty right-panel allocation
  receive the same resolved Track B height;
- C1 and C3 honor the resolved C-track allocation without contributing
  duplicate fixed-height occupants;
- C3 can contribute a variable Conversation Card requirement without teaching
  the coordinator Conversation semantics;
- primary content begins after the resolved allocations already participating
  in the Search-page composition;
- the right Conversation panel can request more context height without moving
  only its own message list;
- the sidebar top menu still renders and remains interactive.

## Regression Tests

Regression coverage should protect against:

- reintroducing panel-specific top padding outside the track plan;
- assigning Track C a direct fixed height outside the occupant negotiation
  mechanism;
- adding duplicate fixed-height spacing occupants to C1 or C3;
- search controls pushing message results down independently;
- right Conversation Card overflow when glyphs or metadata are denser;
- sidebar menu popover being clipped or made non-interactive by track wrappers;
- disabling debug margins changing actual layout.

## Manual Verification

Manual verification should use the Search page first.

Scenarios:

1. Open Search all messages with no search term.
2. Search for a term with many results.
3. Open a result in Conversation context.
4. Toggle column-band or track debug diagnostics if available.
5. Compare the content-start positions of:
   - sidebar navigation content;
   - center message results;
   - right conversation excerpt messages.
6. Test Conversation Cards with:
   - short one-to-one title;
   - one-to-one title plus chat hook;
   - group title;
   - visible tags;
   - larger glyph density.
7. Resize the window narrower and wider.
8. Open the sidebar top menu and confirm it overlays correctly and remains
   interactive.

## Acceptance Criteria

The first implementation should be accepted only if:

- the Search page keeps its current user-facing behavior;
- track resolution improves or preserves the current visual rhythm;
- sidebar cassette flow remains owned by the sidebar;
- no source-specific widget learns about sibling columns;
- debug tooling makes the resolved track plan understandable.
