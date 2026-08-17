---
tier: project
scope: production-archive-recovery
owner: agent-per-project
last_reviewed: 2026-08-17
source_of_truth: audit
links:
  - 06-HISTORICAL-IMPORT-POST-CORRECTION-VERIFICATION.md
  - 08-ARCHIVE-MUTATION-OWNER-AWARE-DATABASE-ADMISSION-IMPLEMENTATION.md
  - 09-HISTORICAL-REMOVAL-ONBOARDING-REDIRECT-AUDIT.md
  - ../../../25-ONBOARDING-AND-ARCHIVE/10-onboarding-gate.md
  - ../../../25-ONBOARDING-AND-ARCHIVE/20-environment-readiness.md
tests: []
---

# Fresh-Start Gating Anomaly Audit

## Conclusion

The screenshot did not come from a fresh process admitted to the disposable
Historical Archives staging clone.

It came from a process admitted to the ordinary development archive:

```text
/Volumes/WD_ELEMENTS/DEVELOPMENT_DATA_FOLDER/MessageLens Development
```

That archive truthfully contains zero imported messages and zero Conversation
Graph messages. `OnboardingGate` therefore classified it as
`awaitingUserAction`, and panel synchronization selected Environment Readiness.

The intended staging archive remains populated and healthy:

```text
/Volumes/WD_ELEMENTS/ARCHIVE_INGESTION_TRIAL/
  2026-08_16-DATA_FOLDER-STAGING/
  com.bigbenchsoftware.MessageLens
```

This is an **archive-root selection / launch-context mismatch**, not stale
failure state, a startup provider race, a latched center panel, or a maintenance
classification defect.

No gate implementation correction is justified by this observation.

## Read-Only Evidence

### Intended staging archive

Immutable SQLite inspection produced:

| Store | Evidence |
|---|---:|
| source-1 import messages | 136,943 |
| source-3 import messages | 8,882 |
| total import messages | 145,825 |
| source-1 graph messages | 136,943 |
| source-3 graph messages | 8,882 |
| total graph messages | 145,825 |
| graph chats | 341 |
| graph message edges | 125,086 |

Every graph message joined to exactly one source-scoped import message by
`ss_id`; there were no unmatched graph rows.

The source registry remains deterministic and singular:

- source 1: `live-chat-db`;
- source 2: `live-address-book`;
- source 3: the authorized `Messages_2012-IMPORT_SOURCE/chat.db`.

`quick_check` and `integrity_check` returned `ok` for the import ledger,
Conversation Graph, and overlay database. Foreign-key checks returned no rows.
The persisted onboarding import and graph-result values remain empty. The
Historical Archives record reports the completed source-3 workflow. The
attachment archive exists.

The staging application log's final write was 2026-08-16 14:47:19 PDT. It has
no application launch corresponding to the 2026-08-17 screenshot.

### Archive that produced the screenshot

The ordinary development archive contains:

| Store | Evidence |
|---|---:|
| import messages | 0 |
| graph messages | 0 |
| graph chats | 0 |
| graph message edges | 0 |

Its source registry contains only the expected live Messages and Address Book
sources. Its import and graph databases pass `quick_check` and
`integrity_check`, but they are unpopulated. Its attachment archive does not
exist.

Those facts match all distinctive evidence in the screenshot:

- `Imported message data: Not prepared yet`;
- `Conversation browsing data: Not prepared yet`;
- `Live message updates: Watching source row 153111`;
- `Attachment archive: Not created yet`.

The ordinary development log records matching fresh launches at
2026-08-17T15:44:56Z, 15:50:51Z, and 16:12:50Z. Each resolves the same empty
archive facts, and the latter launches record the matching live source cursor
of 153111. The staging log ends at source cursor 153088 on the previous day.

## Why The Root Changed

The staging rehearsal was launched with a process-scoped override:

```bash
MESSAGELENS_DEVELOPMENT_ARCHIVE_ROOT="/Volumes/WD_ELEMENTS/ARCHIVE_INGESTION_TRIAL/2026-08_16-DATA_FOLDER-STAGING/com.bigbenchsoftware.MessageLens" \
  flutter run -d macos
```

That environment applies only to the process launched by that command. A later
normal Run/Debug launch does not inherit it. The repository's ordinary
development launch configuration supplies:

```text
/Volumes/WD_ELEMENTS/DEVELOPMENT_DATA_FOLDER/MessageLens Development
```

Native and Dart archive admission then correctly agree on that canonical root.
Both roots are valid development archives, so admission cannot infer that the
operator intended the rehearsal clone.

## Exact Startup Decision Path

The cold-start path is:

```text
native archive-root claim
  -> Dart ArchiveAccessAuthority admission
  -> onboardingEnvironmentReportProvider
  -> OnboardingGate
  -> OnboardingCenterPanelSyncObserver
  -> OnboardingCenterPanelSyncController
  -> EnvironmentReadinessSpec.readinessPanel
```

`onboardingEnvironmentReportProvider` receives the admitted root from
`archiveAccessAuthorityProvider.rootPath`. It derives the import and graph paths
inside that root and asks `OnboardingDatabaseProbeReader` for their facts.

While the asynchronous report is loading, `OnboardingGate` calls its fallback.
`DatabaseExistenceChecker` evaluates the same admitted root. The ordinary
development graph is not ready, so the fallback returns
`awaitingUserAction`.

The sync controller receives that status while the center panel is empty and
selects Environment Readiness. This is the first visible state in the log.

When the complete report arrives, it does not contradict the fallback. It
reports:

```text
environmentState = readyToImport
environmentBlocker = sourceScopedImportDatabaseEmpty
sourceScopedImportDbRowCount = 0
conversationGraphRowCount = 0
hasPopulatedAppDatabases = false
```

`OnboardingGate` therefore remains `awaitingUserAction`. No later healthy
result was emitted for this process, so there was no initial false result to
latch.

## Exact Source Of The Two Displayed Facts

### Imported message data

`onboardingEnvironmentReportProvider` resolves:

```text
<admitted root>/macos_import_ss.db
```

and executes the centralized probe equivalent of:

```sql
SELECT COUNT(*) FROM messages;
```

The result on this cold start was `0`. The resulting
`sourceScopedImportDatabase.hasData` was false. The Environment Readiness view
maps that exact Boolean to:

```text
Imported message data: Not prepared yet
```

Direct immutable inspection of the same on-disk database also returned `0`.

### Conversation browsing data

The same provider resolves:

```text
<admitted root>/working_ss.db
```

and executes the same `messages` count probe, plus the Conversation Graph
readiness queries. The message count was `0`; chats and message edges were also
`0`. The resulting `conversationGraph.hasData` was false. The view maps that
exact Boolean to:

```text
Conversation browsing data: Not prepared yet
```

Direct immutable inspection of the same on-disk graph also returned `0`.

Against the staging root, these same provider queries would have returned
145,825 and 145,825, so neither line would have read `Not prepared yet`.

## Failure, Override, And Maintenance Findings

- `workflowOverrideStatus` was `null` throughout the relevant startup.
- No persisted onboarding failure supplied the decision.
- The center panel began empty; no previous panel selection survived restart.
- No archive mutation was active or durably restored.
- `maintenanceInProgress` did not cause the cold-start decision.
- The asynchronous report confirmed rather than reversed the synchronous
  fallback.
- The panel was not stuck: it remained visible because current facts continued
  to require it.

The later maintenance transitions in the ordinary development log occurred
after startup and are not the initiator of the screenshot state.

## Classification

| Candidate | Finding |
|---|---|
| stale persisted failure | disproved |
| startup race | disproved |
| provider initialization order | not causal |
| latched UI state | disproved |
| maintenance classification | disproved |
| something else | **confirmed: different admitted archive root** |

## Smallest Recommended Correction

The next controlled GUI validation should launch the staging archive explicitly
on every fresh process:

```bash
MESSAGELENS_DEVELOPMENT_ARCHIVE_ROOT="/Volumes/WD_ELEMENTS/ARCHIVE_INGESTION_TRIAL/2026-08_16-DATA_FOLDER-STAGING/com.bigbenchsoftware.MessageLens" \
  flutter run -d macos
```

Before interpreting any UI result, confirm that the new application-log entry
was written under that same staging root. Do not use the ordinary VS Code
development launch configuration for the rehearsal unless its root is
temporarily and deliberately changed outside this audit.

A later observability improvement could display or log the admitted archive
root more prominently for development builds. That would prevent mistaken
cross-root comparisons, but it is not required to correct gate behavior and is
not implemented here.

## Invariant Preserved

A fresh process still derives admission from current durable truth. The process
shown in the screenshot did exactly that, but for a different valid development
archive than the operator intended to inspect.

No database, archive marker, import, graph, overlay fact, attachment payload,
production archive, frozen snapshot, or donor was modified during this audit.
