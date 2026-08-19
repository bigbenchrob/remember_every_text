---
tier: project
scope: production-archive-recovery
owner: agent-per-project
last_reviewed: 2026-08-19
source_of_truth: code
links:
  - ../00-START-HERE.md
  - 31-HISTORICAL-ARCHIVE-REMOVAL-DIRECTED-INSTRUMENTATION-IMPLEMENTATION.md
tests:
  - test/essentials/conversation_graph/application/archives/source_scoped_archive_graph_import_service_test.dart
  - test/features/settings/application/historical_archives_workflow_panel_model_provider_test.dart
  - test/features/settings/presentation/view/historical_archives_panel_test.dart
---

# Mac Messages Ingestion Narrator And Directed Instrumentation

## Result

The valid Mac Messages folder journey now remains in the Historical Archives
Narrator surface from inspection through terminal import success or failure.
The ordinary path no longer falls through to the legacy Execution Gate,
preflight, activity-log, phase, and result control-panel stack.

The presentation is driven by boundaries that already exist in the ingestion
operation. It does not estimate progress, advance from timers, or report work
that the operation does not perform separately.

## Audited Execution Sequence

### Before authorization

1. The sidebar folder chooser returns one folder selected by the human.
2. `ArchiveSourceInspectionRepository` qualifies the folder and its `chat.db`.
3. `preflightHistoricalArchivesFolder` reads source counts, date evidence, and
   the GUID-compatible comparison against current MessageLens history.
4. Invalid and already-added folders terminate through their established modal
   boundaries. A genuinely new readable folder enters the ready presentation.
5. The ready presentation shows typed evidence and offers the explicit action
   **Add Messages to MessageLens**.

Inspection may remember source metadata, but it creates neither imported facts
nor finalized sidebar membership. Remembered preflight knowledge cannot later
authorize import without a fresh active add journey.

### After authorization

The explicit action asks `ArchiveMutationCoordinator` to admit
`historicalArchiveImport`. Inside that owner-aware scope:

1. `SourceScopedArchiveImportService.importSourceFacts` registers the canonical
   source and imports the source-scoped ledger facts.
2. `SourceScopedArchiveGraphImportService` runs the contiguous graph projector
   sequence for handles, chat-handle edges, chats, messages, attachments,
   chat-message edges, and message-attachment edges.
3. Message-data version invalidation makes the completed graph available to
   evidence, search, timeline, and heatmap readers.
4. Final verification reruns source qualification, resolves the canonical
   imported source key, and requires a positive source-scoped message count.
5. Only then is successful completion metadata written and invalidated for the
   sidebar read model.

There is no independent search-index or heatmap-rebuild operation in this path.
Those surfaces derive from the projected graph after message-data invalidation,
so no additional progress row was invented.

## Typed Import Observations

`SourceScopedArchiveGraphImportService` now accepts an optional
`SourceScopedArchiveGraphImportObserver`. It emits only:

- `importingSourceFacts / started`;
- `importingSourceFacts / completed`;
- `projectingConversationGraph / started`;
- `projectingConversationGraph / completed`.

The observer is descriptive only. It cannot authorize, sequence, cancel, or
otherwise control ingestion.

Historical Archives maps those observations into three human-facing rows:

| Real boundary | Directed Instrumentation |
|---|---|
| source fact import | Adding messages from this folder |
| contiguous graph projection | Preparing conversations for browsing |
| post-projection source and membership verification | Checking that import finished |

Each row is `Waiting`, `Working`, `Done`, or `Failed`. Completed rows remain
visible, only the current sequential stage works, and no percentage is shown.

## Narrator And Decisions

The inspection Narrator remains:

> Let’s see what’s in this Messages folder.

Resolved typed evidence supplies message count, date range, new-to-MessageLens
count, and already-represented count. Narrator interprets that evidence rather
than restating every number.

The sole import authorization is:

> Add Messages to MessageLens

No additional confirmation modal was added. The selected folder, resolved
evidence, source-safety explanation, and deliberately worded consequential
button already form one informed human decision; another modal would be
confirmation theater.

After authorization, ready controls disappear and Narrator says:

> Adding this Messages folder to MessageLens.

It then leaves the real stage evidence to speak for the operation.

## Success And Sidebar Membership

Success requires source facts, complete graph projection, final readable-source
verification, positive canonical imported membership, and successful metadata
finalization. Positive ledger rows alone are insufficient.

After all requirements succeed, the add journey ends automatically, the center
returns to the virgin hub, and the newly finalized cartouche appears under
Folders Already Added. A bounded gentle orange correspondence identifies that
new object without selecting it blue. This existing correspondence grammar is
the visible completion evidence; no permanent completion report or Done button
is introduced.

## Failure And Retry

A post-authorization failure keeps the real stage history:

- completed stages remain `Done`;
- the active failing stage becomes `Failed`;
- later work remains `Waiting`;
- the center explains that MessageLens could not finish adding the folder;
- technical detail remains behind Details;
- **Try Again** is offered only while the current inspection evidence remains;
- **Choose Another Folder** abandons the failed candidate.

Failure metadata records `lastImportSuccess = false`. The sidebar requires both
a positive canonical imported count and successful completion metadata, so a
partial source-ledger write cannot masquerade as an added archive. Retry uses
the existing idempotent source-scoped import and projection operation rather
than deleting partial facts or fabricating recovery state.

## Preserved Boundaries

- `ArchiveMutationCoordinator` still owns mutation admission.
- The admitted historical import uses the existing caller-specific graph
  authority; unrelated graph readers remain blocked during maintenance.
- Current-Mac/source-1 facts are not reset, replaced, or deduplicated away.
- Overlapping GUIDs retain source-scoped provenance.
- Source `chat.db`, WAL/SHM files, Attachments, and donor payloads remain
  read-only input.
- Attachments remains optional for Mac Messages history qualification.
- All Apple Messages timestamp conversion remains exclusively owned by
  `lib/core/util/date_converter.dart`.
- Historical Archives retains shared Tracks A-E and the approved sidebar
  hierarchy, spacing, duplicate boundary, invalid-folder boundary, selection,
  and removal journey.
- Active admitted maintenance remains a Historical Archives operation; it does
  not become an Onboarding failure.

## Diagnostics

Source paths, source key, exact inspection evidence, mutation-gate state, and
failure detail remain available through the collapsed Details disclosure. The
legacy phase and activity models remain available for compatibility where
still consumed, but they no longer own the ordinary valid-folder journey.

## Explicit Non-Goals

This slice does not implement:

- MessageLens-folder ingestion or enable its segmented-control arm;
- historical attachment-payload recovery;
- a generic progress/workflow framework;
- schema or persistence-format changes;
- alternate date normalization;
- donor/source mutation; or
- unrelated Settings or Historical Archives redesign.

## Manual Staging Rehearsal

Using only the authorized development staging archive:

1. Open Settings > Historical Archives > Mac Messages.
2. Choose `Messages_2012-IMPORT_SOURCE`.
3. Confirm inspection resolves to the expected 8,882-message 2012-2017 evidence.
4. Select **Add Messages to MessageLens** once.
5. Observe the three Directed Instrumentation rows progress from Waiting to
   Working to Done without the legacy control panel or Onboarding appearing.
6. Confirm the center returns to the empty hub only after final verification.
7. Confirm the new cartouche appears under Folders Already Added and receives
   only the bounded gentle orange correspondence.
8. Confirm normal MessageLens evidence extends through July 2012.

Do not perform this rehearsal against production or any original donor.
