---
tier: project
scope: production-archive-recovery
owner: agent-per-project
last_reviewed: 2026-08-17
source_of_truth: implementation-record
links:
  - 10-HISTORICAL-ARCHIVES-NARRATOR-DIRECTED-INSTRUMENTATION-DESIGN.md
  - 12-NARRATOR-SLICE-01-IMPLEMENTATION.md
tests:
  - test/features/settings/application/historical_archives_workflow_panel_model_provider_test.dart
  - test/features/settings/application/sidebar_cassette_spec/providers/historical_archives_sidebar_known_sources_provider_test.dart
  - test/features/settings/application/sidebar_cassette_spec/widget_builders/historical_archives_settings_supplemental_content_test.dart
  - test/features/settings/infrastructure/repositories/archive_source_inspection_repository_test.dart
  - test/features/settings/infrastructure/repositories/import_ledger_historical_archive_imported_source_lookup_test.dart
  - test/features/settings/presentation/view/historical_archives_panel_test.dart
---

# Narrator Already-Imported Reference Signal Implementation

## Scope

This bounded slice recognizes when the folder selected in Historical Archives
already corresponds to source-scoped messages imported into MessageLens. It
adds one truthful Narrator branch, directs attention to the matching known
source, and repairs the distinct-GUID comparison denominator exposed by the
manual rehearsal.

Import-running, completion, removal, source persistence, and archive mutation
behavior are unchanged.

## Imported Truth

The selected folder is resolved through the existing Historical Messages
archive folder resolver. That produces the canonical source key used by source
registration and import.

An archive is classified as already imported only when both facts hold:

1. the source key exists in the source-scoped import ledger; and
2. that source ID has a positive source-scoped message count.

A source registration created by preflight alone therefore does not count as
an imported archive. Sidebar labels, prior workflow summaries, and overlay
last-run metadata do not authorize this classification.

## Narrator Branch

When inspection resolves to an imported source, the ordinary ready-for-import
composition stops. The center panel says:

```text
This archive is already part of MessageLens.
```

It shows only current source facts:

- Messages;
- Dates;
- Status: Already imported.

No **Import Archive**, **New to MessageLens**, or **Already represented**
presentation is emitted. **Choose Another Folder** remains available. Existing
removal policy is unchanged and is not broadened into this composition.

## Canonical Sidebar Reference

The center branch and sidebar target both use the same canonical source key.
The matching known-source cartouche receives the existing orange referential
grammar: orange means "this is the thing being referred to," not warning,
failure, or selection.

The cartouche receives one 760 ms presentation pulse when the workflow makes a
fresh transition into the already-imported state, then settles into persistent
referential chrome. Reduced-motion presentation retains the persistent signal
without animation.

`pulseOccurrence` is monotonically increasing process/presentation state only.
It is not persisted, does not participate in source identity, and does not
become archive metadata. The source key answers which archive; the occurrence
answers only that a fresh "look here" event happened. Rebuilds carrying the
same occurrence do not replay the pulse. Selecting another source clears the
reference.

## Comparison Arithmetic Correction

Source inspection already counted distinct source GUIDs. The graph side
previously counted every source-scoped graph row whose GUID matched, so one
logical message observed in multiple sources could be counted more than once.
That produced the impossible rehearsal presentation:

```text
Messages               8,882
Already represented   15,395
New to MessageLens    -6,513
```

The graph query now counts `DISTINCT guid`, restoring one semantic denominator
on both sides. Source-scoped observations remain intact as internal graph
facts; they simply are not presented as multiple represented messages.

The panel projection also requires comparison evidence to be internally
coherent before displaying it: counts must be nonnegative, new plus represented
must equal the comparable distinct-GUID population, and that population cannot
exceed the source message count. Incoherent evidence is reported as
unavailable rather than clamped or cosmetically repaired.

## Persistence

No database schema or persistence-format change was introduced. The overlay
known-source record still stores its existing source path and workflow facts.
Its canonical source key is derived at read time using the existing source
identity rule. Pulse state is never stored.

## Verification

- Focused Historical Archives workflow, source lookup, source inspection,
  source metadata, sidebar, resolver, panel, and graph-admission tests: passed,
  43 tests.
- Architecture tripwires: passed, 374 tests.
- `flutter analyze`: no issues.
- `dart format`: clean for touched handwritten Dart files.
- `git diff --check`: clean.

No archive import, removal, source mutation, database mutation, GUI operation,
production-data operation, staging operation, donor access, or attachment
operation was performed by this implementation pass.
