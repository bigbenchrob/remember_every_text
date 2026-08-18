Work on branch Ftr.archive-recovery.

This is the next bounded Historical Archives folder-selection boundary correction.

Suggested prompt name:

prompts/18-HISTORICAL-ARCHIVES-INVALID-FOLDER-BOUNDARY.MD

Read the current Feature 26 implementation records, especially Prompt/Response 17 for duplicate-folder handling.

Do not proceed into valid new-archive inspection/import redesign yet.

MANUAL REVIEW FINDING

After the duplicate-folder boundary was corrected, manual testing exposed the same responsibility problem for a different early folder-selection outcome.

The user clicked Add an Archive Folder and selected an arbitrary folder that does not contain a usable Messages archive.

Current behavior puts the failure into the center panel:

“This folder does not contain a Messages database.”

Messages database Missing

Choose Another Folder

Details

This is incorrect.

No valid archive context was established, so the center panel does not own this failure.

GOVERNING RULE

A folder-selection attempt earns Historical Archives center-panel add/import context only after MessageLens has established that the chosen folder is a usable candidate archive.

Early rejection outcomes at the folder-selection/inspection boundary do not become center-panel states.

They are transient exceptional interactions.

After they are acknowledged, the feature returns to the virgin hub.

INVALID-FOLDER FLOW

For a folder that cannot qualify as a Messages archive, use:

Add an Archive Folder
→ native folder chooser
→ inspect selected folder
→ folder fails basic archive qualification
→ terminate add context
→ restore hub
→ show modal explaining the problem
→ user dismisses modal
→ remain in virgin hub

After dismissal:

- no source is selected;
- no orange reference exists;
- no blue selection exists;
- sidebar shows Folders Already Added;
- sidebar shows Add an Archive Folder;
- center panel is empty.

NO REFERENTIAL HIGHLIGHT

Unlike the duplicate-folder case, an invalid arbitrary folder has no existing sidebar object corresponding to it.

Therefore:

- no orange pulse;
- no lingering orange correspondence;
- no blue cartouche selection;
- no sidebar object is changed at all.

The modal is the complete notification.

MODAL

Use the same established modal presentation approach as the duplicate-folder boundary.

Representative copy:

This folder doesn’t appear to contain a Messages archive.

Choose a folder containing Messages data if you want to add an archive.

[ OK ]

Derive final concise wording from existing product terminology.

Do not make the modal chatty or technical.

Do not expose:

- filesystem paths;
- SQLite terminology;
- GUIDs;
- source identity;
- mutation authority;
- graph terminology.

If a concise detail such as “Messages database not found” is useful, keep it secondary rather than turning the dialog into diagnostics.

Do not include a Choose Another Folder button in the modal unless there is strong existing interaction precedent requiring it. Dismissing returns the user to the stable hub, where Add an Archive Folder already owns that action.

NO “CHOOSE ANOTHER FOLDER”

Do not show the phrase Choose Another Folder after this failed attempt.

That wording implies some UI owner is retaining the history of the previous attempt.

The sidebar owns only the stable action:

Add an Archive Folder

The failed selection is over.

CENTER PANEL

The center panel must never become the ordinary error surface for this early rejection.

During/after this invalid-folder outcome, do not leave:

- failed instrumentation;
- error Narrator;
- Details;
- folder-changing controls;
- stale inspection facts.

Once rejection occurs, the add presentation context terminates.

The hub center remains empty.

ERROR CLASSIFICATION

Trace the current source-inspection failure cases before editing.

For this slice, identify which failures mean:

“This selected folder cannot currently establish a valid archive candidate.”

At minimum cover the observed deterministic case:

- required Messages database/chat.db absent.

If existing code has closely equivalent structural qualification failures that clearly belong to the same pre-context boundary, handle them consistently.

Do NOT casually sweep operational failures into this modal model if they occur after a valid archive context has actually been established.

In particular, preserve the distinction between:

A. FOLDER DOES NOT QUALIFY
No usable archive context was established.
→ modal
→ hub

B. VALID ARCHIVE CONTEXT + LATER OPERATION FAILURE
Meaningful archive work had begun and failed.
→ belongs to the later Narrator/Directed Instrumentation failure design, not this slice.

Document the exact boundary you find.

PERSISTENCE / MUTATION

An invalid-folder selection must not:

- register a historical source;
- persist it as an added folder;
- create/update imported source facts;
- start import;
- start projection;
- alter graph data;
- alter archive payloads.

If current preflight diagnostics are retained transiently for support purposes, they must not cause sidebar membership or center-panel context to survive the rejection.

MODAL / SESSION SAFETY

Reuse the session-safe modal lifecycle established for duplicate handling where appropriate.

A modal completion from an abandoned Historical Archives presentation session must not restore or change current presentation state.

If the user navigates away while the invalid-folder modal is open, later dismissal must not resurrect Historical Archives context.

No orange timer/reference lifecycle is needed for this branch.

MECHANICAL IMPOSSIBILITY

After invalid-folder rejection, the presentation should be structurally incapable of exposing:

- Import Archive;
- Remove from MessageLens;
- Choose Another Folder;
- archive-management Details;
- source-specific center-panel content.

There is no archive object or valid add journey to which those controls could belong.

TESTS

Add focused tests proving:

1. selecting a folder without the required Messages database enters the invalid-folder rejection branch;

2. no valid add-archive center-panel context survives;

3. the add presentation context terminates;

4. the virgin hub is restored;

5. an explanatory modal is presented;

6. center panel remains empty;

7. sidebar continues to show Add an Archive Folder;

8. no Choose Another Folder action appears;

9. no cartouche becomes blue-selected;

10. no orange correspondence is emitted;

11. dismissing the modal leaves the virgin hub unchanged;

12. navigation away while the modal is active cannot cause stale state to return after dismissal;

13. the invalid folder is not added to Folders Already Added;

14. no historical source registration/import/projection/removal occurs;

15. genuinely valid new folders continue into the existing inspection path unchanged;

16. duplicate imported folders continue to use the separate modal + orange-reference behavior from Prompt 17.

SCOPE / NON-GOALS

Do not:

- redesign valid new-folder inspection yet;
- redesign import running/completion;
- redesign later operational failures;
- redesign removal;
- change source identity;
- change source registry semantics;
- change archive persistence;
- change mutation authority;
- change DateConverter;
- change database schema;
- create generic error/modal/workflow infrastructure.

Reuse the smallest existing presentation seams.

DOCUMENTATION

Create the next Feature 26 implementation record under responses/.

Document the broader boundary now established:

A selected folder does not earn center-panel add/import context until it has qualified as a usable new archive.

Document the distinction:

duplicate existing archive
→ modal → hub → orange points to existing object

invalid arbitrary folder
→ modal → hub → no reference

valid new archive
→ earns add/import center-panel context

Update version/changelog according to repository rules.

VERIFICATION

Run focused Historical Archives workflow/panel/modal tests, Settings tests as appropriate, architecture tripwires, flutter analyze, formatting, and git diff --check.

Commit and push if clean.

STOP after this slice.

Do not continue into valid new-folder inspection/import redesign.

Report:

- exact qualification boundary used;
- which failure cases are handled as pre-context modal rejection;
- confirmation that invalid selection leaves the center panel empty;
- confirmation that no orange/blue sidebar state is generated;
- confirmation that no durable source/import state changes;
- manual review instructions for selecting an arbitrary non-Messages folder.
