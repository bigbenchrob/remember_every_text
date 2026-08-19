Work on branch Ftr.archive-recovery.

This prompt is PRE-APPROVED for implementation. After your planning pass, proceed directly with the bounded implementation below without stopping for another approval, provided investigation confirms the assumptions and hard invariants. Stop only if the work would require broadening scope or changing an invariant.

Suggested prompt name:

prompts/22-HISTORICAL-ARCHIVES-SOURCE-TYPE-SEGMENTED-CONTROL.MD

This is a small Historical Archives sidebar information-architecture slice.

Do not implement MessageLens data-folder ingestion yet.

CURRENT DESIGN PROBLEM

The Historical Archives sidebar is currently being polished around only one source type: macOS Messages folders.

We already know that Historical Archives will eventually contain two closely related source types:

- macOS Messages Folders
- MessageLens Data Folders

The workflow/UI for those two arms is expected to be very similar, but the underlying source specialists will differ.

We have reached the point where continuing to refine the sidebar without representing this distinction will cause us to polish the wrong hierarchy.

GOAL

Introduce the source-type segmented control now so the permanent sidebar hierarchy becomes visible before further spacing/copy work.

Historical Archives remains the umbrella Settings feature.

Immediately below the umbrella-level introduction, add a segmented control conceptually:

Messages Folders | MessageLens Data Folders

For this slice:

- Messages Folders is selected and functional.
- MessageLens Data Folders is visible but disabled.
- The disabled segment must not pretend that a workflow exists yet.

Do not implement any MessageLens-data-folder behavior.

WHY DISABLED

Do not make MessageLens Data Folders clickable if clicking it would do nothing.

A control must truthfully represent an available interaction.

The purpose of showing the disabled segment now is structural:

- it establishes the future two-arm information architecture;
- it clarifies that the content below belongs specifically to Messages Folders;
- it lets us remove redundant headings and judge the sidebar hierarchy correctly.

SIDEBAR HIERARCHY

The current Messages-folder arm should read conceptually as:

Historical Archives Settings identity

[brief umbrella explanation]

[ Messages Folders | MessageLens Data Folders ]
second segment disabled

Folders Already Added

[existing imported Messages-folder cartouches]

Add from a Messages Folder

[Messages-folder-specific guidance]

[ Choose Messages Folder… ]

The exact spacing/copy polish is a later visual refinement, but make any minimal layout changes required so this hierarchy is structurally clear.

REMOVE REDUNDANT INNER HEADER

The sidebar currently repeats “Historical Archives” inside its content even though:

- the Settings selector already says Historical Archives;
- the page itself is Historical Archives;
- the new segmented control identifies the current source type.

Remove the redundant inner Historical Archives content heading if investigation confirms it serves no separate accessibility or structural purpose.

Do not remove the actual Settings/sidebar feature identity.

UMBRELLA EXPLANATION

The short introductory explanation above the segmented control should describe Historical Archives broadly enough to accommodate both future arms.

It should not describe only macOS Messages folders.

Keep the wording concise and truthful.

Representative meaning:

MessageLens can add older message history from preserved Messages folders or MessageLens data folders without replacing your current message data.

Do not over-polish final marketing copy in this slice.

Do not imply that MessageLens Data Folder ingestion is available yet.

If necessary, phrase the umbrella explanation more generically so the disabled segment communicates future scope without promising current capability.

MESSAGES-FOLDER ARM

Everything below the segmented control currently belongs to Messages Folders:

- Folders Already Added;
- existing Messages-folder cartouches;
- Add from a Messages Folder;
- Messages-folder location/chat.db guidance;
- Choose Messages Folder action.

Preserve all currently validated behavior:

- virgin hub center panel remains empty;
- existing cartouche selection remains blue;
- duplicate-folder modal/reference behavior remains unchanged;
- invalid-folder modal behavior remains unchanged;
- Folders Already Added contains only actually imported folders;
- Add action remains sidebar-owned.

Do not move any of these into the center panel.

FUTURE ARM BOUNDARY

Do not create generic archive-source infrastructure merely because two labels now exist.

For this slice, the segmented control is presentation structure only.

Do not add:

- MessageLens Data Folder repositories;
- source inspection;
- ingestion;
- source registry logic;
- placeholder persistence;
- fake empty known-source lists;
- new database models.

If a tiny typed presentation enum is needed to express the selected segment cleanly, keep it presentation-scoped and bounded.

The disabled MessageLens Data Folders segment should have no downstream execution path.

MECHANICAL IMPOSSIBILITY

Make it mechanically impossible for the disabled MessageLens Data Folders segment to:

- open a chooser;
- change source type;
- enter an add workflow;
- mutate state;
- create center-panel content;
- invoke any archive operation.

Messages Folders remains the only active arm.

VISUAL / CONTROL CONSISTENCY

Use the established segmented-control component/style already used elsewhere in MessageLens if one exists.

Do not invent a Historical-Archives-specific segmented control.

Respect existing light/dark mode, selected/disabled state, sizing, and accessibility behavior.

Do not create new color tokens unless required by an established shared component.

TESTS

Add/update focused tests proving:

1. Historical Archives sidebar shows a two-segment source-type control;

2. Messages Folders is selected;

3. MessageLens Data Folders is visible but disabled;

4. disabled segment cannot trigger interaction or presentation-state changes;

5. redundant inner Historical Archives heading is removed if safe;

6. umbrella introduction no longer describes only Messages folders;

7. Folders Already Added remains under the Messages Folders arm;

8. existing imported Messages-folder cartouches remain present and unchanged;

9. Add from a Messages Folder guidance remains under the Messages Folders arm;

10. Choose Messages Folder still invokes the existing chooser seam;

11. virgin hub center panel remains empty;

12. blue selection, orange reference, duplicate-modal, invalid-folder, and navigation-reset behavior remain unchanged;

13. no MessageLens Data Folder execution/persistence path is introduced;

14. no archive execution semantics change.

SCOPE / NON-GOALS

Do not:

- implement MessageLens Data Folder ingestion;
- design its qualification rules;
- redesign valid Messages-folder inspection;
- redesign import running/completion;
- redesign removal;
- perform the detailed spacing pass yet;
- change source identity;
- change persistence;
- change mutation authority;
- change DateConverter;
- change database schema;
- perform GUI archive mutations.

This task establishes sidebar architecture only.

DOCUMENTATION

Create the next Feature 26 implementation record under responses/.

Document:

- Historical Archives as the umbrella concept;
- Messages Folders and MessageLens Data Folders as the two intended arms;
- Messages Folders as the only currently enabled arm;
- why the second segment is visible but disabled;
- removal of redundant heading if applicable;
- explicit statement that no MessageLens Data Folder workflow was introduced.

Update version/changelog according to repository rules.

VERIFICATION

Run focused Historical Archives sidebar/presentation tests, tests for the shared segmented control as appropriate, Settings tests, architecture tripwires, flutter analyze, formatting, and git diff --check.

Commit and push if clean.

STOP after this slice.

Do not proceed into MessageLens Data Folder functionality or further sidebar spacing/copy refinement.

Report:

- exact segmented-control component reused;
- exact enabled/disabled behavior;
- final umbrella/sidebar hierarchy;
- redundant heading removed or reason retained;
- confirmation that MessageLens Data Folders has no execution path;
- manual review instructions.
