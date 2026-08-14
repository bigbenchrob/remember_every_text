---
tier: project
scope: presence-production-integration
owner: agent-per-project
last_reviewed: 2026-08-13
source_of_truth: code
links:
  - 00-START-HERE.md
  - 16-GENERIC-PRESENCE-PRESENTATION-IMPLEMENTATION.md
  - 17-ONBOARDING-MESSAGES-HISTORY-CHOICE-WORKFLOW-IMPLEMENTATION.md
  - ../../25-ONBOARDING-AND-ARCHIVE/10-onboarding-gate.md
tests:
  - test/essentials/presence/presentation/presence_runner_test.dart
  - test/essentials/onboarding/presentation/onboarding_presence_host_test.dart
  - test/architecture/forbidden_imports_test.dart
---

# Production Generic Presence Runner Integration

## Result

The real required-source Onboarding Schedule is now rendered in production by
the permanent generic Presence presentation path.

```text
Onboarding gate classifies required-source readiness
    -> Onboarding production host
    -> initialized Presence Scheduler
    -> PresenceRunner
    -> generic projection and PresenceStepPresenter
    -> Presence runtime checkpoint
    -> refreshed current Step
```

Generic Tell, Test, Fixed Destination, and Choice mechanics no longer require a
parallel production Onboarding renderer. Onboarding still owns its workflow
definition, real TestAgent bindings, production composition, and the one
explicit FDA Settings specialist integration.

## Before This Slice

The required-source Presence Schedule, runtime, generic presentation, and real
Messages-history Choice workflow existed, but only the development inspection
host initialized and displayed that Schedule. The release application still
used the legacy `OnboardingGate` readiness presentation. Presence therefore had
no ordinary production host despite already owning the generic mechanics.

The development host was implementation evidence only. It also owns Mermaid,
trace, live topology, source substitution, and Run Again behavior that does not
belong in production.

## Final Composition

`MacosAppShell` continues to observe `OnboardingGate`. For
`awaitingFda` and `awaitingUserAction`, it mounts `OnboardingPresenceHost`.

The production composition provider:

- obtains the real Messages-readiness, Contacts-readiness, and Messages-history
  TestAgents;
- obtains the real FDA Settings authority;
- builds the immutable opaque TestAgent resolver;
- installs or safely extends the authored Onboarding definition;
- initializes the permanent `PresenceScheduler` for Schedule 6.

When the readiness Schedule completes, the Presence surface disappears. The
existing gate remains responsible for recovery, import, graph construction,
completion, and reimport. Presence did not absorb those operational concerns.

## Why A Runner Was Added

`PresenceStepPresentationProjector` and `PresenceStepPresenter` already owned
generic projection and presentation, but neither owned execution refresh or
autonomous Steps. A small permanent `PresenceRunner` therefore earned its
place.

Its responsibilities are deliberately narrow:

- read the Scheduler's current Step;
- autonomously complete Test and Fixed Destination Steps;
- project Tell and Choice Steps through the permanent presentation boundary;
- delegate specialist presentation to the host;
- refresh from Scheduler state after a checkpoint;
- expose a small retry surface when autonomous completion fails.

It does not infer routes, inspect workflow values, own durable loading state,
or import any MessageLens feature.

## Generic Step Ownership

Presence production presentation now owns:

- persisted Tell text and completion;
- autonomous Test execution through opaque TestAgent identity;
- autonomous Fixed Destination routing;
- ordered finite Choice labels and opaque `ChoiceValue` submission.

Neither production Onboarding nor Presence presentation knows where `recheck`
or `import_anyway` routes. Destination lookup remains entirely inside the
current persisted `ChoiceStep` and Presence runtime.

## FDA Exception Boundary

`OpenFdaSettingsStep` remains the explicit exception. `PresenceRunner` sees
only that the projected Step requires a specialist. The Onboarding host supplies
the FDA presentation and invokes the context-bound Presence completion. That
completion executes the existing Onboarding-owned platform authority and then
checkpoints the Trip.

The existing FDA content was extracted from the legacy overlay into the public
`OnboardingFdaContent` presentation so production keeps the established copy
and visual character. No `ActionStep` or generalized operation abstraction was
introduced.

## State Refresh And Interaction Safety

After Tell completion, Choice selection, specialist completion, or autonomous
routing, `PresenceRunner` reads the Scheduler again and rebuilds from its new
current Step. Widgets never predict the next destination.

Choice in-flight protection remains owned by the generic presenter. The FDA
specialist prevents repeated opening while its operation is in flight. Test and
Fixed Destination Steps schedule one post-frame completion per current Step.
Runtime activation checks and ordinary checkpointing remain correctness
authority.

Autonomous failures are not swallowed or rerouted. The runner shows a minimal
error and permits an explicit retry. Production composition failures are shown
by the Onboarding host without resetting the Schedule.

## Restart And Existing Runs

This slice changed no schema, run row, occurrence identity, checkpoint rule, or
definition-extension behavior. `schedule_runs.current_trip_occurrence_id`
remains the durable coordinate. Relaunch reconstructs that Trip at Step 1.

The pre-existing restart and definition-extension tests remain the direct proof
for sparse guidance, history re-check, import-anyway confirmation, and stable
occurrence identity. The production runner stores no current-Step state.

## Real Choice Production Proof

Production-host tests use the real authored Onboarding definition with
controllable factual agents. They prove:

- sufficient history bypasses Choice and reaches confirmation;
- sparse history reaches the real `Re-check` / `Import Anyway` Choice through
  `PresenceStepPresenter`;
- Re-check performs a fresh history-agent evaluation;
- Import Anyway reaches the persisted confirmation destination;
- only opaque `ChoiceValue` crosses the presentation boundary;
- the FDA Step continues through the explicit Onboarding specialist path.

Architecture tripwires additionally prohibit production Onboarding from
containing Choice-value translation or depending on the development harness.

## Removed Or Reused Code

There was no parallel production Onboarding Tell or Choice renderer to delete;
the pre-slice production path had not yet adopted the Presence Schedule.

The FDA content was refactored for reuse rather than duplicated. The legacy
overlay remains because it still owns operational import, graph-build,
recovery, and completion surfaces. The development host remains intact as a
diagnostic client of the same permanent presenter.

## Manual macOS Verification

A direct production-app launch was intentionally not performed in this pass:
the production identity and archive are real, while debug launch deliberately
enters the development Presence harness. Sparse and sufficient production-host
paths were instead exercised deterministically through the real Onboarding
definition in widget tests. A debug macOS build verifies application-shell
integration without modifying production data or resetting a production run.

## Verification

Verification completed with:

- all 237 Presence, development-harness, and Onboarding tests, including seven
  focused production Presence-runner and Onboarding-host tests;
- all 369 architecture tripwires;
- clean analyzer and formatting;
- `git diff --check`;
- successful debug macOS build.

## Deviations From The Proposal

The proposal's launch trace presumed the production gate already reached a
Presence execution surface. Inspection showed that Presence was still wired
only into the debug development host. This slice therefore added the missing
production composition provider and Onboarding host rather than merely swapping
one renderer inside an existing production host.

The requested live production sanity check was not safe under the available
launch seams and was not simulated by changing real source data. No other
architectural deviation was required.
