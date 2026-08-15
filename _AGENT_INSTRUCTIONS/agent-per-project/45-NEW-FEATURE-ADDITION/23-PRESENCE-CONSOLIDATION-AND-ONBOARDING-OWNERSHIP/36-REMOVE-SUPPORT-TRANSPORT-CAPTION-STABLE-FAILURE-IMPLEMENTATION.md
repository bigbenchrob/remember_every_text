---
tier: project
scope: remove-stable-failure-support-transport-caption
owner: agent-per-project
last_reviewed: 2026-08-14
source_of_truth: code
links:
  - ./33-FAILURE-DIAGNOSTIC-INFORMATION-HIERARCHY-AUDIT.md
  - ./34-REMOVE-WHAT-TO-CHECK-STABLE-FAILURE-IMPLEMENTATION.md
  - ./35-REMOVE-ENVIRONMENT-SUMMARY-STABLE-FAILURE-IMPLEMENTATION.md
tests:
  - ../../../../test/essentials/onboarding/presentation/onboarding_overlay_failure_test.dart
  - ../../../../test/essentials/logging/application/diagnostic_report_actions_test.dart
---

# Remove Support Transport Caption From Stable Failure Implementation

## Implemented Correction

The ordinary stable `importFailed` and `graphProjectionFailed` surfaces no
longer explain, before the human acts, that MessageLens will try to open an
email draft and otherwise reveal the support bundle in Finder.

The shared caption was rendered only when the stable-failure presentation
enabled **Send Report To Developer**. Removing that block therefore does not
alter transport or help copy on another application surface.

## Why The Caption Did Not Belong Before The Action

The supported decision is whether to send diagnostic information to the
developer. The button label already communicates that action. Email attachment
and Finder fallback are delivery mechanics; explaining both in advance added
reading weight without changing the decision or offering another action.

Result-specific feedback remains useful after the action because it tells the
human what actually happened.

## Support Action And Feedback Preserved

**Send Report To Developer** remains visible and continues through the same
exporter and support-report operation. No API, recipient, bundle, privacy,
email, or Finder behavior changed.

The existing snackbar feedback remains unchanged for all three outcomes:

- an email draft was prepared with the bundle attached;
- the bundle was prepared and revealed in Finder;
- a diagnostic report could not be prepared.

Focused widget coverage invokes the real presentation callback with each
exporter outcome and proves that the corresponding feedback appears.

## Diagnostics Preserved

No diagnostic evidence changed. Raw failures, timestamps, environment and
database probes, logs, failure persistence, pipeline audit data, support-report
headers, and support bundles remain available to support/developer systems.

## Retry Behavior Preserved

The stable branches retain their existing labels and dispatch:

```text
importFailed
    Try Import Again

graphProjectionFailed
    Retry Import and Graph Build
```

Both still invoke the existing full reset-and-rebuild operation. Recovery,
reset, attachment preservation, and Presence are unchanged.

## Final Stable-Failure Reading Order

```text
[failure icon]

MessageLens couldn't finish setup

MessageLens couldn't finish preparing your browsing data.
You can try again.

[Try Import Again / Retry Import and Graph Build]

[Send Report To Developer]
```

The earlier **What to check** and **Environment summary** removals remain in
force. No Technical Details disclosure or replacement diagnostic presentation
was added.

## Layout Result

Both branches fit naturally at default test typography inside the existing
overlay envelope. No scrolling, larger card, smaller typography, tighter
spacing, or other layout mechanism was introduced.

## Verification Coverage

Focused coverage proves that:

- both stable branches retain the settled primary copy and retry actions;
- **Send Report To Developer** remains visible and functional;
- the pre-action email/Finder caption is absent;
- **What to check** and **Environment summary** remain absent;
- email success, Finder fallback, and report-generation failure each retain
  their existing post-action snackbar feedback;
- support-report evidence remains unchanged.

Broader verification covers Environment Readiness, `OnboardingGate`, the
complete Onboarding suite, architecture tripwires, analyzer, formatting, diff
integrity, and a debug macOS build without launching the app.

Final results:

- 6 focused stable-failure presentation tests passed at default typography;
- 2 focused support-report action tests passed;
- 129 complete Onboarding and Environment Readiness tests passed;
- 373 architecture tripwires passed;
- `flutter analyze` reported no issues;
- the debug macOS build produced `MessageLens Development.app` without launch;
- formatting and `git diff --check` passed.

## Deviations From Audit 33

None.

The implementation removes exactly the redundant pre-action transport caption
identified by Audit 33. Automatic-recovery presentation remains a separate
future review.
