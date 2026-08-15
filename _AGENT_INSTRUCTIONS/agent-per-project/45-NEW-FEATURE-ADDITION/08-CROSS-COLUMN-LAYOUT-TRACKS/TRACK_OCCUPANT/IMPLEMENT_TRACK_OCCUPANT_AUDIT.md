---
tier: project
scope: implementation-audit
owner: agent-per-project
last_reviewed: 2026-07-15
source_of_truth: audit
status: complete
links:
  - ./IMPLEMENT_TRACK_OCCUPANT.md
  - ../TRACK_OCCUPANT_ARCHITECTURE_ANALYSIS.md
  - ../README.md
tests:
  - flutter test test/config/theme/widgets/layout/cross_column_track_plan_test.dart --reporter compact
  - flutter analyze
---

# TrackOccupant Implementation Audit

## Summary

The first TrackOccupant implementation slice is architecturally sound.

Search-page Track A and Track B no longer depend on page-owned numeric
requirements. Requirements are now produced by declarative occupants and
resolved by the generic `ResolvedTrackPlan` coordinator.

The slice remains appropriately narrow. In the current Search-page composition:

- A1: sidebar top menu occupant.
- A2: center title occupant.
- A3: right title occupant.
- B1: no occupant.
- B2: center metadata occupant.
- B3: no occupant.
- No C2 fixed-height spacing occupant, Conversation Card occupant, glyph occupant, sidebar
  cassette participation, Contacts migration, or wrapper retirement.

## Audit Source Note

`IMPLEMENT_TRACK_OCCUPANT_CHECK.md` currently contains no content. This audit
therefore used `IMPLEMENT_TRACK_OCCUPANT.md` as the operative implementation
checklist.

Recommendation: either populate `IMPLEMENT_TRACK_OCCUPANT_CHECK.md` with this
audit checklist later or treat this report as the completed verification record
for the first slice.

## Architecture Validation

### Generic Coordinator

Status: passes.

`ResolvedTrackPlan.fromOccupants` collects `TrackRequirement` values from
occupants and delegates to the existing maximum-height resolver. The
coordinator does not branch on Search, sidebar controls, titles, metadata,
cards, glyphs, or concrete occupant types.

### TrackOccupant Contract

Status: passes for the first slice.

The implementation introduces:

- `TrackOccupant`
- `TrackRequirementContext`
- `ResolvedTrackAllocation`
- `TrackOccupantView`
- `TextTrackOccupant`

The requirement context is a plain immutable value object containing only
layout-relevant environment:

- available width
- `TextScaler`
- `TextDirection`
- optional locale

It does not carry providers, repositories, database handles, graph facts, user
intent, or mutation APIs.

### Constant And Calculated Requirements

Status: passes.

`TextTrackOccupant` calculates requirements with `TextPainter`, using the same
text, style, max-line, overflow, and wrapping contract used to build the
presentation widget.

`TopMenuTrackOccupant` receives its requirement from
`TopChatMenuPresentationMetrics.naturalTriggerHeight`, and the rendered
top-menu widget uses the same presentation metric constants for trigger
padding and trailing icon size.

### Empty Cells

Status: passes.

The Search-page resolved plan omits sidebar and right-panel Track B occupants.
Those cells therefore contribute no requirements.

The generic `TrackCellColumnBand` compatibility wrapper still renders empty
sidebar and right-panel Track B cells so the resolved allocation exists in the
visual layout. This is acceptable because those cells do not contribute to
requirement resolution.

## Scope Validation

The implementation stays within the approved first-slice scope.

Implemented:

- Search Track A occupants.
- Search Track B center metadata occupant.
- Occupant-derived Search track plan.
- Focused tests.
- Documentation updates.

Not implemented:

- Track C or later tracks.
- Shim tracks.
- Conversation Card occupants.
- Conversation glyph occupants.
- Sidebar cassette track participation.
- Automatic cassette placement.
- Contacts or Conversations-page migration.
- Wrapper retirement.
- Compact variants.
- Baseline negotiation.
- Custom layout/render objects.
- Post-frame measurement.

## Integration Review

### Search Page Plan

Status: acceptable first-slice adapter.

`resolveSearchPageTrackPlan` now assembles Search Track A/B occupants and
resolves a plan from them. It is page-layout code, not generic coordinator
code, so it is the correct place to choose the Search page's participating
occupants.

The function still uses a representative metadata text value because Track B is
currently a single-line typography-height track. This is acceptable for the
first slice because the visible metadata uses the same text style and
one-line presentation contract.

Future caution: if Track B ever permits wrapping or variable metadata height,
the actual metadata presentation data and available column width must reach the
Track B occupant. At that point a representative string would no longer be
sufficient.

### Message Evidence Header

Status: acceptable.

In the resolved track path:

- the center title renders through `TrackOccupantView(TextTrackOccupant)`;
- the center metadata renders through `TrackOccupantView(TextTrackOccupant)`;
- supporting context and search controls remain outside Track B.

This preserves the approved Track B boundary.

### Conversation Excerpt Panel

Status: acceptable.

The right-panel `Conversation` title renders through a Track A text occupant
when a resolved track plan is present. The Conversation Card and excerpt
description remain outside Track B, as required.

### Sidebar Top Menu

Status: acceptable.

The sidebar top menu is rendered through `TopMenuTrackOccupantView`, and the
top-menu occupant constructs the same top-menu presentation widget used before.
The cassette flow remains responsible for cassette sequencing and user
interaction.

## Tests And Verification

Commands run:

```bash
flutter test test/config/theme/widgets/layout/cross_column_track_plan_test.dart --reporter compact
flutter analyze
```

Results:

- Focused layout tests: passed.
- Analyzer: passed with no issues.

The test coverage now verifies:

- maximum-height track resolution;
- fallback behavior when no track requirements exist;
- resolution from occupants;
- text occupant requirement calculation;
- top-menu presentation metric requirement;
- Track A wrapper consumption of resolved height;
- Track B wrapper consumption of resolved height;
- compatibility wrapper fallback behavior without a resolved plan.

## Deviations Or Caveats

### Width-Aware Occupants Deferred

`TrackOccupantView` currently supplies `availableWidth: double.infinity`.

This is acceptable for the first slice because all implemented occupants are
single-line, non-wrapping title/control/metadata occupants. It is not sufficient
for future wrapped text, Conversation Cards, glyphs, or any occupant whose
requirement depends on finite column width.

Recommendation: the next width-sensitive slice should introduce a column/page
adapter that supplies finite track-cell width to requirements before resolving
the plan.

### Metadata Requirement Uses A Representative String

The Search-page plan uses a representative metadata string to calculate Track B
height, while the visible metadata is built from live header data.

This is acceptable only because Track B is currently a single-line text-height
track. It should not be carried into any future variable-height Track B model.

### `IMPLEMENT_TRACK_OCCUPANT_CHECK.md` Is Empty

The requested check file exists but contains no checklist content. This did not
block the audit because `IMPLEMENT_TRACK_OCCUPANT.md` is complete, but it is a
documentation consistency issue.

## Recommendation

The first TrackOccupant slice should be accepted as validating the architecture.

Do not refactor further before visual review unless a bug appears. The next
implementation slice should be chosen deliberately:

- If the goal is to improve Search vertical rhythm, introduce the next explicit
  track only after deciding which content owns it.
- If the goal is to generalize occupants, add finite-width requirement support
  before attempting Conversation Cards or glyphs.
- If the goal is sidebar integration, design sidebar cassette participation as
  a separate slice rather than extending this proof opportunistically.
