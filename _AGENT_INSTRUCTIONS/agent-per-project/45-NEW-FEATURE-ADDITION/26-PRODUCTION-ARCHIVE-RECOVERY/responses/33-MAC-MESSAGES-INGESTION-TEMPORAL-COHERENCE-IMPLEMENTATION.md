---
tier: project
scope: production-archive-recovery
owner: agent-per-project
last_reviewed: 2026-08-20
source_of_truth: code
links:
  - ../00-START-HERE.md
  - 32-MAC-MESSAGES-INGESTION-NARRATOR-DIRECTED-INSTRUMENTATION-IMPLEMENTATION.md
tests:
  - test/essentials/conversation_graph/application/archives/source_scoped_archive_graph_import_service_test.dart
  - test/features/settings/application/historical_archives_workflow_panel_model_provider_test.dart
  - test/features/settings/presentation/view/historical_archives_panel_test.dart
---

# Mac Messages Ingestion Temporal Coherence

## Result

The Historical Archives add journey now has one continuous temporal owner:

```text
stable candidate
-> explicit authorization
-> visible operation
-> real graph progress
-> perceptible completed state
-> virgin hub
```

The correction changes presentation timing and observation only. It does not
change archive mutation admission, source import, graph projection, final
verification, source identity, removal, or donor safety.

## Ready-State Stability

The concrete disappearing-action defect was a presentation conditional. The
ready decision rendered **Add Messages to MessageLens** only while
`importButtonEnabled` was true. That value includes the current shared mutation
gate. An incidental busy-gate refresh therefore removed the action even though
the qualified candidate and its add journey remained valid.

The ready candidate now continues to project the same decision surface while
the gate changes. The Add action remains present and becomes disabled when
authority is temporarily unavailable. Candidate evidence, Cancel, and Details
remain present. The gate controls whether import may begin; it does not revoke
the candidate or replace its presentation.

No separate workflow path was found that conditionally removed Details while a
ready candidate remained active. Details is derived from the ready candidate's
inspection evidence. Regression coverage now proves that its content remains
present across gate availability refreshes instead of attributing the manual
observation to an unproven second state transition.

A genuine candidate transition may still remove the ready surface: explicit
authorization, Cancel, navigation away, failed qualification, or another real
source-state change.

## Cancel Ownership

The ready secondary action is now **Cancel**, not **Choose Another Folder**.
Cancel abandons only the current add attempt and restores the virgin hub. It
does not reopen the folder chooser, select a source, create correspondence, or
request archive mutation. Once the hub returns, the sidebar again owns the
choice to begin another folder-selection attempt.

## Authorization And Immediate Presentation

Authorization synchronously moves the workflow from `addArchive` to
`importingArchive` before asking `ArchiveMutationCoordinator` to run the
operation. A second activation therefore no longer satisfies the ready-state
precondition and cannot acquire a second import.

After publishing the already-truthful operation state, the workflow yields one
event-loop turn. This is not a delay or simulated work. It gives Flutter an
opportunity to replace the decision surface with Narrator and Directed
Instrumentation before source import and graph projection begin. The first
real service observation then changes **Adding messages from this folder** to
Working.

The primary action uses the established MessageLens primary-button component,
including its normal enabled, disabled, hover, and pressed behavior. Historical
Archives adds no private interaction colors or animation.

## Preparing Conversations Audit

The long **Preparing conversations for browsing** stage contains seven ordered
projector calls:

1. handles;
2. chat-to-handle edges;
3. chats;
4. messages;
5. attachments;
6. chat-to-message edges;
7. message-to-attachment edges.

Those calls already form five truthful, human-comprehensible execution units:

| Unit | Existing work |
|---|---|
| Participants | handles and chat-to-handle relationships |
| Conversations | chats |
| Messages | messages |
| Attachments | attachments |
| Relationships | chat-message and message-attachment relationships |

The graph import service now emits one descriptive observation at the start of
each unit. Directed Instrumentation presents the active unit and the number of
fully completed units, from `Participants · 0 of 5` through
`Relationships · 4 of 5`, before the real stage becomes Done.

Both numerator and denominator come directly from this fixed executed
sequence. No timer advances progress, no elapsed-time estimate is shown, and
no record-level percentage is invented. The individual projectors currently
expose no truthful within-projector denominator, so this slice deliberately
does not claim finer progress.

If graph preparation fails, its last real unit and count remain visible beside
Failed. Completion is never inferred from the count alone.

## Completion Dwell

Final source verification must succeed and all three real import stages must
be Done before presentation enters completion dwell. The admitted operation
has already returned and database work is complete at that point.

The all-Done instrumentation remains visible for **750 ms**. No spinner remains
active, no work is delayed, and no stage is made artificially long. The delay
belongs only to presentation so the completed state can be perceived. After
the bounded dwell, the workflow restores the virgin hub automatically.

The dwell carries the presentation-session occurrence that authorized the
operation. It revalidates both that occurrence and the complete import state
before clearing presentation. Navigation, Cancel/reset, or a newer add attempt
makes the old dwell powerless to mutate the newer session.

## Cartouche Semantics

Successful import no longer creates an orange reference occurrence. After the
all-Done dwell, the finalized source cartouche simply exists in its ordinary,
unselected state. It receives neither orange correspondence nor automatic blue
selection.

The duplicate-folder boundary is unchanged. A fresh duplicate attempt still
ends at its modal and, after dismissal in the same presentation session,
creates the established transient orange reference to the already-existing
cartouche. That is a real cross-UI pointing gesture; successful creation is
not.

## Preserved Boundaries

- `ArchiveMutationCoordinator` still owns import admission.
- Import and projection execute in their original order and caller-specific
  graph authority.
- Source-scoped identity, final membership verification, and retry semantics
  are unchanged.
- Current/live source facts, overlay intent, donor databases, and attachment
  preservation data are unchanged.
- Partial failure remains visible and retryable; it never enters completion
  dwell or creates finalized cartouche presentation.
- Historical Archives Tracks A-E, sidebar hierarchy, duplicate handling,
  invalid-folder handling, and removal Directed Instrumentation are unchanged.
- Legitimate admitted maintenance remains suppressed from Onboarding as before.
- Apple Messages timestamps remain exclusively owned by
  `lib/core/util/date_converter.dart`.

## Manual Staging Review

The human staging rerun should verify only presentation behavior:

1. qualify the disposable 2012 source;
2. confirm Add, Cancel, and Details remain stable while waiting;
3. activate Add once and observe the operation surface appear immediately;
4. observe real graph units advance without synthetic percentage;
5. observe all three stages Done briefly after final verification;
6. confirm the center returns to the virgin hub;
7. confirm the new cartouche is ordinary and unselected, with no orange pulse.

No automated verification in this slice opens the GUI or mutates production,
the staging archive, donor folders, or attachment payloads.
