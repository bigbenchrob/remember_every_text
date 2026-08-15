---
tier: project
scope: calm-truthful-automatic-recovery-copy
owner: agent-per-project
last_reviewed: 2026-08-15
source_of_truth: code
links:
  - ./27-ATTACHMENT-PRESERVATION-SAFETY-INVARIANT.md
  - ./40-AUTOMATIC-RECOVERY-PRESENTATION-AUDIT.md
  - ./38-REMOVE-AUTOMATIC-RECOVERY-DIAGNOSTIC-REASON-IMPLEMENTATION.md
tests:
  - ../../../../test/essentials/onboarding/presentation/onboarding_overlay_progress_test.dart
  - ../../../../test/essentials/onboarding/application/onboarding_gate_provider_test.dart
  - ../../../../test/essentials/onboarding/application/onboarding_environment_report_provider_test.dart
---

# Calm, Truthful Automatic-Recovery Copy Implementation

## Scope

This bounded production-presentation slice completes the copy correction
identified by [the automatic-recovery presentation audit](40-AUTOMATIC-RECOVERY-PRESENTATION-AUDIT.md), after
[Slice 38](38-REMOVE-AUTOMATIC-RECOVERY-DIAGNOSTIC-REASON-IMPLEMENTATION.md)
removed the technical reason card.

Only the automatic-recovery heading and explanatory paragraph changed.
Recovery classification, mechanics, reset behavior, diagnostics, persistence,
attachment preservation, and Presence remain unchanged.

## Previous Copy

```text
Cleaning Up A Previous Setup Attempt

MessageLens detected signs that an earlier setup attempt left incomplete local
data. It is clearing that data now so setup can restart cleanly.
```

This wording made several unsupported or overbroad claims:

- **Previous** and **earlier setup attempt** implied launch/process history that
  the recovery evidence does not establish.
- **local data** could reasonably include Apple sources, source attachments,
  preservation data, overlay intent, or preferences.
- **clearing that data** foregrounded deletion without defining the narrow
  rebuildable-store boundary.
- **setup can restart cleanly** could imply that recovery automatically reruns
  setup, which it does not.

## Final Copy

```text
Preparing MessageLens to try again

MessageLens found incomplete browsing data and is preparing for another setup
attempt. Please wait.
```

The heading remains truthful before mutation admission succeeds. It does not
claim that deletion has begun, identify a failed phase, or promise that setup
will rerun automatically.

The body communicates the complete human contract:

1. MessageLens found an incomplete condition.
2. The condition concerns browsing data.
3. MessageLens is preparing another attempt rather than resuming one.
4. No diagnosis or decision is required from the human.
5. The human should wait while the current operation runs.

## Why “Browsing Data” Is Correct

The automatic reset targets only allow-listed MessageLens stores used to
prepare imported Messages data for browsing. **Browsing data** is therefore a
bounded human-facing description of the affected derived stores.

It does not suggest alteration of:

- Apple Messages or Contacts;
- locally available source attachment payloads;
- MessageLens archived attachment payloads;
- overlay/user intent; or
- preferences.

It also avoids requiring the human to understand import ledgers, Conversation
Graphs, graph projection, or row-count heuristics.

## Why Preservation Reassurance Was Not Added

No sentence such as **Your original Messages are safe** or **Your attachment
archive will not be touched** was added. The reset allow-list mechanically
preserves those categories, but naming possible deletion targets in ordinary
recovery copy could introduce concern that the human did not have.

The copy instead uses the precise term **incomplete browsing data**. The
attachment-preservation invariant remains enforced in reset ownership and
tests rather than expanded into the primary recovery narrative.

## Preserved Presentation

The production surface retains:

- the existing recovery icon;
- the existing typography and spacing;
- the indeterminate circular activity indicator;
- no percentage, stage, ETA, or elapsed time; and
- no Cancel, Retry, Continue, Dismiss, or other control.

The diagnostic reason removed by Slice 38 remains absent.

## Recovery Mechanics Unchanged

The lifecycle remains:

```text
environment inference
    -> recoveringFailedAttempt
    -> mutation admission
    -> resetDerivedData()
    -> clear recovery override
    -> invalidate environment
    -> awaitingUserAction
    -> fresh environment classification
```

Successful recovery normally makes **Import My Messages** available. It does
not start setup automatically. Reset failure, mutation-admission denial, and
abrupt termination retain their existing behavior.

## Diagnostics Unchanged

This slice does not alter:

- `OnboardingEnvironmentReport.resetAppDatabasesReason`;
- reason generation or environment classification;
- Gate, recovery, or reset-service logging;
- development-panel diagnostics;
- support evidence; or
- classification tests.

Production copy remains the human projection. Diagnostic systems retain the
technical explanation.

## Tests

Focused production recovery coverage proves:

- the new heading is visible;
- the complete new body is visible;
- previous/earlier-attempt language is absent;
- local-data, clearing-data, and restart-cleanly language is absent;
- import-ledger, Conversation-Graph, graph-projection, and row-disparity
  language remains absent even when the report contains a technical reason;
- the indeterminate activity indicator remains visible;
- no recovery controls appear; and
- the existing card constraints report no layout exception.

Existing Gate tests continue to prove one automatic reset followed by
`awaitingUserAction`. Environment Readiness and reset-preservation tests remain
unchanged.

## Verification

The implementation was verified with:

- focused automatic-recovery presentation tests;
- Onboarding Gate recovery tests;
- Environment Readiness recovery-classification tests;
- reset-service preservation tests;
- the complete Onboarding test directory;
- architecture tripwires;
- `flutter analyze`;
- formatting;
- `git diff --check`; and
- a debug macOS build without launching the application.

## Deviations From The Presentation Audit

None.

The implementation uses the exact heading and body concept recommended by
the presentation audit and authorized by the implementation prompt. It does
not address automatic-recovery failure behavior or any later Onboarding
concern.
