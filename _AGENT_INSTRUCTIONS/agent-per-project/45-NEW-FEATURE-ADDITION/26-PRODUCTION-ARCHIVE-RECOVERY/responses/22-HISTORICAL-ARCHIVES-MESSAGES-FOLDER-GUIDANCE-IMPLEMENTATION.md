# Historical Archives Messages Folder Guidance Implementation

## Outcome

Historical Archives remains the umbrella Settings concept. In its current
macOS Messages-source arm, the sidebar action now names the concrete object the
human must locate:

> Add a Messages Folder

The existing folder chooser action and workflow seam are unchanged.

## Sidebar Ownership

The sidebar now provides compact orientation before Finder opens. It explains
that the user should select a Messages folder containing `chat.db`, not the
`chat.db` file itself. It shows the normal location without embedding a user
name:

> Home → Library → Messages

It also states that older copies may have moved, been renamed, or live on
another drive.

This guidance belongs with the sidebar action it supports. It is hidden with
that action once an add-archive presentation context begins. It carries no
inspection evidence, selected-folder identity, workflow state, or persistence
authority.

## Truthful Source Contract

Current source inspection requires:

- the chosen object to be a real directory; and
- that directory to contain a regular file named `chat.db`.

An `Attachments` directory is observed when present but is not required for
this Messages-history ingestion path. The guidance therefore describes it as
optional and does not alter source qualification.

## Center Panel Boundary

The virgin Historical Archives hub remains silent. Reading the folder-location
guidance does not create center-panel context. The center panel continues to
appear only after the user has earned a valid workflow or selected-source
context through the existing boundaries.

## Scope Preserved

This change does not alter:

- source inspection or qualification;
- source identity or registration;
- import, removal, or archive mutation;
- persistence or database schema;
- duplicate-folder or invalid-folder handling;
- known-source cartouche membership; or
- the future MessageLens-data-folder arm.

## Verification

Focused coverage verifies the new action wording, truthful guidance, absence
of a hard-coded user path, optional `Attachments` language, unchanged chooser
callback, hidden action/guidance during the add journey, and unchanged source
cartouche behavior. Existing panel coverage continues to prove the virgin hub
center panel is empty and duplicate/invalid-folder boundaries remain modal.

Verification completed with:

- 28 focused Historical Archives sidebar, panel, and source-inspection tests;
- all 101 Settings tests;
- all 374 architecture tripwires;
- a clean `flutter analyze`;
- formatting; and
- `git diff --check`.
