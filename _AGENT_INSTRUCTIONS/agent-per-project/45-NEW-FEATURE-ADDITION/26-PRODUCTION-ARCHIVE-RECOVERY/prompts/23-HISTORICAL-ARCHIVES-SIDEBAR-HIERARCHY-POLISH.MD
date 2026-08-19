Work on branch Ftr.archive-recovery.

This prompt is PRE-APPROVED for implementation. After your planning pass, proceed directly with the bounded implementation below without stopping for another approval, provided investigation confirms the assumptions and hard invariants. Stop only if the work would require broadening scope or changing an invariant.

Su

This is a presentation-only Historical Archives sidebar hierarchy pass.

Do not proceed into valid-folder ingestion, import-running/completion, removal workflow, or MessageLens-folder functionality yet.

MANUAL REVIEW FINDING

Adding the source-type segmented control was the right structural change:

Messages Folders | MessageLens Data Folders

However, it has exposed several remaining information-hierarchy problems.

The sidebar currently reads as a stack of similarly weighted headings and paragraphs rather than a clear hierarchy.

GOAL

Make the Historical Archives sidebar read naturally as:

Historical Archives umbrella
→ choose source type
→ see folders already added for that source type
→ understand how to add another one
→ choose a folder

This task is typography, wording, spacing, and hierarchy only.

No workflow ownership or archive semantics should change.

1. SIMPLIFY THE UMBRELLA INTRODUCTION

The content immediately above the segmented control must describe Historical Archives broadly, not only macOS Messages folders.

Remove the redundant inner Historical Archives heading.

The Settings feature identity at the top already establishes where the user is.

Replace the current Messages-specific introductory prose with a short umbrella-level explanation.

Representative meaning:

Add older message history to MessageLens without replacing your current data.

Choose where that history comes from below.

Do not treat this exact wording as mandatory, but keep it concise.

Do not mention chat.db, Attachments, or Messages-specific paths above the segmented control.

Those belong inside the Messages Folders arm.

Remove the current italicized “Archive import is additive...” line if its meaning is already expressed cleanly by the new umbrella copy.

Avoid saying the same safety fact twice.

2. SHORTEN THE SEGMENT LABELS

The current second segment:

MessageLens Data Folders

wraps onto two lines and makes the control unnecessarily tall and visually dominant.

Use:

Messages Folders

and:

MessageLens Folders

unless investigation finds an important existing product term that makes “MessageLens Folders” misleading.

The intended meaning is still future MessageLens data folders; this is a compact navigation label, not a schema term.

MessageLens Folders remains visible but disabled in this slice.

Do not make it interactive.

3. CREATE CLEAR MAJOR-SECTION SPACING

The sidebar should visibly contain three major regions beneath the umbrella intro:

A. source-type segmented control

B. Folders Already Added

C. Add from a Messages Folder

Use deliberate larger vertical spacing between these major regions.

Do not rely on one repeated generic column gap.

The user should perceive them as separate conceptual sections at a glance.

4. KEEP FOLDERS ALREADY ADDED COMPACT

Preserve the current heading:

Folders Already Added

Preserve the current cartouche semantics and content.

Do not redesign the cartouche in this task.

There should be enough separation above and below this section that it does not visually merge with either the segmented control or the Add section.

5. STRUCTURE THE ADD-MESSAGES GUIDANCE

Keep the heading:

Add from a Messages Folder

The explanation should now appear BEFORE the chooser button.

Preserve the useful current fact:

Choose a copy of your Mac’s Messages folder — the folder containing chat.db.

Then break the remaining guidance into small scan-friendly subparts instead of one continuous prose block.

Representative hierarchy:

Add from a Messages Folder

Choose a copy of your Mac’s Messages folder — the folder containing chat.db.

Usually found at
Home → Library → Messages

Using an older copy?
It may be on another drive, moved somewhere else, or renamed. That’s fine.

Attachments
An Attachments folder may also be present. It isn’t required for adding message history.

[ Choose Messages Folder… ]

Use modest subordinate labels rather than large section headings.

The hierarchy should be:

section heading
→ short explanation
→ small label
→ supporting sentence/value

Do not increase total verbosity unnecessarily.

6. BUTTON REMAINS AT THE BOTTOM

Keep:

Choose Messages Folder…

after all prerequisite guidance.

The human should understand what they are looking for before opening Finder.

Do not move the action above the explanation.

Do not add a second equivalent chooser button elsewhere.

7. SPACING GRAMMAR

Use three visibly different spacing levels where consistent with existing MessageLens layout conventions:

Large:
between major conceptual sections.

Medium:
between guidance topics such as Usually found at / Using an older copy? / Attachments.

Small:
between a subordinate label and the text/value it owns.

Reuse established spacing constants/tokens where available.

Do not invent a Historical-Archives-specific spacing framework.

8. CENTER PANEL REMAINS UNCHANGED

Preserve the current responsibility boundary:

virgin Historical Archives hub
→ center panel empty

This sidebar polish must not create any center-panel orientation or help content.

9. PRESERVE ALL CURRENT BEHAVIOR

Do not change:

- Folders Already Added membership;
- cartouche blue selection;
- duplicate-folder modal;
- transient orange correspondence;
- invalid-folder modal;
- navigation-away reset;
- Messages-folder qualification;
- source identity;
- import/removal behavior;
- persistence;
- mutation authority.

10. FUTURE MESSAGE LENS FOLDER ARM

Do not implement it.

The sidebar should merely be structurally ready for:

Messages Folders | MessageLens Folders

The disabled MessageLens Folders segment must still have no execution path.

Do not add placeholder content below it.

TESTS

Add/update focused tests proving:

1. redundant inner Historical Archives heading is absent;

2. umbrella introduction is source-type-neutral;

3. Messages-specific chat.db/path guidance appears only below the segmented control;

4. segmented labels are Messages Folders and MessageLens Folders;

5. MessageLens Folders remains disabled;

6. Folders Already Added remains present;

7. Add from a Messages Folder remains present;

8. guidance appears before Choose Messages Folder;

9. Home → Library → Messages remains visible;

10. older-drive/moved/renamed guidance remains visible;

11. Attachments remains explicitly optional;

12. Choose Messages Folder remains the only chooser action in this hub state;

13. virgin center panel remains empty;

14. existing duplicate/invalid/reference/selection behavior is unchanged;

15. no MessageLens Folder functionality is introduced.

SCOPE / NON-GOALS

Do not:

- implement MessageLens Folder ingestion;
- redesign valid-folder inspection;
- redesign import running/completion;
- redesign removal;
- alter the cartouche beyond incidental layout compatibility;
- change orange correspondence behavior;
- change source identity;
- change persistence;
- change DateConverter;
- change mutation authority;
- change database schema;
- perform GUI archive mutations.

DOCUMENTATION

Create the next Feature 26 implementation record under responses/.

Document:

- simplified umbrella hierarchy;
- compact source-type labels;
- major-section spacing;
- structured Messages-folder guidance;
- why chooser action comes after explanatory content;
- confirmation that the center panel remains silent in the virgin hub.

Update version/changelog according to repository rules.

VERIFICATION

Run focused Historical Archives sidebar/presentation tests, Settings tests as appropriate, architecture tripwires, flutter analyze, formatting, and git diff --check.

Commit and push if clean.

STOP after this hierarchy pass.

Do not proceed into valid-folder ingestion yet.

Report:

- final umbrella copy;
- final segment labels;
- final Messages-folder guidance structure;
- spacing approach used;
- confirmation that MessageLens Folders remains disabled with no execution path;
- manual review instructions.
