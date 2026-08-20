---
tier: project
scope: production-archive-recovery
owner: agent-per-project
last_reviewed: 2026-08-20
source_of_truth: implementation-record
links:
  - ../prompts/36-MAC-MESSAGES-NARRATOR-SCOPE-TRANSITION.MD
  - ./10-HISTORICAL-ARCHIVES-NARRATOR-DIRECTED-INSTRUMENTATION-DESIGN.md
  - ./34-MAC-MESSAGES-IMPORT-RESPONSIVENESS-AND-REAL-PROGRESS-IMPLEMENTATION.md
tests:
  - test/features/settings/application/historical_archives_workflow_panel_model_provider_test.dart
  - test/features/settings/presentation/view/historical_archives_panel_test.dart
---

# Mac Messages Narrator Scope Transition

## Result

Historical Archives now explains the real change of scope between adding the
selected Messages folder and preparing the combined MessageLens history.

The ready evidence remains source-specific. In the staging example, both of
these statements are truthful:

- the selected folder contains 8,882 messages; and
- the subsequent graph workload spans roughly 150,000 messages already held
  across MessageLens sources.

The numerical instrumentation was not wrong. The missing information was the
human meaning of the transition between those scopes.

## Narrator Contract

While source addition is current, Narrator says:

> Adding this Messages folder to MessageLens.

When `preparingConversations` becomes current, Narrator says:

> The messages from this folder are added. Now I’m updating your combined
> MessageLens history so everything appears together.

The transition is derived only from typed `HistoricalArchiveImportProgress`.
It occurs when the graph-preparation stage leaves `waiting`; no timer, elapsed
time, displayed string, animation callback, or widget state participates.

Final verification retains the combined-history narration because its scope
has not changed again. A source-stage failure retains the existing bounded
failure narration. A graph-stage failure retains the combined-history context
alongside truthful failed instrumentation.

## Directed Instrumentation

The stage heading remains **Preparing conversations for browsing**. Narrator
now owns the combined-history scope explanation, so changing the heading to
repeat that scope would add redundancy rather than clarity.

All established progress semantics remain unchanged:

- source evidence and source-addition counts describe the selected folder;
- Conversations, Messages, and Attachments retain their exact graph workload
  denominators;
- Participants and Relationships retain their coarse truthful units; and
- no selected-folder count substitutes for the larger combined-history work.

No progress estimate, synthetic denominator, delay, or other progress theater
was introduced.

## General Rule

Narrator intervenes when the human meaning or scope of the work changes, not
merely because another implementation stage begins.

Narrator explains changes in meaning and scope. Directed Instrumentation
exposes the factual work within that scope.

## Preserved Boundaries

The import service, source identity, graph preparation, final verification,
success modal, partial-failure behavior, ready-state evidence, removal journey,
sidebar/Track layout, maintenance authority, and attachment preservation are
unchanged.

## Verification

- Focused Historical Archives model and panel tests: 54 passed.
- Graph progress, mutation authority, Onboarding maintenance, import-ledger,
  Track, and graph-admission regressions: 48 passed.
- Complete Settings feature suite: 127 passed.
- Architecture tripwires: 374 passed.
- `flutter analyze`: no issues.
- macOS debug build: succeeded.
- `dart format` and `git diff --check`: clean.
