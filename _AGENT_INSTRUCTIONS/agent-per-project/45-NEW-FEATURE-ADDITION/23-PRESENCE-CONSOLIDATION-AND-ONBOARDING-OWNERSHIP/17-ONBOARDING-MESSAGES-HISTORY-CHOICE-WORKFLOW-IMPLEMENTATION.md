---
tier: project
scope: onboarding-messages-history-choice-workflow
owner: agent-per-project
last_reviewed: 2026-08-13
source_of_truth: implementation
links:
  - 11-MESSAGES-SOURCE-HISTORY-SUFFICIENCY-TESTAGENT-IMPLEMENTATION.md
  - 12-CHOICESTEP-AND-WORKFLOW-PRESENTATION-PROPOSAL.md
  - 13-CHOICESTEP-PURE-DOMAIN-IMPLEMENTATION.md
  - 14-CHOICESTEP-ADDITIVE-PERSISTENCE-IMPLEMENTATION.md
  - 15-CHOICESTEP-RUNTIME-COMPLETION-IMPLEMENTATION.md
  - 16-GENERIC-PRESENCE-PRESENTATION-IMPLEMENTATION.md
  - ../21-PRESENCE-ITERATION-SIMPLE/03-SCHEDULE-TRIP-EXPERIMENT/generated/required_sources_readiness_onboarding_experiment.md
tests:
  - test/essentials/onboarding/application/required_sources_readiness_schedule_test.dart
  - test/essentials/onboarding/application/required_sources_readiness_definition_extension_test.dart
  - test/essentials/onboarding/application/required_sources_readiness_choice_presentation_test.dart
  - test/features/presence_iteration_simple/infrastructure/development/schedule_mermaid_renderer_test.dart
---

# Onboarding Messages-History Choice Workflow Implementation

## Result

The active required-sources Onboarding Schedule now uses the complete generic
Presence grammar to evaluate local Messages-history sufficiency, explain a
sparse result, and obtain one human choice.

```text
TestStep
    sufficient -> confirmation
    sparse -> TellStep -> TellStep -> ChoiceStep

ChoiceStep
    recheck -> history TestStep
    import_anyway -> confirmation
```

No sparse-history interaction type, Onboarding renderer, retry object, or
runtime value-to-Trip translation was introduced.

## Previous Active Topology

Before Slice 5, successful Contacts readiness routed directly from Trip `305`
to the existing confirmation Trip `307`:

```text
Messages source readable
    -> Contacts source readable
    -> required-sources confirmation
```

The history-sufficiency Agent was implemented and bound but unused by the
active Schedule.

## New Definitions

The existing Schedule remains Schedule `6`. Existing Trip, occurrence, and
Step identities remain stable.

| Position | Occurrence | Trip | Name | Terminal behavior |
| ---: | ---: | ---: | --- | --- |
| 6 | `6108` | `308` | `determine_messages_source_history_sufficiency` | Test sufficient history |
| 7 | `6109` | `309` | `guide_sparse_or_unsynced_messages_source` | Human Choice |
| 8 | `6107` | `307` | `required_sources_confirmation` | Existing confirmation |

Trip `308` contains Test Step `6801`. Trip `309` contains Tell Steps `6901`
and `6902`, followed by Choice Step `6903`.

The existing Contacts Test Step `6501` now routes its true arm to Trip `308`.
Its false/default arm still enters Contacts guidance.

## Factual Agent

Step `6801` uses the already-proven opaque Agent identity:

```text
onboarding.messages-source-history-sufficient
```

The Agent still performs the approved fresh `COUNT(*) FROM message` fact:

```text
0 through 10 -> false
11 or more   -> true
unavailable  -> typed evaluation failure
```

No SQL or threshold was duplicated in the Schedule.

## Choice Contract

The persisted options are:

| Position | Durable value | Visible label | Destination |
| ---: | --- | --- | --- |
| 0 | `recheck` | Re-check | Trip `308` |
| 1 | `import_anyway` | Import Anyway | Trip `307` |

Labels are presentation copy. Opaque values are the interaction result. The
destinations remain private execution geometry loaded from `presence.db`.

The sufficient Test arm and explicit Import Anyway arm converge on the same
existing confirmation occurrence, `6107`. That confirmation remains the one
canonical point at which required source readiness is accepted.

## Fresh Re-check

Selecting `recheck` checkpoints occurrence `6109` directly to occurrence
`6108`. Re-entering Trip `308` reconstructs its generic Test Step and invokes
the Agent again. No Boolean, retry count, pending Choice, or current Step is
persisted.

Tests prove both:

```text
false -> guidance -> recheck -> false -> guidance
false -> guidance -> recheck -> true -> confirmation
```

## Restart Behavior

Trip-granular restart semantics are unchanged:

- restart during Trip `309` returns to its first Tell Step;
- restart after Re-check resumes at Trip `308`, Step 1;
- restart after Import Anyway resumes at Trip `307`, Step 1;
- no selected value or current Step is persisted.

## Existing-Run Safety

Startup now asks the repository to install or additively extend the canonical
definition. The extension is transactional and fail-closed.

It permits only the changes required by this slice:

- adding new Trip, Step, subtype, option, and occurrence rows;
- moving an existing occurrence to a new ordinal position;
- changing configured destinations on an existing generic Test Step.

It rejects removal or semantic remapping of an existing occurrence. Existing
occurrence `6107` therefore remains the same confirmation Trip even though its
position moves from 6 to 8. Existing `schedule_runs.current_trip_occurrence_id`
values remain valid, and no run or trace row is deleted or recreated.

Tests begin from the exact seven-Trip pre-Slice-5 definition and prove:

- a run waiting at Contacts Test occurrence `6105` keeps the same run and
  checkpoint, then follows the new route;
- a run already at confirmation occurrence `6107` resumes at that same
  confirmation after extension;
- a completed run remains completed;
- an attempted occurrence-to-Trip remapping is rejected without changing the
  stored definition.

This is a canonical-definition update inside schema v9, not a SQLite schema
migration.

## Generic Presentation

The real Onboarding `ChoiceStep` is projected by
`PresenceStepPresentationProjector` and rendered by `PresenceStepPresenter`.
The presenter receives only the ordered labels, opaque values, and a
context-bound selection operation.

Onboarding contains no Flutter control for Re-check or Import Anyway and no
runtime callback translating either value into a Trip. Onboarding authors the
meaning once in the Schedule definition; generic Presence execution resolves
the stored destination.

## Topology And Trace

The development topology projector now represents generic Choice options as
ordinary explicit edges. The regenerated checked artifact shows nine Trips,
fourteen possible edges, and the backward `309 -> 308` loop.

The universal trace remains unchanged. Focused tests observe ordinary route
history equivalent to:

```text
6108 -> 6109 -> 6108
6108 -> 6109 -> 6107
```

No Choice-specific trace fields were added.

## Manual Experiment Boundary

The existing development source substitution controls Contacts only. There is
no safe development seam for substituting a disposable Messages database, so
this slice did not add one and did not modify the user's real `chat.db`.

The deterministic sparse and sufficient cases are exercised with isolated
repository fixtures and mutable Test Agents. A future manual sparse-source
experiment must first provide an explicitly development-only Messages-source
substitution, point it at a disposable SQLite source with 10 or fewer rows,
and then exercise Re-check and Import Anyway through the existing development
host. The normal development source can exercise the sufficient branch when
its real count exceeds 10.

## Verification

The complete Presence, development-harness, and Onboarding test pass completed
with 230 passing tests. This includes focused coverage of:

- sufficient and sparse history branches;
- repeated sparse Re-check loops and sparse-to-sufficient escape;
- Import Anyway routing;
- restart during guidance and after either Choice;
- ordinary universal route tracing;
- run-preserving additive definition extension from the exact previous
  seven-Trip definition;
- real Onboarding Choice projection and generic presentation;
- generated Mermaid topology and live run visualization.

All 366 architecture tripwires passed. `flutter analyze` reported no issues,
formatting completed cleanly, `git diff --check` reported no errors, and the
debug macOS application built successfully. The generated topology artifact
was regenerated from the implemented definition.

## Deviations

The implementation preserves the proposal's architecture. The existing
confirmation Trip `307` is the canonical convergence point rather than a new
confirmation identity. Manual sparse-history execution was intentionally not
performed because no safe Messages-source substitution currently exists.
