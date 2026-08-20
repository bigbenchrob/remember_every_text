Work on branch `Ftr.archive-recovery`.

This prompt is PRE-APPROVED for implementation. Proceed directly after the planning pass unless investigation reveals that the requested presentation would misrepresent the actual import/projection boundary.

Suggested prompt name:

`prompts/36-MAC-MESSAGES-NARRATOR-SCOPE-TRANSITION.MD`

This is a small but important Narrator + Directed Instrumentation refinement to the now-functioning Mac Messages ingestion journey.

Do not redesign import execution, progress counting, removal, sidebar architecture, or MessageLens-folder ingestion.

## Manual review finding

The current import instrumentation is truthful and substantially improved.

The ready screen reports approximately:

- 8,882 messages in the selected Messages folder;
- 2,369 new to MessageLens;
- 6,513 already represented.

During import:

`Adding messages from this folder`

completes.

Then:

`Preparing conversations for browsing`

begins.

Its real graph-projector instrumentation may show a Messages count advancing through roughly 150,000 records.

This initially confused the user:

> Why did the selected folder contain 8,882 messages, but the Messages progress counter now advances through approximately 150,000?

The answer is legitimate:

The scope of the work has changed.

The first stage concerns the selected historical Messages folder.

The graph-projection stage concerns the **combined MessageLens history** that must be prepared for browsing after the new source has been incorporated.

The instrumentation is truthful.

The missing element is Narrator interpretation at the moment the semantic scope changes.

## Design lesson

This is an important example of why:

**Narrator + Directed Instrumentation**

is more powerful than either alone.

Directed Instrumentation says:

`Messages 67,250 / 145,825`

That proves real work is occurring, but does not explain why the denominator is much larger than the 8,882-message source the user just selected.

Narrator could say:

“Now I’m updating your combined MessageLens history.”

That explains the meaning, but by itself would leave the human staring at prose during a long operation.

Together:

Narrator explains the change of scope.

Directed Instrumentation proves the work is progressing.

## Governing Narrator rule

Document and apply this principle:

> Narrator should intervene when the human meaning or scope of the work changes, not merely because another implementation stage has begun.

Do not make Narrator announce every technical phase.

A Narrator transition is earned when the user's mental model needs updating.

This import contains such a transition.

## Current conceptual sequence

The user begins with one selected source:

**this Messages folder**

The ready evidence describes that source:

8,882 messages
2,369 new
6,513 already represented

Stage 1 remains source-specific:

**Adding messages from this folder**

After that succeeds, MessageLens moves into a different scope:

**the combined MessageLens history**

The graph is being prepared so the complete archive — existing/current data plus the newly added historical source — can be browsed coherently.

That transition must be explained.

## Desired Narrator transition

When:

`Adding messages from this folder`

has genuinely completed

and immediately before / as:

`Preparing conversations for browsing`

becomes active,

change the Narrator content.

Representative wording:

**The messages from this folder are added. Now I’m updating your combined MessageLens history so everything appears together.**

This wording is representative rather than mandatory.

Final copy should remain:

- concise;
- human;
- technically truthful;
- non-reassuring;
- non-celebratory.

Avoid:

- graph;
- projection;
- source-scoped;
- ledger;
- database;
- provider;
- rebuild;
- implementation terminology.

The important concepts are:

1. the selected folder's messages have now been added;
2. MessageLens is now working on the combined history;
3. this is why the following counts may be much larger than the source-folder count.

## Do not repeat the numbers in Narrator

Narrator should not say:

“You selected 8,882 messages and now I am processing 145,825 messages…”

unless investigation shows that such explicit comparison is genuinely necessary.

The instrumentation already owns the numbers.

Narrator owns meaning.

Keep those responsibilities separate.

## Directed Instrumentation wording

Review the stage-2 presentation alongside the new Narrator.

The current heading:

`Preparing conversations for browsing`

may remain if it reads naturally with the Narrator transition.

However, inspect whether one small wording refinement would make the scope clearer.

For example:

`Preparing your MessageLens history for browsing`

may communicate scope more clearly than:

`Preparing conversations for browsing`.

Do not change it merely for novelty.

Choose the wording that best complements the Narrator without redundancy.

## Messages row scope

The numerical Messages projector counter is a count from the combined graph workload, not from the selected source's 8,882 messages.

If the row currently reads only:

`Messages    67,250 / 145,825`

determine whether the new Narrator alone makes that sufficiently clear.

Prefer that solution.

Do not clutter every row with phrases such as:

`All messages in your combined MessageLens history`

unless manual/compositional reasoning shows it is still necessary.

The Narrator should carry the scope explanation so Directed Instrumentation can remain compact.

## Narrator states

The import journey may therefore have at least two meaningful Narrator moments.

### Source-addition phase

Representative existing meaning:

**Adding this Messages folder to MessageLens.**

This owns the source-specific stage.

### Combined-history phase

After source addition succeeds:

**The messages from this folder are added. Now I’m updating your combined MessageLens history so everything appears together.**

This owns the graph/browsing preparation stage.

### Final verification

Do NOT automatically add a third Narrator sentence merely because:

`Checking that import finished`

begins.

The scope has not necessarily changed again.

The Directed Instrumentation row may be sufficient.

Only add Narrator content there if there is a genuine human semantic transition that needs explanation.

## Transition mechanics

Drive the Narrator change from the real typed import progress state.

Do not:

- use timers;
- infer transition from elapsed time;
- inspect displayed strings;
- trigger it from widget animation.

The source-addition Narrator remains until the real source-addition stage completes.

The combined-history Narrator appears when the real graph-preparation stage becomes current.

If graph preparation fails before beginning, do not falsely announce that it is underway.

## Fast transitions

Do not artificially hold the first Narrator sentence merely so it can be read.

If source addition completes quickly, the Narrator may transition quickly.

This is truthful.

The important long-lived explanation is the combined-history Narrator because that is where the human otherwise encounters the surprising large denominator.

## Failure semantics

If source addition fails:

- do not show the combined-history Narrator;
- preserve current failure behavior.

If graph preparation fails:

- the combined-history Narrator may remain as the context for the failed instrumentation;
- do not falsely say everything was successfully prepared.

If final verification fails:

- preserve existing partial-failure semantics;
- do not show success modal.

## Success modal

Preserve Prompt 35 success behavior unchanged.

Do not rewrite the terminal modal in this task.

Preserve:

**Messages folder added**

The Messages folder you selected has been successfully added to MessageLens.

You should now see the additional messages in your message timelines and heatmaps.

`OK`

The Narrator scope transition occurs during work.

The modal owns terminal acknowledgement.

## Progress counts

Preserve Prompt 34 progress semantics exactly.

Do not change denominators.

Preserve exact counts for:

- Conversations;
- Messages;
- Attachments.

Preserve coarse units for:

- Participants;
- Relationships.

Do not substitute the ready-state 2,369 new-message count for graph workload.

Do not add a progress bar in this task.

The raw changing counts have manually proven effective.

## Ready state

Preserve the current ready-state evidence and controls.

No changes to:

- 8,882 source message count;
- new/represented comparison;
- Add Messages to MessageLens;
- Cancel;
- Details.

## Button behavior

Preserve the newly corrected button feedback and `endOfFrame` authorization boundary.

Do not revisit chooser/Add button styling in this task.

## Maintenance-lock correction

There is also a recent bounded correction in the worktree concerning Environment Readiness suppression during maintenance and the import-ledger busy timeout.

Preserve it.

Do not regress:

- no observational `macos_import_ss.db` counts during admitted maintenance;
- no observational `working_ss.db` counts during admitted maintenance;
- bounded 3-second import-ledger busy timeout;
- legitimate maintenance remains `maintenanceInProgress`;
- no spurious Onboarding.

If those changes are still uncommitted when this task begins, preserve them carefully and include them in verification according to repository conventions. Do not overwrite or reimplement them unnecessarily.

## Tests

Add/update the smallest clear focused test set proving:

1. source-specific Narrator is shown during source-addition stage;

2. combined-history Narrator does not appear before source addition genuinely completes;

3. combined-history Narrator appears when graph preparation becomes current;

4. transition is driven by typed execution state, not time;

5. transition is not driven by display strings;

6. source-addition failure never produces combined-history narration;

7. graph-preparation failure retains truthful combined-history context;

8. final verification does not unnecessarily create another Narrator transition;

9. numerical graph progress remains unchanged;

10. large graph denominator is not replaced with source-folder count;

11. ready-state evidence remains unchanged;

12. success modal remains unchanged;

13. partial-failure behavior remains unchanged;

14. maintenance does not trigger Onboarding;

15. Tracks/sidebar layout remain unchanged;

16. removal journey remains unchanged.

Do not create one test method mechanically for each item.

## Documentation

Create the next Feature 26 implementation record under `responses/`.

Document:

- the observed 8,882 versus ~150,000 confusion;
- why both values are truthful;
- exact source-to-combined-history scope transition;
- final Narrator wording;
- whether the stage-2 heading changed;
- the principle that Narrator intervenes on human meaning/scope changes rather than every technical stage;
- preservation of Directed Instrumentation denominators;
- confirmation that no progress theater was introduced.

Also update the canonical Narrator + Directed Instrumentation design documentation if there is an appropriate existing location for this newly learned principle.

This principle is important enough to preserve beyond Historical Archives:

> Narrator explains changes in meaning and scope; Directed Instrumentation exposes the factual work within that scope.

Update version/changelog according to repository rules.

## Verification

Run:

- focused Historical Archives import/presentation tests;
- graph progress tests;
- Settings tests;
- maintenance/Onboarding regressions;
- architecture tripwires;
- `flutter analyze`;
- formatting;
- `git diff --check`;
- macOS debug build if repository rules require it.

Commit and push if clean.

STOP after this Narrator scope-transition refinement.

Do not proceed into MessageLens-folder ingestion yet.

## Report back with

- final source-addition Narrator wording;
- final combined-history Narrator wording;
- whether stage-2 heading changed;
- exact typed state boundary driving the transition;
- confirmation that 8,882 and ~150,000 retain their correct distinct semantics;
- confirmation that no new fake progress/denominator was introduced;
- canonical documentation updated with the new Narrator rule;
- manual staging-review instructions.

Acceptance standard:

> When the instrumentation changes from describing the selected folder to processing the much larger combined MessageLens history, the user should understand immediately why the scope and numbers changed without needing to know anything about graph projection.
