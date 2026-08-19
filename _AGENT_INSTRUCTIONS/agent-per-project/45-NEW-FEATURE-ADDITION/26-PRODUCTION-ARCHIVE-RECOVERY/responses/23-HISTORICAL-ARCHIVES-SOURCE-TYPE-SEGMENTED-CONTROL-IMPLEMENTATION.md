# Historical Archives Source-Type Segmented Control Implementation

## Outcome

Historical Archives now presents its intended two-arm information architecture
before the Messages-folder content:

```text
Historical Archives Settings identity
umbrella explanation

[ Messages Folders | MessageLens Data Folders ]

Folders Already Added
Messages-folder cartouches

Add from a Messages Folder
Messages-folder guidance
Choose Messages Folder...
```

**Messages Folders** is selected and is the only enabled arm.
**MessageLens Data Folders** is visible but disabled.

## Shared Control

The implementation reuses the established `AppSegmentedModeControl`. The
shared component gained two backward-compatible presentation capabilities:

- an optional predicate that determines whether each option is enabled; and
- an optional maximum label-line count so truthful labels can fit narrow
  sidebar widths.

Existing callers retain their prior all-enabled, one-line behavior by default.
Disabled options use the shared disabled text color, basic cursor, disabled
semantics, no hover treatment, and a null tap handler.

## Mechanical Boundary

The source-type values are a private presentation enum in the Historical
Archives sidebar widget. No source-type provider or durable state was added.
The MessageLens Data Folders option is disabled before gesture dispatch and
therefore cannot:

- invoke the Messages folder chooser;
- alter Historical Archives workflow state;
- create center-panel context;
- persist source metadata; or
- invoke an archive operation.

No MessageLens Data Folder workflow, repository, source inspector, registry
logic, database model, or placeholder source list exists in this slice.

## Umbrella And Arm Ownership

The actual Settings selector continues to identify **Historical Archives**.
The redundant inner `SidebarInfoCard` title was removed because it supplied no
separate structural or accessibility role.

The introductory copy is now source-neutral. Everything below the segmented
control remains explicitly owned by the Messages Folders arm:

- imported Messages-folder membership and cartouches;
- the Messages-folder source-location guidance; and
- the unchanged `chooseMessagesFolder()` action seam.

The add section now names its hierarchy explicitly as **Add from a Messages
Folder**, followed by the existing guidance and **Choose Messages Folder...**
action.

## Preserved Behavior

This slice does not change:

- the silent virgin center-panel hub;
- blue selected-source presentation;
- orange duplicate-source reference presentation;
- duplicate-folder or invalid-folder modal boundaries;
- navigation reset and presentation-session guards;
- imported-source membership;
- source qualification, identity, or persistence;
- archive import, removal, or mutation authority;
- database schema; or
- Apple timestamp conversion.

## Verification

Focused shared-control and Historical Archives coverage proves selected and
disabled presentation, disabled interaction, two-line label support, removal
of the inner title, source-neutral umbrella copy, unchanged known-source
cartouches, and the unchanged Messages-folder chooser seam.

Completed verification:

- focused shared-control and Historical Archives suite: 35 tests passed;
- complete Settings feature suite: 102 tests passed;
- architecture tripwires: 374 tests passed;
- `flutter analyze`: no issues;
- formatting check: clean; and
- `git diff --check`: clean.
