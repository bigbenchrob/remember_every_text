Good. The next slice should be **production generic-runner integration**: take the generic Presence presenter that has already survived the development host and real Onboarding definitions, and make it the ordinary production surface for Onboarding.

ChoiceStep itself should remain untouched. The real question is now:

> Can production Onboarding simply hand the current Presence Step to the generic Presence runner, with Onboarding participating only where genuinely domain-specific behavior still remains?

The active workflow is now already expressed entirely through generic grammar except for the existing FDA-settings-opening exception. 17\-ONBOARDING\-MESSAGES\-HISTORY\-CHOICE\-WORKFLOW\-IMPLEMENTATION.md And the real ChoiceStep is already projected and rendered by the generic Presence presentation boundary in tests, with no Onboarding value-to-route translation. 17\-ONBOARDING\-MESSAGES\-HISTORY\-CHOICE\-WORKFLOW\-IMPLEMENTATION.md

Implement the **production generic Presence-runner integration slice** following the completed ChoiceStep work.

Read first:

- `12-CHOICESTEP-AND-WORKFLOW-PRESENTATION-PROPOSAL.md`
- `15-CHOICESTEP-RUNTIME-COMPLETION-IMPLEMENTATION.md`
- `16-GENERIC-PRESENCE-PRESENTATION-IMPLEMENTATION.md`
- `17-ONBOARDING-MESSAGES-HISTORY-CHOICE-WORKFLOW-IMPLEMENTATION.md`
- current production Onboarding presentation / `OnboardingGate` code
- current `presence_iteration_simple` host only as implementation evidence, not as code to graduate wholesale.

This slice should make **generic Presence presentation the normal production renderer for generic Steps in the real Onboarding Schedule**.

Do not redesign ChoiceStep.

Do not add another Step type.

Do not generalize `OpenFdaSettingsStep`.

Do not expand Onboarding beyond the currently implemented required-sources/history workflow.

---

# Governing rule

The permanent runtime ownership should now be:

```text
Onboarding
    owns:
        workflow meaning
        authored persisted definitions
        TestAgent bindings
        genuinely onboarding-specific integration

Presence
    owns:
        Schedule execution
        generic Step reconstruction
        generic Step presentation
        generic interaction
        routing
        checkpointing

Specialists
    own:
        factual / platform expertise
```

For any generic current Step:

```text
TellStep
TestStep
FixedDestinationStep
ChoiceStep
```

production Onboarding should not need its own renderer.

---

# 1. Inspect current production Onboarding UI first

Before changing code, trace the current real production path from:

```text
application launch
    -> OnboardingGate
    -> current ScheduleRun
    -> current Trip / Step
    -> production UI
```

Document:

1. which production widget currently decides what to display;
2. where it currently understands Step-specific behavior;
3. what is already generic;
4. what is still Onboarding-specific;
5. how FDA settings opening currently enters the UI path.

Do not assume the development host structure matches production.

Use current production code as source of truth.

---

# 2. Identify the smallest permanent generic runner boundary

Assess whether production needs a small permanent component conceptually like:

```text
PresenceRunner
```

or whether the existing:

```text
PresenceStepPresentationProjector
PresenceStepPresenter
PresenceScheduler
```

already compose cleanly enough that no additional named abstraction is required.

Prefer the smallest readable composition.

Do not create a grand framework merely because “runner” is a useful conceptual phrase.

If one small orchestrating widget/class genuinely improves clarity, add it.

Its job should be boring:

```text
read current Presence execution state
project current generic Step
render with PresenceStepPresenter
invoke context-bound Presence operations
refresh after transition
```

Nothing more.

---

# 3. Production uses PresenceStepPresenter for generic Steps

Cut the production Onboarding surface over so generic Step types are rendered through the permanent Presence presentation layer.

The production path should not contain parallel branches such as:

```text
if TellStep:
    render onboarding tell UI

if ChoiceStep:
    render onboarding choice buttons
```

when Presence already owns those mechanics.

Instead, production should conceptually do:

```text
current Step
    -> Presence projection
    -> PresenceStepPresenter
```

for the generic Step shapes.

Reuse the exact presentation-safe boundaries already proven in Slice 4.

---

# 4. ChoiceStep must require no production Onboarding code

The real sparse-history ChoiceStep must work in production solely because it is:

```text
ChoiceStep
    label/value options
```

and Presence understands generic finite human choice.

There must be no production Onboarding code that knows:

```text
recheck
import_anyway
Trip 308
Trip 307
```

for runtime interaction.

Those values and destinations exist only in authored workflow definition / Presence execution geometry.

Search explicitly for accidental production coupling.

---

# 5. TellStep remains generic

Production Presence presentation may display persisted Tell copy.

Onboarding should not wrap individual TellSteps merely because their text happens to discuss Messages, Contacts, or synchronization.

The generic rule is:

```text
TellStep
    persisted text
    -> generic Presence Tell presentation
```

Presence does not need to know what the text means.

---

# 6. TestStep remains generic and autonomous

Preserve the current generic Test behavior.

If the current production execution already automatically evaluates TestSteps, continue doing so.

Do not invent user controls for Tests.

Do not create Onboarding progress semantics unless current UI already has justified generic progress behavior.

A TestStep means only:

```text
invoke opaque TestAgent
Boolean result
configured route
```

Presence presentation/runtime may know that mechanics; it must not know what fact is being established.

---

# 7. FixedDestinationStep remains generic

Preserve current autonomous mechanics.

Do not make a visible button appear merely because production now uses a generic presenter.

If the Step requires no human interaction, it should remain mechanically automatic.

---

# 8. OpenFdaSettingsStep remains the explicit exception

Do **not** use this slice to solve `OpenFdaSettingsStep`.

It is still the one current domain-specific presentation/operation exception.

Preserve its behavior through the smallest explicit escape hatch.

Conceptually:

```text
generic Step?
    -> PresenceStepPresenter

OpenFdaSettingsStep?
    -> existing FDA-specific production integration
```

Do not convert it to:

```text
ActionStep
OperationStep
ExternalCommandStep
```

yet.

Do not let this exception infect the generic presenter.

The desirable architecture is not:

> everything must be generic.

It is:

> generic things are generic; exceptional things remain visibly exceptional until evidence earns another abstraction.

---

# 9. Preserve production visual character

This is an ownership integration slice, not a redesign.

Keep current production Onboarding visual styling, spacing, calmness, and layout as closely as practical.

If moving generic rendering into Presence causes small visual changes, minimize them.

Do not use this slice to redesign:

- typography;
- card style;
- animation;
- onboarding chrome;
- overall layout;
- progress indication.

The user-facing change should ideally be negligible except that the new real ChoiceStep can now appear.

---

# 10. Production state refresh

After generic Step completion / Choice submission / automatic routing, production UI must refresh from Presence execution state.

Use the existing Riverpod/application-state mechanism.

Do not make widgets manually infer the next Step.

The authoritative flow should remain:

```text
interaction
    -> Presence runtime
    -> checkpoint
    -> current execution state changes
    -> UI reads new current Step
```

No presentation-side route prediction.

---

# 11. Loading / in-flight state

Production must remain stable while:

- a TestAgent is evaluating;
- a TellStep completion is being accepted;
- a Choice selection is in flight;
- an FDA-specific operation is occurring.

Reuse the generic in-flight protections already present.

Do not introduce durable loading state.

Do not let rapid repeated taps produce duplicate transitions.

Runtime remains correctness authority.

---

# 12. Error behavior

Generic Presence execution failures should surface through the smallest existing production error convention.

Do not:

- locally reroute;
- silently retry;
- swallow unknown Choice errors;
- interpret workflow values;
- reset the Schedule automatically.

If production currently has a friendly error surface, reuse it.

Keep diagnostics sufficient for development without exposing internal Trip/Step coordinates unnecessarily to ordinary users.

---

# 13. Restart behavior must remain unchanged

Do not alter:

```text
schedule_runs.current_trip_occurrence_id
```

semantics.

Production relaunch should still reconstruct the current Trip from Step 1.

Explicitly verify:

```text
quit during sparse guidance
    -> resume guidance Trip Step 1

quit after Re-check checkpoint
    -> resume history Test Trip

quit after Import Anyway checkpoint
    -> resume confirmation Trip
```

The integration layer must not introduce current-Step persistence.

---

# 14. Existing-run definition extension remains untouched

Slice 5 implemented safe transactional extension of the canonical Onboarding definition while preserving existing runs and trace.

Do not rework that mechanism in this slice.

The implementation record establishes that occurrence `6107` remains stable and existing checkpoints survive the definition update.

This slice consumes that definition; it does not redefine migration policy.

---

# 15. Development harness remains a harness

Do not delete or collapse `presence_iteration_simple`.

It still owns useful development-only observability:

```text
Mermaid
live topology
trace
diagnostics
source substitution
Run Again
```

Production integration should share permanent Presence presentation code with it, but the harness remains its own host.

Target:

```text
                    +-> production Onboarding host
Presence presenter -|
                    +-> development inspection host
```

Not:

```text
development host becomes production architecture
```

---

# 16. Architecture cleanup after cutover

Once production generic rendering works, inspect for now-redundant Onboarding presentation code.

Remove only code that has become provably obsolete because generic Presence presentation owns it.

Good deletion candidates might include:

- duplicate generic Tell rendering;
- duplicate generic choice rendering;
- duplicate generic progression wrappers.

Do not delete FDA-specific integration.

Do not perform unrelated presentation cleanup.

Prefer deletion over compatibility shims.

---

# 17. Focused production tests

Add tests proving at least:

### Generic Tell in production

A real Onboarding TellStep is rendered by Presence presentation.

### Generic Test in production

A real TestStep evaluates/routs without Onboarding-specific rendering logic.

### Real sparse Choice in production

When history is sparse, production reaches:

```text
Re-check
Import Anyway
```

through `PresenceStepPresenter`.

### Re-check

Tap:

```text
Re-check
```

Prove only `ChoiceValue("recheck")` crosses presentation boundary and the workflow returns to the fresh Test.

### Import Anyway

Tap:

```text
Import Anyway
```

Prove only `ChoiceValue("import_anyway")` crosses the presentation boundary and the workflow reaches confirmation.

### No destination leakage

Production presentation API exposes no Trip destination.

### No Onboarding runtime translation

Search/test that production Onboarding contains no:

```text
recheck -> Trip
import_anyway -> Trip
```

routing logic.

### FDA exception

Prove existing Open FDA Settings behavior still uses its explicit exceptional path.

### Existing normal onboarding path

With sufficient history, production continues through generic Steps with no Choice UI.

---

# 18. Full workflow regressions

Preserve all previously proven Onboarding behaviors:

- Messages source unreadable;
- FDA guidance;
- restart after FDA setting;
- Messages verification;
- Contacts unavailable;
- Contacts guidance;
- Contacts restart;
- Contacts verification;
- history sufficiency;
- sparse history;
- Re-check loop;
- Import Anyway;
- final confirmation.

Do not accept a production presenter cutover that regresses earlier proof.

---

# 19. Manual macOS experiment

This slice should include a real production-host manual sanity check where safe.

At minimum, using the normal real source path:

1. launch production application;
2. verify generic Onboarding Steps render correctly;
3. verify no obvious presentation regression;
4. verify normal sufficient-history route reaches confirmation.

If a safe sparse Messages source still does not exist, do not modify real `chat.db` merely to force the Choice branch.

Instead, rely on deterministic widget/application tests for sparse Choice behavior and document the manual limitation.

If an existing safe development seam has appeared since Slice 5, it may be used, but do not invent one in this slice unless required for production correctness.

---

# 20. Production Presenter blank-stare tests

After implementation, these should all be true.

Ask production Onboarding UI:

> Where does `recheck` go?

Correct:

```text
I don't know.
```

Ask Presence presentation:

> Where does `recheck` go?

Correct:

```text
I don't know.
```

Ask Presence runtime:

> Where does `recheck` go in the current ChoiceStep?

Correct:

```text
Configured destination Trip X.
```

Ask Presence:

> What does `recheck` mean?

Correct:

```text
I don't know.
```

Ask Onboarding:

> How do I draw a generic ChoiceStep?

Correct:

```text
Presence presentation owns that.
```

---

# 21. Architecture tripwires

Extend existing architecture protections if needed so:

- production Onboarding may depend on Presence application/presentation;
- Presence presentation does not depend on Onboarding;
- Presence domain remains Flutter-free;
- production Onboarding contains no generic Choice routing translation;
- generic Presence presentation contains no Onboarding semantics;
- `ChoiceValue` strings are not interpreted;
- FDA-specific dependencies remain confined to explicit exceptional integration;
- development-only harness code does not leak into production essentials.

Do not invent a new architecture-test framework.

---

# 22. Documentation

Create:

`18-PRODUCTION-GENERIC-PRESENCE-RUNNER-INTEGRATION.md`

Record:

1. pre-slice production Onboarding rendering path;
2. final production composition;
3. whether a new runner/orchestrator class was necessary;
4. generic Step types now owned by Presence presentation;
5. exact FDA exception boundary;
6. obsolete Onboarding rendering code removed;
7. state-refresh flow;
8. error/in-flight behavior;
9. restart verification;
10. real ChoiceStep production proof;
11. manual macOS experiment;
12. tests;
13. deviations from the approved proposal.

Update:

- `00-START-HERE.md`
- package index
- `DOCUMENTATION_PASS_LOG.md`
- any production Onboarding architecture document whose ownership statement is now stale.

Do not rewrite historical implementation records.

---

# 23. Verification

Run:

- focused production Presence-presentation tests;
- real Onboarding Choice presentation tests;
- Choice domain/persistence/runtime tests;
- generic Presence presentation tests;
- complete Presence tests;
- development-harness tests;
- complete Onboarding tests;
- architecture tripwires;
- `flutter analyze`;
- formatting;
- `git diff --check`;
- debug macOS build.

Perform the safe manual production-host experiment described above.

---

# Hard constraints

Do not in this slice:

- change ChoiceStep domain;
- change ChoiceStep persistence;
- change schema version;
- change Choice runtime contract;
- add Choice presentation metadata;
- add MenuChoiceStep / RadioChoiceStep variants;
- extend Onboarding workflow semantics;
- add another readiness concern;
- add ActionStep;
- generalize OpenFdaSettingsStep;
- reset production Schedule runs;
- alter Trip-granular restart;
- add Choice-specific trace;
- expose Trip/Step identity to presentation;
- move development diagnostics into production;
- create an Onboarding-specific Choice renderer.

If production integration appears to require any of those, stop and explain why before implementing it.

---

# Success criterion

At the end of this slice, the real production Onboarding host should conceptually be little more than:

```text
current Presence execution
        |
        v
is current Step generic?
        |
       yes
        |
        v
Presence generic presentation
        |
        v
generic interaction
        |
        v
Presence execution/checkpoint


exception:
    OpenFdaSettingsStep
        -> existing explicit FDA-specific integration
```

And when sparse Messages history eventually produces:

```text
[ Re-check ]   [ Import Anyway ]
```

those controls should exist simply because:

```text
the current Step is a ChoiceStep
```

—not because production Onboarding contains code for sparse history.

That is the proof we want.

Stop after this production integration slice and report before addressing any additional Onboarding concern or the remaining FDA-specific Step debt.
