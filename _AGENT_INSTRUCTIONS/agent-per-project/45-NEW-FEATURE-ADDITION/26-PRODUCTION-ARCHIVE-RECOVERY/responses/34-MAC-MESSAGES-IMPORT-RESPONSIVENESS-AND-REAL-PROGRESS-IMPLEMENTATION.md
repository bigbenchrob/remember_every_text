---
tier: project
scope: production-archive-recovery
owner: agent-per-project
last_reviewed: 2026-08-20
source_of_truth: code
links:
  - ../00-START-HERE.md
  - 33-MAC-MESSAGES-INGESTION-TEMPORAL-COHERENCE-IMPLEMENTATION.md
tests:
  - test/config/theme/widgets/buttons/app_primary_button_test.dart
  - test/essentials/conversation_graph/application/projection_work_progress_test.dart
  - test/essentials/conversation_graph/application/archives/source_scoped_archive_graph_import_service_test.dart
  - test/features/settings/application/historical_archives_workflow_panel_model_provider_test.dart
  - test/features/settings/presentation/view/historical_archives_panel_test.dart
---

# Mac Messages Import Responsiveness And Real Progress

## Result

Historical Archives now acknowledges import authorization at the presentation
boundary and exposes changing evidence from real graph work:

```text
pressed Add
-> importing state published
-> operation frame painted
-> mutation admitted
-> source import observations
-> five graph units
-> exact bounded counts where one truthful denominator exists
```

No archive, donor, staging store, production store, or attachment payload was
opened or modified during this implementation.

## Authorization-To-First-Paint Audit

The workflow already published `importingArchive` synchronously before
requesting mutation admission. Its subsequent `Future.delayed(Duration.zero)`
yielded the event loop, but did not establish a frame boundary. Provider
construction, coordinator acquisition, source-database opening, and other
synchronous setup could therefore resume before Flutter painted the new
operation surface. The user could continue seeing the ready decision while
the application had already begun expensive preparation.

The UI action boundary now supplies Flutter's next `endOfFrame` as a
presentation barrier. The workflow publishes importing ownership first, then
waits at that barrier before invoking `ArchiveMutationCoordinator`. Focused
tests hold the barrier deliberately and prove:

- importing context and stage are already effective;
- the graph-import service has zero calls;
- the mutation coordinator has zero admissions;
- completing the barrier permits exactly one admission;
- a second activation remains mechanically ineligible.

The fallback event-loop yield remains available to non-rendering tests. No
arbitrary duration or simulated work was introduced.

The resulting activation sequence is explicit:

1. pointer entry selects the hover token;
2. pointer down selects the pressed token, removes the resting shadow, and
   applies the pressed scale;
3. pointer up invokes the action callback;
4. the workflow synchronously publishes importing ownership;
5. Riverpod schedules the replacement presentation;
6. Flutter builds and paints the operation frame;
7. the frame barrier resolves;
8. the mutation coordinator begins admitted work;
9. the source service emits its first real observation.

## Primary Button Feedback

`AppPrimaryButton` already tracked hover and pointer-down state, but expressed
both by reducing the accent color's alpha. Against the surrounding surface the
result was too subtle in this composition, and its unchanged shadow and size
made pointer-down particularly difficult to perceive.

The shared component now uses semantic theme treatments:

- hover composites the existing surface-hover token over the primary accent;
- pressed composites the existing surface-pressed token over the accent;
- pressed removes the resting shadow and applies a restrained `0.98` scale;
- disabled presentation remains the existing disabled primary token.

Historical Archives adds no private color or animation. Component tests drive
a real mouse pointer through rest, hover, down, and up and verify both the
token-owned colors and one activation.

## Projector Timing Audit

An isolated disposable fixture exercised the concrete source importer and all
seven concrete graph repositories. It contained:

- 61 conversations;
- 61 handles and 61 chat-handle edges;
- 1,001 messages;
- 101 attachments;
- 1,001 chat-message and 101 message-attachment edges.

Two clean runs produced this relative evidence:

| Human unit | Run 1 | Run 2 | Fixture workload |
|---|---:|---:|---|
| Participants | 11 ms | 9 ms | 61 handles + 61 edges |
| Conversations | 6 ms | 5 ms | 61 chats |
| Messages | 86 ms | 92 ms | 1,001 messages |
| Attachments | 6 ms | 4 ms | 101 attachments |
| Relationships | 42 ms | 42 ms | 1,102 edges |

These are local fixture timings, not production duration promises. They show
that Messages is the dominant projector for message-heavy archives and that
Relationships is the second material wait. They also confirm that the
ready-state GUID comparison is not the graph denominator.

## Workload And Denominator Audit

All seven repositories already load a finite source collection and process
that collection row by row inside their existing transaction. The algorithm
was not converted from set-based SQL for presentation.

| Human unit | Mechanism | Truthful total during execution | Presentation |
|---|---|---|---|
| Participants | handles, then chat-handle edges | Each repository knows its own total; no single monotonic five-unit total exists | Coarse Working/Done |
| Conversations | one chat collection | Exact `rows.length` | Raw completed / total |
| Messages | one message collection | Exact `rows.length` | Raw completed / total |
| Attachments | one attachment collection | Exact `rows.length` | Raw completed / total |
| Relationships | chat-message edges, then message-attachment edges | Each repository knows its own total; one combined display would reset or require another counting seam | Coarse Working/Done |

Participants and Relationships deliberately remain coarse. Presenting either
repository's denominator as the whole human unit would be misleading, while
splitting them would replace the established five-unit vocabulary with seven
implementation rows.

## Numerical Progress Seam

The chat, message, and attachment projection repository contracts accept an
optional typed work observer. Each concrete repository reports:

```text
0 / exact row count
every 250 completed rows
exact terminal completed row count
```

A completed count is emitted only after that row's existing database work has
finished. Counts are monotonic and bounded by the exact collection size. No
timer, elapsed-time estimate, percentage, or ready-state message count is
involved.

The service carries those observations inside the already-established active
graph unit. The Historical Archives workflow preserves the latest truthful
count on failure. Directed Instrumentation retains the three top-level stages
and nests the five graph rows under **Preparing conversations for browsing**.
The human-facing shape is:

```text
Adding messages from this folder                    Done
Preparing conversations for browsing                Working
    Participants                                     Done
    Conversations                                    Done
    Messages                                         4,250 / 8,882
    Attachments                                      Waiting
    Relationships                                    Waiting
Checking that import finished                        Waiting
```

Raw counts were chosen instead of a progress bar. They are stronger evidence
of ongoing work, expose the actual workload directly, and avoid suggesting a
time-to-completion estimate.

## Preserved Semantics

- The top-level three-stage import story remains unchanged.
- The five graph units remain canonical and ordered.
- The 750 ms all-Done presentation dwell is unchanged.
- Terminal workflow verification, not a full count, still owns success.
- Successful import still returns to the hub without orange reference or blue
  selection.
- Cancel, duplicate-folder handling, invalid-folder handling, removal,
  source-scoped identity, caller-specific graph admission, and Tracks A-E are
  unchanged.
- Current-Mac source protection and the DateConverter-only Apple timestamp
  invariant remain unchanged.
- No database operation was made less efficient merely to animate progress.

## Manual Staging Review

The next human staging run should verify:

1. hover and hold pointer-down on **Add Messages to MessageLens**;
2. confirm both states are visually perceptible;
3. click once and confirm the ready decision is replaced by the operation
   surface before the first source observation;
4. confirm the five graph rows appear beneath conversation preparation;
5. confirm Conversations, Messages, and Attachments show changing exact counts
   for sufficiently large workloads;
6. confirm Participants and Relationships remain honest coarse states;
7. confirm all-Done remains visible briefly, then the virgin hub returns;
8. confirm the new cartouche receives no automatic orange or blue treatment.

The human should continue using only the disposable development staging
archive and import source established by Feature 26.

## Verification

- `flutter analyze`: clean.
- Conversation Graph suite: 118 tests passed.
- Settings suite: 123 tests passed.
- Archive-environment, database, and Onboarding suites: 245 tests passed.
- Architecture tripwires: 374 tests passed.
- Focused button, progress, graph-import, workflow, and panel tests: 58 tests
  passed in their final focused run.
- macOS debug build: succeeded as `MessageLens Development.app`.
- `git diff --check`: clean.

Code generation updated only the two Riverpod hashes belonging to the changed
Historical Archives workflow and action providers. There are no schema,
migration, Drift model, or persistence-format changes.
