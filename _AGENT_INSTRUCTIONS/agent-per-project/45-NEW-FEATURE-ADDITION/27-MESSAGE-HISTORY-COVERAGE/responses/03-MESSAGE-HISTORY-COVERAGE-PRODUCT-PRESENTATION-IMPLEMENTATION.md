---
tier: project
scope: message-history-coverage
owner: agent-per-project
last_reviewed: 2026-08-22
source_of_truth: implementation-record
---

# Message History Coverage Product Presentation Implementation

## Opening Presentation Audit

The completed pre-slice page presented the coverage result as a dense report:

- a hero card with a status badge, headline, summary, and generated time;
- a separate Message Accounting card and segmented accounting bar;
- equal-height Reconciliation and Timeline Coverage cards;
- a separate Recovered Messages card;
- a Notes card;
- large rounded card chrome and repeated headings throughout the page;
- primary-accent treatment for complete and destructive-red treatment for
  incomplete;
- a detached, centered `Loading Message History Coverage...` message;
- diagnostic language such as visible, missing, reconciliation, and source
  database comparison in the main reading order.

The page offered no exact evidence-navigation action. Its visual structure was
built for the earlier gross-count arithmetic and gave a healthy result the
weight of a diagnostics dashboard.

## Final Page Hierarchy

The final report follows one short reading order:

1. `Message History Coverage` page identity;
2. semantic status label and status icon;
3. one precise headline;
4. one explanatory sentence;
5. one compact count surface when truthful counts are available;
6. Retry only for a genuine failed check;
7. collapsed Details for supporting evidence and scope.

No chart was added. Exact counts communicate the small recovered and
unaccounted categories more truthfully than a proportional graphic would.

## Final State Copy

### Complete

Headline:

> All messages on this Mac are accounted for

With no recovered messages, the summary states that all messages are available
in conversations. With recovered messages, it states:

> MessageLens has accounted for all {total} messages. {conversation count}
> appear in conversations and {recovered count} are available in Recovered
> Messages.

Recovered Messages therefore remains explicitly inside the accounted total.
It uses ordinary evidence styling and is never presented as a warning.

### Incomplete

Headline:

> {unaccounted count} messages could not be accounted for

Summary:

> {accounted count} of {total count} messages on this Mac are accounted for.

The warning icon, `Review needed` label, and exact count communicate the state
without destructive database-corruption language.

### Temporarily Unavailable

Headline:

> Message history coverage is temporarily unavailable

The explanation says MessageLens is updating message data and that the report
will refresh when the work finishes. No zero counts, stale complete result, or
Retry action are shown.

### Failed

Headline:

> Message history coverage could not be checked

A safe `Try Again` action invalidates the report provider. Details preserves
the bounded diagnostic evidence supplied by the typed failed report. An
unexpected asynchronous provider error is adapted to the same stable failed
presentation rather than exposing the exception in primary UI.

## Numerical Hierarchy

The sole count surface presents:

- Messages on this Mac;
- In conversations;
- Recovered Messages;
- Unaccounted.

The view model maps these values from the typed report. The widget performs no
coverage arithmetic. Unaccounted zero is visually quiet; a positive value uses
the existing warning semantic color and remains understandable from its label,
headline, and accessibility description.

## Actionability Decision

No `Review unaccounted messages` action was added. The canonical report exposes
an aggregate count, not an exact list of unaccounted source rows suitable for a
destination ViewSpec. A vague navigation action would be misleading.

No `View Recovered Messages` action was added. The aggregate recovered/unlinked
category is accounted evidence and does not currently map to one exact
destination containing precisely the report set. This report does not duplicate
Recovered Messages or create a new evidence browser.

An exact exception browser remains a possible later bounded feature only if a
canonical evidence contract supplies the exact rows.

## Loading And Narrator

Loading uses the same page title and native content position as every result.
It contains a small native activity indicator and `Checking messages on this
Mac...`. There is no artificial delay, staged progress, or loading choreography.

Narrator is not used. The approximately 0.10-second set query does not create a
human journey or an extended operation whose changing meaning needs narration.

## Track Mapping

Message History Coverage declares one shared Track:

```text
A1: Settings top-menu occupant
A2: Message History Coverage title occupant
A3: no occupant
```

Track A resolves from the truthful natural requirements of the menu trigger and
title. Below A, sidebar cassettes and the Settings report resume their native
flows independently. Loading, complete, incomplete, unavailable, and failed
states all consume the same center skeleton.

The tracked menu uses an anchored overlay for its open panel. The overlay does
not alter the closed trigger's Track requirement and remains interactive beyond
the fixed Track allocation.

## Accessibility

- Status icon, status label, and headline are exposed as one semantic header.
- The count surface has one complete natural-language semantic description.
- Warning meaning is communicated by text and icon as well as color.
- Loading has an explicit semantic label without a noisy live region.
- Details is a button with truthful expanded/collapsed semantics.
- Retry has a visible, meaningful label.

## Verification Scope

Focused tests cover:

- complete, recovered-but-complete, and incomplete copy;
- typed count mapping without widget arithmetic;
- distinct unavailable and failed presentations;
- stable loading/result structure;
- Details diagnostics and accessibility labels;
- absence of unsupported evidence-navigation actions;
- one-track A1/A2 matrix composition and truthful maximum-height resolution;
- Settings sidebar continuation after A1;
- tracked Settings menu overlay behavior within a fixed-height allocation.

Prompt 02's partition, source-identity, historical exclusion, maintenance, and
set-query tests remain unchanged.

## Verification Results

- Focused Message History Coverage, Settings presentation, Track layout, and
  tracked-menu tests passed.
- The complete Flutter suite passed all 1,958 tests.
- All 381 architecture tripwires passed.
- `flutter analyze` reported no issues.
- `flutter build macos --debug` produced
  `build/macos/Build/Products/Debug/MessageLens Development.app`.
- `git diff --check` passed before commit.
