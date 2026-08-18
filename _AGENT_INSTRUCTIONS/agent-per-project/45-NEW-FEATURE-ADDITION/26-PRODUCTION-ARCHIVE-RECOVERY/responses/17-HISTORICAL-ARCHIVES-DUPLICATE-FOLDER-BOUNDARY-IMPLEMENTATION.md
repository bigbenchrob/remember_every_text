---
tier: project
scope: production-archive-recovery
owner: agent-per-project
last_reviewed: 2026-08-18
source_of_truth: implementation-record
links:
  - 15-HISTORICAL-ARCHIVES-HUB-AND-SELECTION-CONTEXT-IMPLEMENTATION.md
  - 16-HISTORICAL-ARCHIVES-HUB-SEMANTIC-CLEANUP-IMPLEMENTATION.md
tests:
  - test/features/settings/application/historical_archives_workflow_panel_model_provider_test.dart
  - test/features/settings/application/sidebar_cassette_spec/providers/historical_archives_sidebar_known_sources_provider_test.dart
  - test/features/settings/application/sidebar_cassette_spec/widget_builders/historical_archives_settings_supplemental_content_test.dart
  - test/features/settings/presentation/view/historical_archives_panel_test.dart
---

# Historical Archives Duplicate-Folder Boundary Implementation

## Boundary

Selecting a folder already represented by a positive source-scoped import is a
failed **Add an Archive Folder** action. It is not selection of an existing
archive and does not establish either `existingSource` or a continuing
`addArchive` context.

Duplicate detection still uses the established canonical historical source
key and imported-source lookup. Once that lookup returns a positive imported
match, the workflow does not persist source metadata or enter the ordinary
folder-inspection result path. It restores a hub-shaped state carrying only a
one-use duplicate notice.

## Modal And Hub Ordering

The modal owns the exceptional notification:

```text
This folder has already been added to MessageLens.

You can find it under Folders Already Added.
```

The add context has already ended before the modal appears. Behind the modal,
and after it closes, the center panel is the virgin empty hub. The sidebar
action is **Add an Archive Folder**. No selected source, archive-management
context, **Import Archive**, **Remove from MessageLens**, **Details**, or
**Choose Another Folder** action is created by the failed attempt.

## Referential Gesture

Modal dismissal creates a fresh process-scoped reference occurrence only when
the notice and Historical Archives presentation-session occurrences still
match current state. A dismissal arriving after navigation reset therefore has
no sidebar effect.

The matching canonical-key cartouche then uses the existing orange
correspondence appearance:

1. 760 ms attention pulse;
2. 1.2 s gentle correspondence linger;
3. 1 s gradual fade to the ordinary unselected appearance;
4. complete removal of the reference.

Blue remains reserved for an archive explicitly selected by clicking its
cartouche. Orange remains an external pointing gesture: another interaction is
temporarily saying, "this one."

The workflow owns the bounded reference lifetime. Expiry is guarded by both
presentation-session occurrence and reference occurrence, so an older timer
cannot clear a newer reference. Widget/provider rebuilds do not create or
replay occurrences. A second folder-choice attempt creates a new notice and,
after dismissal, a new pulse.

Reduced-motion presentation retains the gentle canonical correspondence
appearance for the same bounded lifetime without running the pulse or fade
animation, then clears it completely.

## Persistence And Operations

Duplicate handling changes no durable source fact. It performs no source
registration, metadata upsert, import, removal, graph projection, database
mutation, attachment operation, or source-identity change. Genuinely new
folders continue through the existing inspection and persistence path.

## Obsolete Center Branch

The `alreadyImported` add-flow Narrator kind and its **Choose Another Folder**
decision were removed. Explicit cartouche selection remains a separate
`existingSource` presentation with blue selected-object semantics.

## Verification

Focused coverage proves modal ownership, hub restoration, canonical targeting,
no blue selection, no source persistence, post-dismissal timing, bounded fade,
rebuild replay prevention, repeated duplicate occurrences, stale-dismissal
rejection, older-expiry protection, reduced motion, and unchanged new-folder
behavior.

Verification completed on 2026-08-18:

- focused duplicate-folder coverage: 45 tests passed;
- complete Settings feature suite: 92 tests passed;
- architecture tripwires: 374 tests passed;
- `flutter analyze`: no issues found;
- `dart format`: no changes required;
- `git diff --check`: clean.

The architecture tripwire allowlists name only the two approved lifecycle
owners introduced by this slice: the workflow provider owns occurrence-scoped
reference expiry, and the Historical Archives panel owns deferred modal
presentation. The exact allowlists continue to reject use of those lifecycle
primitives elsewhere.
