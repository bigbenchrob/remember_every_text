Work on branch Ftr.archive-recovery.

This prompt is PRE-APPROVED for implementation. After your planning pass, proceed directly with the bounded implementation below without stopping for another approval, provided investigation confirms the assumptions and hard invariants. Stop only if the work would require broadening scope or changing an invariant.

Suggested prompt name:

prompts/24-HISTORICAL-ARCHIVES-SIDEBAR-SIMPLIFICATION.MD

This is a presentation-only Historical Archives sidebar simplification pass.

Do not proceed into valid-folder inspection/import, import-running/completion, removal workflow, or MessageLens ingestion yet.

MANUAL REVIEW FINDING

The segmented control and major sidebar structure are now conceptually correct, but the sidebar still feels too busy because too many textual levels compete for attention.

The problem is no longer architecture. It is information density and hierarchy.

GOAL

Reduce the sidebar to the fewest textual levels needed to make the structure obvious.

The target hierarchy is:

Historical Archives

short umbrella explanation

[ Mac Messages | MessageLens ]

Folders Already Added
[cartouches]

Add from a Messages Folder
short practical guidance
[ Choose Messages Folder… ]

The result should feel calm, obvious, and easy to scan.

1. SEGMENT LABELS

Change the segmented control labels to:

Mac Messages

and:

MessageLens

This is preferred over:

Messages Folders
MessageLens Folders

because:

- the Historical Archives context already implies folders/sources;
- the shorter labels fit naturally in the available width;
- “Mac Messages” clearly distinguishes Apple/macOS Messages material from MessageLens material;
- the lower action can still use the concrete wording “Messages Folder”.

MessageLens remains disabled in this slice.

Do not add any MessageLens execution path.

2. SIMPLIFY THE UMBRELLA COPY

Keep only one short umbrella statement above the segmented control.

Representative wording:

Add older message history to MessageLens without replacing your current data.

Remove the extra sentence:

Choose where that history comes from below.

The segmented control already communicates that choice.

Do not add replacement prose merely to fill space.

3. KEEP FOLDERS ALREADY ADDED AS A DISTINCT MAJOR SECTION

Preserve:

Folders Already Added

and the existing cartouches.

Do not redesign the cartouche in this task.

Maintain a clear major-section gap above and below this section.

4. SIMPLIFY THE ADD-MESSAGES GUIDANCE

Keep the section heading:

Add from a Messages Folder

Reduce the guidance from several mini-sections/headings to one simple instruction plus a small number of supporting notes.

Target information:

Choose the folder containing chat.db.

Usually: Home → Library → Messages

Older copies can be on another drive, moved, or renamed. An Attachments folder may also be present, but it isn’t required.

Then:

[ Choose Messages Folder… ]

Do not preserve separate large/subordinate headings such as:

Usually found at
Using an older copy?
Attachments

The information remains useful, but those extra heading levels make the sidebar feel like a lesson rather than a simple instruction.

5. PRESERVE THE IMPORTANT HUMAN FACTS

The simplified guidance must still communicate:

- choose a folder, not chat.db itself;
- chat.db is the required clue;
- normal location is Home → Library → Messages;
- an older copy may be elsewhere or renamed;
- Attachments is optional.

Use concise natural language.

Do not introduce technical terminology beyond chat.db and Attachments, which are actual objects the user may see in Finder.

6. BUTTON REMAINS AT THE BOTTOM

Keep:

Choose Messages Folder…

after the explanation.

The user should understand what they are looking for before Finder opens.

Do not add another chooser action elsewhere.

7. SPACING / HIERARCHY

Preserve the current major-section spacing approach, but simplify the internal structure.

Use:

- large spacing between:
  - umbrella/segmented control
  - Folders Already Added
  - Add from a Messages Folder

- modest paragraph spacing within the Add section

Do not create multiple visual sub-sections inside the guidance.

The goal is fewer levels, not more spacing tokens.

8. CENTER PANEL REMAINS EMPTY IN HUB

Preserve:

virgin Historical Archives hub
-> center panel empty

This task is sidebar-only.

9. PRESERVE ALL CURRENT BEHAVIOR

Do not change:

- Folders Already Added membership;
- cartouche selection;
- duplicate-folder modal;
- transient orange reference behavior;
- invalid-folder modal;
- navigation-away reset;
- Mac Messages folder qualification;
- source identity;
- import/removal behavior;
- persistence;
- mutation authority.

10. FUTURE MESSAGE LENS ARM

Do not implement it.

The segmented control should simply read:

Mac Messages | MessageLens

with MessageLens disabled and mechanically inert.

TESTS

Add/update focused tests proving:

1. segmented labels are exactly Mac Messages and MessageLens;

2. MessageLens remains disabled;

3. umbrella copy is reduced to one concise source-neutral statement;

4. removed “Choose where that history comes from below” copy is absent;

5. Folders Already Added remains present;

6. Add from a Messages Folder remains present;

7. guidance includes chat.db;

8. guidance communicates Home → Library → Messages;

9. guidance allows moved/renamed/external copies;

10. guidance states Attachments is optional;

11. separate subheadings “Usually found at”, “Using an older copy?”, and “Attachments” are absent;

12. Choose Messages Folder remains below the guidance;

13. center panel remains empty in virgin hub;

14. no MessageLens functionality is introduced;

15. existing duplicate/invalid/selection/reference behavior remains unchanged.

SCOPE / NON-GOALS

Do not:

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

DOCUMENTATION

Create the next Feature 26 implementation record under responses/.

Document:

- final segmented labels;
- simplified umbrella copy;
- reduced guidance hierarchy;
- retained factual guidance;
- confirmation that the center panel remains silent in hub state.

Update version/changelog according to repository rules.

VERIFICATION

Run focused Historical Archives sidebar/presentation tests, Settings tests as appropriate, architecture tripwires, flutter analyze, formatting, and git diff --check.

Commit and push if clean.

STOP after this simplification pass.

Do not proceed into valid-folder ingestion yet.

Report:

- final umbrella copy;
- final segment labels;
- final Add-from-Messages guidance wording;
- confirmation that the extra mini-headings are gone;
- confirmation that MessageLens remains disabled with no execution path;
- manual review instructions.
