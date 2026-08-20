---
tier: project
scope: production-archive-recovery
owner: agent-per-project
last_reviewed: 2026-08-20
source_of_truth: implementation-record
links:
  - ../prompts/37-NARRATOR-LIFECYCLE-AND-STALE-COMMENTARY.MD
  - ./10-HISTORICAL-ARCHIVES-NARRATOR-DIRECTED-INSTRUMENTATION-DESIGN.md
  - ./37-MAC-MESSAGES-NARRATOR-SCOPE-TRANSITION-IMPLEMENTATION.md
tests:
  - test/features/settings/application/historical_archives_workflow_panel_model_provider_test.dart
  - test/features/settings/presentation/view/historical_archives_panel_test.dart
---

# Narrator Lifecycle And Stale Commentary

## Observed Defect

The combined-history Narrator statement correctly explained the larger graph
workload while **Preparing conversations for browsing** was active. It remained
visible after that stage completed and **Checking that import finished** became
current, even though the instrumentation showed all graph units as Done.

The statement had become temporally false: it continued to say MessageLens was
updating the combined history after that work had finished.

## Typed Lifecycle

Narrator text is now an optional part of the existing presentation model. Its
import lifecycle is derived entirely from `HistoricalArchiveImportProgress`:

```text
preparingConversations == waiting
    -> source-addition Narrator

preparingConversations == running
    -> combined-history Narrator

preparingConversations == failed
    -> combined-history Narrator remains as failure context

preparingConversations == succeeded
    -> Narrator silent

verifyingImport != waiting
    -> Narrator silent
```

No timer, elapsed time, rendered string, numeric progress value, animation, or
widget-owned state controls the transition.

## Final Verification

Final verification is intentionally Narrator-silent. The existing **Checking
that import finished** instrumentation row communicates the current work, so no
replacement sentence was earned.

This first correction omitted the Narrator widget when text was absent. The
follow-up stable-Track implementation supersedes that spatial behavior:
Narrator may now be silent while its structural Track remains present, so
Directed Instrumentation does not move.

## Failure Behavior

- A source-stage failure retains the existing bounded failure sentence and
  never claims combined-history work began.
- A graph-preparation failure retains the combined-history statement because
  that context still explains the failed workload.
- A final-verification failure remains Narrator-silent and relies on the
  existing failure instrumentation and actions.
- Terminal success remains owned solely by the existing success modal.

## Removal Follow-Up

The subsequent removal audit found a meaningful source-contribution to
remaining-history scope transition. Removal now has phase-specific Narrator
commentary, reuses the real graph projector observations, and becomes silent
for final verification. See
`39-STABLE-NARRATOR-TRACK-REMOVAL-JOURNEY-AND-TERMINAL-PERCEPTION-IMPLEMENTATION.md`.

## Preserved Semantics

All import stages, exact progress counts and denominators, ready evidence,
buttons, success modal, cartouches, sidebar/Track layout, source identity,
persistence, `DateConverter`, mutation authority, and attachment preservation
remain unchanged.

## Canonical Rule

Narrator commentary has a lifecycle. It is present only while its
interpretation applies to the current human-visible state. When that meaning
expires, Narrator either transitions to a newly earned interpretation or
becomes silent.

Silence is preferable to commentary that merely paraphrases self-explanatory
instrumentation.

## Verification

- Focused Historical Archives model and presentation tests: 55 passed.
- Complete Settings feature tests: 128 passed.
- Architecture tripwires: 374 passed.
- `flutter analyze`: no issues found.
- macOS debug build: succeeded at
  `build/macos/Build/Products/Debug/MessageLens Development.app`.
- Formatting and `git diff --check`: clean.

Manual staging review should confirm the same typed sequence: source-addition
commentary while messages are added, combined-history commentary while
conversations are prepared, then no Narrator sentence while **Checking that
import finished** remains visible and active. The existing success modal should
remain the sole terminal-success surface.
