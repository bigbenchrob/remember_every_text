---
tier: project
scope: production-archive-recovery
owner: agent-per-project
last_reviewed: 2026-08-20
source_of_truth: implementation-record
links:
  - ../prompts/38-STABLE-NARRATOR-TRACK-REMOVAL-JOURNEY-AND-TERMINAL-PERCEPTION.MD
  - ./10-HISTORICAL-ARCHIVES-NARRATOR-DIRECTED-INSTRUMENTATION-DESIGN.md
  - ./38-NARRATOR-LIFECYCLE-AND-STALE-COMMENTARY-IMPLEMENTATION.md
tests:
  - test/essentials/navigation/presentation/layout/historical_archives_page_track_plan_test.dart
  - test/essentials/conversation_graph/application/archives/source_scoped_archive_graph_import_service_test.dart
  - test/features/settings/application/historical_archives_workflow_panel_model_provider_test.dart
  - test/features/settings/presentation/view/historical_archives_panel_test.dart
---

# Stable Narrator Track, Removal Journey, And Terminal Perception

## Result

Historical Archives operation presentation now separates stable spatial
structure from optional commentary:

```text
Track F: page title
Track G: title-to-Narrator transition
Track H: two-line Narrator allocation
Track I: Narrator-to-instrumentation transition
native center flow: Directed Instrumentation
```

Tracks A-E and the Historical Archives sidebar remain unchanged. The new
center-only Tracks reserve the ordinary two-line Narrator grammar using the
established title typography and current presentation constraints. When
Narrator is silent, Track H remains structurally present but renders no visible
placeholder. Directed Instrumentation therefore keeps the same Y-coordinate.

## Removal Execution Audit

### Removing imported source facts

`ImportDatabase.deleteRowsForSource` performs ten set-based deletes inside one
SQLite transaction. Result counts are known only after the statements finish.
Splitting that efficient operation into row-by-row Dart work merely to animate
progress would be false and slower. This stage intentionally retains one
coarse working indicator.

### Updating remaining history

Removal clears the rebuildable graph projection and then runs the real ordered
projectors for:

1. Participants
2. Conversations
3. Messages
4. Attachments
5. Relationships

The removal service now emits the same typed graph-unit observations already
used by import. Existing projector callbacks provide exact completed/total
work for Conversations, Messages, and Attachments. Composite Participants and
Relationships remain truthful coarse units because they have no single honest
numeric denominator.

No elapsed-time percentage, estimated count, or synthetic work was added.

## Removal Narrator Lifecycle

Narrator is derived only from typed removal state:

```text
source contribution removal
    -> Removing the messages added from this folder.

remaining-history update
    -> Those messages are removed. Now I’m updating your remaining
       MessageLens history so everything stays together.

verification or all-Done receipt
    -> silent
```

A failure retains the commentary for the scope in which it occurred. A final
verification failure remains Narrator-silent because instrumentation and
Details own that evidence.

## Terminal Perception

Import and removal now retain their fully resolved all-Done instrument panel
for 1,500 ms. Real database work has already completed and no spinner remains.
The dwell begins only after mutation authority is released, then uses existing
presentation-session and operation-identity checks before returning to the hub
or presenting the import acknowledgement.

The dwell changes presentation lifetime only. It does not delay execution,
manufacture progress, or keep Narrator commentary alive.

## Preserved Boundaries

- Source fact deletion remains one efficient transaction.
- Archive mutation authority and maintenance admission are unchanged.
- Sidebar layout, source identity, import/removal semantics, persistence, and
  attachment preservation are unchanged.
- Existing-source presentation still leaves the shared Matrix after Track E.
- No arbitrary top padding or fixed pixel Narrator box was introduced.

## Verification

Focused coverage proves:

- center operation Tracks F-I have truthful resolved geometry;
- source, combined-history, and silent Narrator states share one stable
  Directed Instrumentation coordinate;
- removal emits all five real graph projector units and existing numeric work
  observations;
- removal commentary follows typed phase boundaries;
- verification and all-Done states are Narrator-silent;
- import and removal retain completed evidence for the bounded terminal dwell;
- stale completion cannot replace a newer presentation session.

Completed verification:

- Settings suite: 129 tests passed;
- focused maintenance, Onboarding, and graph regressions: 55 tests passed;
- architecture tripwires: 374 tests passed;
- `flutter analyze`: no issues;
- macOS debug build: succeeded at
  `build/macos/Build/Products/Debug/MessageLens Development.app`;
- `git diff --check`: clean.
