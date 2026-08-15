---
tier: project
scope: remove-automatic-recovery-diagnostic-reason
owner: agent-per-project
last_reviewed: 2026-08-14
source_of_truth: code
links:
  - ./27-ATTACHMENT-PRESERVATION-SAFETY-INVARIANT.md
  - ./30-INITIAL-SETUP-FAILURE-RECOVERY-SURFACE-AUDIT.md
  - ./40-AUTOMATIC-RECOVERY-PRESENTATION-AUDIT.md
tests:
  - ../../../../test/essentials/onboarding/presentation/onboarding_overlay_progress_test.dart
  - ../../../../test/essentials/onboarding/application/onboarding_gate_provider_test.dart
  - ../../../../test/essentials/onboarding/application/onboarding_environment_report_provider_test.dart
---

# Remove Automatic Recovery Diagnostic Reason Implementation

## Scope

This bounded presentation slice implements the single recommendation from
[the automatic-recovery presentation audit](40-AUTOMATIC-RECOVERY-PRESENTATION-AUDIT.md):

> Remove `resetAppDatabasesReason` from ordinary production automatic-recovery
> reading order while preserving it as diagnostic and classification evidence.

No recovery copy, mechanics, reset behavior, classification, persistence,
Presence behavior, or attachment policy changed.

## Presentation Change

The production `_RecoveryContent` no longer receives an environment report and
no longer renders the conditional bordered card containing
`resetAppDatabasesReason`.

The production surface still renders the existing:

```text
Cleaning Up A Previous Setup Attempt

MessageLens detected signs that an earlier setup attempt left incomplete local
data. It is clearing that data now so setup can restart cleanly.

[indeterminate activity indicator]
```

The heading and body remain intentionally unchanged. The presentation audit
found that they need a separate truthfulness correction, but that work was not
mechanically required to remove the diagnostic card.

No replacement disclosure, technical-details action, reason summary, or
recovery control was added.

## Diagnostic Evidence Preserved

The implementation did not remove or alter:

- `OnboardingEnvironmentReport.resetAppDatabasesReason`;
- Environment Readiness reason generation or recovery classification;
- resolved Gate status logging;
- automatic-recovery and fresh-start reason logging;
- reset-service logs;
- the development Onboarding panel's reason display;
- support probes, database-health evidence, or exported logs; or
- classification and Gate tests that intentionally construct or inspect the
  reason.

The resulting boundary is:

```text
production ordinary recovery presentation
    calm human-facing recovery content only

classification and diagnostics
    complete heuristic recovery reasoning retained
```

## Recovery Lifecycle

The lifecycle remains:

```text
environment inference
    -> recoveringFailedAttempt
    -> mutation admission
    -> resetDerivedData()
    -> clear recovery override
    -> invalidate environment report
    -> awaitingUserAction
    -> fresh environment classification
```

No automatic retry, cancellation, resume, progress stage, percentage, ETA, or
durable recovery state was introduced.

## Attachment-Preservation Boundary

This is presentation-only. The reset allow-list remains unchanged:

```text
AUTHORITATIVE EXTERNAL SOURCES
    never reset targets

REBUILDABLE MESSAGELENS DERIVED STORES
    narrow reset targets

MESSAGELENS PRESERVATION DATA
    never reset targets
```

Apple Messages, Apple Contacts, locally available source attachments, archived
attachment payloads, overlay/user intent, and preferences remain outside the
automatic-recovery deletion boundary.

## Layout Result

The simplified recovery surface fits naturally at default typography in the
existing card constraints. The focused widget test reports no layout exception.

No scrolling, card enlargement, typography reduction, spacing reduction, or
other geometry correction was introduced. Removing the variable-height reason
card simply reduces diagnostic density.

## Tests

Focused production recovery coverage proves that a report carrying a non-null
technical reason still renders:

- the unchanged recovery heading;
- the unchanged recovery body; and
- one indeterminate circular activity indicator;

while rendering:

- no reset-reason text;
- no filled, outlined, text, or icon button;
- no cancellation label; and
- no layout exception at default typography.

Existing Gate coverage continues to prove one automatic reset followed by
`awaitingUserAction`. Existing Environment Readiness coverage continues to
prove that the reason is generated outside production presentation.

## Verification

The implementation was verified with:

- focused recovery presentation tests;
- Onboarding Gate tests;
- Environment Readiness classification tests;
- reset-service tests;
- the complete Onboarding test directory;
- architecture tripwires;
- `flutter analyze`;
- formatting;
- `git diff --check`; and
- a debug macOS build without launching the application.

## Deviations From The Presentation Audit

None.

The implementation stops after removal of the production diagnostic reason.
It does not perform the presentation audit's later heading/body truthfulness
correction.
