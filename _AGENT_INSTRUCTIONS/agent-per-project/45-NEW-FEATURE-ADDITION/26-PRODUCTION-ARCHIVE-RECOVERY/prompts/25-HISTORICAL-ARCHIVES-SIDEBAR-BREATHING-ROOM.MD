Work on branch Ftr.archive-recovery.

This prompt is PRE-APPROVED for implementation. After your planning pass, proceed directly with the bounded implementation below without stopping for another approval, provided investigation confirms the assumptions and hard invariants. Stop only if the work would require broadening scope or changing an invariant.

Suggested prompt name:

prompts/25-HISTORICAL-ARCHIVES-SIDEBAR-BREATHING-ROOM.MD

This is a presentation-only Historical Archives sidebar spacing refinement.

Do not change wording, behavior, workflow ownership, archive semantics, or center-panel behavior unless a tiny incidental adjustment is required to preserve the existing layout.

MANUAL REVIEW FINDING

The current sidebar hierarchy is now conceptually correct:

- umbrella explanation;
- Mac Messages | MessageLens segmented control;
- Folders Already Added;
- imported archive cartouche;
- Add from a Messages Folder;
- concise folder-location guidance;
- Choose Messages Folder.

The problem is no longer information architecture or copy.

The existing content is visually compressed into the upper part of a tall sidebar, even though there is substantial unused vertical space below it.

We should use that available space as breathing room rather than adding more content.

GOAL

Make the existing sidebar feel calmer and easier to scan by increasing separation between conceptual sections and giving the guidance/action block more internal breathing room.

Do not fill the unused space with additional information.

The desired principle is:

More room between ideas, not more ideas.

MAJOR SECTION SPACING

Increase the vertical separation between these three major regions:

1. umbrella copy + segmented control;

2. Folders Already Added + cartouche list;

3. Add from a Messages Folder + guidance + chooser action.

These should read as three clearly separate conceptual blocks at a glance.

Use existing shared MessageLens spacing tokens/constants where possible.

Do not introduce a Historical-Archives-specific spacing system.

CARTOUCHE TO ADD-SECTION SEPARATION

Increase the gap after the final Folders Already Added cartouche before:

Add from a Messages Folder

The current transition is too compressed and makes the archive list and add-new workflow read as one continuous block.

The user should visually understand:

these are the folders already present

then

separately, here is how to add another one.

GUIDANCE PARAGRAPH SPACING

The three existing guidance paragraphs are intentionally equal-weight prose.

Keep their wording and hierarchy unchanged.

Increase the vertical spacing between them modestly so they are easier to scan as separate thoughts:

- choose the folder containing chat.db;
- usual Home → Library → Messages location;
- older/moved copies and optional Attachments.

Do not restore subordinate headings.

Do not increase font sizes.

Do not turn them back into separate mini-sections.

CHOOSER ACTION SEPARATION

Increase the vertical gap before:

Choose Messages Folder…

The button should feel like the conclusion/action that follows the explanation, not like another paragraph in the guidance block.

The visual rhythm should be:

instruction
supporting guidance
pause
action

BUTTON AND SECTION WIDTHS

Preserve current widths and alignment unless spacing investigation reveals a genuine inconsistency.

Do not make the chooser larger merely because there is unused space.

Do not stretch content vertically to fill the entire sidebar.

The goal is natural breathing room, not artificial distribution.

SEGMENTED CONTROL

Preserve exactly:

Mac Messages | MessageLens

MessageLens remains disabled and inert.

Do not alter the segmented-control sizing, behavior, or labels in this task unless required by spacing compatibility.

UMBRELLA COPY

Preserve the current concise umbrella wording.

Do not add or remove copy in this task.

FOLDERS ALREADY ADDED

Preserve:

Folders Already Added

and existing cartouche presentation/behavior.

Do not change cartouche metadata, colors, selection, or reference behavior.

CENTER PANEL

Preserve the existing hub invariant:

virgin Historical Archives hub
-> center panel empty

This task must not introduce center-panel help or orientation content.

SPACING GRAMMAR

Prefer a simple existing-token hierarchy approximately equivalent to:

Large gap:
between major conceptual regions.

Medium gap:
between the final guidance paragraph and chooser action.

Moderate/small gap:
between guidance paragraphs.

Small gap:
within existing heading/text pairs where already established.

Do not over-engineer exact pixel values.

Use the repository’s existing spacing vocabulary and visually coherent ratios.

The screenshot shows ample room below the content, so err slightly toward more separation rather than tightly packing the upper sidebar.

TESTS

Update/add focused tests only where they are meaningful for structural layout.

Do not write brittle pixel-perfect tests for every gap.

Prefer tests proving:

1. the existing content order is unchanged;

2. the three major sidebar regions remain distinct in widget structure;

3. chooser remains after all guidance;

4. no additional content was introduced;

5. segmented control remains Mac Messages | MessageLens;

6. MessageLens remains disabled;

7. center panel remains empty in virgin hub;

8. existing archive/cartouche, duplicate, invalid-folder, reference, and navigation behavior remains unchanged.

If existing golden/layout tests can safely verify the intended hierarchy without becoming fragile, update them narrowly.

SCOPE / NON-GOALS

Do not:

- rewrite copy;
- add explanatory content;
- implement MessageLens ingestion;
- redesign valid-folder inspection;
- redesign import running/completion;
- redesign removal;
- redesign cartouches;
- change orange correspondence;
- change source identity;
- change persistence;
- change DateConverter;
- change mutation authority;
- change database schema;
- perform GUI archive mutations.

This is spacing and visual rhythm only.

DOCUMENTATION

Create the next Feature 26 implementation record under responses/.

Document:

- that the sidebar hierarchy was already semantically correct;
- that this pass uses available vertical space to improve separation;
- the spacing tokens/levels used;
- confirmation that no information or behavior was added.

Update version/changelog according to repository rules.

VERIFICATION

Run focused Historical Archives sidebar/presentation tests, Settings tests as appropriate, architecture tripwires, flutter analyze, formatting, and git diff --check.

Commit and push if clean.

STOP after this spacing refinement.

Do not proceed into valid-folder ingestion yet.

Report:

- exact shared spacing tokens used;
- where major-section spacing increased;
- where guidance/action spacing increased;
- confirmation that no copy or behavior changed;
- manual review instructions.
