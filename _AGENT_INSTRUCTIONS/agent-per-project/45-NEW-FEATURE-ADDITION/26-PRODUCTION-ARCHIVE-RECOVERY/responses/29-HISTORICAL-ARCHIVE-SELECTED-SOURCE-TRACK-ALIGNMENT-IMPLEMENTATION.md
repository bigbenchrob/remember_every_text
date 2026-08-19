# Historical Archive Selected-Source Track Alignment Implementation

## Outcome

Historical Archives now uses the existing `PageTrackLayoutMatrix` to establish
one fixed shared vertical region above its variable sidebar and center-panel
content.

The selected-source story begins at the same y-coordinate as the known-folder
cartouche list. This makes the center content read as information about the
sidebar's archive objects rather than as a general feature introduction.

## Fixed Shared Region

Navigation owns a Historical Archives matrix containing Tracks A through E:

| Track | Column 1 occupancy | Column 2 occupancy |
|---|---|---|
| A | Historical Archives context occupant | none |
| B | source-type control occupant | none |
| C | established source-to-section spacing occupant | none |
| D | **Folders Already Added** heading occupant | none |
| E | established heading-to-list spacing occupant | none |

Column 2 consumes empty `TrackCellView`s for A-E. These are structural cells,
not visible placeholders.

The bottom edge of E is the shared handoff coordinate. Immediately after it:

- Column 1 resumes native flow with the known-folder cartouche list; and
- Column 2 resumes native flow with the selected-source story.

The list and story are not occupants of E. This is essential: the matrix shares
their starting coordinate without coupling their variable heights.

## Truthful Dimensional Claims

The visible occupants own claims derived from the presentation they construct:

- the context occupant uses `TextPainter` with the actual info-card text style,
  text scaling, locale, direction, and the canonical sidebar content width;
- the source-type occupant uses the actual segmented-control text treatment and
  the same explicit control padding supplied to its presentation; and
- the heading occupant uses `TextPainter` with the actual heading style and
  canonical sidebar content width.

Tracks C and E contain ordinary fixed-height spacing occupants using the
already-approved `AppSpacing` values. No top padding, viewport calculation, or
locally measured offset was added to the center panel.

## Multiple Cartouches

The shared coordinate is the start of the cartouche-list region, not the row of
the selected cartouche. The cartouche list remains ordinary variable-length
sidebar flow after E. One, several, or no cartouches therefore do not alter the
resolved shared geometry.

Selection remains blue object context. This slice does not introduce dynamic
row alignment, scrolling synchronization, repeated archive identity, or orange
correspondence.

## Scope Preservation

The matrix is scoped only to the active Historical Archives Settings workspace.
Inactive Messages pages cannot consume this Settings matrix, and other Settings
pages receive no Historical Archives Track scope.

The following remain unchanged:

- sidebar wording, approved spacing, cartouche layout, and Add flow;
- selected-source wording, readable width, details disclosure, and removal
  confirmation;
- hub and add-archive center presentations;
- source identity, persistence, archive execution, and mutation authority.

## Verification

Focused tests establish that:

- the matrix declares exactly A1-E1 as occupied and A2-E2 as empty;
- empty center cells receive the same resolved heights as their sidebar peers;
- sidebar native flow begins at the trailing edge of E;
- selected-source center native flow begins at the trailing edge of E;
- the cartouche itself contributes no Track height; and
- existing Historical Archives presentation and interaction tests remain green.

Completed verification:

- Settings, shared layout, and sidebar renderer suite: 153 tests passed;
- architecture tripwires: 374 tests passed;
- `flutter analyze`: no issues;
- macOS debug build: succeeded; and
- formatting and `git diff --check`: clean.
