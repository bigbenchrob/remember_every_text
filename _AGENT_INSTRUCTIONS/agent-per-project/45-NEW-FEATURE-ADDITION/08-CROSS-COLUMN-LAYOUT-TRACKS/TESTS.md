---
tier: project
scope: tests
owner: agent-per-project
last_reviewed: 2026-07-14
source_of_truth: proposal
status: second-slice-implemented
links:
  - ./CHECKLIST.md
  - ../../09-CROSS-COLUMN-LAYOUT/03-search-page-current-implementation.md
tests: []
---

# Tests: Cross-Column Layout Tracks

This document describes validation strategy for the track model. Track A and
Track B are implemented on the Search page; broader Track C/later-track and
cassette participation remain future work.

## Implemented Track A / Track B Tests

Focused test coverage exists at:

`test/config/theme/widgets/layout/cross_column_track_plan_test.dart`

It verifies:

- `ResolvedTrackPlan` resolves a track to the maximum declared height
  requirement;
- `ResolvedTrackPlan` resolves separate Track A and Track B requirements;
- missing tracks fall back to the wrapper default;
- `TitleColumnBand` consumes a scoped resolved Track A height;
- `TitleColumnBand` preserves its default height without a resolved track plan;
- `ContextColumnBand` consumes a scoped resolved Track B height;
- `ContextColumnBand` preserves its default height without a resolved track
  plan.

These tests prove the first two vertical slices without depending on the full
Search page widget tree.

## Unit Tests

Track-plan model tests should cover:

- resolved height equals the maximum declared height requirement for each track;
- empty participants do not break resolution;
- missing optional tracks use documented fallback behavior;
- multiple columns can declare different height requirements;
- resolved plans are deterministic.

## Widget Tests

Search-page widget tests should verify:

- center and right title regions receive the same resolved Track A height;
- sidebar top menu receives the same resolved Track A height;
- center metadata, empty sidebar allocation, and empty right-panel allocation
  receive the same resolved Track B height;
- primary content begins after the resolved context track;
- the right Conversation panel can request more context height without moving
  only its own message list;
- the sidebar top menu still renders and remains interactive.

## Regression Tests

Regression coverage should protect against:

- reintroducing panel-specific top padding outside the track plan;
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
