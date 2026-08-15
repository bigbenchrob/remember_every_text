---
tier: project
scope: remove-stable-failure-what-to-check
owner: agent-per-project
last_reviewed: 2026-08-14
source_of_truth: code
links:
  - ./33-FAILURE-DIAGNOSTIC-INFORMATION-HIERARCHY-AUDIT.md
  - ./32-PHASE-NEUTRAL-STABLE-SETUP-FAILURE-COPY-IMPLEMENTATION.md
  - ./27-ATTACHMENT-PRESERVATION-SAFETY-INVARIANT.md
tests:
  - ../../../../test/essentials/onboarding/presentation/onboarding_overlay_failure_test.dart
  - ../../../../test/essentials/logging/application/diagnostic_report_actions_test.dart
---

# Remove What To Check From Stable Failure Implementation

## Implemented Correction

The stable `importFailed` and `graphProjectionFailed` presentations no longer
supply branch-specific notes to the ordinary Onboarding failure surface.
Because the shared **What to check** card renders only when notes exist, the
entire card is now absent from those two branches.

No replacement disclosure was introduced. In particular, there is no
**Technical Details**, **Show Details**, or equivalent interaction.

Other Onboarding states retain their existing use of the shared advice card.

## Removed From Ordinary Reading Order

The stable failure surface no longer displays:

- raw persisted exception text;
- failure timestamps;
- unsupported **previous launch** narrative;
- unsupported inference that imported rows prove a browsing-preparation
  failure;
- imported/graph-store diagnostic notes;
- the clean-import-pass explanation;
- duplicated instructions to use **Send Report To Developer**.

The settled primary layer remains unchanged:

> **MessageLens couldn't finish setup**

> MessageLens couldn't finish preparing your browsing data. You can try again.

## Diagnostic Evidence Preserved

No diagnostic authority or evidence changed. The implementation does not
modify:

- `OnboardingFailureStore` or its raw failure strings and timestamps;
- environment or database probes;
- controller error state;
- current or previous logs;
- pipeline audit logs;
- database-health reporting;
- support-bundle generation or report headers;
- email/Finder presentation and snackbar feedback.

Focused coverage proves that the same raw graph failure and recorded timestamp
remain in the generated support-report header while neither appears in the
ordinary widget tree.

## Content Deliberately Retained

This slice retains, without redesign:

- **Environment summary**;
- **Try Import Again** for the import bucket;
- **Retry Import and Graph Build** for the graph-projection bucket;
- **Send Report To Developer**;
- the email/Finder transport caption;
- automatic-recovery presentation and `resetAppDatabasesReason`.

Both retry actions continue to dispatch through the existing
`OnboardingGate.startImportAndGraphBuild()` operation. Retry, reset, recovery,
failure persistence, and archived-attachment preservation are unchanged.

## Overflow Result

The stable failure widget tests now run at normal/default test typography. The
previous test-only `TextScaler.linear(0.6)` workaround has been removed.

Both failure branches fit the existing 920-pixel maximum card height without
overflow. No scrolling, smaller typography, larger card, reduced spacing, or
other geometry change was required.

This confirms Audit 33's diagnosis: the observed overflow was caused primarily
by unjustified information density and unbounded diagnostic text rather than
by an inadequate layout mechanism.

## Verification Coverage

Focused tests prove that:

- both branches retain the settled primary heading and body;
- **Environment summary** remains visible;
- **What to check**, raw errors, previous-launch text, clean-pass text, and the
  unsupported graph-phase inference are absent;
- branch-specific retry labels and dispatch remain unchanged;
- support export remains functional;
- the transport caption remains visible;
- raw failure and timestamp evidence remain in support-report headers;
- the surface renders at default typography without overflow.

Broader verification covers Environment Readiness failure behavior,
`OnboardingGate` retry/failure behavior, the complete Onboarding suite,
architecture tripwires, analyzer, formatting, diff integrity, and a debug
macOS build without launching the app.

Final results:

- 2 focused stable-failure widget tests passed at default typography;
- 2 support-report action tests passed;
- 125 complete Onboarding and Environment Readiness tests passed;
- 373 architecture tripwires passed;
- `flutter analyze` reported no issues;
- the debug macOS build produced `MessageLens Development.app` without launch;
- formatting and `git diff --check` passed.

## Deviations From Audit 33

None.

The implementation removes exactly the one component recommended by Audit 33.
Environment Summary and support-transport copy remain available for later
bounded review.
