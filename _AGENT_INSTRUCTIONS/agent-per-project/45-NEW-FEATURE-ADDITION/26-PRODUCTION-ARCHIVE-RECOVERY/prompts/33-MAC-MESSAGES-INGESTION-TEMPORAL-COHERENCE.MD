Work on branch Ftr.archive-recovery.

This prompt is PRE-APPROVED for implementation. Begin with the required investigation, then proceed directly with the bounded corrections below without stopping for another approval, provided the investigation confirms the assumptions and hard invariants.

Stop only if truthful progress for the long graph-preparation stage requires materially broadening architecture or changing import semantics. In that case, implement the other bounded corrections and report the progress limitation separately.

Suggested prompt name:

prompts/33-MAC-MESSAGES-INGESTION-TEMPORAL-COHERENCE.MD

PURPOSE

Manual staging validation of the new Mac Messages Narrator + Directed Instrumentation ingestion journey succeeded mechanically:

- the 2012 folder was accepted;
- import completed;
- the 2012 cartouche appeared;
- heatmaps again extended through 2012.

The new presentation is dramatically better than the old control panel.

However, manual observation exposed several temporal/ownership problems that make the journey feel less coherent than it should.

This task should make the import journey temporally truthful and perceptually continuous:

stable decision
→ unmistakable authorization
→ immediate operation transition
→ visible forward progress
→ perceptible completion
→ quiet virgin hub

MANUAL FINDINGS

1. Ready-state secondary action has the wrong ownership

Current ready state shows:

- Add Messages to MessageLens
- Choose Another Folder

The second action is wrong.

Once a valid candidate has earned the center panel, the user is inside one Add workflow.

The center panel may:

- authorize this candidate;
- abandon this candidate.

It should not take over the sidebar’s responsibility for initiating another folder-selection attempt.

Replace:

Choose Another Folder

with:

Cancel

Cancel means:

abandon this current candidate and return to the virgin Historical Archives hub.

After Cancel:

- add context is cleared;
- center panel becomes empty;
- normal sidebar Choose Messages Folder… action returns;
- no folder chooser automatically opens;
- no source is selected;
- no orange/blue correspondence occurs.

The sidebar owns starting another attempt.

2. Ready-state controls transiently disappear and reappear

During manual review, while the user was doing nothing, both:

- Add Messages to MessageLens
- Details disclosure

disappeared for several seconds and then reappeared.

This is a BUG.

Investigate the exact provider/workflow invalidation causing a stable valid candidate to temporarily project another presentation state.

Once the workflow has reached a truthful readyToAdd equivalent, incidental provider refreshes must not make the decision controls disappear unless the underlying candidate truth has genuinely changed.

Do not solve this by caching stale widget output blindly.

Trace the state transition and correct the presentation/workflow ownership.

Required invariant:

A valid ready-to-add candidate remains visibly ready to add until the human authorizes it, cancels it, navigates away, or a genuine source/state change invalidates it.

Ordinary provider rebuilds/read-model refreshes cannot revoke the decision surface temporarily.

3. Add Messages button feels like static text

Manual behavior:

The user clicks:

Add Messages to MessageLens

and initially sees no obvious response.

There is insufficient hover/pressed/click feedback, and more importantly the center panel does not transition perceptibly quickly enough into the import-operation state.

This leaves the human wondering:

Did I actually click it?

Audit both:

A. button interaction styling;

B. event-loop/execution ordering after authorization.

Use established MessageLens/macOS button interaction states.

Do not invent flashy animation.

The button should have ordinary perceivable hover/pressed feedback.

More importantly:

after authorization, transition presentation state to addingArchive / equivalent immediately and give Flutter an opportunity to render the operation surface before expensive synchronous work monopolizes execution.

The desired sequence is:

button press visibly acknowledged
→ ready-state controls disappear
→ Narrator/import instrumentation appears
→ first real stage becomes Working
→ expensive work proceeds.

Do not add an arbitrary delay.

If current code begins expensive synchronous work before the operation state can paint, introduce the smallest legitimate async/event-loop boundary required to let the already-true state render.

Do not fake work.

4. Long Preparing conversations for browsing stage

Manual observation:

Preparing conversations for browsing

remains Working for approximately 30 seconds.

This is much better than a generic spinner because the user knows what phase is active, but 30 seconds is still long enough to wonder whether progress has stalled.

FIRST audit the exact implementation behind this stage.

Determine whether it consists of smaller real units such as:

- projector stages;
- conversations;
- messages;
- batches;
- graph nodes/edges;
- tables;
- source chunks;
- another meaningful countable unit.

Determine whether the execution code already knows:

- current completed units;
- total units;

or could expose those facts through a small bounded observation addition.

Preferred solution A: real sub-stages

If this 30-second phase already consists of several meaningful sequential operations with observable boundaries, expose a small number of human-comprehensible real sub-stages.

Do not over-fragment.

Preferred solution B: real numerical progress

If the phase is conceptually one operation but processes a measurable set with a real denominator, expose continuously changing numerical evidence.

Examples ONLY if semantically true:

Preparing conversations for browsing 18,432 / 96,011

or:

Preparing conversations for browsing 412 / 1,203 conversations

A percentage may be derived only from a real numerator/denominator, but raw counts may be preferable.

The important human signal is:

the number is changing, therefore the machine is making forward progress.

Fallback

If the underlying operation exposes neither truthful sub-boundaries nor a meaningful measurable denominator, retain the single Working row.

Do NOT:

- invent percentages;
- increment fake counters;
- derive progress from elapsed time;
- estimate completion;
- animate pseudo-progress.

Report the limitation.

5. Terminal stage disappears before the human sees it complete

Manual observation:

The final:

Checking that import finished

stage completes so quickly that the center panel clears before the user can perceive the final all-Done state.

Do NOT impose artificial minimum durations on every execution stage.

Fast stages should remain fast.

Instead distinguish:

execution duration

from:

completed-state presentation dwell

Once the real terminal stage has completed successfully:

- render all real stages as Done;
- preserve that fully completed instrumentation state for a brief bounded perceptual dwell;
- then resolve automatically to the hub.

Use approximately 750 ms as a starting dwell, within a reasonable 500–1000 ms range.

This delay occurs AFTER the real operation has completed.

It must not:

- delay database work;
- pretend a stage is still running;
- keep a spinner active;
- alter success semantics.

The UI is simply allowing the human visual system to perceive:

✓
✓
✓

before the operation surface disappears.

This is permitted presentation timing, not fake progress.

6. Newly created cartouche must NOT receive orange correspondence

Manual success currently:

- new cartouche appears;
- cartouche receives orange referential highlighting;
- highlight fades.

This is semantically wrong.

Orange means:

“That other thing over there is what I am referring to.”

After successful import, the newly created cartouche itself is already obvious evidence of the result.

Nothing needs to point at it.

Therefore terminal success should be:

all stages Done
→ bounded completed-state dwell
→ add journey ends
→ virgin hub
→ new cartouche simply exists under Folders Already Added in its ordinary unselected appearance
→ center panel empty.

No orange.

No blue.

No pulse.

No fade.

No completion pointing gesture.

Remove only the success-created reference occurrence.

Preserve orange behavior for the genuinely appropriate duplicate-folder case.

TEMPORAL MECHANICAL IMPOSSIBILITY

Treat temporal coherence as another application of mechanical impossibility.

At each point, only one truthful temporal state may own the presentation.

readyToAdd

Must show stable candidate evidence and:

- Add Messages to MessageLens
- Cancel
- Details as appropriate.

Cannot spontaneously become visually non-ready due to incidental refresh.

authorization transition

Once Add is activated:

- ready controls cease to own the UI;
- operation state owns the center panel immediately;
- import cannot be running invisibly behind a ready-state screen.

addingArchive

Must show only:

- import Narrator;
- real Directed Instrumentation.

Cannot show:

- ready controls;
- candidate-changing controls;
- selected-source management;
- old giant control panel.

terminal success dwell

Operation is actually complete.

Presentation shows:

- every real stage Done;
- no Working spinner;
- no future Waiting state.

This state exists only long enough for perception.

hub

After dwell:

- add context gone;
- center empty;
- normal sidebar controls restored;
- new cartouche visible ordinarily.

No stale completion/reference state survives.

READY-STATE PRESENTATION

Preserve the currently successful evidence presentation unless investigation finds a concrete defect.

It should continue to communicate:

- message count;
- date range;
- new-to-MessageLens count;
- already-represented count;
- current valid candidate meaning.

Do not redesign this screen broadly.

This task owns temporal behavior and the Cancel responsibility correction.

DETAILS

Details should remain stable in readyToAdd.

Its unexplained disappearance/reappearance is part of the ready-state bug.

Do not make Details permanently expanded.

Do not move technical diagnostics back into the ordinary journey.

SIDEBAR DURING ACTIVE CANDIDATE

Preserve the established responsibility:

While addArchive / candidate context is active:

- sidebar add chooser is hidden;
- center owns this attempt.

After Cancel:

- hub restored;
- sidebar chooser returns.

After import begins:

- sidebar does not offer a competing chooser.

After success:

- hub restored;
- sidebar chooser returns;
- new cartouche appears normally.

CARTOUCHE APPEARANCE DURING IMPORT

Preserve the rule that the new source does not become an ordinary Folders Already Added cartouche before terminal success.

Do not create it early merely to show progress.

Terminal membership remains based on finalized successful source truth.

PARTIAL FAILURE

Preserve the partial-failure protections from Prompt 32.

The new completed-state dwell must occur ONLY after true terminal success.

A failed stage:

- remains Failed;
- does not enter success dwell;
- does not create an ordinary successful cartouche;
- does not return silently to hub.

If numerical progress is added to the long graph-preparation stage, failure must preserve the last truthful observed count without implying completion.

NAVIGATION / SESSION SAFETY

All new presentation timing must be guarded by current Historical Archives presentation session/occurrence.

If the user navigates away during:

- ready state;
- import;
- success dwell;

a late Future/timer must not resurrect Historical Archives presentation after return.

In particular, the ~750 ms success-dwell timer must not clear or mutate a newer presentation session.

Reuse the session/occurrence pattern already established for transient reference/modal timing.

BUTTON INTERACTION

Inspect the actual widget used for:

Add Messages to MessageLens

Ensure it participates in established MessageLens/macOS:

- hover;
- pressed;
- enabled/disabled

visual states.

Do not introduce custom button colors merely for this screen.

If the current widget already supports those states but they are not visible because of styling, fix the styling through established tokens/component usage.

TRACKS

Preserve Historical Archives Tracks A–E and current center alignment.

Do not modify the sidebar spacing/layout in this task.

REMOVE OLD SUCCESS REFERENCE ONLY

Do not globally remove or redesign orange correspondence.

Preserve:

duplicate already-added folder
→ modal
→ dismissal
→ gentle transient orange reference to existing cartouche.

Remove:

successful new import
→ orange reference.

These are semantically different.

TESTS

Add/update focused tests proving at minimum:

Cancel ownership

1. ready state shows Cancel instead of Choose Another Folder;
2. Cancel returns directly to hub;
3. Cancel does not reopen chooser;
4. Cancel performs no import mutation;
5. sidebar chooser reappears after Cancel;
6. center becomes empty.

Stable ready state

7. valid ready candidate remains ready through incidental provider/read-model refreshes;
8. Add Messages action does not disappear/reappear without a genuine state transition;
9. Details does not disappear/reappear without a genuine state transition;
10. genuine candidate invalidation may still revoke ready state where appropriate.

Authorization responsiveness

11. Add action has established hover/pressed feedback;
12. authorization immediately transitions presentation to import context;
13. expensive import work does not begin invisibly behind the ready-state composition;
14. first instrumentation state can render before long synchronous work;
15. Add cannot be triggered twice during transition/import.

Long-stage progress

16. any newly exposed sub-stage corresponds to a real execution boundary;
17. any numerical progress has a real numerator;
18. any numerical progress has a real denominator;
19. numerical progress is monotonic according to the underlying operation;
20. no timer advances progress;
21. no elapsed-time estimate masquerades as work progress;
22. if no truthful finer progress exists, the fallback remains one honest Working stage.

Terminal completion

23. terminal stage really completes before success dwell begins;
24. success dwell shows every stage Done;
25. no spinner remains during success dwell;
26. dwell is bounded approximately 500–1000 ms;
27. dwell does not delay execution itself;
28. after dwell, hub restores automatically;
29. center becomes empty;
30. no Done/Next button exists.

Cartouche semantics

31. new cartouche does not appear before terminal success;
32. new cartouche appears after terminal success;
33. successful new cartouche receives no orange reference;
34. successful new cartouche receives no automatic blue selection;
35. duplicate-folder orange behavior remains unchanged.

Session/failure regression

36. stale dwell completion cannot affect a newer presentation session;
37. navigation away prevents late presentation resurrection;
38. partial failure never enters success dwell;
39. partial failure never creates a normal successful cartouche;
40. removal Directed Instrumentation remains unchanged;
41. invalid-folder behavior remains unchanged;
42. Tracks/sidebar layout remain unchanged;
43. Onboarding remains suppressed during legitimate admitted maintenance.

Cover these with the smallest clear focused test set; do not create one test method per numbered item mechanically.

SAFETY

Do not perform a real GUI staging import.

Use fixtures/temp databases for automated verification.

Do not mutate:

- production data;
- staging archive;
- donor folders;
- attachment payloads.

The human will rerun the 2012 staging import manually.

DOCUMENTATION

Create the next Feature 26 implementation record under responses/.

Document:

1. cause of transient ready-state control disappearance;
2. correction that stabilizes ready state;
3. Cancel ownership semantics;
4. button responsiveness/event-loop correction;
5. audited internals of Preparing conversations for browsing;
6. finer progress observations added, or exact reason unavailable;
7. success-dwell semantics and duration;
8. distinction between truthful execution timing and perceptual completion dwell;
9. removal of success-created orange reference;
10. preserved duplicate-folder orange semantics;
11. session/timer safety;
12. confirmation that import/removal/source semantics remain unchanged.

Update version/changelog according to repository rules.

VERIFICATION

Run:

- focused Historical Archives import/presentation tests;
- source-scoped import/graph tests;
- Settings tests;
- session/navigation tests;
- button/component tests as relevant;
- Onboarding/maintenance regressions;
- architecture tripwires;
- flutter analyze;
- formatting;
- git diff --check;
- macOS debug build if repository rules require it.

Commit and push if clean.

STOP after this temporal-coherence refinement.

Do not proceed into MessageLens-folder ingestion.

REPORT

Report:

- cause of Add/Details disappearance;
- exact Cancel behavior;
- button feedback/render-boundary correction;
- exact internals of the long conversation-preparation stage;
- whether sub-stages or numerical progress were added;
- exact human-facing progress presentation;
- success dwell duration;
- confirmation that new-cartouche orange was removed;
- confirmation that duplicate-folder orange remains;
- manual staging-review instructions.

The governing acceptance standard is:

At no point during a valid import should the user have to wonder whether their click registered, whether MessageLens is still making progress, or whether the operation actually finished.
