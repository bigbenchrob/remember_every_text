---
tier: project
scope: production-archive-recovery
owner: agent-per-project
last_reviewed: 2026-08-17
source_of_truth: implementation-record
links:
  - 10-HISTORICAL-ARCHIVES-NARRATOR-DIRECTED-INSTRUMENTATION-DESIGN.md
  - 14-NARRATOR-SIDEBAR-REFERENCE-REFINEMENT-IMPLEMENTATION.md
tests:
  - test/features/settings/application/historical_archives_workflow_panel_model_provider_test.dart
  - test/features/settings/application/sidebar_cassette_spec/providers/historical_archives_sidebar_known_sources_provider_test.dart
  - test/features/settings/application/sidebar_cassette_spec/widget_builders/historical_archives_settings_supplemental_content_test.dart
  - test/features/settings/presentation/view/historical_archives_panel_test.dart
---

# Historical Archives Hub And Selection Context Implementation

This slice supersedes the prior implementation record only where that record
described known-source navigation as recognition or hid the sidebar Add action
for every active center context. The prior source-identity, orange appearance,
and occurrence findings remain historical evidence and remain valid.

## Top-Level Context

Historical Archives now has three explicit, transient presentation contexts:

- `hub`: no current archive task;
- `existingSource`: an explicit cartouche selection in the current
  presentation session;
- `addArchive`: the folder-choice, inspection, and import journey.

The initial and returning state is always `hub`. Durable source metadata does
not select an archive and cannot cause `existingSource`. Only an explicit
cartouche action establishes that context.

## Selection And Recognition

Selection and recognition are separate facts:

- a selected existing source carries an exact canonical source key and uses
  the established blue selected-object appearance;
- add-flow recognition carries a process-scoped reference occurrence and uses
  the established orange correspondence appearance.

Recognizing a chosen folder as an already-known source does not convert the
add journey into an existing-source selection. The center panel continues to
discuss the folder just chosen while orange points to the corresponding known
source. A later explicit cartouche click is required to establish blue
selected-object context.

## Hub And Existing-Source Projection

The hub center panel is deliberately quiet: it identifies Historical Archives
and asks the user to choose an existing archive or add another one. It exposes
no archive statistics, chooser controls, import action, removal action, or
stale recognition narration.

An existing-source selection projects the persisted source label, message
count, date range, and status. It does not show the add-flow recognition
narrator, **Choose Another Folder**, or **Import Archive**. **Add an Archive
Folder** remains in the sidebar in both `hub` and `existingSource`, and is
hidden only while `addArchive` owns the current context.

## Presentation Lifetime

Changing away from Historical Archives clears:

- selected known-source context;
- add-archive context;
- orange source reference;
- recognition occurrence state.

Known archive identities, counts, ranges, status, and import facts remain
durable and unchanged.

Folder choice and inspection capture a presentation-session occurrence. A
late asynchronous result may still persist truthful source facts, but it may
not update presentation unless its occurrence still matches the current
Historical Archives session. This prevents abandoned work from resurrecting a
stale center-panel context.

## Operational Boundaries

No database schema, source identity, archive import, archive removal,
attachment preservation, or mutation-coordination behavior changed. The
change is confined to transient Historical Archives presentation state and its
sidebar/center projections.

## Verification

Focused coverage proves:

- neutral hub entry with no implicit selection;
- explicit exact-key source selection;
- blue selection without orange reference chrome;
- add-flow recognition without blue selection;
- Add action visibility by presentation context;
- source-specific management presentation without add-flow controls;
- navigation-away reset without loss of durable source facts;
- rejection of late inspection results from an abandoned presentation
  session.

Verification completed with:

- all Settings tests: passed, 87 tests;
- architecture tripwires: passed, 374 tests;
- `flutter analyze`: no issues;
- `dart format`: clean for touched handwritten Dart files;
- `git diff --check`: clean.

No archive import, removal, database mutation, GUI archive operation,
production-data operation, staging operation, donor access, or attachment
operation was performed by this implementation pass.
