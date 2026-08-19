# Historical Archives Sidebar Breathing Room Implementation

## Outcome

The Historical Archives sidebar hierarchy was already semantically correct.
This pass uses available vertical space to separate its existing ideas more
clearly without adding information, controls, or behavior.

## Shared Spacing Tokens

The implementation uses only the established `AppSpacing` vocabulary:

- `AppSpacing.xl` (`32px`) for major conceptual breaks;
- `AppSpacing.md` (`16px`) between equal-weight guidance paragraphs;
- `AppSpacing.lg` (`24px`) between the final guidance paragraph and chooser;
  and
- the existing `AppSpacing.sm` (`8px`) between the add-section heading and its
  first paragraph.

No Historical Archives-specific spacing constants or layout system were added.

## Major Section Separation

The selector-to-**Folders Already Added** gap increased from
`AppSpacing.sectionGap` (`24px`) to `AppSpacing.xl` (`32px`).

The final known-folder cartouche or empty-state-to-**Add from a Messages
Folder** gap also increased from `24px` to `32px`. This makes existing archive
membership and the separate add-new workflow read as distinct regions.

## Guidance And Action Rhythm

The three existing guidance paragraphs keep identical copy, typography, width,
and order. Their two internal gaps increased from `AppSpacing.sm` (`8px`) to
`AppSpacing.md` (`16px`).

The pause before **Choose Messages Folder...** increased from `AppSpacing.md`
(`16px`) to `AppSpacing.lg` (`24px`), so the unchanged action reads as the
conclusion of the guidance rather than a fourth paragraph.

## Preserved Boundaries

This pass changes no copy and adds no content. It preserves:

- `Mac Messages | MessageLens`, including the disabled and inert MessageLens
  arm;
- known-folder membership and cartouche presentation;
- selection, duplicate-folder, invalid-folder, and orange-reference behavior;
- navigation reset and the empty virgin center panel;
- source qualification and identity;
- import/removal behavior, persistence, and mutation authority;
- database schema and Apple timestamp conversion; and
- all existing widths and alignments.

## Verification

Completed verification:

- focused supplemental-content and Historical Archives panel suite: 24 tests
  passed, including structural spacing tokens, content ordering, disabled
  interaction, the silent virgin hub, and existing modal, selection, reference,
  and removal behavior;
- complete Settings feature suite: 102 tests passed;
- architecture tripwires: 374 tests passed;
- `flutter analyze`: no issues;
- formatting check: clean; and
- `git diff --check`: clean.
