---
tier: project
scope: production-archive-recovery
owner: agent-per-project
last_reviewed: 2026-08-17
source_of_truth: implementation-record
links:
  - 10-HISTORICAL-ARCHIVES-NARRATOR-DIRECTED-INSTRUMENTATION-DESIGN.md
  - 13-NARRATOR-ALREADY-IMPORTED-REFERENCE-SIGNAL-IMPLEMENTATION.md
tests:
  - test/features/messages/presentation/widgets/message_evidence/message_evidence_row_test.dart
  - test/features/settings/application/historical_archives_workflow_panel_model_provider_test.dart
  - test/features/settings/application/sidebar_cassette_spec/widget_builders/historical_archives_settings_supplemental_content_test.dart
  - test/features/settings/infrastructure/repositories/historical_archive_sources_repository_test.dart
  - test/features/settings/infrastructure/repositories/import_ledger_historical_archive_imported_source_lookup_test.dart
  - test/features/settings/presentation/view/historical_archives_panel_test.dart
---

# Narrator Sidebar Reference Refinement Implementation

## Responsibility Split

The center panel owns the current archive journey, its narration, evidence,
decisions, and management actions. The sidebar owns archive context, source
navigation, and referential correspondence.

Accordingly, **Add an Archive Folder** appears only while the workflow is in
the no-source presentation stage. Once a source journey exists, folder-changing
actions come from the center panel rather than competing controls in both
places.

## Known-Source Navigation

Each Known Archive Source cartouche now has one action: **show this archive**.
It passes the persisted source's canonical source key to the workflow. The
workflow resolves that exact key against the source metadata and source-scoped
import ledger; it does not match labels or infer identity from display text.

For an imported source, the center panel presents the existing
already-imported composition. For a preflight-only known source, it presents a
read-only known-source composition. Persisted source knowledge never authorizes
import: the user must choose the folder again so a fresh inspection can
establish current source truth before **Import Archive** can appear.

Clicking a cartouche does not open the chooser, inspect a folder, import,
remove, or mutate archive data. It also does not fabricate a recognition pulse.

## Referential Appearance

All Messages and Historical Archives now consume one small appearance helper
for the established orange correspondence chrome:

- background;
- border;
- glow.

The helper owns appearance only. All Messages and Historical Archives continue
to decide independently when correspondence exists, when a pulse occurrence is
created, how the pulse runs, and how reduced-motion presentation behaves. No
cross-feature pulse controller or semantic abstraction was introduced.

The Historical Archives cartouche keeps primary text legible throughout the
pulse and settled state. Orange continues to mean "this is the thing I am
referring to," not warning, failure, or selection.

## Repeated Recognition

Archive recognition state and recognition occurrence are separate. Selecting
an imported source through the folder chooser emits one process-scoped
occurrence. Selecting that same folder through a fresh chooser action emits a
new occurrence and the calm acknowledgment:

```text
That’s the same archive — it’s already part of MessageLens.
```

Provider and widget rebuilds do not increment the occurrence or replay the
pulse. Choosing another source clears or moves the reference as before.
Recognition occurrence remains presentation state only: it is not persisted
and is never used as source identity.

## Persistence And Operations

No database schema, stored metadata format, source identity rule, import
operation, removal operation, or archive mutation behavior changed. Existing
source metadata fields are exposed through the read model only so the center
panel can truthfully present a selected known source.

## Verification

Focused Historical Archives and All Messages correspondence tests cover:

- no-source versus active-journey sidebar action visibility;
- exact canonical-key cartouche navigation;
- read-only preflight-known-source behavior;
- imported known-source presentation;
- shared canonical orange appearance and text legibility;
- reduced-motion behavior;
- one pulse per recognition occurrence;
- a second occurrence from a fresh selection of the same folder;
- no pulse replay on rebuild.

Verification completed with:

- focused Historical Archives, All Messages correspondence, reduced-motion,
  and graph-admission tests: passed, 54 tests;
- architecture tripwires: passed, 374 tests;
- `flutter analyze`: no issues;
- `dart format`: clean for touched handwritten Dart files;
- `git diff --check`: clean.

No archive import, removal, source mutation, database mutation, GUI operation,
production-data operation, staging operation, donor access, or attachment
operation was performed by this implementation pass.
