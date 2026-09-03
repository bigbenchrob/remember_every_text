---
tier: project
scope: feature-28-tester-reports
owner: essentials-onboarding
last_reviewed: 2026-09-02
source_of_truth: feature-records-tests-and-tester-evidence
---

# Tester-Reported Onboarding Problems, Diagnoses, And Fixes

## Purpose And Scope

This document consolidates the Onboarding problems reported by external
testers and recorded during Feature 28. It distinguishes confirmed causes from
historical reports that could not be reconstructed conclusively.

Development-only profiling and Complete Erase rehearsal defects are not
presented here as tester reports. They remain documented in their individual
Feature 28 records.

The status terms used below mean:

- **Corrected:** the reported cause was reproduced or proved and a focused fix
  was implemented.
- **Structurally addressed:** the failure class is now handled, although the
  original historical incident could not be reproduced exactly.
- **Intentionally constrained:** the observed behavior remains because allowing
  the requested alternative would violate installation truth or safety.

## Summary

| Tester-observed problem | Diagnosis | Resolution | Status |
| --- | --- | --- | --- |
| Testers did not understand what Messages/iCloud setup was required | MessageLens needs the desired history to be present in the local Mac `chat.db`; it cannot inspect an iPhone or prove iCloud synchronization | Added truthful Messages and History Episodes, local-history evidence, sparse-history guidance, and explicit acceptance | Corrected |
| An import appeared to stop around an unusual handle resembling `*city*` associated with Hong Kong | The exact historical trigger is unproved; related code assigned unsupported canonical meaning to opaque handles and earlier validation mishandled canonicalized membership counts | Preserve opaque handles by source-scoped identity, exclude them from unsupported alias/contact semantics, and continue dependent records where relationships remain truthful | Structurally addressed |
| Long work appeared stalled or dead | Onboarding exposed coarse spinner state without durable stage, liveness, or restart evidence | Added a durable typed operation snapshot, real stage progress, bounded liveness observations, failure state, and restart reconciliation | Corrected |
| Abandoned April 2026 tester installations had an unclear and incompatible state | The tester build used a specific pre-marker, pre-source-scoped `4/3/3` database generation that current code must not open or guess about | Added read-only exact-cohort recognition and an explicitly authorized **Delete Old Data and Continue** compatibility path | Corrected for the proven cohort |
| A genuine new install failed with `missingMarker` before Onboarding | Production marker creation was rejected unconditionally even after the root had been proved absent or empty | Allow initial production marker creation only across the existing proven empty-root boundary | Corrected in `0.2.100+118` |
| A new install reached **Everything is ready**, then failed every time **Import My Messages** was pressed | The no-reset branch still requested `messageDataReset`; production checkpoint authority correctly rejected that destructive request because a virgin install has no checkpoint | Skip reset for coherent virgin stores and proceed directly to import; retain checkpoint protection when reset is genuinely required | Corrected in `0.2.101+119` |
| The support report described empty derived stores but omitted the actual import exception | The failure screen sent the reconciled environment report without the process-local operation failure | Include the current typed operation-failure summary in the report and diagnostic header | Corrected in `0.2.101+119` |
| The import failure screen offered retry/report but no route into the app | An incomplete first installation cannot truthfully be treated as a usable installation | The known repeatable failure was fixed; normal application entry remains unavailable until durable verification succeeds | Intentionally constrained |

## 1. Messages, iCloud, And Local History Were Unclear

### Report

Early testers did not understand which Messages/iCloud settings needed to be
enabled on the Mac and iPhone. The practical risk was that a tester could
import only the history currently present on the Mac without realizing that
older history had not finished synchronizing.

### Diagnosis

The historical instruction "enable Messages in iCloud" was too coarse.
MessageLens does not fundamentally require iCloud. It requires a readable
local Messages database containing the history the person wants to import.

MessageLens can prove that the local `chat.db` exists, is readable, and has a
measured count and date range. It cannot inspect another Apple device or prove
that iCloud synchronization has completed.

### Fix

The first-run Journey now separates:

```text
Messages -> History -> Contacts -> Ready -> Import -> Start
```

- **Messages** owns Full Disk Access and local source readability.
- **History** explains that only history stored on this Mac can be imported.
- Sparse or potentially incomplete local evidence requires a truthful human
  decision before proceeding.
- The guidance recommends checking Messages in iCloud only when expected
  history is missing; it does not claim that MessageLens inspected iCloud.

The current wording is:

> MessageLens imports only the history stored on this Mac. If messages you
> expect are missing here, make sure Messages in iCloud is enabled and has
> finished syncing on your devices before continuing.

See
[`11-ENVIRONMENT-READINESS-AS-GUIDED-PRESENCE-EPISODE-AND-ONBOARDING-HANDOFF-IMPLEMENTATION.md`](11-ENVIRONMENT-READINESS-AS-GUIDED-PRESENCE-EPISODE-AND-ONBOARDING-HANDOFF-IMPLEMENTATION.md)
and
[`14-ONBOARDING-JOURNEY-NODE-SEMANTICS-AND-VERIFICATION-GATE-IMPLEMENTATION.md`](14-ONBOARDING-JOURNEY-NODE-SEMANTICS-AND-VERIFICATION-GATE-IMPLEMENTATION.md).

## 2. The Unusual `*city*` / Hong Kong Handle Incident

### Report

One historical tester import appeared to stop around an unusual handle
resembling `*city*`, associated in the tester's recollection with Hong Kong.
The application did not provide a useful explanation.

### Diagnosis

The exact incident cannot be reconstructed. No retained log, fixture, source
row, or test proves that this literal handle caused the stop.

Two related weaknesses were established:

1. an earlier validation compared pre-canonical and post-canonical
   chat-to-handle membership counts incorrectly; and
2. graph projection treated an opaque raw handle as a canonical grouping key,
   which could assign unsupported identity meaning or merge distinct source
   rows.

Current evidence therefore supports the unusual-handle report as a genuine
failure archetype, but not a claim that `*city*` itself was the exact cause.

### Fix

Source identity is now independent of optional semantic interpretation:

- every nonempty handle retains deterministic source-scoped identity;
- recognized phone and email handles continue through normal normalization;
- opaque service identifiers remain visible source evidence;
- opaque values do not enter canonical alias grouping or contact matching;
- dependent chats and messages continue when their source relationships remain
  truthful;
- only missing structural identity or systemic integrity failure stops the
  operation.

The same dependency-aware rule was then applied to messages, chats,
attachments, reactions, rich text, and Contacts enrichment. A
production-shaped validation completed with all 137,373 messages represented
in both the import ledger and Conversation Graph, including 13 handles
preserved without unsupported normalization.

See
[`06-DEPENDENCY-AWARE-SOURCE-ANOMALY-HANDLING-STARTING-WITH-HANDLES-IMPLEMENTATION.md`](06-DEPENDENCY-AWARE-SOURCE-ANOMALY-HANDLING-STARTING-WITH-HANDLES-IMPLEMENTATION.md),
[`07-DEPENDENCY-AWARE-ANOMALY-POLICY-FOR-REMAINING-ONBOARDING-DOMAINS-IMPLEMENTATION.md`](07-DEPENDENCY-AWARE-ANOMALY-POLICY-FOR-REMAINING-ONBOARDING-DOMAINS-IMPLEMENTATION.md),
and
[`08-PRODUCTION-SHAPED-ONBOARDING-ANOMALY-VALIDATION.md`](08-PRODUCTION-SHAPED-ONBOARDING-ANOMALY-VALIDATION.md).

## 3. Long-Running Work Looked Stalled

### Report

Tester experience included long-running work that could look like a frozen
screen, unexplained spinner, or dead application. After interruption, it was
also unclear whether completed work had survived or what should happen next.

### Diagnosis

The operation had real internal stages, but Onboarding exposed only coarse
gate state and an indeterminate spinner. It lacked one durable typed account
of the current operation, completed stages, progress revision, process
session, last real progress, failure, and restart reconciliation.

### Fix

Feature 28 added:

- one durable typed Onboarding operation snapshot;
- stage-specific real progress and liveness observations;
- bounded persistence rather than per-row writes;
- typed failure and retry ownership;
- process-session and operation-occurrence identity;
- restart reconciliation for interrupted operations;
- Directed Instrumentation based on measured work rather than invented
  percentages or reassurance.

The later production-shaped run completed in roughly 49 seconds and retained
durable stage and anomaly evidence throughout. This does not promise that no
future operation can fail; it prevents the product from representing unknown
operation state as an unexplained spinner.

See
[`02-DURABLE-TYPED-ONBOARDING-OPERATION-SNAPSHOT-AND-LIVENESS-FOUNDATION-IMPLEMENTATION.md`](02-DURABLE-TYPED-ONBOARDING-OPERATION-SNAPSHOT-AND-LIVENESS-FOUNDATION-IMPLEMENTATION.md),
[`04-ONBOARDING-STAGE-OBSERVABILITY-AND-REAL-PROGRESS-INSTRUMENTATION-IMPLEMENTATION.md`](04-ONBOARDING-STAGE-OBSERVABILITY-AND-REAL-PROGRESS-INSTRUMENTATION-IMPLEMENTATION.md),
and
[`05-PRODUCTION-SHAPED-ONBOARDING-PROFILING-AND-LIVENESS-EVIDENCE.md`](05-PRODUCTION-SHAPED-ONBOARDING-PROFILING-AND-LIVENESS-EVIDENCE.md).

## 4. Older Tester Installations Could Not Safely Continue

### Report

Three early testers may still have the final April 2026 tester build,
`0.1.16+17`. Those installations predate archive markers, source-scoped import
storage, the current graph database, and durable Presence/Onboarding state.
Their later state and safe recovery path were unclear.

### Diagnosis

The old data cannot be treated as a current archive, but a missing marker alone
cannot authorize deletion. The audited tester generation has a narrower
positive signature:

- `macos_import.db`, schema version 4, with its exact legacy table set;
- `working.db`, schema version 3, with its exact legacy table set;
- `user_overlays.db`, schema version 3, with its exact legacy table set;
- no current marker, source-scoped import database, graph database, or
  `presence.db`.

### Fix

A read-only legacy inspector now recognizes only that complete signature. It
does not open the files through current providers, migrate them, mark them, or
infer authority from filenames alone.

The recognized installation enters a restricted compatibility surface. Only
an explicit **Delete Old Data and Continue** command admits the dedicated
mutation. It deletes only the positively identified MessageLens-owned legacy
root, proves a new virgin archive, and relaunches into current Onboarding.
Apple Messages, Contacts, and external sources remain outside the deletion
boundary.

Unknown, damaged, partial, or merely unmarked archives continue to fail closed.

See
[`18-LAST-DISTRIBUTED-TESTER-BUILD-LEGACY-INSTALL-SIGNATURE-AUDIT.md`](18-LAST-DISTRIBUTED-TESTER-BUILD-LEGACY-INSTALL-SIGNATURE-AUDIT.md),
[`19-LEGACY-TESTER-INSTALL-INSPECTOR-AND-STARTUP-CLASSIFICATION-IMPLEMENTATION.md`](19-LEGACY-TESTER-INSTALL-INSPECTOR-AND-STARTUP-CLASSIFICATION-IMPLEMENTATION.md),
and
[`21-LEGACY-TESTER-DATA-DELETION-AUTHORIZATION-AND-ONBOARDING-HANDOFF-IMPLEMENTATION.md`](21-LEGACY-TESTER-DATA-DELETION-AUTHORIZATION-AND-ONBOARDING-HANDOFF-IMPLEMENTATION.md).

## 5. A New Production Install Was Rejected For A Missing Marker

### Report

On 2026-09-02, a tester launching a genuinely new production installation saw:

```text
ArchiveAdmissionException(ArchiveAdmissionFailure.missingMarker):
Production refuses an unmarked archive outside explicit adoption.
```

Onboarding never opened.

### Diagnosis

The archive admission service had already proved that the canonical production
root was absent or empty. After that proof, its marker-creation method still
rejected every production claim unconditionally. The second rule contradicted
the established first-install boundary.

### Fix

Initial marker creation now uses the same fail-closed filesystem proof in both
environments:

- an absent or empty canonical root may receive its first environment marker;
- the native instance lock may already exist and is preserved;
- the marker records the environment proved by the native claim;
- nonempty unmarked production roots remain in the legacy-inspection,
  explicit-adoption, or fail-closed paths.

The correction shipped as `0.2.100+118`. No existing archive admission rule
was weakened.

See
[`24-FIRST-INSTALL-PRODUCTION-ARCHIVE-MARKER-BOOTSTRAP-CORRECTION.md`](24-FIRST-INSTALL-PRODUCTION-ARCHIVE-MARKER-BOOTSTRAP-CORRECTION.md).

## 6. First Import Requested A Destructive Reset It Did Not Need

### Report

After installing the marker correction, the tester reached **Everything is
ready** and saw approximately 5,200 local messages. Pressing **Import My
Messages** always produced **MessageLens couldn't finish setup**. **Try Again**
repeated the failure.

The attached support bundle reported `readyToImport` with
`sourceScopedImportDatabaseEmpty`, even though Full Disk Access and both Apple
source databases were available.

### Diagnosis

The empty current-schema import and graph stores were the coherent expected
state before a first import. They were not the defect.

`OnboardingJourneyCoordinator._prepareForFreshStartIfNeeded()` checked whether
the environment required a reset. Its true branch requested the canonical
reset, but its false branch also requested the same reset unconditionally.

The actual sequence was:

```text
first import admitted
    -> coherent virgin stores observed
    -> messageDataReset requested unnecessarily
    -> no production checkpoint exists on a first install
    -> checkpoint authority correctly rejects the reset
    -> import never begins
```

The safety rule behaved correctly. The caller requested the wrong operation.

### Fix

The coordinator now requests `MessageDataResetService` only when canonical
environment evidence says reset is required. A coherent virgin installation
continues directly into source import and graph construction.

The production checkpoint rule remains unchanged. It still protects every
genuine message-data reset.

The correction shipped as `0.2.101+119`. The tester's failed installation was
safe to retry because no import or destructive reset had occurred.

See
[`26-FIRST-PRODUCTION-IMPORT-CHECKPOINT-CONFLICT-CORRECTION.md`](26-FIRST-PRODUCTION-IMPORT-CHECKPOINT-CONFLICT-CORRECTION.md).

## 7. The Support Bundle Hid The Operative Failure

### Report

The tester used **Send Report To Developer**, but the initial bundle emphasized
the reconciled empty-store blocker rather than the exception that had caused
the operation to fail. That made a valid virgin state look like the cause.

### Diagnosis

The process-local `OnboardingOperationFailed` state retained the real
checkpoint exception. The report action sent only the broader reconciled
`OnboardingEnvironmentReport`, so the most useful causal evidence was omitted.

### Fix

The report action now includes the current operation-failure summary in both
the email body and diagnostic header. Durable operation semantics did not
change; this is a correction to support evidence.

This shipped with `0.2.101+119` and is covered by attached-email and
manual-attachment report tests.

## 8. No Cancel Path From The Failure Screen

### Report

The tester noted that the failure surface offered **Try Again** and **Send
Report To Developer**, but no way to cancel into MessageLens; quitting the app
was the only way to leave the failed first-run flow.

### Diagnosis And Current Decision

This was not the cause of the failure. A first installation with no verified
derived data is not yet a usable MessageLens installation, so allowing
**Cancel** to enter the normal application would make installation state
untruthful.

No separate bypass was added. The known deterministic failure was corrected,
retry remains available for recoverable failures, reporting now carries the
operative error, and **Start** remains mechanically impossible until internal
durable verification succeeds.

Whether a future failure surface should offer a more explicit **Quit
MessageLens** action is a presentation question. It must not become permission
to bypass required first-install completion.

## Release Sequence

| Release | Tester-facing purpose |
| --- | --- |
| `0.2.99+117` | Current six-node Onboarding, typed operation/liveness handling, anomaly preservation, and exact legacy-tester compatibility path |
| `0.2.100+118` | Genuine first-install production archive marker bootstrap |
| `0.2.101+119` | Virgin first-import checkpoint correction and complete failure-report context |

## Overall Assessment

The reports did not share one root cause. They exposed four different boundary
problems:

1. human prerequisites were described more broadly than MessageLens could
   prove;
2. source interpretation was allowed to threaten otherwise valid source
   identity;
3. operation continuity and failure evidence were too coarse;
4. first-install and legacy-install archive states were not separated cleanly
   enough from destructive maintenance paths.

The resulting architecture now derives the visible Onboarding Episode from
typed prerequisite evidence, durable operation truth, and explicit human
intent. It preserves unusual but structurally valid source data, fails closed
around unknown archives and destructive operations, and does not expose the
normal application until the import and its internal durable verification have
actually succeeded.
