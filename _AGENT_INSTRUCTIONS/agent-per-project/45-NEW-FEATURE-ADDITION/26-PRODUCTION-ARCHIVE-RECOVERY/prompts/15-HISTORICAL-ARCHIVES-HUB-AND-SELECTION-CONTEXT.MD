Work on branch Ftr.archive-recovery.

This is the next bounded Historical Archives Narrator + Directed Instrumentation refinement.

Prompt name:

prompts/15-HISTORICAL-ARCHIVES-HUB-AND-SELECTION-CONTEXT.MD

Read:

- responses/10-HISTORICAL-ARCHIVES-NARRATOR-DIRECTED-INSTRUMENTATION-DESIGN.md
- responses/12-NARRATOR-SLICE-01-IMPLEMENTATION.md
- responses/14-NARRATOR-SIDEBAR-REFERENCE-REFINEMENT-IMPLEMENTATION.md
- the current Historical Archives sidebar and center-panel composition
- canonical MessageLens sidebar selection behavior/colors
- the existing orange referential-attention grammar

Do not proceed into new-folder chooser/import redesign yet.

MANUAL REVIEW FINDINGS

The current sidebar and center panel are still not working together with the same selection semantics used elsewhere in MessageLens.

We need to correct the top-level Historical Archives context before continuing the add-folder journey.

DESIRED TOP-LEVEL MODEL

Historical Archives is a HUB.

On entry, it presents:

SIDEBAR

- orientation/info
- Known Archive Sources
- existing archive cartouches
- Add an Archive Folder

CENTER PANEL

- no archive-specific context yet
- no implicit selected archive
- no implicit add-archive workflow
- at most a quiet neutral orientation surface

The user then chooses what they want to do.

There are two distinct sidebar actions:

1. Click an existing Known Archive Source
   -> select that archive
   -> show archive-management context in the center panel

2. Click Add an Archive Folder
   -> enter the add/archive-import journey
   -> later work will handle chooser/inspection/import

This slice implements only the hub and existing-source selection behavior.

CORE INVARIANT

Historical Archives has no implicit selected archive or implicit add workflow.

Center-panel archive-specific content exists only as the consequence of an explicit sidebar action.

MECHANICAL IMPOSSIBILITY APPLIES TO PRESENTATION

The originating sidebar action establishes the center-panel context.

Existing archive selected
-> center panel can expose only actions meaningful for managing that existing archive.

Add Archive selected
-> center panel can expose only actions meaningful for adding/importing a new archive.

Do not allow controls from one context to leak into the other.

NEUTRAL / VIRGIN HUB STATE

When the user first navigates to Historical Archives:

- no archive cartouche is selected;
- no orange referential highlight is active;
- Add an Archive Folder is visible;
- the center panel does not show:
  - “This archive is already part of MessageLens”;
  - archive stats;
  - Choose Another Folder;
  - Import Archive;
  - removal controls;
  - any stale previous archive context.

A minimal neutral center panel is acceptable, for example:

Historical Archives

Choose an existing archive to review it, or add another archive.

Do not over-narrate.

The sidebar already carries much of the orientation.

EXISTING ARCHIVE CARTOUCHE SELECTION

Clicking a Known Archive Source cartouche means:

“Show me this archive.”

This is ordinary object selection.

Therefore:

- selected cartouche uses the canonical BLUE sidebar selected state;
- do NOT use orange for the selected object;
- orange remains reserved for supplementary referential pointing from one part of the UI to another.

The center panel should become an archive-management surface.

Do not show the recognition Narrator:

“This archive is already part of MessageLens.”

That sentence is useful when MessageLens recognizes a folder chosen elsewhere and points to the existing sidebar object.

It is redundant when the human deliberately clicked the existing archive object.

ARCHIVE MANAGEMENT CENTER PANEL

For an imported known source, show a source-specific header and important facts.

Representative shape:

Messages_2012-IMPORT_SOURCE

Historical Messages Archive

Messages 8,882
Dates Jul 2012 – Jun 2017
Status Imported

[ Details ]

[ Remove from MessageLens… ] only if current policy permits removal here.

Use actual typed/persisted source facts.

Do not show:

- Choose Another Folder;
- Import Archive;
- add-folder controls;
- orange recognition Narrator;
- preflight dry-run decision evidence that belongs to new-source import.

The sidebar retains Add an Archive Folder in its normal location.

Do not move that action into the center panel.

BLUE VS ORANGE SEMANTICS

Lock this grammar explicitly:

BLUE
= this sidebar object is selected / this is the current primary context.

ORANGE
= this other UI object is being referred to or pointed out by the current context.

Example:

User clicks known archive cartouche
-> BLUE.

User chooses a folder through the add workflow and MessageLens recognizes that it corresponds to an existing known-source cartouche
-> that cartouche may receive transient ORANGE referential attention.

Do not mix these meanings.

TRANSIENT PRESENTATION STATE ON NAVIGATION AWAY

Historical Archives selection/add context is transient.

When the user navigates away from Historical Archives:

- clear selected known-source presentation context;
- clear add-archive presentation context;
- clear orange reference state/pulse;
- clear Narrator occurrence state specific to that journey.

When the user returns to Historical Archives:

-> return to the neutral/virgin hub state.

Do NOT automatically restore the last viewed archive.

RATIONALE

Persist only things that remain meaningful independently of the current viewing session.

Durable:

- known archive identities;
- imported status;
- counts;
- date ranges;
- source metadata.

Transient:

- which known archive the user happens to be viewing;
- whether add-archive mode is active;
- orange pulse/reference occurrence;
- Narrator transition state.

A known archive can be reselected with one click. Retaining it after leaving the feature falsely implies that it remains the current task.

IMPORTANT

Do not clear durable selected-folder/source metadata merely to achieve this UI reset if that metadata serves import persistence or recovery.

Clear the PRESENTATION CONTEXT at the correct feature/navigation boundary.

If current workflow state conflates durable archive facts with transient UI selection, introduce the smallest projection/presentation distinction needed.

Do not alter archive execution semantics.

ADD AN ARCHIVE FOLDER

For this slice:

- keep the sidebar action visible in the neutral hub;
- keep it visible while an existing archive is selected;
- clicking it may enter an explicit addArchive presentation context if needed;
- do NOT redesign the actual folder chooser/inspection/import screens yet.

The important point is that Add Archive remains a sidebar action.

Do not move its equivalent into an existing-archive management center panel.

KNOWN-SOURCE CARTOUCHE

Keep cartouche semantics simple:

click
-> select source
-> blue selected state
-> show source in center panel

No import.
No removal directly from cartouche.
No folder chooser.
No pulse merely because it was clicked.

TESTS

Add focused tests proving:

1. entering Historical Archives produces the neutral hub state;

2. no known-source cartouche is implicitly selected on entry;

3. center panel contains no archive-specific state until a sidebar action is taken;

4. Add an Archive Folder is visible in the neutral hub;

5. clicking an existing known-source cartouche selects it;

6. selected cartouche uses canonical BLUE selection treatment, not orange referential treatment;

7. clicking the cartouche shows that source's management presentation;

8. archive-management presentation contains source-specific facts;

9. archive-management presentation does not show Choose Another Folder;

10. archive-management presentation does not show Import Archive;

11. archive-management presentation does not show redundant “already part of MessageLens” recognition narration;

12. Add an Archive Folder remains in the sidebar while an existing source is selected;

13. navigating away clears transient Historical Archives selection context;

14. returning to Historical Archives restores the neutral hub state;

15. durable known-source metadata remains intact across that navigation;

16. orange referential state remains available for folder-recognition flows but is not used for ordinary cartouche selection;

17. no import/removal execution semantics change.

SCOPE / NON-GOALS

Do not:

- redesign the folder chooser flow;
- redesign inspection;
- redesign import-running/completion;
- redesign removal-running/completion;
- change source identity;
- change source registry or overlay schema;
- change persistence format;
- change mutation authority;
- change DateConverter;
- perform any GUI archive mutation;
- create a generic navigation framework.

This is a Historical Archives hub/selection-context correction only.

DOCUMENTATION

Create the next Feature 26 implementation record under responses/.

Document:

- neutral hub semantics;
- sidebar action ownership;
- existing-source selection semantics;
- blue versus orange grammar;
- center-panel mechanical-impossibility rules;
- navigation-away reset behavior;
- what is durable versus transient.

Update version/changelog according to repository rules.

VERIFICATION

Run focused Historical Archives sidebar/panel/navigation tests, relevant canonical selection/reference-color tests, architecture tripwires, flutter analyze, formatting, and git diff --check.

Commit and push if clean.

STOP after this slice.

Do not continue into new-folder selection/import redesign.

Report:

- exact neutral hub state;
- exact existing-source selection model;
- exact blue/orange distinction implemented;
- how transient state is cleared on navigation away;
- how durable source metadata is preserved;
- manual review instructions for:
  1. entering Historical Archives fresh;
  2. selecting an existing archive;
  3. navigating away and returning.
