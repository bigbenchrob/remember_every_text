---
tier: project
scope: production-archive-recovery
owner: agent-per-project
last_reviewed: 2026-08-18
source_of_truth: implementation-record
links:
  - 17-HISTORICAL-ARCHIVES-DUPLICATE-FOLDER-BOUNDARY-IMPLEMENTATION.md
tests:
  - test/features/settings/application/historical_archives_workflow_panel_model_provider_test.dart
  - test/features/settings/presentation/view/historical_archives_panel_test.dart
---

# Historical Archives Invalid-Folder Boundary Implementation

## Qualification Boundary

A selected folder earns Historical Archives add/import center-panel context
only after it qualifies as a usable archive candidate. The current bounded
qualification rule is exact:

```text
chatDbStatusLabel == Missing
```

`Missing` covers a selected folder that no longer exists and a selected folder
that does not contain a regular `chat.db`. Neither outcome establishes an
archive candidate.

`Read failed` is deliberately not included. It means a database was present
but could not be safely inspected. That condition may represent access,
format, SQLite, or another operational failure whose semantics have not yet
been established. It continues through the existing inspection-failure path
rather than being mislabeled as "not an archive."

## Modal And Hub Ordering

When inspection returns `Missing`, the workflow replaces its in-progress add
state with the virgin hub before the modal is presented. The modal says:

```text
This folder doesn’t appear to contain a Messages archive.

Choose a folder that contains Messages data. It must contain the file chat.db.
```

The center panel remains empty behind the modal and after dismissal. The
sidebar again owns the stable **Add an Archive Folder** action. No **Choose
Another Folder**, instrumentation, diagnostics, archive details, or import and
management controls survive the rejection.

## Ephemeral Notice

The invalid-folder notice contains only:

- a process-scoped notice occurrence;
- the Historical Archives presentation-session occurrence.

It contains no folder path, source key, source label, inspection evidence, or
other archive identity. It therefore cannot become a shadow add workflow or a
place from which rejected folder state is later restored.

Dismissal clears only the exact notice occurrence in the same active
presentation session. Navigation reset removes the notice and advances the
session, so a later modal completion cannot resurrect Historical Archives or
change its current state.

## Sidebar Semantics

An invalid arbitrary folder has no existing MessageLens object. Consequently
the branch creates:

- no blue selected-object state;
- no orange external reference;
- no pulse, linger, fade, or reference timer;
- no sidebar cartouche change.

This differs intentionally from duplicate handling:

```text
duplicate existing archive
  → modal → hub → orange points to the existing object

invalid arbitrary folder
  → modal → hub → no reference

valid new archive
  → earns add/import center-panel context
```

## Persistence And Operations

The `Missing` branch returns before source metadata persistence and before a
center-panel inspection result is constructed. It performs no source
registration, imported-source update, import, projection, removal, graph
mutation, attachment operation, or source-identity change.

Genuinely valid new folders continue through the existing inspection and
persistence path. Duplicate imported folders continue through the separate
modal-plus-orange-reference boundary established by Response 17.

## Verification

Focused coverage proves `Missing` classification, hub restoration, modal
ownership, no source persistence, no selected or referenced sidebar state,
session-safe dismissal, retained `Read failed` semantics, and unchanged valid
and duplicate paths.

Verification completed on 2026-08-18:

- focused Historical Archives workflow/sidebar/panel coverage: 44 tests passed;
- complete Settings feature suite: 97 tests passed;
- architecture tripwires: 374 tests passed;
- `flutter analyze`: no issues found;
- `dart format`: no changes required;
- `git diff --check`: clean.
