Work on branch `Ftr.archive-recovery`.

This prompt is PRE-APPROVED for implementation. Begin with the required timing/projection audit, then proceed directly with the bounded corrections below unless truthful progress would require materially changing the import algorithm or database strategy. In that case, implement the responsiveness fixes and any zero-cost truthful progress improvements, then stop and report the architectural limitation.

Suggested prompt name:

`prompts/34-MAC-MESSAGES-IMPORT-RESPONSIVENESS-AND-REAL-PROGRESS.MD`

## Purpose

Manual staging validation of Prompt 33 showed that the import journey is now structurally correct and much easier to understand:

- ready state remained stable;
- Cancel ownership is correct;
- all real import/projection stages appeared;
- terminal completion behavior improved;
- successful import no longer produces an inappropriate orange reference.

Two important UX problems remain.

### Problem 1 — Add action still feels unresponsive

The user clicked:

`Add Messages to MessageLens`

and observed:

- no perceptible rollover/hover effect;
- no perceptible pressed/click effect;
- approximately 1–2 seconds before the UI visibly changed.

The result feels like clicking static text.

This is true even though the implementation record states that the action uses the established MessageLens primary button component and that the workflow publishes `importingArchive` before yielding one event-loop turn.

Manual observation therefore overrides assumptions from component architecture: the feedback is not perceptible enough in this actual composition.

### Problem 2 — long graph-projection units still feel stalled

The new graph instrumentation exposes five real units:

1. Participants
2. Conversations
3. Messages
4. Attachments
5. Relationships

This is a major improvement.

However, the first several units — especially the long-running work within `Preparing conversations for browsing` — can remain visually unchanged for many seconds.

A row such as:

`Messages · 2 of 5`

may sit unchanged long enough that the user still wonders whether MessageLens is progressing.

The current implementation record explicitly states that the individual projectors expose no within-projector denominator.

This task should determine whether useful, truthful finer progress is actually available from the work those projectors already perform.

## Governing rule

Do not build progress theater.

A progress bar or changing numeric display is desirable only when backed by real work units and a real denominator.

Do not:

- derive progress from elapsed time;
- estimate completion;
- increment counters on timers;
- map the ready-state `New to MessageLens` count onto graph projection unless it is genuinely the projector's workload;
- replace efficient set-based database operations with slow row-by-row work merely to animate progress.

Truth and performance take priority.

## First audit — authorization-to-first-paint latency

Instrument/test the current import authorization path precisely.

Measure or otherwise establish the sequence:

1. pointer enters primary button;
2. hover presentation;
3. pointer down / pressed presentation;
4. action callback invoked;
5. workflow publishes import-operation state;
6. Flutter schedules/builds new center presentation;
7. first import-operation frame is painted;
8. mutation coordinator begins admitted work;
9. first source-import observation is emitted.

The important user-facing interval is:

**button activation → first visibly changed frame**

Determine why this remains approximately 1–2 seconds in manual use despite the existing event-loop yield.

Do not guess.

Investigate whether the delay arises from:

- button/component visual styling;
- synchronous work before state publication;
- synchronous Riverpod/provider invalidation;
- coordinator acquisition;
- expensive presentation computation;
- event-loop scheduling;
- source database opening;
- another operation.

## Fix button affordance

The primary action must visibly behave as an interactive control.

Reuse established MessageLens/macOS components and tokens.

Ensure the user can perceive:

- hover;
- pressed/down;
- disabled state while authorization/import transition owns the action.

Do not add flashy animation.

Do not add Historical-Archives-specific arbitrary colors.

If the current shared primary button technically has hover/pressed states but they are too subtle to perceive here, identify why and use the smallest established stronger treatment consistent with other MessageLens controls.

Manual acceptance criterion:

> Before the import begins, I can tell from the button itself that my pointer is over it and that my click was registered.

## Immediate semantic transition

After activation, the ready-state screen should disappear as close to immediately as practical.

Target sequence:

pressed button  
→ import presentation state published  
→ import-operation surface paints  
→ first real stage appears  
→ admitted work proceeds.

Do not require the first service observation before showing that the operation has begun.

It is truthful to display the operation shell immediately after the human has authorized the import and the workflow has entered the admitted import path.

For example:

**Adding this Messages folder to MessageLens.**

ADDING MESSAGES FOLDER

Adding messages from this folder Waiting/Starting

Then the first real service observation changes that row to Working.

Use current presentation grammar rather than inventing a fake completed stage.

The user must never spend 1–2 seconds staring at the still-enabled ready screen after clicking Add.

## Second audit — time each graph unit

Measure the real duration of:

- Participants;
- Conversations;
- Messages;
- Attachments;
- Relationships.

Use isolated test fixtures, instrumentation, debug timing, or another non-production method.

Do not mutate real staging or production data.

Report which units account for the perceptually long wait.

Do not assume `Messages` is the only expensive unit.

## Inspect each long projector

For every unit taking perceptually significant time, inspect its implementation.

Determine whether it works via:

A. a known collection/batch iteration where both:

- total work count is known before execution;
- completed count can be observed cheaply;

B. multiple large SQL statements with meaningful boundaries;

C. one set-based SQL operation / transaction with no incremental progress callback;

D. another mechanism.

For each projector report:

- actual unit of work;
- whether a trustworthy total exists;
- whether a trustworthy completed count exists during execution;
- cost/risk of publishing progress;
- whether observation can be added without altering algorithmic behavior.

## Important denominator distinction

Do NOT assume:

`New to MessageLens = 2,369`

is the denominator for graph projection.

That number is a GUID-based comparison used for the human import decision.

The graph projector may process:

- all 8,882 source-scoped historical messages;
- the complete combined graph;
- another source-specific set;
- database-level sets unrelated to the ready-state comparison.

Use the actual projector workload.

If a truthful denominator is 8,882, use 8,882.

If it is approximately 145,000 combined graph rows, use that.

If there is no meaningful denominator, say so.

## Preferred finer progress

For any long projector that naturally knows completed/total work, expose it through the smallest typed observation extension.

Examples only if truthful:

`Messages                  3,412 / 8,882`

`Conversations               143 / 612`

or a progress bar driven by exactly the same numerator/denominator.

The display should visibly change often enough to reassure the user that work is continuing.

## Count versus progress bar

Prefer the clearest human presentation.

A changing raw count is excellent evidence:

`4,121 / 8,882`

A progress bar may accompany it if:

- numerator and denominator are exact;
- progress is monotonic;
- the visual does not imply a time-to-completion estimate.

Do not show a percentage alone if counts are more informative.

A bar represents proportion of completed work units, not elapsed time.

## Update frequency

If record-level progress exists, do not publish Riverpod/UI updates for every individual row if that harms performance.

Use a bounded real-work batching strategy, for example publishing:

- every N processed records;
- every completed existing batch;
- another naturally bounded unit.

The counter must still derive from actual completed work.

Do not use a wall-clock timer to fabricate movement.

If the operation processes 100,000 rows, updating every few hundred/thousand rows may be sufficient.

Choose the smallest approach that remains visibly alive without materially slowing the operation.

## Do not damage database performance for UI progress

This is critical.

If a long projector is currently implemented as an efficient SQLite operation such as:

`INSERT INTO ... SELECT ...`

and SQLite does not expose meaningful progress through the current API, do not replace that operation with thousands of Dart-side inserts merely to animate a bar.

In that case:

- preserve the efficient operation;
- retain the truthful coarse projector row;
- consider whether real statement-level sub-boundaries exist;
- document that finer progress is unavailable without architectural/performance cost.

## Possible hybrid presentation

If some projectors have real numerical progress and others do not, mixed instrumentation is acceptable.

Example:

Participants Done
Conversations Done
Messages 4,121 / 8,882
Attachments Waiting
Relationships Waiting

Do not force every row to have the same presentation shape.

Truthful asymmetry is preferable to fake uniformity.

## Graph-unit completion semantics

Preserve the five established real units.

Do not discard them merely because finer progress becomes available inside one or more.

Conceptually:

Preparing conversations for browsing

Participants ✓
Conversations ✓
Messages 4,121 / 8,882
Attachments Waiting
Relationships Waiting

When Messages completes:

Messages ✓

then Attachments begins.

## Keep top-level three-stage story

Preserve the existing larger import stages:

1. Adding messages from this folder
2. Preparing conversations for browsing
3. Checking that import finished

The five projector units are Directed Instrumentation nested inside stage 2.

Do not flatten everything into an overwhelming 7–10 row permanent dashboard unless current composition genuinely requires it.

Use hierarchy.

## Stable UI during progress observations

New fine-grained observations must not recreate the earlier ready-state flicker or cause controls/stages to vanish.

Observation publication should update only the relevant progress evidence.

It must not:

- reclassify the presentation context;
- cause Add/Details to reappear during import;
- invalidate Historical Archives into hub;
- trigger Onboarding;
- cause cartouche membership to appear early.

## Completion dwell

Preserve the existing 750 ms all-Done dwell.

Do not extend it merely because progress now has more granularity.

The completed state is already working conceptually.

## Success cartouche

Preserve:

- new cartouche appears only after terminal success;
- no orange reference;
- no automatic blue selection;
- hub restores;
- center clears.

## Cancel

Preserve Prompt 33 behavior:

ready candidate  
→ Cancel  
→ virgin hub  
→ center empty  
→ sidebar chooser available.

Do not modify it in this task.

## Failure

If fine-grained progress exists and the long projector fails:

- preserve last truthful completed count;
- mark the owning projector/stage Failed;
- do not round count up to total;
- do not imply success from a full-looking bar unless the actual operation has completed successfully.

Terminal success remains governed by workflow completion, not merely progress count.

## Tests

Add/update focused tests covering the following behaviors with the smallest clear test set.

### Authorization responsiveness

1. primary Add control exposes visible hover state through the actual component used;

2. primary Add control exposes visible pressed state;

3. activation immediately publishes import-operation presentation state;

4. ready-state controls cannot remain the owning presentation while admitted import work begins;

5. import-operation shell can render before first service observation;

6. double activation remains mechanically impossible;

7. the fix introduces no arbitrary fake delay.

### Graph-unit timing/audit

8. the five real graph units remain the canonical coarse sequence;

9. any added finer progress is derived from actual projector workload;

10. ready-state new-message count is not reused as a denominator unless code proves it equals actual projector workload;

11. any displayed total is known from real data;

12. any displayed completed count represents completed work;

13. progress is monotonic;

14. no elapsed-time-derived progress exists;

15. no timer increments counters.

### Performance

16. fine-grained progress publication is batched/bounded where appropriate;

17. efficient set-based SQL operations are not replaced by row-by-row Dart work solely for presentation;

18. tests preserve existing import correctness/performance architecture.

### Presentation

19. top-level three-stage journey remains intact;

20. stage-2 projector units remain visible;

21. numerical progress appears only where supported;

22. units without a truthful denominator remain coarse Working/Waiting/Done;

23. completion dwell remains 750 ms;

24. success returns to hub without orange/blue reference.

### Regression

25. ready-state stability remains fixed;

26. Cancel remains correct;

27. duplicate-folder orange behavior remains correct;

28. invalid-folder behavior remains correct;

29. removal instrumentation remains correct;

30. source-1/current-Mac data remains protected;

31. DateConverter invariant remains intact;

32. legitimate import maintenance does not trigger Onboarding;

33. Tracks A–E and sidebar layout remain unchanged.

## Safety

Do not perform the real staging import yourself.

Use tests/temp stores/fixtures for execution tracing.

Do not modify:

- production MessageLens data;
- staging archive;
- donor folders;
- attachment payloads.

The human will rerun the 2012 import manually.

## Documentation

Create the next Feature 26 implementation record under `responses/`.

Document:

- measured/observed authorization-to-first-paint sequence;
- cause of the remaining 1–2 second perceived dead interval;
- button hover/pressed correction;
- exact five projector durations or relative bottleneck evidence;
- implementation strategy for each expensive projector;
- actual denominator availability for each;
- any numerical progress seam introduced;
- batching/update strategy;
- any projector for which finer progress was deliberately rejected and why;
- confirmation that database algorithms were not degraded merely for UI feedback;
- preserved completion/success semantics.

Update version/changelog according to repository rules.

## Verification

Run:

- focused Historical Archives import/presentation tests;
- graph projector tests;
- performance-sensitive regression tests where available;
- Settings tests;
- button/component tests;
- Onboarding/maintenance regressions;
- architecture tripwires;
- `flutter analyze`;
- formatting;
- `git diff --check`;
- macOS debug build if required.

Commit and push if clean.

STOP after this responsiveness/progress refinement.

Do not proceed into MessageLens-folder ingestion yet.

## Report back with

- exact cause of the 1–2 second post-click dead feeling;
- exact button interaction correction;
- measured/relative durations of Participants, Conversations, Messages, Attachments, Relationships;
- actual workload/denominator of each long projector;
- which units gained numerical progress;
- exact human-facing presentation;
- whether a progress bar, raw count, or both were used;
- update batching strategy;
- which units remain coarse and why;
- confirmation that no database operation was made less efficient merely for animation;
- manual staging instructions.

Acceptance standard:

> Clicking Add should feel immediately acknowledged, and any operation that takes long enough to make the user wonder whether MessageLens has stalled should expose real changing evidence whenever the underlying work can truthfully provide it.
