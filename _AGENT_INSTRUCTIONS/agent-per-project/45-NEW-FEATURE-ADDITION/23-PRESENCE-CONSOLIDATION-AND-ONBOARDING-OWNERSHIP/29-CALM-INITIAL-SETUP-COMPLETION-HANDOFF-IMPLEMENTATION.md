---
tier: project
scope: calm-initial-setup-completion-handoff
owner: agent-per-project
last_reviewed: 2026-08-14
source_of_truth: code-and-doc
links:
  - ./28-INITIAL-SETUP-COMPLETION-SURFACE-AUDIT.md
  - ./27-ATTACHMENT-PRESERVATION-SAFETY-INVARIANT.md
  - ../../25-ONBOARDING-AND-ARCHIVE/ATTACHMENT-PRESERVATION-INVARIANT.md
tests:
  - test/essentials/onboarding/presentation/onboarding_overlay_progress_test.dart
  - test/essentials/onboarding/application/onboarding_gate_provider_test.dart
  - test/essentials/conversation_graph/application/conversation_graph_build_controller_provider_test.dart
---

# Calm Initial Setup Completion Handoff Implementation

## Result

The production completion surface now answers the human questions established
by [Audit 28](28-INITIAL-SETUP-COMPLETION-SURFACE-AUDIT.md): setup succeeded,
MessageLens is ready, and the existing action enters or returns to the app.

The final shared completion hierarchy is:

```text
success icon

MessageLens is ready

Your local browsing data is prepared.

Get Started
```

Direct reimport uses the same component and substitutes only:

```text
Done
```

## Previous Presentation

The previous primary surface displayed:

```text
Import Complete!

Imported
Projected
Text enriched

Get Started / Done
```

Those counters were literal `ConversationGraphBuildReport` facts, but they
described source-ledger insertion, Conversation Graph insertion, and one text-
recovery subset. Expected differences could look like incomplete work to a
human unfamiliar with the pipeline.

## Presentation Correction

`OnboardingOverlay` continues to map both `complete` and `reimportComplete` to
the existing private `_CompleteContent` component.

That component now:

- retains the themed success icon;
- uses **MessageLens is ready** as its result-oriented heading;
- adds **Your local browsing data is prepared.** as one bounded supporting
  sentence;
- retains 12 px between heading and supporting copy;
- retains 24 px between supporting copy and the action;
- keeps the existing **Get Started** / **Done** label distinction.

No new completion component, status, provider, design token, metric, or
presentation architecture was introduced.

## Diagnostic Data Preserved

The production `_GraphBuildSummaryMetrics` and `_MetricChip` presentation
helpers were removed because the primary completion surface no longer renders
technical counts.

No diagnostic data was deleted or weakened:

- `ConversationGraphBuildReport` is unchanged;
- import, projection, and enrichment result types are unchanged;
- controller `lastReport` behavior is unchanged;
- stage names and timings are unchanged;
- status logging is unchanged;
- the development Onboarding panel retains its diagnostic report metrics.

The production completion component no longer watches `lastReport` because it
has no human-facing use for that report.

## Handoff Behavior Preserved

The action still dispatches through `OnboardingOverlayActions.dismiss()` to
`OnboardingGate.dismiss()`.

The Gate still:

1. clears its process-local workflow override after the current frame;
2. selects `SidebarMode.messages`;
3. sets the process-local Gate state to `notNeeded`.

Neither action commits data. **Get Started** remains a deliberate first-run
human acknowledgement; **Done** remains the direct-reimport return action.

## Completion Durability Unchanged

No completion acknowledgement, final report, or success-screen state was made
durable. If MessageLens closes on the completion surface, the next launch still
derives readiness from the populated databases and opens normally without
replaying completion.

## Attachment-Preservation Boundary

The approved sentence describes MessageLens's local browsing representation.
It does not claim that:

- every attachment payload was locally available;
- every attachment was archived;
- cloud-evicted payloads are preserved;
- all source data is permanently reconstructible;
- Apple Messages data may be discarded.

Attachment archival behavior and the permanent
[Attachment Preservation Invariant](../../25-ONBOARDING-AND-ARCHIVE/ATTACHMENT-PRESERVATION-INVARIANT.md)
remain unchanged.

## Focused Tests

Production-overlay tests now prove for successful initial setup and direct
reimport:

- the success icon remains;
- **MessageLens is ready** is visible;
- **Your local browsing data is prepared.** is visible;
- the context-appropriate **Get Started** or **Done** action is visible;
- **Import Complete!**, **Imported**, **Projected**, and **Text enriched** are
  absent even while a successful final report remains available;
- no approved-forbidden attachment-preservation claim appears;
- pressing the action still dispatches dismissal through the existing Gate
  seam.

The real Gate lifecycle tests additionally prove that both completion actions
return the Gate to `notNeeded` and select the Messages sidebar. Controller
lifecycle tests continue to prove that successful reports remain available.

## Verification

- 22 focused completion and Gate tests passed.
- All 110 Onboarding tests passed.
- All 3 Conversation Graph build-controller tests passed.
- All 373 architecture tripwires passed.
- `flutter analyze` reported no issues.
- Targeted Dart formatting passed.
- `git diff --check` passed.
- A debug macOS build completed successfully without launching MessageLens or
  accessing the production archive.

The build retained the existing Xcode build-number diagnostic and
`volume_controller` privacy-manifest processing warning. Neither was introduced
by this slice.

## Deviations From Audit 28

None.

The development Onboarding panel intentionally retains technical metrics. Audit
28 identified developer diagnostics as an appropriate location for that
evidence; the approved implementation removed the counters only from the
ordinary production completion surface.
