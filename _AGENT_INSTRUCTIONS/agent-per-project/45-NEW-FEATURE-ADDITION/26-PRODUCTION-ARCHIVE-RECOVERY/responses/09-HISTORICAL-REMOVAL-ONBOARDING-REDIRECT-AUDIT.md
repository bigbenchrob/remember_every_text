---
tier: project
scope: production-archive-recovery
owner: agent-per-project
last_reviewed: 2026-08-17
source_of_truth: audit
links:
  - 06-HISTORICAL-IMPORT-POST-CORRECTION-VERIFICATION.md
  - 07-ARCHIVE-MUTATION-OWNER-AWARE-DATABASE-ADMISSION-AUDIT.md
  - 08-ARCHIVE-MUTATION-OWNER-AWARE-DATABASE-ADMISSION-IMPLEMENTATION.md
---

# Historical Removal Onboarding Redirect Audit

## Conclusion

The observed redirect was not caused by source-1 ledger loss and was not caused
by Historical Archives calling the broad onboarding message-data reset.

The logs establish two separate operations:

1. source-3 removal deleted only source-3 import facts, cleared the derived
   graph, and successfully reprojected source 1; then
2. a new historical import began seconds later, cleared/rebuilt graph-visible
   state again, and completed successfully.

The running build interpreted the deliberately incomplete graph between clear
and reprojection as `graphProjectionFailed`. `OnboardingGate` translated that
state to `awaitingUserAction`, and `OnboardingCenterPanelSyncController`
replaced the Messages center panel with Environment Readiness. The resulting
"Import My Messages" action was false: the log records it being rejected
because the historical import already held archive mutation authority.

This is a readiness misclassification and navigation defect around legitimate
maintenance. It is not evidence that source-1 facts were destroyed.

## Evidence boundary

The staging clone is no longer in the immediate post-removal state described
by the observation. Immutable inspection now finds source 3 fully imported
again. The current state can therefore be inspected directly, while the brief
post-removal state must be reconstructed from the application log and the
previous verified baseline.

No database, import, removal, recovery, application launch, attachment payload,
production archive, snapshot, or donor was modified during this audit.

## Current persistent state

All expected databases exist:

- `macos_import_ss.db`;
- `working_ss.db`;
- `user_overlays.db`; and
- `presence.db`.

`quick_check` and `integrity_check` return `ok` for the import ledger, graph,
and Overlay databases. Their foreign-key checks report zero violations where
foreign-key structure exists.

### Source registry

The ledger currently has exactly one row for each source:

| Source | Kind | Identity |
|---:|---|---|
| 1 | `live_chat_db` | `live-chat-db` |
| 2 | `live_address_book` | `live-address-book` |
| 3 | `historical_messages_archive` | the selected disposable archive `chat.db` |

Source 3 remains registered across removal. Removal deletes its imported facts
and batches, not its registry identity. Reimport therefore reuses the same
deterministic source identity rather than registering a second historical
source.

### Import ledger and graph

Current source-1 and source-3 rows match exactly between ledger and graph:

| Fact | Source 1 | Source 3 |
|---|---:|---:|
| messages | 136,943 | 8,882 |
| handles | 261 | 77 |
| chats | 255 | 86 |
| attachments | 40,007 | 773 |
| chat/message edges | 116,197 | 8,889 |
| chat/handle edges | 340 | 104 |
| message/attachment edges | 39,386 | 808 |

The graph contains 145,825 messages in total. Source 1 spans
2014-01-01 through 2026-08-16; source 3 spans 2012-07-25 through 2017-06-11.
Both sources have one distinct GUID per message.

The prior verified baseline contained 136,943 source-1 messages in both stores.
The current counts are identical. Source-1 data remains intact.

## Reconstructed removal sequence

The code path is:

```text
HistoricalArchivesWorkflow.removeImportedArchiveDataForSelectedSource
    -> ArchiveMutationCoordinator.run(historicalArchiveRemoval)
    -> SourceScopedArchiveGraphRemovalService.removeArchiveSource
    -> ImportLedger.deleteRowsForSource(sourceId: 3)
    -> GraphProjectionResetter.clearProjectionRows()
    -> project every remaining ledger fact into working_ss.db
    -> bump messageDataVersion
    -> rerun selected-folder preflight
```

`ImportDatabase.deleteRowsForSource` uses source-qualified predicates for every
fact and topology table. It does not invoke `MessageDataResetService`, delete
database files, or target source 1. `SourceScopedArchiveGraphRemovalService`
does intentionally clear every derived graph table before projecting all facts
remaining in the ledger.

The log records the expected count transitions:

```text
21:37:47Z  graph temporarily unreadable/incomplete; ledger still 145,824
21:38:19Z  removal/reprojection complete; ledger and graph both 136,942
21:38:28Z  a new historical import begins; graph again incomplete
21:39:01Z  source-1 projection is available at 136,942
21:39:53Z  historical reimport completes at 145,824
```

The one later live message accounts for the present 136,943 / 145,825 totals.

The successful 136,942 state at 21:38:19 proves that removal reprojected the
remaining source-1 ledger before the later reimport began. The selected-folder
dry run reporting 0 likely imported and 8,882 likely new is also consistent
with source-3 facts having been removed at that point.

## Addendum: what initiated the reimport?

The available evidence does not identify the physical initiator conclusively.
It does, however, narrow the production call graph to one entry point and makes
a fresh user command the strongest supported explanation.

### Durable timing evidence

The application log records the post-removal graph as fully ready at
`2026-08-16T21:38:19.702504Z`, with 136,942 rows in both the import ledger and
graph. The first new source-3 `import_batches` row begins at
`2026-08-16T21:38:28.806038Z`. The old running build first observes the graph
clear/reproject interval at `21:38:28.848083Z`.

The historical import therefore began approximately 9.1 seconds after removal
and source-1 reprojection had completed. It was a separate admitted operation,
not a continuation inside the removal operation.

The source-3 batches begin at:

```text
21:38:28.806Z  batch 15490
21:38:28.919Z  batch 15491
21:38:29.055Z  batch 15492
21:38:29.980Z  batch 15493
21:38:30.122Z  batch 15494
21:38:30.410Z  batch 15495
21:39:21.848Z  batch 15496
21:39:21.900Z  batch 15497
21:39:21.979Z  batch 15498
21:39:22.226Z  batch 15499
```

These rows establish when import work began, but `import_batches` does not
record the caller or initiating interaction. The Historical Archives Overlay
record captures the final successful import, not its initiating command.
Mutation-coordinator ownership and the Historical Archives activity log are
process-local state rather than a durable operation journal. The application
log proves that `historical-archives-import` owned
`historicalArchiveImport` by `21:38:42`, when a later onboarding import request
was denied, but it does not contain an admission-start or button-press event.

### Production call graph

There is one production path to the historical import method:

```text
Historical Archives "Begin Import" GestureDetector.onTap
    -> HistoricalArchivesWorkflowActions.beginImportForSelectedSource
    -> HistoricalArchivesWorkflow.beginImportForSelectedSource
    -> ArchiveMutationCoordinator.run(
         historicalArchiveImport,
         ownerLabel: historical-archives-import,
       )
    -> SourceScopedArchiveGraphImportService.importAndProject
```

The removal path is independent:

```text
removeImportedArchiveDataForSelectedSource
    -> removeArchiveSource
    -> loadFolder (rerun preflight and refresh presentation state)
    -> return
```

It never calls `beginImportForSelectedSource`, the import service, or the import
operation. `loadFolder` performs inspection/preflight only.

No automatic-recovery, startup, live-monitor, provider-listener, timer,
post-frame callback, or other background path calls
`beginImportForSelectedSource` or
`SourceScopedArchiveGraphImportService.importAndProject`. Onboarding automatic
recovery owns onboarding import/recovery operations; the live Messages monitor
owns current-source updates. Neither can initiate historical source-3 import.

### Initiator classification

| Candidate | Finding |
|---|---|
| Direct user command | **Strongly supported, not conclusively proven.** It is the only production entry point. The 9.1-second interval after the page returned to a ready state is consistent with the user's recollection of clicking Reimport/Begin Import during the confusing sequence. |
| Retained, delayed, duplicated, or replayed UI callback | **No supporting mechanism or evidence found.** The button uses a direct `GestureDetector.onTap` callback. No callback queue, timer, replay, or delayed dispatch exists in this path. A concurrent duplicate would encounter the coordinator's existing owner gate rather than become an independently queued future import. |
| Automatic recovery | **Ruled out by the static call graph.** Automatic recovery does not call the Historical Archives workflow or source-scoped archive import service. |
| Other background observer or workflow | **Ruled out by the static call graph inspected.** No other production caller reaches the historical import service. |

### Forensic conclusion

The most strongly supported account is that a fresh human click on **Begin
Import** initiated the operation at approximately `21:38:28.8Z`. This is
consistent with the user's recollection, and no automatic or removal-triggered
path exists. It cannot be stated as proven fact because the application did not
durably record the interaction or mutation-admission start.

The hard invariant is satisfied by the current call graph:

> Historical archive import does not begin because a historical source was
> removed. A fresh historical import requires a fresh explicit human command.

Future forensic certainty would require recording an explicit import-intent
event at the Historical Archives action seam before coordinator admission.
That is an observability recommendation only; no such change was made in this
audit.

## Why Onboarding appeared

The old running build observed `working_ss.db` while its projection tables were
between clear and rebuild. Its readiness report produced:

```text
environmentState = graphProjectionFailed
hasPopulatedAppDatabases = false
sourceScopedImportDbRowCount = populated
conversationGraphRowCount = null
```

`OnboardingGate` mapped that state to `awaitingUserAction`.
`OnboardingCenterPanelSyncController` then mechanically showed the Environment
Readiness center panel. This was not an explicit navigation command from
Historical Archives.

At 21:38:42, the misleading readiness action attempted
`onboardingImport`. The coordinator rejected it because
`historicalArchiveImport` already owned mutation authority. This proves that
the apparent persistent onboarding state occurred during the subsequent
historical reimport, not because removal had erased the live ledger.

The current owner-aware maintenance implementation classifies an active
archive mutation as `maintenanceInProgress`, which maps to
`OnboardingStatus.notNeeded`. That correction had not yet been exercised by
the logged staging run. A future staging validation should verify this exact
remove/reimport sequence against the corrected build before any further design
change is justified.

## Overlay and attachment preservation

Overlay integrity passes. Current representative user-intent counts include:

- 38 favourite contacts;
- 12 dismissed handles;
- 4 Conversation Tags with 8 assignments; and
- 3 participant overrides.

Their latest user-intent timestamps predate the removal/reimport window. The
Historical Archives setting records the later successful reimport; there is no
separate durable removal-operation record. The setting is workflow metadata,
not evidence that source-1 data changed.

`archived_attachments` currently contains 33,407 records. No archive record was
created during the 21:37-21:40 removal/reimport window. The payload tree
currently contains 26,136 files and occupies 37,145,336 KiB. Its top-level
directory timestamp predates the rehearsal. Because no clone-specific payload
manifest was captured immediately before removal, this audit cannot prove
byte-for-byte equality; it can prove that neither the removal service nor its
observed operation window targeted attachment preservation data.

## Classification

| Concern | Finding |
|---|---|
| source-1 ledger loss | No |
| source-3 scoped removal | Yes, followed by a later successful reimport |
| graph projection loss | Temporary by design during clear/reproject; no current loss |
| broad onboarding reset | Not used |
| readiness classification | Incorrect in the old running build during maintenance |
| navigation | Derived from the incorrect readiness state |
| current database corruption | None found |

## Smallest recommended correction

Do not add another data repair path and do not reset this staging clone.

First validate the already implemented owner-aware maintenance correction with
the exact source-removal and historical-reimport sequence. The required
invariant is:

> While an admitted archive mutation is intentionally rebuilding derived graph
> state, Environment Readiness reports maintenance, and Onboarding does not
> claim that initial import is required.

Add focused lifecycle coverage that drives graph readiness through the
clear/reproject interval and proves the center-panel synchronization never
selects Environment Readiness while `historicalArchiveRemoval` or
`historicalArchiveImport` owns mutation authority.

Separately, the clear-then-reproject sequence is not crash-atomic across the
ledger and graph databases. If a future controlled test proves that terminating
the process can leave the graph empty after mutation authority disappears, that
requires an owned, restart-reconcilable projection operation. It should not be
inferred from this run: the log proves both reprojections completed and the
current graph is coherent.

The existing staging clone is coherent and requires no repair before a bounded
validation of the corrected readiness behavior.
