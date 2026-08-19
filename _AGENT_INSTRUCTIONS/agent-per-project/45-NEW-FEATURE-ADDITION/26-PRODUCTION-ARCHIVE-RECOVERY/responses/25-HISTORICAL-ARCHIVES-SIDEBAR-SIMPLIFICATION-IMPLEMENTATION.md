# Historical Archives Sidebar Simplification Implementation

## Outcome

Historical Archives now uses the fewest textual levels needed to explain the
current source arm:

```text
umbrella explanation
[ Mac Messages | MessageLens ]
Folders Already Added
Add from a Messages Folder
three short guidance paragraphs
Choose Messages Folder...
```

This remains a presentation-only change.

## Final Umbrella Copy

> Add older message history to MessageLens without replacing your current
> data.

The segmented control already communicates source choice, so the prior
instruction to choose a source below was removed without replacement.

## Final Segment Labels

The segmented control now reads:

```text
Mac Messages | MessageLens
```

**Mac Messages** remains selected and operational. **MessageLens** remains
visible but disabled before gesture dispatch. No MessageLens workflow, source
specialist, placeholder content, provider state, persistence, or archive
operation was introduced.

## Simplified Messages-Folder Guidance

The add section retains only three equal-weight supporting notes:

1. `Choose the folder containing chat.db, not the chat.db file itself.`
2. `Usually: Home → Library → Messages`
3. `Older copies can be on another drive, moved, or renamed. An Attachments
   folder may also be present, but it isn't required.`

The separate **Usually found at**, **Using an older copy?**, and **Attachments**
mini-headings were removed. The required human facts remain, and the sole
**Choose Messages Folder...** action still follows all guidance.

## Spacing

The existing `AppSpacing.sectionGap` major breaks remain between source
selection, known folders, and the add section. The add guidance now uses only
`AppSpacing.sm` paragraph spacing and one `AppSpacing.md` handoff into the
chooser. No new spacing tokens or Historical Archives-specific layout system
were added.

## Preserved Boundaries

The virgin Historical Archives hub still leaves the center panel empty. This
pass does not change known-folder membership, cartouche selection, duplicate or
invalid-folder modals, orange reference behavior, navigation reset, source
qualification or identity, import/removal behavior, persistence, mutation
authority, database schema, or Apple timestamp conversion.

## Verification

Completed verification:

- focused resolver, supplemental-content, and Historical Archives panel suite:
  26 tests passed, including exact labels and copy, disabled interaction,
  absent mini-headings, guidance ordering, the silent virgin hub, and existing
  modal, selection, reference, and removal behavior;
- complete Settings feature suite: 102 tests passed;
- architecture tripwires: 374 tests passed;
- `flutter analyze`: no issues;
- formatting check: clean; and
- `git diff --check`: clean.
