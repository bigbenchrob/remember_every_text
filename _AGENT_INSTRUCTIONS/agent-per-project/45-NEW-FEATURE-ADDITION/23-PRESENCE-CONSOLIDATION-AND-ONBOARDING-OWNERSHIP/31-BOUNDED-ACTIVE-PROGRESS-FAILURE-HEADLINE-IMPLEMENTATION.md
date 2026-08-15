---
tier: project
scope: bounded-active-progress-failure-headline
owner: agent-per-project
last_reviewed: 2026-08-14
source_of_truth: code
links:
  - ./30-INITIAL-SETUP-FAILURE-RECOVERY-SURFACE-AUDIT.md
  - ./26-PRE-RESET-PREPARATION-PROGRESS-IMPLEMENTATION.md
tests:
  - ../../../../test/essentials/onboarding/presentation/onboarding_overlay_progress_test.dart
  - ../../../../test/essentials/conversation_graph/application/conversation_graph_build_controller_provider_test.dart
---

# Bounded Active-Progress Failure Headline Implementation

## Previous Behavior

During the controller-to-Gate failure handoff, the Gate can still own
`buildingGraph` or `reimportBuildingGraph` after the graph-build controller has
published `failed`. The active progress presentation previously promoted
`ConversationGraphBuildState.lastError` directly into its primary headline.

Because `lastError` is produced from `error.toString()`, the headline could
contain SQL, SQLite details, file paths, internal component names, or an
arbitrarily long third-party exception description.

## Implemented Correction

The failed controller state now produces one fixed headline in both first-run
setup and direct reimport:

> MessageLens couldn't finish preparing browsing data.

The wording is deliberately phase-neutral. The current controller catch spans
source import, enrichment, join construction, graph projection, and immediate
post-build publication. It cannot truthfully identify one failed phase.

Only the active progress headline changed. Running, successful, idle, and
pre-reset preparation presentations retain their existing behavior.

## Diagnostic Evidence

`ConversationGraphBuildState.lastError` remains unchanged and continues to
hold the raw diagnostic value. The controller's error capture, logs, persisted
failure records, support reporting, and developer diagnostics were not changed.

The boundary is now explicit:

```text
human headline
    bounded phase-neutral truth

diagnostics
    raw error preserved
```

## Gate Behavior

The same fixed sentence is used while either active Gate state remains visible:

- `buildingGraph`;
- `reimportBuildingGraph`.

The existing preparation precedence is preserved. While the Gate owns
`importing`, **Preparing setup…** remains authoritative even if the keep-alive
controller still contains a failed state from an older attempt.

No Gate/controller handoff, failure persistence, environment invalidation,
stable failure presentation, automatic recovery, retry, or reset behavior was
changed.

## Verification Coverage

Focused coverage proves that:

- a deliberately technical raw error is absent from the first-run active
  progress headline;
- direct reimport uses the same bounded headline;
- the controller state still retains its raw technical error;
- preparation still overrides stale controller failure;
- running and successful progress presentations remain unchanged.

The stable failure content audited in document 30 remains unchanged and is
reserved for later, separately reviewed slices.

## Deviations From Audit 30

None. This implementation is limited to the single presentation correction
recommended by the audit.
