# Historical Archive Selected-Source Story Implementation

## Outcome

Selecting a cartouche under **Folders Already Added** now produces a dedicated
selected-source presentation. It no longer sends stable archive management
through the add-flow Narrator or directed instrumentation.

The sidebar and center panel are treated as one composition:

- the selected sidebar cartouche owns archive identity; and
- the center panel owns archive meaning and management.

The center panel therefore does not repeat the feature title, source-category
label, or selected folder name.

## Primary Story

The selected-source view uses a centered `760px` readable-width constraint and
one left-aligned vertical `Column`, matching the established Historical
Archives center-panel composition. Existing `AppSpacing` tokens separate its
successive thoughts. No local grid, dashboard, or second alignment system was
introduced.

Its primary content is:

```text
This is a Mac Messages folder.

You added it to MessageLens on Aug 10, 2026.  [when supported]

It contains 8,882 messages sent or received between July 2012 and June 2017.

More Details

Remove this folder…  [when removal policy permits]
```

The exact import date and message facts vary with the selected source.

## Evidence Boundaries

The import-date sentence is derived only from
`lastImportFinishedAtUtc` when `lastImportSuccess == true`. The existing
`DateLabelFormatter` produces its human date. An absent or unsuccessful import
record produces no fallback sentence.

No numeric unique-contribution statement is shown in this slice. Current
durable source metadata does not preserve the successful import's original,
pre-import GUID comparison as a stable result:

- persisted dry-run comparison values may be refreshed after import; and
- `lastImportedMessageCount` is a source-scoped insertion count, not a count of
  messages newly added to the combined MessageLens history.

Treating either as unique contribution would repeat the denominator error that
previously produced impossible comparison values. The primary view therefore
omits the claim rather than inventing one. Technical source facts and the
distinct-GUID comparison methodology remain available under **More Details**.

## Structural Separation

`existingSource` now builds a dedicated typed presentation model and is
structurally excluded from `HistoricalArchivesNarratorPresentationViewModel`.
That makes the selected-source view incapable of inheriting:

- **Historical Archives** or **Historical Messages Archive** headings;
- the selected archive name;
- green resolved checkmarks or item/value instrumentation;
- **Import Archive**; or
- add-flow folder-choice and recovery actions.

Conversely, add-flow presentations do not receive selected-source management
controls.

## Removal Entry

The selected-source view exposes **Remove this folder…** only when the existing
removal policy permits it. The button reuses
`destructiveForeground`, `destructiveBorder`, and the ordinary control surface
from the canonical theme.

The action still opens the existing confirmation dialog. Only confirmation
dispatches the existing
`removeImportedArchiveDataForSelectedSource` action. Mutation authority,
removal execution, source identity, and persistence are unchanged.

## Verification

Focused coverage proves:

- selected-source content is separate from Narrator instrumentation;
- archive identity and feature headings are not repeated;
- trustworthy dates and human count/range prose appear;
- unsupported import and contribution facts are omitted;
- **More Details** retains forensic facts;
- removal uses canonical destructive styling and confirmation; and
- import/folder-choice actions do not enter selected-source context.

Broader verification results are recorded in the completion report and
`DOCUMENTATION_PASS_LOG.md`:

- focused Historical Archives panel/model suite: 36 tests passed;
- complete Settings feature suite: 103 tests passed;
- architecture tripwires: 374 tests passed;
- `flutter analyze`: no issues;
- formatting: clean; and
- `git diff --check`: clean.
