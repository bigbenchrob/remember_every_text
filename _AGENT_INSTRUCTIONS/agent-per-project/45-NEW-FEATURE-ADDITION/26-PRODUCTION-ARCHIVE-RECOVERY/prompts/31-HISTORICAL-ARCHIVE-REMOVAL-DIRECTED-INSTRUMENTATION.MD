Work on branch `Ftr.archive-recovery`.

This prompt is PRE-APPROVED for implementation. Begin with the required execution audit, then proceed directly with the bounded implementation if the current removal path exposes clear, distinct real milestones. Stop only if truthful instrumentation would require materially broadening architecture or changing removal semantics.

Suggested prompt name:

`prompts/31-HISTORICAL-ARCHIVE-REMOVAL-DIRECTED-INSTRUMENTATION.MD`

This task is the next refinement of the existing Historical Archive removal journey.

## Manual review finding

The removal mechanics appear to work correctly, but the user experience is poor during the 10–20 second removal interval.

Observed behavior:

- confirmation modal works;
- Cancel works;
- Remove Folder begins removal;
- center panel shows essentially one generic `Working…` state;
- the user is left wondering whether the app is stalled;
- the archive cartouche disappears from the sidebar before the overall operation has visibly finished;
- selected-source management content and removal-progress content feel mixed together rather than forming a coherent journey.

The result is mechanically successful but experientially disorganized.

## Governing design principle

Use:

Narrator + Directed Instrumentation

Narrator provides meaning.

Directed Instrumentation provides truthful evidence of real work.

Do not use a generic long-lived spinner when the execution path contains meaningful sequential operations that can be observed directly.

Do not invent progress stages.

## First: audit the real removal execution sequence

Trace the current source-removal operation from confirmed removal through final success.

Identify the exact ordered operations already performed.

At minimum inspect whether the path contains distinct real boundaries corresponding to concepts such as:

- deleting/removing the selected source's imported facts;
- rebuilding/reprojecting browsing/conversation data from remaining sources;
- rebuilding search/heatmap/derived support structures;
- refreshing shared evidence/read models;
- final source-membership/readiness verification.

Do not assume these exact labels or count.

Use the implementation as source of truth.

For each actual step determine:

- where the step starts;
- where it completes successfully;
- whether it can fail independently;
- whether the workflow can truthfully publish that transition without moving execution ownership or duplicating work.

## Add the smallest typed removal-progress seam

If the operation already has clear sequential calls, expose them through a small Historical-Archives-owned typed progress model.

For example conceptually:

`HistoricalArchiveRemovalStage`

with values derived from the real execution path.

Do not build a generic application-wide progress framework.

Do not create percentages.

Do not infer progress from elapsed time.

Do not publish a stage before that stage actually begins.

Do not mark a stage complete until the real operation returns successfully.

A stage model should be presentation evidence only; removal execution remains owned by the existing service/workflow.

## Desired center-panel journey

Once the user confirms removal:

1. destructive modal closes;
2. selected-source management story disappears;
3. removal operation becomes the sole center-panel context;
4. Narrator appears briefly;
5. Directed Instrumentation displays the real stage sequence.

Representative Narrator:

**Removing this folder from MessageLens.**

Then, for example only if supported by the audit:

REMOVAL

Removing messages added from this folder ✓  
Updating your MessageLens history ✓  
Refreshing search and timeline views …  
Final check waiting

Use human-facing labels derived from actual operations.

Do not expose:

- source-scoped rows;
- ledger;
- graph projection;
- provider invalidation;
- FTS table names;
- mutation authority.

## No competing selected-source content while running

During removal, do not continue showing:

- “This is a Mac Messages folder”;
- message/date summary;
- More Details;
- Remove this folder…;
- existing-source management controls.

The operation owns the center panel while it is active.

This should feel like a journey, not like progress widgets pasted on top of an existing object page.

## Cartouche lifecycle

Do NOT remove the cartouche from `Folders Already Added` merely because the source-scoped facts have been deleted during an intermediate stage.

While overall removal is still running, keep the cartouche present as the visual object whose removal is in progress.

Its presentation may become non-interactive/temporarily busy if necessary, but do not blue-select another context or let the cartouche vanish early.

The sidebar and center panel must not contradict one another.

Required semantic rule:

cartouche disappears only after the complete removal operation has succeeded and final durable membership/readiness verification has passed.

Then:

- imported count for that source is confirmed zero;
- graph/browsing rebuild has completed;
- required refresh/finalization has completed;
- cartouche disappears;
- existing-source selection clears;
- presentation returns to `hub`;
- center panel becomes empty.

No Done/Next button.

## Important architecture distinction

Sidebar membership currently derives from durable positive imported source-scoped data.

During removal, those rows may become zero before the entire operation is complete.

Do not weaken durable membership semantics globally merely to keep the cartouche visible.

Instead, introduce the smallest transient presentation override needed to represent:

“this previously-added archive is currently being removed.”

For example, the workflow may retain the currently removing source in presentation state until the admitted removal operation reaches terminal success/failure.

Do not persist this as archive metadata.

Do not lie about durable imported state in repositories.

This is temporary UI journey state.

## Failure behavior

If a stage fails:

- mark earlier genuinely completed stages resolved;
- mark the failing stage failed;
- do not mark later stages complete;
- stop generic spinner/progress;
- keep or restore enough source context for the user to understand what failed.

Then verify durable truth:

If imported facts still remain:

- cartouche remains under Folders Already Added;
- existing-source context may be restored after failure.

If imported facts are already zero but later reprojection/finalization failed:

- do not invent a successful removal state;
- surface the failure truthfully;
- do not silently return to the hub simply because the cartouche membership query is now zero.

This partial-failure case is important.

Determine from current architecture how recovery/retry should work.

Do not casually redesign recovery in this slice. If current semantics cannot represent partial removal failure safely, stop and report the exact gap.

## Instrumentation visual grammar

Use the emerging Directed Instrumentation language:

- compact vertical list;
- one row per real stage;
- resolved state;
- current active state;
- not-yet-started state;
- failure state when necessary.

Do not use a single large spinner.

A small activity indicator on the active row is fine.

Completed stages should remain visible so the human can see forward motion.

The display should answer:

“What has finished?”

“What is happening now?”

“What remains?”

## Timing

Do not artificially delay fast stages just to make them visible.

If several stages complete quickly, they may appear already resolved by the time the frame renders.

The purpose is truthful instrumentation, not theater.

Likewise, do not advance rows on timers.

## Tracks

Preserve the current Historical Archives A–E Track geometry.

The removal journey occupies the same center-panel structural region already earned by selected-source context.

Do not add magic offsets or redesign sidebar alignment.

## Onboarding / maintenance invariant

Preserve the owner-aware admission correction.

During legitimate removal:

- maintenance remains `maintenanceInProgress`;
- no temporary graph clear/rebuild may trigger Onboarding;
- the user remains in Historical Archives until terminal success/failure.

Add focused regression coverage if the new stage publication causes additional invalidations.

## Source safety

The donor/original Messages folder remains untouched.

No stage label or implementation change may imply that MessageLens is deleting files from that folder.

Human-facing language should consistently describe removal from MessageLens.

## Tests

Add/update focused tests proving at minimum:

1. confirmed removal enters a dedicated removal-operation presentation context;

2. selected-source story disappears while removal is active;

3. each displayed stage corresponds to a real execution boundary;

4. no timer-created/fabricated stages exist;

5. completed stages remain visible;

6. exactly one current stage is active at a time where execution is sequential;

7. later stages are not marked complete before execution reaches them;

8. failure marks the correct stage and does not falsely complete later stages;

9. generic single `Working…` presentation is removed;

10. cartouche remains visible while removal is in progress even if durable imported count temporarily reaches zero;

11. cartouche is not interactive as a competing archive-management context while its own removal is active, if current architecture requires that;

12. successful finalization removes the cartouche only after terminal success;

13. success then returns automatically to virgin hub;

14. center panel becomes empty after success;

15. no Next/Done button exists;

16. partial failure after source-row deletion cannot falsely present success;

17. source-1/current-Mac facts survive;

18. donor/source files remain unchanged;

19. maintenance never triggers Onboarding;

20. existing duplicate-folder, invalid-folder, blue/orange, navigation-reset, and Track behavior remain unchanged.

## Manual staging safety

Do not perform the actual GUI staging removal yourself.

Automated tests must use fixtures/temp databases.

The human will perform the manual staging rehearsal after implementation.

## Documentation

Create the next Feature 26 implementation record under `responses/`.

Document:

- exact real removal stages found;
- exact boundaries used to publish progress;
- stage model introduced;
- how cartouche visibility is held until terminal success;
- failure and partial-failure semantics;
- confirmation that no fake timed stages were introduced;
- maintenance/Onboarding protection;
- source-folder safety.

Update version/changelog according to repository rules.

## Verification

Run:

- focused Historical Archives removal/workflow/presentation tests;
- Settings tests;
- mutation coordinator / graph admission tests as relevant;
- architecture tripwires;
- `flutter analyze`;
- formatting;
- `git diff --check`;
- macOS debug build if required.

Commit and push if clean.

STOP after this removal-instrumentation journey is complete.

Do not proceed into valid new-folder ingestion yet.

Report:

- exact stages discovered;
- exact typed progress model added;
- exact human-facing row labels;
- how cartouche visibility is preserved until terminal success;
- failure/partial-failure behavior;
- confirmation that no artificial timers drive progress;
- manual staging-review instructions.
