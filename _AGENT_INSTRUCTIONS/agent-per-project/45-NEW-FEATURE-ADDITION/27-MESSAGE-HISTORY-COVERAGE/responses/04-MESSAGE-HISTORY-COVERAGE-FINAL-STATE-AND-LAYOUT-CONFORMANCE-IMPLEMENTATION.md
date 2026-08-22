---
tier: project
scope: message-history-coverage
owner: agent-per-project
last_reviewed: 2026-08-22
source_of_truth: implementation-record
---

# Message History Coverage Final State And Layout Conformance

## Title Alignment Root Cause

Track A correctly established shared vertical geometry, but A2 contained a bare
`TextTrackOccupant`. `TrackCellView` therefore placed the title at the center
panel's outer left boundary. The report body independently used a 32-point
horizontal inset and a 720-point maximum readable width, so the two
presentations did not share one horizontal contract.

Track resolution was not the fault. The title occupant bypassed the report's
content-column geometry.

## Canonical Horizontal Alignment

Settings now owns one Message History Coverage center-column presentation
contract:

- horizontal inset: `AppSpacing.xl`;
- maximum readable width: 720 points;
- leading alignment inside the readable column.

The A2 title occupant and every native report state use the same wrapper. The
title's dimensional claim is calculated from that same contract. Track A still
owns only shared height and vertical placement; it has acquired no horizontal
layout responsibility.

Tests prove that the title and report body share the same leading coordinate at
both 520- and 1000-point fixture widths.

## Final Status Treatment

All four report states retain one semantic status icon and one explicit
headline. The separate `Complete`, `Review needed`, `Temporarily unavailable`,
and `Check failed` eyebrows were removed.

The headline already carries the complete human conclusion, so the eyebrow
created visual and spoken repetition without adding authority. The icon keeps
the state easy to scan, while the headline makes its meaning independent of
color.

### Complete

> All messages on this Mac are accounted for

The success icon is retained. Recovered Messages remains ordinary accounted
evidence and receives no warning treatment.

### Incomplete

> {count} messages could not be accounted for

The warning icon and warning semantic color are restrained rather than
destructive. Exact counts and the headline communicate the exception without
depending on color. Complete-state language cannot appear in this state.

### Temporarily Unavailable

The report explains that MessageLens is updating message data, shows no stale
counts, and offers no unnecessary Retry action. The report provider watches
maintenance authority, so releasing maintenance recomputes current truth
without a polling loop or user command.

### Failed

The bounded failure headline, safe `Try Again` action, and disclosed diagnostic
evidence remain. No large technical failure panel was introduced.

## Count Surface

The existing compact count surface was retained:

1. Messages on this Mac;
2. In conversations;
3. Recovered Messages;
4. Unaccounted.

Its row spacing, separator, tabular number alignment, and hierarchy already
read correctly. Zero unaccounted messages remain tertiary in the complete
state. A positive unaccounted value receives warning emphasis without changing
the card's geometry.

The view still renders values from the typed report model and performs no
coverage arithmetic.

## Details

Details no longer repeats the four primary count rows. It now provides only
additional evidence:

- total accounted for;
- date range on this Mac;
- checked time;
- bounded diagnostic detail when present;
- the Historical Archives scope distinction.

This keeps the disclosure useful without making it a second copy of the count
surface.

## Sidebar And Capitalization

The three sidebar sections remain unchanged. Their spacing and explanatory
hierarchy are already clear, and the opening `Message History Coverage`
subheading usefully identifies the report before the two explanatory sections.

The menu's sentence-case `Message history coverage report` follows menu-label
conventions. The center and sidebar titles remain title case. No global copy
normalization was justified.

## Accessibility

- The page title is a semantic header in both tracked and isolated fixtures.
- Each state headline is one semantic header without a repeated eyebrow.
- Status meaning is explicit in text and icon, not color alone.
- The count surface exposes one natural-language summary with labels and
  values.
- Details remains a button with truthful expanded/collapsed state.
- `Try Again` retains a direct action label.
- Loading retains a concise semantic label and no artificial delay or noisy
  live-region choreography.

## Final Track Contract

The page continues to declare exactly one shared Track:

```text
A1: Settings menu occupant
A2: Message History Coverage title occupant
A3: no occupant
```

Below A, the Settings sidebar and report body resume independent native flow.
Loading, complete, incomplete, temporarily unavailable, and failed states use
the same skeleton. No Track, minimum reservation, fixed-height occupant, or
magic title inset was added.

## Architecture Conformance

- Prompt 02's denominator and terminal partition are unchanged.
- Presentation performs no count arithmetic and introduces no clamp.
- Historical sources remain outside current-Mac coverage.
- Recovered Messages remains accounted-for.
- Provider lifecycle and maintenance authority are unchanged.
- No Narrator or progress framework was added.
- No database schema or persistence format changed.

## Release Readiness

### READY

Message History Coverage is complete for its current product contract. A future
exact browser for unaccounted rows remains optional; its absence does not make
the current aggregate report untruthful or incomplete.

## Verification

Final verification completed successfully:

- 48 focused Message History Coverage, Track, Settings-menu, and panel-routing
  tests passed;
- all 179 Settings feature tests passed;
- all 381 architecture tripwires passed;
- the complete 1,960-test Flutter suite passed;
- `flutter analyze` reported no issues;
- formatting and `git diff --check` passed;
- `flutter build macos --debug` produced `MessageLens Development.app`.
