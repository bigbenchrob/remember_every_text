---
tier: project
scope: production-archive-recovery
owner: agent-per-project
last_reviewed: 2026-08-21
source_of_truth: implementation-record
links:
  - ../prompts/41-RESPONSE-TO-AUDIT-02.md
  - ./40-HISTORICAL-ARCHIVES-ARCHITECTURE-CONFORMANCE-AUDIT.md
  - ./41-HISTORICAL-ARCHIVES-TYPED-PRESENTATION-STATE-IMPLEMENTATION.md
  - ../../../09-CROSS-COLUMN-LAYOUT/00-cross-column-layout-contract.md
  - ../../../09-CROSS-COLUMN-LAYOUT/07-column-specific-shared-track-boundaries.md
tests:
  - test/architecture/historical_archives_typed_presentation_state_test.dart
  - test/essentials/navigation/presentation/layout/historical_archives_page_track_plan_test.dart
  - test/features/settings/application/historical_archives_workflow_panel_model_provider_test.dart
  - test/features/settings/presentation/view/historical_archives_panel_test.dart
---

# Historical Archives Stable Center Track Skeleton

## Result

Historical Archives now has one center-column shared Track boundary for every
sealed presentation variant:

```text
center shared lifetime: A -> I
center native-flow seam: after I
```

Before this correction, hub-family presentation rendered no center Track
cells, selected-source presentation consumed A-E, and candidate/import/removal
presentation consumed A-I. The visible results could look intentional, but the
page skeleton changed with transient workflow state.

One `_HistoricalArchivesCenterTrackScaffold` now consumes every resolved page
Track for Column 2 and exposes one optional native-flow body after I. Hub,
selected-source, and Narrator/operation presentations all use that scaffold.

## Current Page-Specific Track Composition

Track letters remain ordinal geometric coordinates. The descriptions below
record current Historical Archives occupancy; they do not assign semantics to
the generic Track model.

| Track | Column 1 current occupant | Column 2 current occupant | Resolution and empty presentation |
| --- | --- | --- | --- |
| A | Historical Archives umbrella/context | none | shared height comes from A1; A2 consumes it empty |
| B | Mac Messages / MessageLens source control | none | shared height comes from B1; B2 consumes it empty |
| C | fixed source-control-to-section transition | none | shared height comes from C1; C2 consumes it empty |
| D | Folders Already Added heading | none | shared height comes from D1; D2 consumes it empty |
| E | fixed heading-to-cartouche-list transition | none | shared height comes from E1; E2 consumes it empty |
| F | none | page-title presentation contract | F2 keeps its natural title allocation; title may be visually absent |
| G | none | fixed title-to-Narrator transition | center-only structural allocation |
| H | none | fixed two-line Narrator presentation contract | Narrator may be silent without collapsing H |
| I | none | fixed Narrator-to-body transition | center-only structural allocation |

Column 1 declares E as its final shared Track and then resumes its native
sidebar flow. Column 2 declares I as its final shared Track and then resumes
its feature-owned body flow. The two declared boundaries are both stable.

## Variant By Track Audit

All variants consume A-I in Column 2. `empty` below means no visible
presentation in the resolved allocation; the structural Track remains.
`transition` is an existing fixed-height occupant in the page matrix.

| Sealed variant | A-E | F | G | H | I | After I |
| --- | --- | --- | --- | --- | --- | --- |
| `HistoricalArchivesHubState` | empty | empty | transition | silent | transition | empty |
| `HistoricalArchivesDuplicateNoticeState` | empty | empty | transition | silent | transition | empty behind modal |
| `HistoricalArchivesInvalidNoticeState` | empty | empty | transition | silent | transition | empty behind modal |
| `HistoricalArchivesImportSuccessNoticeState` | empty | empty | transition | silent | transition | empty behind modal |
| `HistoricalArchivesKnownSourceReferenceState` | empty | empty | transition | silent | transition | empty |
| `HistoricalArchivesInspectingCandidateState` | empty | title | transition | Narrator | transition | directed evidence |
| `HistoricalArchivesInspectionFailedState` | empty | title | transition | Narrator | transition | failure evidence/actions |
| `HistoricalArchivesReadyToAddState` | empty | title | transition | Narrator | transition | evidence/actions |
| `HistoricalArchivesExistingSourceState` | empty | empty | transition | silent | transition | selected-source story/actions |
| `HistoricalArchivesImportingState` | empty | title | transition | Narrator or truthful silence | transition | Directed Instrumentation |
| `HistoricalArchivesImportFailedState` | empty | title | transition | Narrator | transition | failure instrumentation/actions |
| `HistoricalArchivesRemovingState` | empty | title | transition | Narrator or truthful silence | transition | Directed Instrumentation |
| `HistoricalArchivesRemovalFailedState` | empty | title | transition | Narrator | transition | failure instrumentation/actions |

The page-title decision is an exhaustive switch over the sealed presentation
state. It is not inferred from nullable fields. The Track boundary itself has
no switch and no state input.

## Native-Flow Seams

The sidebar and center intentionally resume independent flow at different
coordinates:

```text
Column 1: A-E -> variable cartouche list and remaining sidebar content
Column 2: A-I -> selected-source story or operation/evidence body
```

The cartouche list remains variable-height sidebar content. Its total height,
selected row, and scroll position do not contribute to F-I and cannot move the
center story. No selected-row synchronization or scroll coordination was
introduced.

The selected-source story now reaches the same post-I seam as all other center
states. This adds the already-approved F-I structural allocation above that
story compared with the former A-E escape point. The story copy, internal
composition, controls, and sidebar behavior are unchanged.

## Removed State-Dependent Layout Paths

The implementation removed three alternate Track roots:

- the hub's bare center `ColoredBox`, which bypassed Track consumption;
- the selected-source-only A-E `TrackCellView` loop;
- the Narrator/operation-only A-I `TrackCellView` loop.

There is now exactly one scoped center loop over the resolved matrix's Track
IDs and one post-Track body location. No state-specific Matrix constructor,
conditional Track insertion, top offset, or spacer stack was added.

## Spacing And Scroll Audit

The real page path contains one center `SingleChildScrollView`. Its children
are the A-I `TrackCellView`s followed by the optional body. Body padding has
horizontal and bottom insets only; it contributes no top alignment.

Existing `SizedBox`, `Padding`, `Center`, and `ConstrainedBox` uses inside the
selected-source story and Directed Instrumentation remain local compound
presentation geometry. The old no-scope defensive rendering path retains its
existing local title/Narrator spacing for isolated rendering, but it is not the
page's Track-enabled layout path. No page-composition spacing was added outside
the matrix.

## Mechanical Guarantees

- Hub and modal-backed hub variants cannot omit the center skeleton.
- Selected-source presentation cannot leave shared coordination after E.
- Import or removal cannot insert F-I when an operation begins.
- Narrator silence cannot remove H or move the post-I body seam.
- A navigation reset to hub changes visible content, not center geometry.
- A future sealed variant must make an explicit title-visibility decision,
  while the common renderer gives it the same A-I boundary automatically.

## Verification

The focused implementation tests prove:

- the page matrix owns A-I while the sidebar boundary remains A-E;
- the hub renders all nine empty center cells;
- the selected-source body and operation body share the post-I coordinate;
- all 13 sealed variants make an exhaustive title-occupancy decision;
- one and only one center Track loop exists;
- the fixed Narrator height survives truthful silence;
- the selected-source story does not acquire a redundant page title.

Verification completed with:

- 87 focused Historical Archives model, layout, Track, sidebar, panel, and
  architecture tests passed;
- the complete Settings suite: 136 passed;
- the complete architecture suite: 384 passed;
- the complete Flutter suite: 1,840 passed;
- `flutter analyze`: no issues;
- formatting verification: no changes required;
- `git diff --check`: clean;
- macOS debug build: succeeded at
  `build/macos/Build/Products/Debug/MessageLens Development.app`.

The build retained the pre-existing `volume_controller` privacy-manifest
warning and completed successfully. Audit finding D2 is resolved. D3 source
identity remains a separate, unchanged concern.
