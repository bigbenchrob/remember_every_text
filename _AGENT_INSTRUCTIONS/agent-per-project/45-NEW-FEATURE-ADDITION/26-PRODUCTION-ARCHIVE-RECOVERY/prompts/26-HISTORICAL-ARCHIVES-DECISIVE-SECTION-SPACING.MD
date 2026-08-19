COPY THIS TO CODEX

Work on branch Ftr.archive-recovery.

This prompt is PRE-APPROVED for implementation. After your planning pass, proceed directly with the bounded implementation below without stopping for another approval, provided investigation confirms the assumptions and hard invariants. Stop only if the work would require broadening scope or changing an invariant.

Suggested prompt name:

`prompts/26-HISTORICAL-ARCHIVES-DECISIVE-SECTION-SPACING.MD`

This is a presentation-only Historical Archives sidebar spacing correction.

The previous breathing-room pass was technically correct but perceptually ineffective.

Do not change copy, controls, workflow, persistence, archive semantics, cartouche behavior, or center-panel behavior.

## MANUAL REVIEW FINDING

The previous pass changed:

- major sections: 24px → 32px;
- guidance paragraphs: 8px → 16px;
- guidance-to-chooser: 16px → 24px.

Manual hot-reload review shows that these changes are almost imperceptible.

The sidebar still reads visually as one continuous stack:

intro  
→ segmented control  
→ heading  
→ cartouche  
→ heading  
→ prose  
→ prose  
→ prose  
→ button

There are hundreds of unused vertical pixels beneath the content.

The goal is not to conserve vertical space.

The goal is to use that available space deliberately so the user perceives the information architecture before reading the text.

## GOAL

Make these three major regions unmistakably separate:

1. CONTEXT
   - umbrella explanation
   - Mac Messages | MessageLens selector

2. WHAT IS ALREADY PRESENT
   - Folders Already Added
   - cartouches

3. ADD SOMETHING NEW
   - Add from a Messages Folder
   - guidance
   - Choose Messages Folder

The human eye should perceive these as three distinct regions immediately.

This is not a request to “increase the existing gaps slightly.”

Make the separation visually decisive.

## MAJOR SECTION SPACING

Use approximately **48–56px** of vertical separation:

- after the segmented-control/context block before Folders Already Added;
- after the final Folders Already Added cartouche before Add from a Messages Folder.

Use human visual judgment within that range.

A starting value around **52px** is appropriate.

Do not constrain the design merely because `AppSpacing.xl == 32px`.

If the shared spacing vocabulary does not contain an appropriate single token, use the smallest clear composition of existing spacing values or an established larger layout constant.

Do not add a new global spacing token solely for this screen unless repository conventions clearly require it.

The important invariant is the perceptual result, not whether one named token represents the whole gap.

## GUIDANCE SPACING

The guidance paragraphs should remain clearly part of one Add-from-Messages section, but each thought should have enough room to register separately.

Use approximately **20–24px** between the three existing guidance paragraphs.

Do not restore mini-headings.

Do not alter their wording.

The desired effect is:

instruction

small breath

normal location

small breath

older-copy / Attachments note

—not three separate major sections.

## GUIDANCE TO ACTION

Use approximately **32px** between the final guidance paragraph and:

Choose Messages Folder…

The chooser should visually read as:

“Now that you understand what to find, perform the action.”

It should not look like a fourth paragraph in the guidance block.

## HEADING-TO-CONTENT SPACING

Preserve ordinary compact spacing between:

- Folders Already Added and its first cartouche;
- Add from a Messages Folder and its first explanatory paragraph.

These are heading/content relationships and should remain visibly tighter than the gaps between major regions.

Do not spread every element equally.

The hierarchy depends on contrast between small internal gaps and large section gaps.

## DO NOT VERTICALLY JUSTIFY THE SIDEBAR

There happens to be substantial empty space beneath the content.

Do not distribute the three regions evenly from top to bottom merely to consume it.

Do not use `spaceBetween`, flexible spacers, or viewport-relative positioning that would cause the layout to expand strangely on taller windows.

Use deliberate fixed/content-relative separation near the top.

Remaining unused space at the bottom is desirable.

## HUMAN-EYE ACCEPTANCE STANDARD

Do not judge success primarily by:

- percentage increase in spacing;
- movement from `lg` to `xl`;
- whether a larger named token was used.

Judge it by this question:

> Without reading the words, does the sidebar clearly look like three separate conceptual regions?

The intended visual rhythm is:

CONTEXT

**large breath**

WHAT YOU ALREADY HAVE

**large breath**

ADD SOMETHING NEW

If hot reload still makes the change difficult to notice, the spacing is still too small.

## PRESERVE CURRENT CONTENT EXACTLY

Do not change the currently approved:

- umbrella wording;
- `Mac Messages | MessageLens` labels;
- Folders Already Added heading;
- cartouche contents;
- Add from a Messages Folder heading;
- three guidance paragraphs;
- Choose Messages Folder wording.

This task is spacing only.

## PRESERVE CURRENT BEHAVIOR

Do not change:

- MessageLens segment disabled state;
- virgin hub center panel;
- cartouche selection;
- duplicate-folder modal;
- gentle orange correspondence behavior;
- invalid-folder modal;
- navigation reset;
- source qualification;
- import/removal behavior;
- source identity;
- persistence;
- mutation authority.

## TESTING

Do not create brittle tests asserting every pixel gap.

Preserve/update structural tests as appropriate.

If an existing layout test reasonably supports checking that major-section separation is materially larger than internal paragraph spacing, a relational assertion is acceptable.

For example, conceptually:

`majorSectionGap > guidanceParagraphGap > headingContentGap`

Prefer that over testing arbitrary coordinates.

Existing behavior tests must remain green.

## SCOPE / NON-GOALS

Do not:

- rewrite copy;
- add content;
- implement MessageLens ingestion;
- redesign valid-folder inspection;
- redesign import running/completion;
- redesign removal;
- redesign cartouches;
- alter orange correspondence;
- alter segmented-control behavior;
- change source identity;
- change persistence;
- change DateConverter;
- change mutation authority;
- change database schema;
- perform GUI archive mutations.

## DOCUMENTATION

Create the next Feature 26 implementation record under `responses/`.

Record:

- why the previous 32px major separation was perceptually insufficient;
- the new major/internal/action spacing values;
- the distinction between major-section separation and internal paragraph rhythm;
- confirmation that no content or behavior changed.

Update version/changelog according to repository rules.

## VERIFICATION

Run:

- focused Historical Archives sidebar/presentation tests;
- Settings tests as appropriate;
- architecture tripwires;
- `flutter analyze`;
- formatting;
- `git diff --check`.

Commit and push if clean.

STOP after this spacing correction.

Do not proceed into valid-folder ingestion yet.

Report:

- exact major-section spacing used;
- exact guidance spacing used;
- exact guidance-to-chooser spacing used;
- whether shared tokens or composed values were used;
- confirmation that no copy or behavior changed;
- manual hot-reload review instructions.

The intended result is not “a little more spacious.”

It should be immediately obvious that the sidebar contains **three separate ideas**.
