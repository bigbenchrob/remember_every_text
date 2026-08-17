---
tier: project
scope: production-archive-recovery
owner: agent-per-project
last_reviewed: 2026-08-17
source_of_truth: implementation-record
links:
  - 10-HISTORICAL-ARCHIVES-NARRATOR-DIRECTED-INSTRUMENTATION-DESIGN.md
tests:
  - test/features/settings/application/historical_archives_workflow_panel_model_provider_test.dart
  - test/features/settings/presentation/view/historical_archives_panel_test.dart
---

# Historical Archives Narrator Slice 01 Implementation

## Scope

This slice replaces the Historical Archives control-panel shell for four
states only:

1. no source selected;
2. source inspection running;
3. source inspection failed;
4. source understood and ready for an import decision.

Import-running, import completion, archive removal, and their failure states
continue to use the existing presentation. Their execution paths are
unchanged.

## Presentation State

`HistoricalArchivesWorkflowState` now carries an explicit presentation stage
and an optional typed `HistoricalArchivesInspectionEvidence` snapshot. The
evidence retains source facts such as message/chat/handle counts, date range,
GUID comparison counts, and diagnostic reasons without requiring the new
presentation to parse legacy summary strings.

The panel-model provider projects those facts into a
`HistoricalArchivesNarratorPresentationViewModel` containing:

- the current Narrator meaning;
- only the instrumentation rows justified by current evidence;
- collapsed diagnostic details;
- whether retry is truthful for the observed inspection failure.

This projection does not perform work or authorize mutation.

## Visible Journey

### No source

The page shows its identity, an invitation to add an older Messages archive,
the folder chooser, and collapsed Details. Empty preflight, activity, phase,
result, and execution-gate sections are absent.

### Inspecting

Folder selection still starts the existing inspection immediately. While its
real Future is unresolved, the page shows one active row:

```text
Inspecting archive source    Working
```

No synthetic substeps or generic Next action exist.

### Failed inspection

The Narrator states the human consequence. The failed Messages-database row
shows the trustworthy result. A missing database offers only **Choose Another
Folder**; a potentially transient read failure may also offer **Retry**.
Technical detail remains collapsed.

### Ready for import

Resolved rows show the actual database result, message count, date range, and
GUID comparison counts. If comparison is unavailable, the page says so rather
than presenting zeroes. The earliest date drives the Narrator statement.
**Import Archive** appears only when the existing preflight and mutation gate
permit import; **Choose Another Folder** remains available.

## Displaced Control-Panel Elements

For these four states, the new composition bypasses:

- `_ShellHeroCard`;
- permanent Execution Gate and Preflight tiles;
- permanent folder, preflight, import, activity, progress, and result cards;
- disabled import controls;
- preformatted summary arrays as primary UI input.

The old widgets remain temporarily for later lifecycle states that this slice
does not redesign.

## Diagnostics

Collapsed Details retains available folder/database paths, attachment status,
chat and handle counts, missing-GUID count, exact UTC timestamps, date-range
diagnostics, GUID-comparison method or unavailability reason, mutation-gate
status, inspection detail, and activity history.

## Existing Model Friction

The workflow historically used one preflight status enum for source
inspection, import, removal, and their failures. Presentation therefore could
not distinguish an inspection failure from a later operation failure without
interpreting labels. The explicit presentation stage supplies that lifecycle
distinction while leaving the existing execution model intact.

The workflow also retained typed source facts only in the transient preflight
result before flattening them into strings. The typed evidence snapshot closes
that presentation gap. Legacy arrays remain because later states still consume
them pending their own bounded redesign.

## Verification

- Focused Historical Archives workflow and panel tests: passed, 19 tests.
- Broader Historical Archives, source inspection, source metadata, sidebar,
  mutation coordinator, and graph-admission tests: passed, 46 tests.
- Architecture tripwires: passed, 374 tests.
- `flutter analyze`: no issues.
- `dart format`: clean.
- `git diff --check`: clean.

No archive import, removal, source mutation, staging-database mutation, or GUI
operation was performed during automated verification.
