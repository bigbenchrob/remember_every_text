# Historical Archives Sidebar Hierarchy Polish Implementation

## Outcome

The Historical Archives sidebar now reads in one deliberate sequence:

```text
umbrella explanation
source-type selection
folders already added
Messages-folder guidance
folder chooser action
```

This is a presentation-only refinement. It does not alter Historical Archives
workflow ownership, source identity, persistence, or archive mutation.

## Umbrella Copy

The redundant inner Historical Archives title and footnote remain absent. The
source-neutral introduction is now:

> Add older message history to MessageLens without replacing your current
> data. Choose where that history comes from below.

Messages-specific source details remain below the segmented control.

## Source-Type Labels

The permanent source-type structure is presented as:

```text
Messages Folders | MessageLens Folders
```

**Messages Folders** remains selected and operational. **MessageLens Folders**
is visible but disabled before gesture dispatch. It has no workflow callback,
provider state, source specialist, placeholder content, persistence, or archive
operation.

## Spacing Grammar

The presentation uses the shared `AppSpacing` tokens rather than local spacing
constants:

- `AppSpacing.sectionGap` (`24px`) separates the source selector, known-folder
  section, and add-folder section;
- `AppSpacing.md` (`16px`) separates guidance topics; and
- `AppSpacing.xs` / `AppSpacing.sm` (`4px` / `8px`) joins a subordinate label
  to its supporting text and a section heading to its introduction.

This makes the three major regions visually distinct without creating a
Historical Archives-specific spacing system.

## Messages-Folder Guidance

The add section now presents information in this order:

1. **Add from a Messages Folder**
2. A concise instruction to choose the folder containing `chat.db`, not the
   file itself.
3. **Usually found at** — `Home → Library → Messages`
4. **Using an older copy?** — another drive, moved, or renamed is acceptable.
5. **Attachments** — the folder may be present but is not required for adding
   message history.
6. **Choose Messages Folder...**

The chooser remains last so the user understands the required filesystem object
before Finder opens. It is still the only chooser action in the stable hub.

## Preserved Boundaries

The virgin Historical Archives hub still leaves the center panel empty. This
pass does not change cartouche membership or appearance, blue selection,
duplicate or invalid-folder modals, orange correspondence, navigation reset,
source qualification, import/removal behavior, persistence, mutation authority,
database schema, or Apple timestamp conversion.

## Verification

Completed verification:

- focused resolver, supplemental-content, and Historical Archives panel suite:
  26 tests passed, including the silent virgin hub and existing modal,
  selection, reference, and removal behavior;
- complete Settings feature suite: 102 tests passed;
- architecture tripwires: 374 tests passed;
- `flutter analyze`: no issues;
- formatting check: clean; and
- `git diff --check`: clean.
