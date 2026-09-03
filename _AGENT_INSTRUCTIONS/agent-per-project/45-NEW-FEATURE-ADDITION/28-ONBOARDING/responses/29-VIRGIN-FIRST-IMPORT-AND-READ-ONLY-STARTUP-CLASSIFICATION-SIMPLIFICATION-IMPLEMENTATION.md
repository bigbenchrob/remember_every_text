---
tier: project
scope: feature-28-virgin-install-simplification
owner: essentials-onboarding
last_reviewed: 2026-09-02
source_of_truth: code-tests-and-architecture-tripwires
related:
  - 28-VIRGIN-INSTALL-ARCHIVE-REGIME-SIMPLIFICATION-AUDIT.md
  - 24-FIRST-INSTALL-PRODUCTION-ARCHIVE-MARKER-BOOTSTRAP-CORRECTION.md
  - 26-FIRST-PRODUCTION-IMPORT-CHECKPOINT-CONFLICT-CORRECTION.md
---

# Virgin First Import And Read-Only Startup Classification Simplification

## Outcome

Audit 28 Slices 1 and 2 are implemented.

A positively classified Virgin installation now has a dedicated fresh-import
boundary with no dependency on reset, checkpoint, recovery, adoption, or erase
machinery. Startup installation classification now gathers its database and
durable-operation evidence through read-only SQLite inspection before ordinary
persistent logging or overlay-backed window restoration begins.

The implementation does not change schemas, migrations, marker semantics,
archive mutation serialization, or Current/legacy/remediation preservation.

## Removed Virgin Call Edges

The former first-import entry point accepted both Ready and failed operation
states, entered an environment-preparation stage, and conditionally called
`MessageDataResetService`. That left reset and verified-checkpoint authority
reachable from the nominally fresh operation graph.

Those edges have been removed. The fresh entry point is now:

```text
OnboardingReadyToImport
  -> startVirginImportAndGraphBuild()
  -> ArchiveMutationOperation.onboardingImport
  -> VirginOnboardingImportExecutor
  -> initialImport / messageDataBuild
  -> source-scoped import and Conversation Graph construction
  -> durableReadinessVerification
```

`VirginOnboardingImportExecutor` cannot import or call
`MessageDataResetService`, `messageDataReset`, verified checkpoint authority,
recovery, adoption, or erase code.

## Remediation Boundary

A report requiring derived-store reset can no longer construct
`OnboardingReadyToImport`. It projects `OnboardingOperationFailed` and remains
outside the Virgin executor.

The explicit remediation entry point is `retryFailedOperation()`. It requests
fresh canonical evidence so the existing automatic recovery path can perform
its bounded reset when justified. Recovery clears its durable operation
snapshot after successful reset, forcing reclassification. Only a subsequently
coherent Virgin report may construct Ready and authorize fresh import.

This preserves the distinction:

- first import constructs fresh stores under `onboardingImport` mutation
  serialization;
- remediation resets inconsistent derived state under its existing authority;
- retry intent cannot invoke the fresh-import entry point.

## Read-Only Classification Seam

`messageLensInstallationStateProvider` no longer constructs the writable
`OnboardingOperationSnapshotController` or persistent logger. It consumes
`SqliteMessageLensInstallationEvidenceReader`, which:

- checks only existing canonical database files;
- opens SQLite evidence with `OpenMode.readOnly`;
- sets `PRAGMA query_only = ON`;
- reads the existing Onboarding snapshot directly from `overlay_settings`;
- treats an absent overlay or absent snapshot as an idle operation;
- creates and migrates nothing.

The shared snapshot setting key remains owned by the Onboarding snapshot-store
contract. This is a narrow observational use of the existing overlay format,
not a second overlay ownership model.

## Startup Ordering

After native/Dart archive admission and first-marker establishment, startup now
orders work as follows:

```text
admitted archive authority
  -> read-only installation evidence
  -> typed installation classification
  -> persistent logger and framework error capture
  -> completed-only window-state restoration
  -> case-specific application presentation/providers
```

Classification itself creates no SQLite files, `application_logs/`, or window
state. A pristine admitted root may contain only its archive marker and native
instance-lock artifacts immediately after classification. Persistent logging
may begin after a typed case has been selected. Overlay-backed window-state
restoration begins only for `completed`; Virgin and remediation presentations
do not open the overlay merely to obtain historical geometry.

## Preserved Regimes

### Marker and identity

`ArchiveAdmissionService` still owns atomic first-marker creation after
bootstrap-empty proof. The classifier neither creates nor repairs marker state.
A meaningful unmarked root still cannot receive an initial marker.

### Current

A completed Current installation is still classified from canonical evidence,
then restores its persisted window state and opens normal providers lazily.

### Exact legacy tester installation

Restricted legacy authority and its read-only `4/3/3` proof are unchanged.
Explicit deletion still converges to a newly admitted canonical Virgin archive,
which rejoins the same ordinary Onboarding path.

### Remediation

Existing resumable, abandoned, and remediation-required distinctions remain.
No destructive operation was made reachable from ordinary Virgin startup.

## Regression Protection

Focused tests and architecture tripwires prove:

- the Virgin executor has no reset/checkpoint call edge;
- only Ready can enter fresh import;
- reset-required evidence cannot construct Ready;
- retry remains a separate intent;
- fresh import starts directly at `messageDataBuild` and proceeds to durable
  verification;
- pristine classification leaves archive contents unchanged;
- operation snapshot evidence is read-only and works without a writable
  controller;
- classification precedes persistent logging and window restoration;
- window state restores only for completed installations;
- legacy, archive-admission, mutation, checkpoint, Start Fresh, and Onboarding
  regressions retain their established behavior.

## Deferred Work

Audit 28 Slice 3 remains deferred: Complete Erase access-mode, startup,
presentation, dispatcher, and low-level root-replacement remnants were not
removed.

Audit 28 Slice 4 remains deferred: retired required-sources Presence coupling,
resumable/abandoned consolidation, and migration/schema archaeology were not
changed.

No manual Development-arm reset was performed during this implementation.
Structural fixtures cover the bounded behavior without touching Production or
creating an external archive clone.

## Verification

- Focused Virgin import, installation classification, operation snapshot,
  startup, coordinator, overlay, archive-admission, mutation, checkpoint,
  Start Fresh, and legacy regression groups: passed.
- Architecture tripwires, including the dedicated Virgin boundary and shared
  snapshot-key authority: passed.
- Full Flutter suite, run serially to avoid an unrelated attachment-test
  scheduling race: **2,180 passed**.
- `flutter analyze`: no issues.
- `flutter build macos --debug`: succeeded and produced
  `MessageLens Development.app`.
- `git diff --check`: passed.

The normal parallel full-suite run exposed the existing attachment-resolver
test's timing sensitivity once; that exact test passed in isolation, and the
complete serial suite passed. No attachment implementation was changed in this
slice.

Release metadata is `0.2.102+120`.
