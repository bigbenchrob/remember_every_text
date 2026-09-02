---
tier: project
scope: feature-28-first-production-import
owner: essentials-onboarding
last_reviewed: 2026-09-02
source_of_truth: code-tests-and-tester-evidence
related:
  - 24-FIRST-INSTALL-PRODUCTION-ARCHIVE-MARKER-BOOTSTRAP-CORRECTION.md
  - 15-FEATURE-28-FINAL-ONBOARDING-RELEASE-READINESS-AND-CONFORMANCE.md
---

# First Production Import Checkpoint Conflict Correction

## Observed Failure

A new production tester installation reached **Everything is ready**, correctly
reported 5,200 Messages rows, and failed immediately after **Import My
Messages**. Repeated retries produced the same result.

The support bundle established that Full Disk Access and both source databases
were available. The source-scoped import and Conversation Graph databases were
valid current-schema stores with zero rows, which is the expected coherent
state before a first import.

The repeated operation error was:

```text
Verified archive checkpoint required for messageDataReset:
no verified checkpoint receipt is registered.
```

## Root Cause

`OnboardingJourneyCoordinator._prepareForFreshStartIfNeeded()` correctly read
the environment report's `shouldResetAppDatabasesBeforeImport` decision. When
that value was true it requested the canonical reset, but its false branch also
requested the same reset unconditionally.

The resulting operation chain was:

```text
onboardingImport admitted
  -> coherent virgin state observed
  -> messageDataReset requested anyway
  -> production checkpoint authority correctly denied reset
  -> onboarding operation failed before import
```

The checkpoint rule was therefore working correctly. The defect was the
unnecessary destructive request made for an already-coherent virgin archive.

## Correction

First-import preparation now has one explicit decision:

- if canonical environment evidence requires reset, invoke
  `MessageDataResetService` exactly as before;
- otherwise preserve the coherent empty stores and continue directly into the
  normal import and graph-build operation.

No checkpoint rule was weakened. Ordinary `messageDataReset` remains protected
in production, and no new reset capability or bypass was introduced.

## Diagnostic Correction

The process-local `OnboardingOperationFailed` state retained the real exception,
but the failure-screen report action previously sent only the reconciled
`OnboardingEnvironmentReport`. That made a useful support bundle describe the
post-failure empty stores without naming the operation that failed.

The failure report now includes the current operation-failure summary in its
email body and diagnostic header. This is reporting context only; it does not
change durable operation or environment state.

## Regression Protection

Focused tests prove:

1. coherent virgin first import does not call the reset service;
2. the same path under production archive authority completes without a
   checkpoint receipt because no reset is requested;
3. explicitly inconsistent derived state still invokes reset and preserves its
   typed failure and retry behavior;
4. the failure screen passes the process-local operation error into the report;
5. both attached-email and manual-attachment report forms contain that error.

No database schema, source data, attachment archive, overlay intent, Presence
history, archive identity, or production checkpoint policy changed.

## Release

The correction is included in MessageLens `0.2.101+119`.
