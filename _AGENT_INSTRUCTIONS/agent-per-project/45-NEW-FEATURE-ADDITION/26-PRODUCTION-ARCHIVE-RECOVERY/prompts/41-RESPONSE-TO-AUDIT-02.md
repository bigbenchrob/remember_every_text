Work on branch `Ftr.archive-recovery`.

This prompt is PRE-APPROVED for implementation.

This is the second remediation pass following the Historical Archives architecture-conformance audit.

D1 — contradictory workflow-state combinations — is now resolved through the sealed `HistoricalArchivesPresentationState` model.

The next deferred finding is D2:

> Historical Archives has a state-dependent center-column shared Track boundary.

The goal of this task is to make the Historical Archives page skeleton structurally stable across all presentation variants.

Do not begin D3 source-identity unification in this task.

## Read first

Read:

- the canonical Track / Page Track / vertical-column-band architecture documentation;
- current `PageTrackLayoutMatrix` implementation and ownership rules;
- Historical Archives sidebar and center-panel Track composition;
- the architecture audit:
  `responses/40-HISTORICAL-ARCHIVES-ARCHITECTURE-CONFORMANCE-AUDIT.md`;
- the D1 remediation:
  `responses/41-HISTORICAL-ARCHIVES-TYPED-PRESENTATION-STATE-IMPLEMENTATION.md`;
- recent Track/Narrator implementation records necessary to understand A–I.

Before editing, reproduce/document the exact current Historical Archives Track occupancy for every sealed presentation variant.

## Problem

Historical Archives now uses shared Tracks A–I, but the center-column participation boundary is not stable across state.

The audit found that operation-oriented presentations and selected-source presentations do not participate in exactly the same shared page skeleton.

For example, some states continue through center Tracks F–I while other states effectively leave the shared Matrix after Track E and then continue in independent native flow.

This can be visually correct in individual screenshots, but architecturally it means:

> the page geometry itself changes depending on transient workflow state.

That conflicts with the intended Track contract.

Tracks should describe stable structural regions of a page.

Presentation state should determine:

- whether a Track is empty;
- what occupies it;

not whether the shared page skeleton ceases to exist.

## Governing principle

Apply:

> Tracks express stable page geometry. State changes Track occupancy, not the Track contract.

Historical Archives should have one stable center-column Track boundary across:

- hub;
- existing source;
- inspecting candidate;
- ready to add;
- importing;
- import failure;
- removing;
- removal failure;
- duplicate/invalid/success notice families where center content is applicable.

Empty Tracks are legitimate structural states.

Do not collapse the page skeleton merely because a state has nothing to render in one band.

## First: map current Track semantics

Document Tracks A–I precisely.

For each Track identify:

- semantic purpose;
- sidebar occupants;
- center occupants;
- whether height is shared;
- whether empty occupancy is allowed;
- whether content after that Track returns to independent native flow.

Do not assume old labels are still accurate.

Current concepts likely include:

- fixed upper Historical Archives context;
- source-type selector;
- section transitions;
- Folders Already Added heading/list start;
- center title;
- title-to-Narrator transition;
- stable Narrator allocation;
- Narrator-to-instrumentation transition.

Use actual code as authority.

## Build a variant × Track matrix

For all 13 sealed `HistoricalArchivesPresentationState` variants, create a matrix showing center occupancy for Tracks A–I.

For example conceptually:

| Variant        | A   | B   | C   | D   | E   | F     | G     | H        | I     | after I         |
| -------------- | --- | --- | --- | --- | --- | ----- | ----- | -------- | ----- | --------------- |
| hub            | ... | ... | ... | ... | ... | empty | empty | empty    | empty | empty           |
| existingSource | ... | ... | ... | ... | ... | ?     | ?     | ?        | ?     | story           |
| readyToAdd     | ... | ... | ... | ... | ... | title | gap   | narrator | gap   | evidence        |
| importing      | ... | ... | ... | ... | ... | title | gap   | narrator | gap   | instrumentation |
| removing       | ... | ... | ... | ... | ... | title | gap   | narrator | gap   | instrumentation |

Use actual variants and actual content.

The purpose is to expose where the shared boundary currently changes.

## Desired architecture

Historical Archives should define one stable Track skeleton.

A likely model is:

Tracks A–E
= shared sidebar/center upper-page alignment

Tracks F–I
= center operation/story structural bands

After Track I
= normal center-panel body flow

The exact contract must be derived from the current design, not imposed blindly.

The key invariant is:

> every center presentation passes through the same defined Track boundary before entering post-Track native flow.

If a state has no title/Narrator/instrumentation, Tracks F–I remain empty.

Do not omit them structurally.

## Existing-source presentation

This is the most important case to inspect.

The selected existing-source story currently begins aligned with the cartouche-list region and uses a compact human narrative:

- This is a Mac Messages folder.
- optional import date;
- message/date facts;
- More Details;
- Remove this folder…

Do not move or redesign that story merely to fill operation Tracks.

Instead determine how it should participate honestly in the stable center skeleton.

Possibilities include:

- story begins in a defined body Track after empty F–I;
- first story sentence occupies F and later Tracks are empty;
- another narrow mapping.

Choose based on the established visual geometry.

The requirement is structural stability, not forcing all states to look like operation screens.

## Hub

Virgin hub center remains visually empty.

But structurally it should still participate in the page Track contract.

Do not create visible placeholders.

Empty Tracks are acceptable.

## Ready/import/removal

Preserve the now-successful Narrator + Directed Instrumentation geometry.

In particular:

- stable Narrator Track remains fixed;
- Directed Instrumentation does not jump when Narrator becomes silent;
- source/combined/final phases retain current behavior.

Do not regress this while normalizing the Track boundary.

## Notices/modals

Duplicate, invalid, and success notices are hub-family transient presentation states.

Their modal ownership should remain separate from center-panel geometry.

Do not create center content merely to make their Track occupancy symmetrical.

The stable center skeleton may remain empty behind the modal.

## Variable sidebar cartouche list

Do not reintroduce the earlier misunderstanding.

Tracks align the **start of the Folders Already Added list region**, not arbitrary selected rows.

Do not:

- add dynamic selected-row synchronization;
- make the whole variable list a shared-height Track;
- align center content to second/third cartouche;
- add scroll synchronization.

The sidebar list remains independent native flow after its shared start coordinate.

## No magic offsets

Search the Historical Archives center/sidebar implementation for:

- `SizedBox(height: ...)`;
- top padding;
- local spacer stacks;
- duplicated AppSpacing combinations;
- fixed offsets that were introduced before Track integration.

Classify each.

Remove only those that now duplicate Track responsibility.

Do not delete ordinary within-content spacing.

## Stable Track ownership

Make the Track definition centrally understandable.

Avoid state-specific code such as conceptually:

`if (state is Importing) useTracksThroughI else stopAtE`

Instead:

one Historical Archives page skeleton

- variant-specific occupants.

Prefer pattern matching over the typed state model to determine occupancy.

## Track heights

Do not change approved visual spacing casually.

This is an architectural stabilization pass, not a visual redesign.

Preserve current rendered positions as closely as possible.

If making the boundary stable necessarily changes a small amount of whitespace, document it.

Do not “improve” unrelated spacing.

## Narrator Track

Preserve the recent fixed Narrator allocation.

Audit that it is now part of the stable Historical Archives Track contract rather than conditionally introduced only for operation states.

When Narrator is silent:

- Track remains;
- no placeholder;
- instrumentation/body remains anchored.

## Center title Track

Audit whether center page title Track F is semantically needed in every variant.

A stable Track does not require visible title content.

If existingSource has no title because sidebar already owns identity, Track F can be empty.

Do not reintroduce redundant headings just to occupy it.

## Post-Track body seam

Define one clear point after the stable shared Track skeleton where center states may continue in ordinary native flow.

Document it.

Examples:

- selected-source story body;
- ready evidence;
- Directed Instrumentation;
- Details;
- destructive actions.

Avoid multiple state-specific escape points from the Track system.

## Scroll behavior

Audit `SingleChildScrollView`, `Center`, `ConstrainedBox`, and Track wrappers.

Confirm that stable Track participation does not create:

- nested competing scroll views;
- scroll jumps on state transition;
- content clipping;
- viewport-dependent offsets.

Do not build generic scroll synchronization.

## Mechanical impossibility

The page structure should make these states impossible:

- importing has one center Track skeleton while existingSource has a different one;
- Narrator silence collapses Track geometry;
- entering/removing operation inserts Tracks that were not part of the page before;
- success/hub transition changes the shared page boundary.

State may alter content, not structural contract.

## Tests

Add/update focused tests proving at minimum:

1. every Historical Archives presentation variant uses the same center Track boundary;

2. hub participates through that boundary with empty occupancy;

3. existingSource participates through the same boundary;

4. readyToAdd participates through the same boundary;

5. importing participates through the same boundary;

6. importFailure participates through the same boundary;

7. removing participates through the same boundary;

8. removalFailure participates through the same boundary;

9. notice-family/hub states do not create a divergent center skeleton;

10. Track F–I existence is not conditional on operation state;

11. Narrator silence does not remove Narrator Track;

12. selected-source story does not reintroduce redundant title content;

13. cartouche-list variable height remains independent of center story height;

14. no dynamic selected-row alignment exists;

15. no hard-coded top inset substitutes for Tracks;

16. state transitions preserve stable center geometry;

17. navigation reset to hub preserves the same Track skeleton;

18. current visual responsibility/sidebar behavior remains unchanged.

Prefer structural Track assertions over brittle pixel coordinates.

Use targeted golden/layout tests only if repository conventions support them robustly.

## Search for obsolete layout branches

After implementation search for:

- state-dependent Matrix constructors;
- conditional Track wrapper insertion;
- alternate center layout roots for existingSource vs operations;
- superseded top spacers;
- old pre-Track alignment helpers.

Remove genuinely obsolete branches.

Do not broadly refactor unrelated Settings layouts.

## D1 integration

Use the sealed typed presentation variants introduced by D1.

Do not reconstruct state from nullable fields.

Track occupancy should pattern-match/project from the typed state.

This task should demonstrate the value of D1:

explicit variants
→ explicit occupancy
→ one stable skeleton.

## D3 is out of scope

Do not change:

- canonical source key;
- path normalization;
- offline identity reconstruction;
- source registry semantics.

That is the next separate remediation.

## Preserve current UX

Do not change:

- sidebar wording/spacing;
- Mac Messages/MessageLens segmented control;
- MessageLens disabled state;
- cartouche contents;
- ready-state wording;
- Add/Cancel;
- chooser buttons;
- import/removal progress;
- Narrator wording/lifecycle;
- success modal;
- destructive confirmation;
- duplicate/invalid modals;
- orange/blue semantics;
- completion dwell.

## Documentation

Create the next Feature 26 implementation record under `responses/`.

Document:

- old state-dependent Track boundary;
- variant × Track audit;
- stable Historical Archives Track contract;
- exact shared boundary;
- post-Track body seam;
- empty Track semantics;
- variable-list handling;
- obsolete layout branches removed;
- visual behavior preserved.

Update the architecture-conformance audit/follow-up to mark D2 resolved if successful.

Update canonical Track architecture guidance if this reveals a reusable rule:

> A page's shared Track boundary is structural and stable. Presentation variants choose occupants, including empty occupancy; they do not choose whether the page participates in the Track system.

Update version/changelog according to repository rules.

## Verification

Run:

- focused Historical Archives layout/Track tests;
- typed-state transition tests;
- Settings suite;
- import/removal presentation tests;
- Narrator tests;
- navigation reset tests;
- architecture tripwires;
- full Flutter suite if feasible;
- `flutter analyze`;
- formatting;
- `git diff --check`;
- macOS debug build.

Commit and push if clean.

## Stop conditions

STOP if:

- stabilizing the Track boundary requires global Track redesign;
- correct implementation requires dynamic list-row synchronization;
- visual behavior must materially change;
- D3 source identity changes become necessary;
- persistence/schema changes are required.

Do not use magic offsets as a fallback.

## Final report

Report:

- old state-dependent boundaries found;
- final stable Track A–I contract;
- variant × Track strategy;
- exact post-Track native-flow seam;
- obsolete layout branches/spacers removed;
- confirmation that variable cartouche lists remain independent;
- confirmation that current rendered UX remains materially unchanged;
- tests/tripwires added;
- documentation updated;
- commit hash;
- confirmation that D2 is resolved;
- recommendation for proceeding to D3 source-identity unification.

Acceptance standard:

> Historical Archives should have one page skeleton. Changing workflow state changes what appears in that skeleton, not which skeleton the page uses.
