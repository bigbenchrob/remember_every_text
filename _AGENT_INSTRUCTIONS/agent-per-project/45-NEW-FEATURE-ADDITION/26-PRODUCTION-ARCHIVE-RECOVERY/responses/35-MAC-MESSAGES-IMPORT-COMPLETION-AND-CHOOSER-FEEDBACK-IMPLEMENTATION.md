---
tier: project
scope: production-archive-recovery
owner: agent-per-project
last_reviewed: 2026-08-20
source_of_truth: implementation-record
links:
  - ../prompts/35-MAC-MESSAGES-IMPORT-COMPLETION-AND-CHOOSER-FEEDBACK.MD
  - ./34-MAC-MESSAGES-IMPORT-RESPONSIVENESS-AND-REAL-PROGRESS-IMPLEMENTATION.md
tests:
  - test/config/theme/widgets/buttons/app_secondary_button_test.dart
  - test/features/settings/application/sidebar_cassette_spec/widget_builders/historical_archives_settings_supplemental_content_test.dart
  - test/features/settings/application/historical_archives_workflow_panel_model_provider_test.dart
  - test/features/settings/presentation/view/historical_archives_panel_test.dart
---

# Mac Messages Import Completion And Chooser Feedback

## Result

The Mac Messages Historical Archives arm now has perceptible feedback at both
ends of the add journey:

- **Choose Messages Folder...** behaves unmistakably like an interactive
  neutral control before the native folder chooser opens; and
- a terminally successful addition ends with a human acknowledgement over the
  already-restored archive hub.

No import, source-identity, graph, database, Track, or archive-mutation
semantics changed.

## Chooser Interaction

The former feature-local `DecoratedBox` / `MouseRegion` / `GestureDetector`
combination now uses the shared `AppSecondaryButton` component. The control
preserves its neutral surface, subtle border, blue action label, dimensions,
and existing chooser action seam.

Its interaction sequence is:

```text
normal secondary surface
    -> theme-owned hover composite
    -> theme-owned pressed composite + 0.98 scale
    -> existing folder chooser action
```

The pressed transition lasts 80 ms and the color transition 120 ms, but no
delay is inserted before the existing action. Pointer-up invokes the chooser
immediately.

## Terminal Success Contract

The success notice cannot exist until all of the existing terminal facts are
true:

1. source-fact import completed;
2. all five graph preparation units completed;
3. final source inspection again confirmed a readable `chat.db`;
4. source-scoped imported membership exists with a positive message count;
5. successful Historical Archives metadata was committed; and
6. all three human-facing import stages report `succeeded`.

The existing **750 ms** all-Done dwell remains. It still gives the user a
perceptible view of the final instrumentation state; the modal then provides
the durable human completion boundary, so no stage timing was inflated.

After that dwell, the workflow creates a process-only success-notice occurrence
while restoring the ordinary virgin hub. Therefore, before the modal appears:

- the center panel is empty;
- the completed source is already a legitimate member of **Folders Already
  Added**;
- the source has no orange correspondence reference; and
- the source has no automatic blue selection.

## Modal

The final wording is:

> **Messages folder added**
>
> The Messages folder you selected has been successfully added to MessageLens.
>
> You should now see the additional messages in your message timelines and
> heatmaps.

`OK` acknowledges and dismisses only that exact notice occurrence. It does not
finalize import, create or select a cartouche, mutate archive/database state,
navigate, or start another workflow.

## Session Safety

The notice carries:

- its own monotonically increasing process-only occurrence; and
- the Historical Archives presentation-session occurrence that completed the
  import.

The panel rechecks both before presenting the dialog. Dismissal also requires
both values and the unchanged hub session. Navigation reset removes the notice,
and a stale dismissal cannot alter a newer presentation. Failed, partial,
cancelled, or abandoned imports never create the notice.

## Preserved Behavior

The three top-level stages, five graph units, exact numerical progress for
Conversations/Messages/Attachments, coarse Participants/Relationships status,
duplicate orange reference, invalid-folder modal, removal journey, ready-state
controls, Tracks A-E, mutation authority, source protection, and attachment
preservation behavior are unchanged.
