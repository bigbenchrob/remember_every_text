Begin the first nested-Journey experiment on the new experimental branch.

This task is deliberately small.

Its purpose is to prove one mechanism:

A parent Step can own a child Journey, and that child Journey can use an independent fake Agent to determine whether its purpose has already been achieved.

Do not attempt the full Full Disk Access workflow.

Do not implement System Settings, retry, restart, repeat, persistence, or production FDA inspection.

---

## Read first

Read:

- the PRESENCE-ITERATION-SIMPLE root orientation documents;
- 30-SYSTEM-BOUNDARIES.md;
- 40-THOUGHT-EXPERIMENT-01-CONJECTURAL-RULES.md;
- the current experimental-branch orientation, if one was created;
- the working Journey, JourneyProgress, Step hierarchy, JourneyView, repository, fixture, and tests.

Treat the thought-experiment rules as conjectural absolute rules for this branch.

Do not treat them as settled architecture.

---

## Question being tested

What is the smallest implementation that proves:

1. An Onboarding Journey can contain one FDA Audit Step.
2. That FDA Audit Step can own or run a child Journey.
3. The child Journey can contain a Step that invokes a fake FDA Auditing Agent.
4. If the fake agent returns true, the child Journey can report success immediately.
5. That success can propagate upward:
   child Journey
   -> parent FDA Audit Step
   -> parent Onboarding Journey.
6. If the fake agent returns false, the child Journey remains active and advances to one simple explanatory Tell.
7. The parent Onboarding Journey remains on the FDA Audit Step while the child Journey continues.

---

## Experimental scope

Implement only two scenarios.

Scenario A: FDA already granted

FakeFdaAuditingAgent.audit()
-> true

The child Journey should:

- recognize that its single purpose is already achieved;
- finish immediately;
- report success upward.

The parent FDA Audit Step should then report success to the Onboarding Journey.

The Onboarding Journey should advance to one simple following Step proving that propagation occurred.

Scenario B: FDA not granted

FakeFdaAuditingAgent.audit()
-> false

The child Journey should:

- complete the audit-check Step normally;
- advance to one Tell Step:

  Full Disk Access has not been granted yet.

Then stop there.

Do not add recovery, retry, settings instructions, or another audit.

The parent Onboarding Journey must remain on the FDA Audit Step.

---

## Journey purposes

Every Journey introduced in this experiment must have one purpose that can be stated in one sentence.

Use clear purpose-oriented names.

For example:

Onboarding Journey:
carry_out_test_onboarding

Child Journey:
ensure_fda_has_been_granted

Do not use vague names such as:

- fda_flow;
- audit_process;
- nested_journey;
- child_workflow;
- journey_manager.

Name classes and files with clear imperative verb phrases consistent with the project’s conventions.

---

## Agent

Introduce the smallest possible agent contract:

```dart
abstract interface class AuditingAgent {
  Future<bool> audit();
}
```

Create:

```dart
final class FakeFdaAuditingAgent implements AuditingAgent
```

The fake must receive or expose a predetermined boolean result.

Its only public operation is:

```dart
Future<bool> audit();
```

It must know nothing about:

- Journey;
- Step;
- Flutter;
- presentation;
- JourneyProgress;
- onboarding;
- success propagation.

Do not add:

- an agent registry;
- agent keys in Drift;
- dependency injection infrastructure;
- providers;
- production FDA services;
- retries;
- error hierarchies.

---

## Child audit-check Step

Create the smallest child Step needed to invoke the agent.

This Step should:

- receive the fake AuditingAgent directly for this experiment;
- invoke audit();
- distinguish only true from false;
- report one of two outcomes to its parent child Journey:

  ordinary Step completion

  or

  the child Journey’s purpose is already achieved

Do not add presentation unless required to make the false path observable.

If the Step completes silently, that is acceptable.

Do not create a general-purpose AgentStep, Audit framework, signal bus, or registry.

Use the clearest concrete name for this exact experiment.

---

## Parent FDA Audit Step

Create one parent Step whose responsibility is:

Ensure Full Disk Access has been granted by running the child Journey.

The parent Step should:

- own or instantiate one child JourneyProgress for the child Journey;
- present the child Journey through the smallest existing mechanism;
- remain current in the parent Onboarding Journey until the child Journey succeeds;
- report success upward only when the child Journey succeeds.

It must know nothing about:

- how the child audit agent works;
- whether the agent returned true or false;
- which internal child Step is current;
- System Settings;
- restart;
- retries.

It knows only:

The child Journey has succeeded or has not yet succeeded.

---

## Signals

Do not create a broad signal framework.

Use the smallest explicit mechanism needed to prove the conjecture.

The experiment requires only two child-to-parent meanings:

1. The current Step has completed normally.
2. The parent Journey’s purpose has already been achieved.

Choose the simplest representation that keeps those meanings explicit and testable.

Possible forms include:

- two callbacks;
- one tiny enum local to this experiment;
- another smaller mechanism discovered during implementation.

Do not add:

- generic event hierarchies;
- payload systems;
- global signal classes;
- downward commands;
- branching destinations;
- jump-to-Step APIs.

The parent Journey may only:

- advance one Step;
- or finish successfully.

---

## Linear rule

Preserve this conjectural rule:

A Journey never jumps to an arbitrary Step.

It either:

- advances to the next Step after ordinary completion;
- or succeeds immediately when a Step establishes that its purpose is already achieved.

No Step IDs may be used as branch destinations.

No conditional routing table may be introduced.

---

## Persistence

Do not persist nested Journey ownership yet.

Do not change the Drift schema unless the experiment cannot be performed otherwise.

Prefer in-memory construction of the parent and child Journey definitions for this first mechanism test.

The current persisted Journey repository may remain untouched.

Do not add:

- parent_step_id;
- child_journey_id;
- Journey nesting tables;
- agent keys;
- signal columns;
- child progress persistence.

This experiment is about runtime composition, not relational modelling.

---

## Presentation

Keep presentation minimal.

Scenario A should visibly prove that the Onboarding Journey advanced after the child Journey succeeded.

For example, the next parent Tell may display:

Full Disk Access is already available.

Scenario B should visibly display the child Tell:

Full Disk Access has not been granted yet.

The parent Onboarding Journey must not advance in Scenario B.

Do not apply the full onboarding visual polish unless existing components provide it naturally.

Do not change shared presentation tokens or current onboarding copy.

---

## Tests

Add focused pure-Dart and widget tests proving:

Agent

1. FakeFdaAuditingAgent returns its configured result.
2. It has no Journey or Flutter dependency.

True path

3. The child audit Step invokes the agent once.
4. A true result establishes immediate child-Journey success.
5. Remaining child Steps are not presented.
6. The parent FDA Audit Step reports success once.
7. The parent Onboarding Journey advances once.
8. The visible parent Step after advancement proves propagation.

False path

9. A false result completes the audit-check Step normally.
10. The child Journey advances to:
    Full Disk Access has not been granted yet.
11. The child Journey has not succeeded.
12. The parent FDA Audit Step has not reported success.
13. The parent Onboarding Journey remains on the FDA Audit Step.
14. No retry or loop occurs.

Boundaries

15. The parent Journey never inspects agent output.
16. The parent FDA Audit Step never interprets agent output.
17. The agent never knows about Journey or Step.
18. No arbitrary Step jump is introduced.
19. No downward signal is required.

Preserve all existing Presence tests.

---

## Questions to answer afterward

Report:

1. What exact object owns the child JourneyProgress?
2. How is the child Journey supplied to the parent FDA Audit Step?
3. What mechanism represents ordinary Step completion?
4. What mechanism represents early successful Journey completion?
5. How does success propagate through all three levels?
6. What remains active after a false audit result?
7. Did the parent Journey learn anything about FDA?
8. Did the parent FDA Audit Step learn the audit result?
9. Did the child Journey remain linear?
10. Did nested Journey composition make the FDA mechanism simpler or merely move complexity?
11. What pressure appeared that the conjectural rules do not yet explain?
12. Is any repeat/resume concept actually required by this first experiment?

---

## Scope discipline

Do not implement:

- real FDA detection;
- System Settings;
- Do Step;
- restart;
- repeat Journey;
- resume persistence;
- retry;
- production onboarding integration;
- agent resolution by key;
- nested Journey persistence;
- generic nested-Journey framework;
- arbitrary branching;
- result transport;
- providers;
- historical Presence concepts.

Nothing may be added merely because the complete FDA workflow will probably need it later.

---

## Verification

Run:

- all new focused tests;
- all Presence tests;
- architecture tripwires;
- flutter analyze;
- macOS debug build if the experiment touches the running laboratory;
- formatting;
- git diff --check.

Do not broaden the task.

---

## Completion report

Report:

1. Every file created or modified.
2. The parent and child Journey purposes.
3. The complete runtime ownership chain.
4. The true-path sequence.
5. The false-path sequence.
6. The minimal signal mechanism chosen.
7. Test and analyzer results.
8. Any conjectural rule that became awkward.
9. Whether the nested-Journey hypothesis should be retained, revised, or abandoned before continuing the FDA workflow.

```

```
