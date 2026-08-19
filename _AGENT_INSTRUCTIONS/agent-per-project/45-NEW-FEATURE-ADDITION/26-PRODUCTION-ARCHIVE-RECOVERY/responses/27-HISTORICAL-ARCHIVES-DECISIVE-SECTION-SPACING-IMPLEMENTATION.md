# Historical Archives Decisive Section Spacing Implementation

## Outcome

The previous `32px` major gaps were structurally larger than the internal
spacing but remained too subtle in manual review. The sidebar still read as one
continuous stack instead of three immediately recognizable regions.

This correction makes the existing context, known-folder, and add-folder
regions perceptually distinct. It changes spacing only.

## Spacing Rhythm

The final values are:

- `56px` after the source selector before **Folders Already Added**;
- `56px` after the final known-folder cartouche or empty state before **Add
  from a Messages Folder**;
- `24px` between the three guidance paragraphs;
- `32px` between the final guidance paragraph and **Choose Messages
  Folder...**; and
- the existing compact `8px` between each section heading and its first
  subordinate item.

The major gap is composed from existing tokens:

```dart
AppSpacing.xxl + AppSpacing.sm
```

The other gaps use `AppSpacing.lg`, `AppSpacing.xl`, and `AppSpacing.sm`
directly. No global or page-specific spacing system was introduced.

## Hierarchy

Large section separation and internal paragraph rhythm remain different
layout concepts:

- `56px` identifies a new conceptual region;
- `24px` lets separate thoughts breathe while retaining one guidance block;
- `32px` establishes the handoff from explanation to action; and
- `8px` keeps headings attached to their content.

The sidebar remains top-led and content-relative. It does not distribute spare
height with flexible spacers or viewport-relative positioning.

## Preserved Boundaries

No copy, controls, source labels, cartouche content, callbacks, workflow state,
source qualification, archive identity, persistence, mutation authority,
import/removal behavior, modal behavior, reference behavior, navigation reset,
or center-panel behavior changed.

## Verification

The layout test now protects the hierarchy relationally:

```text
major section gap > guidance paragraph gap > heading/content gap
guidance-to-action gap > guidance paragraph gap
```

This avoids treating every pixel value as an external contract while ensuring
future changes preserve the intended visual grammar.

Completed verification:

- focused Historical Archives sidebar and panel suite: 24 tests passed;
- complete Settings feature suite: 102 tests passed;
- architecture tripwires: 376 tests passed;
- `flutter analyze`: no issues;
- formatting check: clean; and
- `git diff --check`: clean.
