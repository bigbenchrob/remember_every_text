This audit found the nicest possible outcome: we already have the right preparation surface; it simply appears too late.

The meaningful invisible gap is reset. Today, admission, the current FDA-readiness lookup, and the entire derived-data reset happen while the readiness screen and still-enabled Import My Messages button remain visible. Only after reset completes does OnboardingStatus.importing make the blocking progress overlay appear. 25-PRE-OVERLAY-IMPORT-START-ACKNOWLEDGEMENT-AUDIT.md

The audit’s recommended boundary is very precise:

After mutation admission succeeds and the current FDA-readiness guard passes, publish the existing importing state, render Preparing setup…, then perform reset. 25-PRE-OVERLAY-IMPORT-START-ACKNOWLEDGEMENT-AUDIT.md

That is appealing because it requires no new state, no new component, no new copy, and no operation-layer change. The existing overlay is already truthful while reset is happening: controller idle + Preparing setup… + indeterminate progress + keep-open guidance. 25-PRE-OVERLAY-IMPORT-START-ACKNOWLEDGEMENT-AUDIT.md

There are only two important details to preserve. First, admission denial should not show preparation because the operation never became ours. Second, FDA false should continue to yield immediately to the FDA surface. The preparation overlay begins only after both of those gates have passed. 25-PRE-OVERLAY-IMPORT-START-ACKNOWLEDGEMENT-AUDIT.md

And if reset throws, the newly visible preparation state must be cleared before the existing error continues upward; otherwise we would replace one misleading state with another. 25-PRE-OVERLAY-IMPORT-START-ACKNOWLEDGEMENT-AUDIT.md

One other useful finding: once we show importing earlier, it must override stale terminal controller state when choosing the headline. Otherwise a retry could briefly say Browsing data ready or show an old error while a fresh reset is underway. 25-PRE-OVERLAY-IMPORT-START-ACKNOWLEDGEMENT-AUDIT.md

So yes: ready for implementation.

Implement the single bounded slice recommended by:

25-PRE-OVERLAY-IMPORT-START-ACKNOWLEDGEMENT-AUDIT.md

The goal is:

Show the existing Preparing setup… progress overlay during the derived-data reset that precedes first-run import/build, instead of leaving the readiness screen visible until reset finishes.

Do not add a new Gate state.

Do not add a new progress component.

Do not change reset behavior.

Do not change mutation admission.

Do not change FDA behavior.

Do not change the controller or orchestrator.

⸻

1. Current ordering

Today the first-run path is conceptually:

Gate guard
-> mutation admission
-> current FDA-readiness guard
-> reset derived data
-> publish OnboardingStatus.importing
-> paint progress overlay
-> publish buildingGraph
-> controller run

Change only the presentation-state ordering so that it becomes:

Gate guard
-> mutation admission
-> current FDA-readiness guard
-> publish OnboardingStatus.importing
-> paint progress overlay
-> reset derived data
-> existing controller/build sequence

The operation itself remains unchanged.

⸻

2. Preserve admission boundary

Do not show the preparation overlay before mutation admission succeeds.

If mutation admission is denied:

readiness surface remains visible
no preparation state is published

Do not change denial handling in this slice.

⸻

3. Preserve FDA boundary

Do not show preparation before the current FDA-readiness guard passes.

If the guard is false:

Gate -> awaitingFda
FDA Presence presentation takes over
reset does not begin

No preparation frame should appear first.

Do not change how that provider is computed or cached in this slice.

⸻

4. Publish existing preparation status before reset

After admission and FDA guard success, set the existing:

OnboardingStatus.importing

before invoking:

MessageDataResetService.resetDerivedData()

Use the existing painted-frame mechanism if required so the blocking overlay becomes visibly established before potentially slow reset work begins.

Do not introduce a replacement status such as:

preparing
resetting
startingImport

The existing importing status is already the presentation vehicle for Preparing setup….

⸻

5. Preparation headline must beat stale controller state

The graph-build controller is keep-alive and may still contain:

succeeded
failed

from a previous attempt.

While Gate status is the preparation state for a newly admitted attempt, the progress presenter must show:

Preparing setup…

regardless of stale terminal controller state.

Once Gate reaches the actual controller-running period, controller state may again determine:

Building browsing data…

and terminal state.

Do not reset controller state merely for presentation convenience unless existing architecture already requires that.

Prefer presentation precedence:

Gate says preparation
-> Preparing setup
otherwise
-> derive from controller state

Use the smallest readable implementation.

⸻

6. Reset failure unwind

Because preparation is now visible before reset, handle reset failure explicitly.

If reset throws:

1. clear the ephemeral importing workflow override;
2. return the Gate to the same existing readiness state/presentation it would have shown before this slice;
3. preserve the thrown error behavior.

Do not:

- persist a new pipeline failure;
- invent a reset-failure screen;
- swallow the exception;
- route to controller failure handling;
- add recovery behavior.

This slice only prevents the preparation overlay from remaining falsely active after reset has failed.

⸻

7. Preserve successful continuation

After reset succeeds, continue through the existing lifecycle.

Do not alter:

buildingGraph status
controller runOnce
source import
graph projection
completion
failure persistence
automatic recovery

The visible result should simply become one continuous overlay:

Preparing setup…
during reset
Building browsing data…
once controller runs

with the same indeterminate indicator and keep-open guidance.

⸻

8. Repeated-start protection

Do not add a new lock.

Preserve:

- Gate status guard;
- ArchiveMutationCoordinator exclusion;
- controller in-flight protection.

Publishing importing earlier should naturally shorten the interval during which the visible import action could still pass the Gate guard.

Correctness must continue to depend on mutation coordination, not UI timing.

⸻

9. First-run only

Apply this slice only to the active first-run:

startImportAndGraphBuild()

Do not automatically extend it to:

startReimport()
confirmResetAndPrepareReimport()
automatic recovery

Audit 25 identified similar gaps there, but they have separate journey contracts.

Do not broaden the slice.

⸻

10. Preserve current progress copy

Keep:

Preparing setup…
Building browsing data…

and the shared guidance:

Keep MessageLens open while it prepares your messages. You can use other apps in the meantime.

Do not add reset-specific language such as:

Deleting old databases…
Resetting data…
Cleaning files…

Those are implementation details and add no useful human decision.

⸻

11. Focused tests

Add tests proving at least:

Preparation visible during reset

Use a controllable reset Future/completer.

After admission and FDA success but while reset is still pending, prove:

Gate status = importing
progress overlay visible
headline = Preparing setup…
controller has not started

FDA false

Prove:

no preparation overlay
awaitingFda path remains
reset not invoked

Reset failure

Have reset throw.

Prove:

preparation override cleared
readiness presentation restored
error still propagates
controller does not start

Stale controller succeeded

Seed controller with a previous successful state.

Start a new first-run attempt with reset pending.

Prove headline is:

Preparing setup…

not:

Browsing data ready

Stale controller failed

Same for prior failure.

No raw old error may replace preparation headline.

Reset success

Prove transition continues into:

Building browsing data…

and ordinary successful lifecycle.

Double start

Prove repeated invocation does not create duplicate reset/build execution.

⸻

12. Documentation

Create:

26-PRE-RESET-PREPARATION-PROGRESS-IMPLEMENTATION.md

Record:

1. old ordering;
2. new ordering;
3. why preparation begins only after admission/FDA guard;
4. stale-controller precedence rule;
5. reset-failure unwind;
6. confirmation that reset/build mechanics are unchanged;
7. tests;
8. deviations from Audit 25.

Update:

- 00-START-HERE.md
- package index
- DOCUMENTATION_PASS_LOG.md

Do not rewrite Audit 25.

⸻

13. Verification

Run:

- focused Gate/reset/progress tests;
- onboarding overlay progress tests;
- OnboardingGate tests;
- Environment Readiness tests;
- controller tests;
- complete Onboarding tests;
- architecture tripwires;
- flutter analyze;
- formatting;
- git diff --check;
- debug macOS build.

Do not launch against the production archive.

⸻

Hard constraints

Do not:

- add a new Gate status;
- change mutation policy;
- change reset semantics;
- change FDA provider behavior;
- fix the cached FDA-readiness concern;
- change controller lifecycle;
- change progress telemetry;
- add cancellation;
- add persistence;
- modify Presence;
- change reimport/reset-message-data journeys;
- redesign reset failure reporting;
- solve the nested mutation-policy caveat.

If implementation appears to require any of those, stop and explain why.

⸻

Success criterion

Immediately after a valid first-run setup attempt is admitted and the current FDA-readiness guard passes, the human should see:

Preparing setup…
[indeterminate activity]
Keep MessageLens open while it prepares your messages.
You can use other apps in the meantime.

while reset is already underway.

Then, without changing screens:

controller starts
-> Building browsing data…

If reset fails, that preparation surface disappears and the existing readiness state returns.

The user should never again press Import My Messages and stare at an apparently idle readiness screen while MessageLens is already deleting and preparing its derived data.

This is one of those satisfying fixes where the architecture was already holding the answer; the state transition was simply in the wrong place.
