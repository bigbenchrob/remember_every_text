# Contact Timeline Inertial Scroll Freeze Note

## Purpose

This note captures the current understanding of the contact-timeline inertial
scroll freeze so another agent can review it in the context of the broader app
breakdown refactor.

This is not a formal implementation plan. It is a second-opinion handoff that
explains the active runtime problem, the systems involved, what has already
been tried, and where the remaining bottleneck most likely lives.

## Problem Summary

The current user-visible symptom is:

- small manual scrolls in a contact timeline are often acceptable
- the first inertial scroll causes an immediate freeze

An earlier mitigation made the list visually smooth by suppressing row work
during active scroll motion, but that change was unacceptable because it turned
the list into blank two-line rows with central spinners. That mitigation has
been removed.

The list now scrolls smoothly again, but the original inertial-freeze behavior
remains.

## Current Diagnosis

This no longer looks like a pure viewport or heatmap problem.

The active diagnosis is that several live-scroll systems are still too tightly
coupled on the hot path:

- viewport state and ordinal lookup
- visible-month tracking
- current-row hydration
- neighbor grouping hydration
- attachment resolution and archive availability checks
- media widget initialization and display

The strongest current hypothesis is that the remaining freeze is caused by
current-row attachment and media work under inertial viewport churn, not by the
viewport shell itself.

## Repro Shape

Typical repro:

1. open a contact timeline with enough content to scroll normally
2. make a few small manual scrolls
3. perform an inertial scroll
4. observe an immediate freeze

Important observation:

- the freeze can happen while still remaining inside the same recent time
  window, so this does not appear to depend strictly on month-boundary
  transitions or heatmap updates

## Systems Involved

### Message surface and timeline view

- `lib/features/messages/presentation/view/messages_timeline_view.dart`
- `lib/features/messages/domain/value_objects/message_timeline_scope.dart`

### Ordinal, viewport, and visible-month coordination

- `lib/features/messages/presentation/view_model/timeline/ordinal/message_timeline_ordinal_provider.dart`
- `lib/features/messages/presentation/view_model/timeline/ordinal/message_timeline_index_coordinator_provider.dart`
- `lib/features/messages/presentation/view_model/timeline/ordinal/current_visible_month_provider.dart`

### Full row hydration

- `lib/features/messages/presentation/view_model/timeline/hydration/message_by_ordinal_provider.dart`
- `lib/features/messages/presentation/view_model/timeline/hydration/message_by_id_provider.dart`
- `lib/features/messages/presentation/view_model/shared/message_row_mapper.dart`

### Lightweight grouping-only neighbor hydration

- `lib/features/messages/presentation/view_model/timeline/hydration/message_grouping_metadata_by_ordinal_provider.dart`

### Attachment resolution and display state

- `lib/features/attachments/application/attachment_resolver_provider.dart`
- `lib/features/messages/presentation/view_model/shared/hydration/attachment_info_loader.dart`
- `lib/features/messages/presentation/view_model/shared/hydration/attachment_info.dart`
- `lib/features/attachments/domain/constants/resolved_attachment_availability.dart`

### Media and message-row presentation

- `lib/features/messages/presentation/view_model/shared/display_widgets/new_display_widgets.dart`
- `lib/features/messages/presentation/widgets/message_card.dart`
- `lib/features/messages/presentation/widgets/url_preview_widget.dart`

## What Has Already Been Tried

### 1. Remove scroll-driven row suppression

The first narrow fix removed the scroll-driven row-suppression behavior from
`messages_timeline_view.dart`.

Goal:

- restore acceptable baseline scrolling
- remove the visibly broken blank-row spinner regression

Result:

- scroll became visually smooth again
- the inertial freeze returned

Interpretation:

- the unacceptable placeholder behavior was a bad mitigation, not the root
  cause of the freeze

### 2. Reduce neighbor hydration fan-out for grouping

The second narrow fix introduced
`message_grouping_metadata_by_ordinal_provider.dart` and changed contact row
grouping so previous and next neighbors no longer hydrate as full
`MessageListItem` objects.

The lightweight grouping metadata now carries only the fields grouping needs:

- `chatId`
- `isFromMe`
- `senderName`
- `text`
- `sentAt`
- `hasAttachments`

Result:

- one obvious source of neighbor-side attachment and media work was removed
- the user still reported immediate freeze on inertial scroll

Interpretation:

- neighbor full hydration was a legitimate cost center
- it was not the last remaining bottleneck

## Why Current-Row Attachment Work Is Now The Leading Suspect

The remaining hot path still includes:

1. full current-row hydration by ordinal
2. `MessageRowMapper` attachment loading
3. attachment resolver availability and provenance work
4. media display decisions in the row widgets

Specific reasons this is now the strongest hypothesis:

- the visually broken scroll-suppression layer is gone
- neighbor grouping fan-out has already been reduced
- current rows still flow through full attachment resolution
- the attachment resolver can still involve archive settings, overlay reads,
  file existence checks, availability classification, and recovery/archive side
  effects
- image rows now depend on `displayableFile()` state
- video rows still initialize a `VideoPlayerController.file(...)` when a
  displayable file exists, which is a strong candidate for inertial-scroll pain
  if many rows rapidly enter the viewport

## Architectural Read Of The Failure

This appears to be a hot-path layering problem more than a single isolated bug.

The intended layering should be:

- scope and ordinal decide which row is visible
- visible-month tracking cheaply derives highlight state
- row hydration produces current-row display data
- attachment resolution decides availability and provenance
- media widgets render from already-cheap resolved state

In the current system, too much of that work still appears to occur close to
live viewport churn.

## What Should Not Be Reintroduced

Any proposed fix should avoid these regressions:

- scroll-driven rendering suppression
- blank placeholder rows during motion
- hiding or skipping anomalous records
- broad view-layer hacks that mask lower-layer hot-path costs

## Constraints And Invariants

Keep these constraints in mind while investigating:

- every record must remain visibly renderable even if attachment state is
  unresolved
- database access must continue through centralized providers
- do not fix the freeze by suppressing media rows or suppressing messages
- keep changes narrow and reversible because this area has shown a high
  regression rate under broad refactors

## Questions For A Second Opinion

The most useful second-opinion questions are:

1. Is the remaining inertial freeze best explained by current-row attachment
   resolution and media initialization?
2. If yes, what is the cheapest leverage point?
3. Should availability classification be separated further from expensive file
   and media work on the scroll hot path?
4. Is provider invalidation or repeated recomputation causing current-row work
   to rerun too often during inertial churn even after the neighbor-grouping
   reduction?
5. Is there a narrower way to defer or cache video/image setup without changing
   message semantics or hiding records?

## Validation History

Focused automated validation remained clean after the recent slices. The
unresolved issue is manual runtime behavior only: the user still gets an
immediate freeze on any inertial scroll in a contact timeline.

## Refactor Context

This runtime problem sits alongside the broader app breakdown refactor but is
not itself proof that the refactor plan is wrong.

The direct relevance to the refactor is:

- it is another example of too much cross-system work being entangled on a hot
  path
- it reinforces the need for cleaner boundaries between semantic scope,
  hydration, attachment provenance, and rendering
- it should be treated as active runtime context while evaluating Phase 2,
  Phase 4, and the final hardening expectations in the refactor program