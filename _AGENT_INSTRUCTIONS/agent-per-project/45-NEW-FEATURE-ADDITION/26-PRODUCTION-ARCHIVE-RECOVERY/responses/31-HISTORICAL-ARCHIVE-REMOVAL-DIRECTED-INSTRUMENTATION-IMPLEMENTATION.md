---
tier: project
scope: production-archive-recovery
owner: agent-per-project
last_reviewed: 2026-08-19
source_of_truth: implementation-record
links:
  - ../prompts/31-HISTORICAL-ARCHIVE-REMOVAL-DIRECTED-INSTRUMENTATION.MD
  - 30-HISTORICAL-ARCHIVE-REMOVAL-JOURNEY-IMPLEMENTATION.md
  - 08-ARCHIVE-MUTATION-OWNER-AWARE-DATABASE-ADMISSION-IMPLEMENTATION.md
---

# Historical Archive Removal Directed Instrumentation Implementation

## Execution audit

The removal operation exposes three truthful human-facing stages:

1. **Removing messages added from this folder**
   - starts immediately before the source lookup and source-scoped import-fact
     deletion;
   - completes when that deletion returns;
   - completes without deletion when no matching source exists.
2. **Updating your MessageLens history**
   - starts immediately before the graph is cleared and reprojected from all
     remaining import facts;
   - completes only after every existing projector returns;
   - is `Not needed` when no source facts or topology edges were deleted.
3. **Checking that removal finished**
   - starts after the removal service returns and message-data consumers are
     refreshed;
   - completes only when the canonical imported-source lookup confirms that
     the source key no longer has positive imported membership.

There is no distinct search, heatmap, index, or other refresh operation in the
current path. No additional stage was invented for presentation.

## Typed progress seam

`SourceScopedArchiveGraphRemovalService` now accepts an optional observation
callback. It publishes typed `started`, `completed`, and `skipped` transitions
for its two real service-owned operations. The callback reports evidence only;
it does not own, schedule, repeat, or alter removal work.

Historical Archives maps those observations into its feature-owned
`HistoricalArchiveRemovalProgress`. Each of its three named stages has one of:

```text
waiting | running | succeeded | skipped | failed
```

The final verification stage remains feature-owned because it occurs after the
service completes. Directed Instrumentation renders the same progress as:

```text
Waiting | Working | Done | Not needed | Couldn't finish
```

There are no percentages, elapsed-time estimates, transition timers, or
artificial delays. A fast real operation may move between observable states
before Flutter paints an intermediate frame.

## Removal journey presentation

After confirmation, `removingSource` remains the sole center-panel context.
The selected-source explanation and management controls are absent. The
Narrator states:

> Removing this folder from MessageLens.

The compact Directed Instrumentation list then keeps completed work visible,
marks only the current real stage active, and leaves later work waiting. No
Next, Done, or completion action is introduced. Historical Archives preserves
its existing A-E Track geometry.

## Cartouche lifecycle

Durable known-source membership still requires positive imported facts.
Historical Archives does not weaken or alter that rule.

While the selected source is in `removingSource`, the sidebar provider retains
that one source as transient presentation evidence even if its durable count
has already reached zero. It preserves the last truthful displayed count and
marks the cartouche busy. The cartouche is non-interactive and cannot open a
competing management context.

The override is process-local presentation state. It is neither persisted
archive metadata nor an alternative source identity. The cartouche disappears
only after graph reprojection completes and canonical membership verification
succeeds, at which point the workflow returns automatically to the virgin hub.

## Failure and partial failure

If a stage throws, the currently running real stage becomes failed. Earlier
completed stages remain resolved and later stages remain waiting. The generic
spinner stops, and the removal context stays visible with durable-truth detail.

The workflow rechecks canonical source membership after failure:

- positive membership reports how many messages still remain;
- absent membership reports that source messages are gone but MessageLens did
  not finish updating its browsing data;
- an unavailable lookup reports that membership could not be verified.

None of these cases is presented as successful removal. In particular, source
rows reaching zero before graph reprojection succeeds cannot cause a false hub
transition. This slice does not invent a new recovery command or retry model.

## Safety invariants

Removal remains owned by `SourceScopedArchiveGraphRemovalService` and admitted
through `ArchiveMutationCoordinator.historicalArchiveRemoval`. Owner-aware
graph access remains intact; unrelated readers cannot reopen the graph during
maintenance. Onboarding continues to interpret the operation as
`maintenanceInProgress`, not as database failure.

The source folder is read only as identity. Removal deletes only source-scoped
MessageLens-derived facts and rebuilds MessageLens-owned graph data. It does
not write to the original Messages folder, donor `chat.db`, Attachments, or
`attachment_archive/`.

## Verification

Automated coverage proves:

- service observations occur at the exact ordered execution boundaries;
- all three feature stages progress without timer-created states;
- failure marks the actual current stage and does not complete later work;
- partial failure after source deletion remains a failed removal journey;
- the cartouche remains visible and disabled while durable membership is
  temporarily absent;
- terminal success alone returns to the empty hub;
- source-1 facts and the donor database survive source-3 removal; and
- existing Settings, Track, navigation, maintenance, onboarding, and
  architecture boundaries remain intact.

## Manual staging review

Use only the disposable development staging archive:

1. Select the imported archive cartouche and confirm removal.
2. Verify the selected-source story is replaced by the Narrator and three
   Directed Instrumentation rows.
3. Verify rows move truthfully from **Waiting** to **Working** to **Done** (or
   **Not needed**) without timed pauses.
4. Verify the cartouche remains visible but cannot be selected while removal
   is active.
5. Verify the cartouche disappears only after the final check succeeds, then
   the center returns automatically to the empty hub.
6. Verify current-Mac messages remain, no Onboarding surface appears, and the
   donor folder, attachments, and attachment archive remain unchanged.

Do not perform this review against production data.
