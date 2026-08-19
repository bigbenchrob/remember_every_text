Work on branch Ftr.archive-recovery.

This prompt is PRE-APPROVED for implementation. After your planning pass, proceed directly with the bounded implementation described here without stopping for another approval, provided your investigation confirms the assumptions and hard invariants below. If you discover a conflict that would require broadening scope or changing an invariant, stop and report instead.

Suggested prompt name:

prompts/21-HISTORICAL-ARCHIVES-MESSAGES-FOLDER-GUIDANCE.MD

This is the next small Historical Archives Messages-folder UX refinement.

Do not proceed into import-running/completion or MessageLens-data-folder ingestion yet.

CURRENT PROBLEM

In the virgin Historical Archives hub, the sidebar currently offers:

Add an Archive Folder

Clicking it immediately opens the macOS folder chooser.

Manual review shows that this asks too much implicit knowledge from the user:

- What is an “archive”?
- Am I looking for a file or a folder?
- What should the folder contain?
- Where would macOS normally have stored it?
- If this is an old Mac or external drive, does the folder still have to be in its original location?
- Is a former live Messages folder really an “archive”?

The user should understand what they are looking for before Finder appears.

TERMINOLOGY CORRECTION

Within the current macOS Messages-folder arm, change the sidebar action from:

Add an Archive Folder

to:

Add a Messages Folder

“Historical Archives” remains the umbrella Settings feature.

The object the human is choosing is specifically a macOS Messages folder.

Do not require the human to adopt MessageLens’s abstract “archive” terminology in order to locate it.

SIDEBAR GUIDANCE

Use the available space below Add a Messages Folder to provide concise guidance before the file chooser opens.

The guidance should explain:

1. macOS stores Messages history in a folder containing a database file named:

chat.db

2. Its normal location on a Mac is conceptually:

Home → Library → Messages

Use the repository’s established conventions for displaying paths or breadcrumb-like filesystem locations.

Do not hard-code a username.

3. Older copies may:

- live on another disk;
- have been copied elsewhere;
- have been renamed.

That is fine.

4. The user should choose the FOLDER CONTAINING chat.db, not the chat.db file itself.

This distinction should be particularly clear because the native folder chooser may visibly show chat.db while asking the user to “Use This Folder.”

5. An Attachments folder may also be present and may contain images, videos, and other message attachments.

IMPORTANT: Attachments is NOT required for this Messages-history ingestion path.

The current historical import has already been validated with a source containing chat.db but no Attachments folder.

Do not tell the user that Attachments is mandatory.

Do not change the existing qualification rule merely for this copy task.

REPRESENTATIVE COPY

Do not treat this as mandatory final wording, but aim for approximately this information density and tone:

What am I looking for?

Choose a copy of your Mac’s Messages folder — the folder containing chat.db.

It is normally found at:

Home → Library → Messages

Older copies may be on another drive, moved somewhere else, or renamed. That’s fine.

The folder may also contain an Attachments folder with images, videos, and other message attachments.

Keep the prose compact enough that the sidebar remains calm.

Do not turn this into a troubleshooting manual.

Do not introduce SQLite, database schema, GUID, graph, source-scoped identity, or other implementation terminology.

CENTER PANEL RESPONSIBILITY

Preserve the current hub rule:

- virgin hub center panel remains empty;
- explanatory folder-location guidance belongs in the sidebar because it supports the sidebar action;
- clicking Add a Messages Folder starts the existing folder-selection flow;
- no center-panel content appears merely because the user is reading the guidance.

This is an important responsibility boundary.

SIDEBAR INFORMATION HIERARCHY

The virgin Messages-folder hub should read conceptually as:

Historical Archives

[brief existing orientation]

Folders Already Added
[existing imported-source cartouches]

Add a Messages Folder

[small explanation of what folder to locate]

The guidance should be visually subordinate to the action and should not compete with Folders Already Added.

Do not put the guidance inside each cartouche.

FUTURE MESSAGE LENS DATA FOLDER ARM

Do not implement it in this task.

However, avoid wording that would make the future structure impossible.

The likely future Historical Archives sidebar may distinguish:

Messages Folders
MessageLens Data Folders

possibly through the same kind of segmented control used elsewhere in MessageLens.

This task owns only the Messages-folder arm.

Do not add the toggle yet.

Do not add explanatory copy about MessageLens data folders yet.

VALIDATION OF CURRENT SOURCE REQUIREMENT

Before editing copy, confirm from current inspection code that the minimum deterministic structural requirement for this existing selection path remains the regular chat.db requirement established by the recent invalid-folder work.

If current code requires something materially different, report the discrepancy before encoding misleading copy.

Do not change source qualification behavior in order to make the copy true.

MECHANICAL RESPONSIBILITY

Preserve:

Sidebar:

- identifies existing imported folders;
- initiates Add a Messages Folder;
- explains what object the user needs to locate.

Native folder chooser:

- lets the human select that folder.

Folder-selection boundary:

- rejects invalid folders through the existing modal;
- rejects already-added folders through the existing duplicate modal/reference behavior;
- allows a genuinely valid new source into the add/import journey.

Center panel:

- remains empty until a valid center-panel context has actually been earned.

TESTS

Add/update focused tests proving:

1. virgin hub action reads Add a Messages Folder;

2. old Add an Archive Folder wording is absent from this Messages-folder hub action;

3. guidance explains that the chosen object is a folder containing chat.db;

4. guidance communicates the normal Home → Library → Messages location without hard-coded user identity;

5. guidance allows moved, renamed, or external-drive copies;

6. guidance does not claim Attachments is required;

7. center panel remains empty in the virgin hub;

8. clicking Add a Messages Folder still invokes the existing folder chooser/action seam;

9. duplicate-folder and invalid-folder boundary behavior is unchanged;

10. Folders Already Added membership/cartouche behavior is unchanged;

11. no import/removal/source/persistence semantics change.

SCOPE / NON-GOALS

Do not:

- redesign the native chooser;
- redesign valid-source inspection yet;
- redesign import-running/completion;
- redesign removal;
- add the future Messages Folder / MessageLens Data Folder toggle;
- change source qualification;
- change source identity;
- change persistence;
- change DateConverter;
- change mutation authority;
- change database schema;
- perform GUI archive mutations.

DOCUMENTATION

Create the next Feature 26 implementation record under responses/.

Document:

- Historical Archives remains the umbrella concept;
- Messages Folder is the concrete object selected in this arm;
- sidebar owns pre-chooser orientation;
- chat.db is the required structural clue;
- Attachments is optional for this ingestion path;
- center panel remains silent until context is earned.

Update version/changelog according to repository rules.

VERIFICATION

Run focused Historical Archives sidebar/panel tests, Settings tests as appropriate, architecture tripwires, flutter analyze, formatting, and git diff --check.

Commit and push if clean.

STOP after this refinement.

Do not proceed into valid-folder inspection/import redesign.

Report:

- final button wording;
- final sidebar guidance;
- structural requirement confirmed from code;
- confirmation that Attachments remains optional;
- confirmation that the center panel remains empty in the virgin hub;
- manual review instructions.
