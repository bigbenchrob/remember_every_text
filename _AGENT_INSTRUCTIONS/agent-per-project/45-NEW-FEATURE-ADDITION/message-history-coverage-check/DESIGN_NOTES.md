# Design Notes: Message History Coverage Check

> Current conformance note (2026-06-06): this design note is historical. The
> active feature still answers the same user question, but current
> implementation uses graph-accounted MessageLens evidence rather than retained
> `working.db` as the ordinary accounting source.

## Overview

This feature should be implemented as a Settings troubleshooting flow, not as a new panel or a new diagnostics subsystem.

The whole-library coverage report answers one question only:

- has MessageLens accounted for all messages currently present in this Mac's local `chat.db`?

The design should stay local to the existing transient settings action architecture.

## Architecture Summary

- Settings top-menu actions already distinguish between persistent settings contexts and transient one-off actions.
- `Message history coverage...` should be modeled as a transient troubleshooting action.
- The top-menu click should open a self-contained temporary settings cassette.
- The coverage report should be computed in a resolver and returned as presentation data.
- No new panel/ViewSpec system should be introduced.

## Phase 1 Delivery Shape

Phase 1 is intentionally narrower than the full seed.

Phase 1 will:

- add the settings-menu entry
- add the transient settings cassette spec
- compute the coverage report immediately when the cassette opens
- display the report summary and interpretation in a single self-contained cassette

Phase 1 will not yet:

- add JSON export
- add follow-up troubleshooting action buttons
- add a separate custom widget builder unless the existing settings info payload proves insufficient

This keeps the first implementation slice local and testable.

## Why Compute On Entry In Phase 1

The seed describes a title, description, and primary action `Run Coverage Check`.

For phase 1, the simpler architecture is:

- top-menu transient action triggers the check
- cassette opens directly into the computed result

This avoids introducing a second internal action lifecycle before the base report exists.

If later product review still prefers an explicit in-cassette `Run Coverage Check` button, that can be added in a follow-up phase without discarding the underlying resolver and entity work.

## Data Model

Phase 1 should define a pure value object for the report, with fields equivalent to:

- `chatDbTotalCount`
- `workingDbVisibleCount`
- `workingDbRecoveredCount`
- `workingDbTotalAccountedCount`
- `missingCount`
- `earliestMessageDate`
- `latestMessageDate`
- `status`

The report entity should also be able to serialize to JSON so export can be added later without reshaping the core model.

## Source Of Truth For Counts

### Source Database

Read from local Apple `chat.db`:

- `COUNT(*)` from `message`
- `MIN(date)` and `MAX(date)` from `message`

Use read-only SQLite access and the existing FDA/path helpers.

### Working Database

Read from MessageLens `working.db`:

- visible count from the working timeline index used for global timeline display
- recovered count from `recovered_unlinked_messages`

This keeps the displayed count aligned with what the user can actually browse in MessageLens timelines.

## Classification Notes

### `complete`

Use when source total equals total accounted count.

### `incomplete_import`

Use when source total is greater than total accounted count.

### `incomplete_source_history`

Use only when:

- source total equals total accounted count
- source earliest date is non-null
- earliest date passes a conservative suspiciously-recent threshold

The threshold should be conservative enough to avoid accusing the Mac of partial history casually.

For phase 1, a simple fixed threshold is acceptable so long as the user-facing language remains cautious.

### `unknown`

Use when:

- `chat.db` cannot be opened
- FDA is unavailable
- required queries fail
- totals cannot be computed safely

## Presentation Notes

Phase 1 should reuse an existing settings payload type if possible.

Preferred first approach:

- format the report into a single body-text summary
- return a static settings info payload

This avoids introducing a new custom widget builder before the report contract itself is proven.

If the summary becomes too dense or visually weak, a dedicated payload/widget builder can be added in a later phase.

## User-Facing Copy Rules

- Always include the count summary block.
- Avoid implying data loss when local accounting is complete.
- Use cautious language for partial-source-history interpretation: `may`, not `did`.
- Keep the tone support-oriented, not engineering-oriented.
- For `incomplete_source_history`, keep troubleshooting guidance inline in the same cassette so users do not have to enter a second transient flow to understand next steps.
- Keep troubleshooting guidance focused on confirming local availability and checking another signed-in device before implying any app fault.

## Export Direction For Phase 2

The export should remain a narrow coverage artifact, not a disguised support bundle.

Phase 2 uses the existing MessageLens export presentation style of writing an artifact locally and revealing it in Finder, but it writes a single JSON file instead of preparing a full support bundle or email draft.

The exported file should contain the report JSON plus a `generatedAt` timestamp.
