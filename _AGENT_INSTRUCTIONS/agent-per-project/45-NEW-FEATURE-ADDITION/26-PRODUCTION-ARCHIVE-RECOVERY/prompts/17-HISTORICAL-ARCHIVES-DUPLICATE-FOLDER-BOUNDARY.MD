Work on branch Ftr.archive-recovery.

This is the next bounded Historical Archives Narrator + Directed Instrumentation refinement.

Suggested prompt name:

prompts/17-HISTORICAL-ARCHIVES-DUPLICATE-FOLDER-BOUNDARY.MD

Read the current Feature 26 design and implementation records, especially the hub/selection-context and orange correspondence work.

Do not proceed into the genuinely-new-folder import journey yet.

MANUAL REVIEW FINDING

The current handling of a folder that has already been added still gives the center panel responsibilities it does not own.

Current behavior can leave the add journey active and show center-panel content such as:

“This archive is already part of MessageLens.”

plus archive facts and a “Choose Another Folder” action.

That is the wrong interaction model.

Selecting an already-added folder while performing Add an Archive Folder is an exceptional outcome at the folder-selection boundary.

It does NOT establish:

- an existing-source selection context;
- an archive-management center-panel context;
- a continuing add-folder center-panel context.

The add attempt has failed because the selected folder is already represented.

GOAL

Implement the duplicate-folder boundary as:

Add an Archive Folder
→ folder chooser
→ selected folder resolves to a currently added archive
→ add journey terminates
→ modal explains the duplicate
→ user dismisses modal
→ Historical Archives returns to the virgin hub
→ matching existing cartouche receives transient orange referential attention
→ pulse
→ brief lingering highlight
→ gradual fade to normal
→ center panel remains empty

The user should be able to understand:

“That folder is already here — this is the one MessageLens means.”

without converting that source into the current selected object.

MODAL OWNS THE ERROR

When a freshly chosen folder resolves to an archive already added to MessageLens, present a modal dialog.

Representative copy:

This folder has already been added to MessageLens.

You can find it under Folders Already Added.

[ OK ]

Keep the wording concise and non-scolding.

Do not put the duplicate explanation into the ordinary center-panel Narrator flow.

The modal owns this exceptional condition.

Do not expose technical source identity, paths, GUIDs, or import mechanics in the normal modal.

VIRGIN HUB MUST BE RESTORED

After the duplicate is recognized, terminate the add presentation context.

When the modal closes:

- presentation context is `hub`;
- no cartouche is blue-selected;
- sidebar action reads exactly:
  Add an Archive Folder
- center panel is empty;
- no Choose Another Folder button exists anywhere;
- no archive-management context is active.

Important semantic rule:

The sidebar does not know or care that there was a previous failed folder-selection attempt.

Therefore it must NOT say:

Choose Another Folder

“Another” would incorrectly imply that the sidebar owns add-attempt history.

The failed add interaction is finished.

ORANGE IS AN EXTERNAL REFERENTIAL GESTURE

The matching cartouche does not own the orange state.

Orange means:

“This is the thing another interaction is referring to.”

Conceptually, after the modal closes, an invisible finger from the just-dismissed dialog points across the UI at the relevant cartouche:

“This one.”

That distinction is important.

BLUE
= user selected this object as the current primary context.

ORANGE
= another context is temporarily referring to this object.

The duplicate-folder path must never blue-select the known archive.

The user did not click the cartouche.

They attempted to add a folder and MessageLens recognized that folder as an existing object.

REFERENCE TIMING

Order matters.

Required sequence:

1. recognize duplicate;
2. terminate add context;
3. show modal;
4. user dismisses modal;
5. ensure the virgin hub is already restored;
6. trigger orange correspondence on the matching cartouche;
7. pulse once;
8. retain a gentle orange correspondence highlight briefly;
9. gradually fade the highlight completely;
10. return cartouche to its ordinary unselected appearance.

Do not pulse while the modal is still covering the interface.

The referential gesture should occur after dismissal, when the user can see what MessageLens is pointing at.

TRANSIENT PULSE / LINGER / FADE

Reuse the canonical orange correspondence appearance already shared with All Messages.

Do not introduce new orange values.

Extend only the Historical Archives presentation behavior required for:

pulse
→ linger
→ fade

The pulse attracts attention.

The lingering highlight gives the user a moment to locate and understand the referenced object.

The fade is semantically necessary because, once the duplicate notification has finished, nothing continues referring to that cartouche.

A permanent orange highlight would become false.

Use a modest duration appropriate for human recognition.

Do not create generic application-wide animation infrastructure.

Respect existing reduced-motion behavior.

For reduced motion, preserve the semantic reference without a distracting animated pulse/fade; derive the smallest truthful treatment from existing accessibility conventions.

REFERENCE OWNERSHIP

The temporary correspondence state belongs to the Historical Archives presentation/session layer, not:

- the known-source model;
- the cartouche;
- persisted archive metadata;
- source identity;
- the import ledger.

The cartouche simply renders that another context is temporarily referring to its source key.

The reference should contain only the minimal process-scoped information needed to identify:

- referenced canonical source key;
- recognition/reference occurrence;
- current transient visual phase if necessary.

Do not persist any of this.

REPEATED DUPLICATE ATTEMPTS

If the user:

- waits for the previous orange reference to fade;
- clicks Add an Archive Folder again;
- chooses the same already-added folder again;

then the whole semantic event is new.

Therefore:

- modal appears again;
- after dismissal, the same cartouche pulses again;
- linger/fade occurs again.

Provider rebuilds and widget rebuilds must not replay the effect.

Only a fresh duplicate-recognition occurrence should do so.

MECHANICAL IMPOSSIBILITY

Make the duplicate branch structurally incapable of exposing actions belonging to another context.

After duplicate recognition:

- no Import Archive;
- no Remove from MessageLens;
- no Choose Another Folder;
- no source-management Details;
- no selected archive;
- no center-panel duplicate-error state.

The only exceptional action is dismissal of the modal.

After dismissal, the hub owns the UI again.

CANONICAL IDENTITY

Continue using the canonical historical source key already established by prior slices.

The duplicate branch must target the existing cartouche through that identity.

Do not compare display labels.

Do not create a new identity scheme.

DO NOT MAKE DUPLICATE FOLDERS UNSELECTABLE IN THE FILE CHOOSER

Do not attempt to pre-disable or hide already-added folders inside the macOS folder chooser.

The user is allowed to choose a folder.

MessageLens then truthfully identifies what was chosen and explains its relationship to current state.

This is useful feedback.

TESTS

Add focused tests proving:

1. selecting a genuinely already-added folder through Add an Archive Folder enters the duplicate-folder branch;

2. duplicate recognition does not enter `existingSource`;

3. duplicate recognition terminates `addArchive`;

4. the duplicate modal is shown;

5. center panel does not become the error-display surface;

6. dismissing the modal returns presentation context to `hub`;

7. center panel is empty after dismissal;

8. sidebar action reads Add an Archive Folder;

9. no Choose Another Folder action appears after the failed attempt;

10. no cartouche is blue-selected;

11. after modal dismissal, exactly the matching canonical source cartouche receives orange correspondence;

12. orange pulse begins only after the modal is dismissed;

13. pulse settles into the canonical gentle correspondence appearance;

14. correspondence fades completely after the bounded linger period;

15. unrelated cartouches are unaffected;

16. provider/widget rebuilds do not replay pulse or restart the fade;

17. a second fresh duplicate chooser attempt produces a fresh modal and a fresh pulse;

18. reduced-motion behavior remains accessible and semantically truthful;

19. duplicate handling performs no import, removal, source registration, graph projection, or database mutation;

20. genuinely new folders still proceed into the existing add/inspection path unchanged.

SCOPE / NON-GOALS

Do not:

- redesign genuinely new folder inspection yet;
- redesign import running/completion;
- redesign removal;
- change source-scoped identity;
- change source registry semantics;
- change archive persistence;
- change mutation authority;
- change DateConverter;
- change database schema;
- perform a GUI archive mutation;
- create generic modal, Narrator, workflow, or animation infrastructure.

This slice owns only the duplicate-folder boundary and its transient referential gesture.

DOCUMENTATION

Create the next Feature 26 implementation record under responses/.

Document explicitly:

- duplicate folder selection is a failed Add action, not an archive selection;
- modal owns the exceptional notification;
- add context terminates before correspondence appears;
- hub is restored before orange pointing occurs;
- blue belongs to selected objects;
- orange belongs to external referential attention;
- orange pulse → linger → fade lifecycle;
- sidebar does not retain add-attempt history;
- repeated duplicate selections create fresh recognition occurrences;
- no durable source state is changed.

Update version/changelog according to repository rules.

VERIFICATION

Run focused Historical Archives workflow/sidebar/panel/modal tests, canonical orange/reference tests, reduced-motion tests, Settings tests as appropriate, architecture tripwires, flutter analyze, formatting, and git diff --check.

Commit and push if clean.

STOP after this slice.

Do not proceed into genuinely new archive-folder inspection yet.

Report:

- exact duplicate detection boundary;
- how add context is terminated;
- modal lifecycle;
- how hub restoration occurs before correspondence;
- pulse/linger/fade timing and replay prevention;
- reduced-motion behavior;
- confirmation that no center-panel state or sidebar wording remembers the failed add attempt;
- manual review instructions for repeating the same duplicate selection twice.
