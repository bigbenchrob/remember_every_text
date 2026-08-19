Work on branch `Ftr.archive-recovery`.

This prompt is PRE-APPROVED for implementation of the bounded work described below. However, because the truthful removal-progress seam is not yet established, begin with the required audit. You may proceed directly into implementation only where the audit establishes the semantics unambiguously. If truthful implementation would require inventing progress stages, changing removal semantics, or materially broadening architecture, stop and report instead.

Suggested prompt name:

`prompts/30-HISTORICAL-ARCHIVE-REMOVAL-JOURNEY.MD`

## Context

The **existing-folder management** surface is now structurally correct:

- Folders Already Added owns imported-source membership.
- Clicking a cartouche blue-selects that object.
- Sidebar owns object identity.
- Center panel owns the useful story and management actions.
- Selected-source center content begins on the shared cartouche-list Track.
- More Details is collapsed by default.
- `Remove this folder…` has been restored with canonical destructive styling.
- Historical source removal mechanics were previously exercised successfully against the disposable staging archive.
- Source-scoped removal must preserve unrelated source-1/current-Mac data.

Before beginning the valid-new-folder ingestion journey, finish the complete lifecycle of an **existing imported folder**.

The desired lifecycle is:

select existing folder  
→ understand it  
→ Remove this folder…  
→ explicit destructive confirmation  
→ removal operation  
→ truthful Directed Instrumentation  
→ success  
→ removed cartouche ceases to qualify for Folders Already Added  
→ transient selected-source context becomes impossible  
→ virgin Historical Archives hub  
→ empty center panel

## FIRST: AUDIT THE CURRENT REMOVAL SEAM

Before changing presentation, trace the current removal path from:

`Remove this folder…`

through:

- confirmation;
- Historical Archives workflow action;
- ArchiveMutationCoordinator admission;
- source-scoped import-row deletion;
- graph reprojection;
- source metadata refresh;
- sidebar membership refresh;
- final workflow/presentation state.

Establish exactly what **live observable progress** currently exists.

Specifically determine whether the removal service publishes observations for real stages such as:

- preparing/removing source-scoped records;
- rebuilding browsing/conversation graph;
- refreshing evidence/search/heatmap surfaces;
- completion.

Do not infer stages merely because the implementation performs several sequential calls.

A stage may appear in Directed Instrumentation only if the UI can truthfully know that stage is currently active or has completed.

If the current seam exposes only:

`removal started → removal finished/failed`

then implement one honest coarse active operation for now.

Do NOT fake intermediate progression.

If adding a small typed observation seam is clearly bounded and does not alter execution ownership, you may propose/implement it only if the current architecture makes that straightforward and truthful.

Do not create a generic progress framework.

## DESTRUCTIVE CONFIRMATION

Clicking:

`Remove this folder…`

must NOT immediately mutate anything.

Present a concise modal confirmation.

Representative meaning:

**Remove this folder from MessageLens?**

The messages added from this folder will be removed from MessageLens. Your original Messages folder will not be changed.

`Cancel` | `Remove Folder`

Use existing MessageLens/macOS modal conventions.

The confirm action must use canonical destructive styling.

Do not turn the entire center panel into a warning screen.

Do not expose implementation terminology such as:

- source-scoped rows;
- graph projection;
- ledger;
- GUID;
- mutation authority.

The modal should answer the human's important safety question:

> Will this alter/delete my original Messages folder?

Answer: no.

## CANCEL

Cancel must:

- close the modal;
- leave the existing archive blue-selected;
- leave its center-panel story unchanged;
- perform no mutation;
- preserve Folders Already Added unchanged.

No Narrator aftermath is required.

## CONFIRMATION → OPERATION

After the user confirms:

- close the modal;
- begin the existing source-scoped removal operation;
- keep the operation within the existing mutation-authority model;
- do not leave destructive confirmation UI hanging around;
- center panel may now become the operation surface because legitimate work is underway.

Representative Narrator meaning:

**Removing this folder from MessageLens.**

Keep it brief.

Do not repeatedly reassure the user.

## DIRECTED INSTRUMENTATION

Show only work that the current removal seam truthfully exposes.

If only coarse activity is available:

REMOVING MESSAGES FOLDER

Removing messages added from this folder Working

That is preferable to invented stages.

If the audit establishes truthful live stage observations, use a small number of human-readable rows.

For example only if genuinely supported:

Removing added messages ✓  
Updating MessageLens history …

Do not expose developer terminology.

No percentages unless there is a genuinely meaningful measured denominator.

No generic five-minute spinner divorced from actual work.

The instrumentation should be compact and above the fold.

## SOURCE FOLDER SAFETY

The original selected Messages folder is read-only source material from the user's perspective.

Historical removal removes the archive's contribution **from MessageLens**.

It must not:

- delete the donor/source folder;
- delete `chat.db`;
- delete its Attachments;
- modify source files.

Preserve existing mechanical guarantees.

The confirmation copy and tests should make this distinction explicit.

## SUCCESS SEMANTICS

On successful removal, do NOT leave the user on a permanent:

“Removal Complete”

report for an object that no longer belongs under Folders Already Added.

Instead derive success from durable truth.

Once the removed source has zero imported source-scoped message facts:

- it no longer qualifies for Folders Already Added;
- its cartouche disappears;
- `existingSource` context is cleared;
- no cartouche is selected;
- Historical Archives returns to `hub`;
- center panel becomes empty;
- sidebar again offers the normal Mac Messages hub including Choose Messages Folder.

This should happen automatically.

No Next / Done / Return button.

The human should not have to advance the workflow.

## SHOULD THERE BE A TRANSIENT SUCCESS MESSAGE?

Do not assume one is necessary.

The cartouche disappearing and hub returning may provide sufficient evidence.

During implementation/manual review, prefer the simpler behavior:

removal finishes  
→ cartouche disappears  
→ virgin hub

If current product conventions already provide a lightweight transient success acknowledgement that does not disturb the hub, it may be retained/reused.

Do not introduce a new toast/banner system in this slice.

## REMOVED SOURCE IDENTITY

Do NOT delete canonical source identity merely because the source disappears from Folders Already Added.

Preserve the established distinction:

“MessageLens knows about this source”

is not equivalent to:

“This folder is currently added to MessageLens.”

After removal, source registry/workflow identity may remain as required by existing architecture.

Sidebar membership remains based on positive imported source-scoped data.

This allows the same folder to be chosen later through the Add flow and imported again.

## FAILURE

Audit the existing removal failure behavior.

If removal fails after the user has confirmed:

- do not falsely remove the cartouche if durable imported facts remain;
- do not return to virgin hub if the source still qualifies as added;
- preserve/recover truthful existing-source context where possible;
- explain the failure in human language;
- expose Retry only if the existing operation is genuinely retryable.

Technical detail belongs under Details or existing diagnostic mechanisms.

Do not redesign the entire failure system in this slice.

If existing failure semantics are too ambiguous to present truthfully, document and stop before inventing behavior.

## MAINTENANCE / ONBOARDING

Preserve the owner-aware correction already implemented.

Legitimate removal maintenance must remain `maintenanceInProgress`, not `graphProjectionFailed`.

Removal must not divert the user into Onboarding / Environment Readiness while the graph is intentionally being reprojectioned.

Add/retain focused regression coverage for this.

## TRACKS

During removal operation, preserve the current Historical Archives track relationship where sensible.

Do not undo the newly established fixed A–E upper geometry.

Do not add magic top offsets.

The selected-source story currently begins at the cartouche-list region; removal instrumentation may occupy the same earned center-panel region.

After success and hub restoration, center panel returns to empty.

## PRESENTATION MECHANICAL IMPOSSIBILITY

Before confirmation:

existingSource context may expose:

- story;
- More Details;
- Remove this folder…

It must not expose:

- import controls;
- add-folder controls in center;
- removal progress.

After confirmation while removal runs:

removal context may expose:

- Narrator;
- truthful removal instrumentation.

It must not expose:

- another Remove action;
- Import Archive;
- chooser actions;
- unrelated source-management actions.

After successful removal:

hub context:

- center empty;
- no selected cartouche;
- normal sidebar actions only.

## TESTS

Add/update focused tests proving at minimum:

1. `Remove this folder…` is available only for an eligible selected imported source.

2. Clicking it does not immediately mutate data.

3. Confirmation modal clearly states that MessageLens removes the folder's added messages without modifying the original Messages folder.

4. Cancel performs no mutation and returns to unchanged selected-source view.

5. Confirm invokes the existing source-scoped removal seam exactly once.

6. Unrelated source-1/current-Mac import facts survive removal.

7. Unrelated graph facts survive/reappear after reprojection.

8. Removed source facts reach zero when removal succeeds.

9. Folders Already Added membership disappears when imported count reaches zero.

10. Successful removal clears `existingSource`.

11. Successful removal returns automatically to `hub`.

12. Center panel is empty after successful removal.

13. No Next/Done action is required.

14. Source registry/canonical identity remains where existing architecture requires it.

15. The same removed source remains eligible for a future fresh Add flow.

16. Original donor/source files are never mutated.

17. Directed Instrumentation exposes only real observable removal state.

18. No fabricated progress stages are introduced.

19. Removal maintenance does not trigger Onboarding.

20. Failure cannot falsely remove the cartouche while imported facts remain.

21. Existing duplicate-folder, invalid-folder, blue-selection, orange-reference, navigation-reset, and track behavior remain intact.

## SAFETY

Automated implementation/testing must not mutate:

- production MessageLens archive;
- frozen production snapshots;
- donor Messages folders;
- real attachment payloads.

Use fixtures, temporary databases, or existing safe test infrastructure.

Do not perform the GUI staging removal yourself.

Manual staging validation will be done by the human after implementation.

## DOCUMENTATION

Create the next Feature 26 implementation record under `responses/`.

Document:

- current removal execution path;
- truthful progress observations actually available;
- confirmation semantics;
- original-source safety guarantee;
- removal operation presentation;
- successful durable-state transition back to hub;
- failure behavior;
- preservation of canonical source identity;
- maintenance/Onboarding regression protection.

Update version/changelog according to repository rules.

## VERIFICATION

Run:

- focused Historical Archives removal/workflow/presentation tests;
- mutation-coordinator/graph-admission tests as relevant;
- Settings tests;
- architecture tripwires;
- `flutter analyze`;
- formatting;
- `git diff --check`;
- macOS debug build if repository rules require it.

Commit and push if clean.

STOP after the existing-folder removal journey is complete.

Do not proceed into valid new-folder ingestion yet.

Report:

- exact confirmation wording;
- exact truthful progress seam discovered;
- whether any observation seam was added;
- exact running-state presentation;
- exact success transition;
- failure behavior;
- confirmation that donor files are untouched;
- confirmation that source-1 data remains mechanically protected;
- manual staging-review instructions.
