---
tier: feature
scope: proposal
owner: agent-per-project
last_reviewed: 2026-06-06
source_of_truth: historical-record
links:
  - ../../10-DATABASES/00-all-databases-accessed.md
  - ../../12-DATABASE-HEALTH-AUDIT/00-overview.md
  - ../../42-SPEC-SYSTEM/REFERENCE/50-CROSS-SURFACE-SPEC-SYSTEMS-OVERVIEW/settings-menu-semantics.md
  - ../../42-SPEC-SYSTEM/REFERENCE/54-SIDEBAR-CASSETTE-SPEC-SYSTEM/00-cassette-system-architecture.md
  - ../../42-SPEC-SYSTEM/REFERENCE/55-EPHEMERAL-SPEC-HANDLING/00-ephemeral-spec-handling-architecture.md
tests: []
feature: message-history-coverage-check
status: historical-planning-record
created: 2026-04-26
---

# Feature Proposal - Message History Coverage Check

**Proposed Branch**: `Ftr.msg-hist`
**Status**: Historical planning record
**Created**: 2026-04-26

> Current conformance note (2026-06-06): the user-facing feature name
> "Message History Coverage" remains active, but this proposal's `working.db`
> data-source language is superseded. Current coverage reporting reads source
> `chat.db` plus graph-accounted MessageLens evidence through the settings
> repository/resolver path. Do not use this April proposal to reintroduce
> retained `working.db` as the ordinary coverage authority.

## Overview

Add a user-facing support diagnostic that answers one specific trust question:

"Is MessageLens showing everything that exists in this Mac's local Messages database?"

The feature should live under Settings as a troubleshooting/support capability, not as a normal browsing workflow.

At proposal time, the diagnostic compared:

- Apple's local source database at `~/Library/Messages/chat.db`
- MessageLens working projection in `working.db`

Current implementation compares source `chat.db` with graph-accounted
MessageLens evidence. Retained `working.db` may remain relevant only to
archive/recovery compatibility diagnostics, not the active coverage report.

It then presents a calm summary that distinguishes between:

- complete local coverage
- incomplete MessageLens import/projection
- complete local coverage on a Mac whose local source history is itself partial
- unknown or unreadable state

This proposal is now approved. Planning artifacts and implementation may proceed under the workflow in [README.md](../README.md).

## Problem

Users can see a message count or date range in MessageLens and conclude that the app lost data, even when the real problem is that the current Mac only has a partial local `chat.db` history.

Right now, the team can diagnose that distinction by reading support-bundle logs and audit output, but average users cannot.

That creates three product problems:

1. MessageLens can appear untrustworthy even when it has imported everything available on the current Mac.
2. Support diagnosis depends on internal logs instead of a user-visible explanation.
3. The app does not currently expose a simple summary of source-count, recovered-count, missing-count, and coverage date range in one place.

## User Value

After this feature:

- a user can run a coverage check from Settings without sending logs first
- the app can clearly say whether MessageLens is missing local data or whether the Mac itself appears to have only recent history
- support conversations can start from a shared, user-visible diagnostic instead of a vague suspicion that "older messages are gone"
- exported JSON can capture the same core numbers for support follow-up

## Existing Architecture Summary

- Settings already uses the sidebar cassette system rather than a separate panel flow.
- The settings menu currently exposes transient troubleshooting actions such as `Send logs...` and `Reset message data...`.
- Those transient settings actions route through typed sidebar intents into settings cassette specs and settings resolvers.
- Current graph-era coverage reads must go through named graph/settings repository boundaries, not retained `working.db`.
- Source `chat.db` access is FDA-gated and currently resolved through `FdaChecker` and `onboardingMessagesDatabasePathProvider`.
- Database health auditing already produces structural diagnostics for support bundles, but that output is aimed at support and engineering, not end users.

The nearest architectural fit is therefore a new settings troubleshooting action that resolves a deterministic report from existing data sources and renders it as a settings cassette.

## Assumptions

1. This feature should remain read-only and must not alter import, migration, or user data.
2. The first slice should answer the trust question at the whole-library level only, not per contact or per year.
3. It is acceptable for the feature to classify "incomplete source history" using a conservative heuristic based on a suspiciously recent earliest local message date.
4. The first release can compute the report when the user explicitly runs the check rather than continuously recomputing it in background.
5. Exporting the report as JSON is part of the product contract, but the exact save/share UX can be finalized during planning.

## Hard Invariants

1. Do not bypass centralized database providers or named graph/settings repository boundaries for coverage reads.
2. Do not write any user-intent or diagnostic state into `working.db` tables.
3. Do not make coordinators return widgets.
4. Do not introduce a new panel/navigation subsystem for a feature that belongs in the existing settings cassette flow.
5. Do not suppress or reinterpret source records; this feature reports coverage and date span only.
6. Do not rely on timestamp ordering guarantees beyond informational earliest/latest summaries.
7. Do not claim missing MessageLens data when the numbers show complete local accounting.

## Scope

### In Scope

1. Add a Settings troubleshooting entry for Message History Coverage.
2. Query `chat.db` for total messages and earliest/latest source dates.
3. Query graph-accounted MessageLens evidence for visible message count and recovered/orphan message count.
4. Compute a deterministic report model and status classification.
5. Present user-facing copy for complete, incomplete import, incomplete source history, and unknown states.
6. Provide an export path for the report as JSON.
7. Provide static troubleshooting guidance for users who expected older history.

### Out Of Scope

- per-contact coverage analysis
- per-year or per-chat breakdowns
- iCloud account-state detection
- attachment coverage validation
- changes to import or migration behavior
- support-bundle schema changes unrelated to this feature

## Proposed Direction

### 1. Treat This As A Settings Troubleshooting Capability

The feature should appear under the existing Settings troubleshooting group beside other support actions.

At the product level, the entry point is:

- title: `Message History Coverage`
- summary: `Check whether MessageLens has imported all messages available on this Mac.`
- primary action: `Run Coverage Check`

This keeps the feature in the part of the app where users already look for support and reset tools.

### 2. Use A Deterministic Report Model

The core report should contain:

- `chatDbTotalCount`
- `workingDbVisibleCount`
- `workingDbRecoveredCount`
- `workingDbTotalAccountedCount`
- `missingCount`
- `earliestMessageDate`
- `latestMessageDate`
- `status`

The report should be computed from direct database queries in one resolver-owned path.

### 3. Classify Coverage Conservatively

The classification contract for v1 should be:

- `complete` when source total equals total accounted count
- `incomplete_import` when source total is greater than total accounted count
- `incomplete_source_history` when counts match but the earliest local date appears suspiciously recent
- `unknown` when the analysis cannot be completed safely

The important product rule is that the app must distinguish "MessageLens missed data" from "this Mac seems to have only partial source history."

### 4. Keep Resolver Ownership Local

The new coverage logic should be implemented in a dedicated settings/support resolver path rather than spread across multiple existing services.

That resolver will:

- read graph-accounted MessageLens evidence through approved graph/settings repository boundaries
- read `chat.db` in read-only mode using existing FDA/path helpers
- compute the report entity
- return data for presentation, not widgets

### 5. Present Calm, Trust-Building Copy

The UI should always include a summary block with:

- total messages on this Mac
- visible in MessageLens
- recovered/unlinked
- total accounted for
- missing
- date range

It should then add one clear interpretation:

- MessageLens has accounted for all messages currently available on this Mac.
- Some messages in your Mac's Messages database were not imported into MessageLens.
- MessageLens has imported all messages available on this Mac, but this Mac only has messages starting from a recent date.

### 6. Export The Same Core Facts As JSON

The export should focus on the user-facing coverage facts, not a full support bundle.

Required fields:

- `chatDbTotal`
- `visible`
- `recovered`
- `missing`
- `earliest`
- `latest`
- `status`

The export UX should reuse an existing file/export path where practical, but the report content should stay narrow and human-auditable.

## Architecture Impact

### Areas Likely To Change After Approval

| Area                               | Planned Change                                                                  |
| ---------------------------------- | ------------------------------------------------------------------------------- |
| Settings troubleshooting menu      | Add a new Message History Coverage action                                       |
| Settings cassette spec/coordinator | Add a new transient troubleshooting cassette flow                               |
| Resolver layer                     | Add a dedicated resolver and report entity for coverage analysis                |
| Sidebar action intents             | Potentially add typed intents for run/export/troubleshooting interactions       |
| Presentation                       | Add a settings cassette body that can show report summary and follow-up actions |

### Candidate Files For Future Implementation

- `lib/features/sidebar_utilities/application/sidebar_cassette_spec/resolvers/settings_root_resolver.dart`
- `lib/features/sidebar_utilities/domain/sidebar_utilities_constants.dart`
- `lib/features/sidebar_utilities/domain/settings_top_menu_row.dart`
- `lib/essentials/sidebar/domain/entities/cascade/links/sidebar_utility_children.dart`
- `lib/features/settings/domain/spec_classes/settings_cassette_spec.dart`
- `lib/features/settings/application/sidebar_cassette_spec/coordinators/settings_coordinator.dart`
- `lib/features/settings/application/sidebar_cassette_spec/resolvers/`
- `lib/essentials/sidebar/domain/sidebar_action_intent.dart`
- `lib/essentials/sidebar/application/sidebar_action_dispatcher.dart`

## Risks

1. **Over-classifying partial source history**
   The heuristic for "suspiciously recent" earliest date could be too aggressive if not defined carefully.

2. **Flow complexity in Settings**
   Adding run, export, and troubleshooting actions could blur the boundary between a single transient action and a deeper mini-flow if the cassette contract is not kept simple.

3. **Export UX drift**
   Reusing support-bundle export infrastructure without narrowing the content could accidentally turn this into another engineering-facing report.

4. **Architecture creep**
   It would be easy to overbuild this into a new diagnostics subsystem when the existing settings cassette architecture is sufficient.

## Proposed Delivery Shape

If this proposal is approved, the next planning phase should produce:

1. `CHECKLIST.md` covering sidebar entry, resolver, entity, presentation, export, and validation work.
2. `DESIGN_NOTES.md` documenting status heuristics, report entity shape, and export interaction choices.
3. `TESTS.md` capturing unit coverage for classification logic plus manual validation against real source/working database states.

Implementation should begin only after those planning documents are reviewed.

## Open Questions

1. What exact threshold should classify an earliest local message date as "suspiciously recent"?
2. Should the first cassette open with explanatory text and an explicit `Run Coverage Check` action, or should it compute immediately on entry?
3. Should `Export Coverage Report` write a JSON file directly, reveal it in Finder, or route through a save panel?
4. Should `Show Troubleshooting Steps` expand inline in the same cassette or open a second transient settings cassette?
