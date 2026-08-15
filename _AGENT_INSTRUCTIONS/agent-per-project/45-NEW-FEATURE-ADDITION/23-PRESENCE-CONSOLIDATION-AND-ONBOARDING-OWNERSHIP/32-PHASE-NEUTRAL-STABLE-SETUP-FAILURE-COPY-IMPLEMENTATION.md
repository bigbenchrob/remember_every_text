---
tier: project
scope: phase-neutral-stable-setup-failure-copy
owner: agent-per-project
last_reviewed: 2026-08-14
source_of_truth: code
links:
  - ./30-INITIAL-SETUP-FAILURE-RECOVERY-SURFACE-AUDIT.md
  - ./31-BOUNDED-ACTIVE-PROGRESS-FAILURE-HEADLINE-IMPLEMENTATION.md
  - ./27-ATTACHMENT-PRESERVATION-SAFETY-INVARIANT.md
tests:
  - ../../../../test/essentials/onboarding/presentation/onboarding_overlay_failure_test.dart
---

# Phase-Neutral Stable Setup Failure Copy Implementation

## Previous Primary Presentation

The two persisted failure buckets previously produced different ordinary-user
narratives:

```text
Import Attempt Failed

MessageLens could reach your local sources, but the last import attempt did
not finish successfully. You can retry now or send a report to the developer.
```

```text
Messages Could Not Be Prepared

MessageLens imported source data, but the app could not finish preparing it
for use. You can retry now or send a report to the developer.
```

The second narrative overcommitted to source import having completed. Current
failure persistence does not prove that boundary: every caught controller-
lifecycle error is recorded through the coarse graph-projection bucket.

## Final Primary Presentation

Both `importFailed` and `graphProjectionFailed` now present:

> **MessageLens couldn't finish setup**

> MessageLens couldn't finish preparing your browsing data. You can try again.

The statement reports only the shared human truth: setup did not finish, the
preparation operation has stopped, and another attempt is available. It does
not ask the human to distinguish import, enrichment, join construction, or
Conversation Graph projection.

## Unchanged Operational Boundaries

The persisted import and graph-projection buckets remain separate and
unchanged. This slice does not add stage identity or reinterpret their evidence.

The existing branch-specific actions also remain unchanged:

- `importFailed` retains **Try Import Again**;
- `graphProjectionFailed` retains **Retry Import and Graph Build**;
- both retain **Send Report To Developer**;
- retry still invokes `OnboardingGate.startImportAndGraphBuild()`, which resets
  rebuildable derived stores and runs the complete build again.

There is no resume behavior and no new Presence interaction.

## Diagnostics Intentionally Retained

Only the primary heading and explanatory paragraph changed. Existing secondary
material remains available, including raw persisted errors, timestamps,
environment summaries, **What to check**, report-export guidance, and support-
bundle content.

Some secondary notes still use phase-specific and previous-launch language
identified by Audit 30. They remain visible intentionally because simplifying
diagnostic detail is a separate bounded slice.

## Preservation Boundary

The new copy makes no claim that all work was deleted, all data will be rebuilt,
or every attachment is archived or recoverable.

The existing storage categories remain distinct:

```text
resettable
    rebuildable MessageLens derived stores

preserved
    archived attachment payloads

external sources
    Apple Messages and Contacts
```

## Verification Coverage

Focused widget coverage proves that:

- both stable failure buckets share the bounded heading and body;
- the previous import- and graph-specific primary narratives are absent;
- branch-specific retry labels remain available and dispatch through the same
  Gate operation;
- **Send Report To Developer** still exports a support request;
- raw diagnostic errors remain visible in secondary material and included in
  the support report;
- persisted previous-launch wording remains secondary rather than entering the
  primary orientation layer.

Automatic recovery, reset/admission failure reporting, retry mechanics,
support-bundle contents, and the stable diagnostic hierarchy were not changed.

## Deviations From Audit 30

None. This implements only the next primary-copy correction identified by the
audit and preserves document 31's transient-headline correction.
