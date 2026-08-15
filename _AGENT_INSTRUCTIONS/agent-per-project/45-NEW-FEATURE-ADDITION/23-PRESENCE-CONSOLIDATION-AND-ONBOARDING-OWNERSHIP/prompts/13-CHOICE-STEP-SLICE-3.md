So now we get to the interesting bit: **Slice 3 teaches Presence how to accept one human-selected `ChoiceValue` and turn it into the ordinary Trip-boundary result.** Still no Flutter and no Onboarding.

Implement **ChoiceStep Slice 3 only** from:

`12-CHOICESTEP-AND-WORKFLOW-PRESENTATION-PROPOSAL.md`

using the completed domain and persistence work documented in:

- `13-CHOICESTEP-PURE-DOMAIN-IMPLEMENTATION.md`
- `14-CHOICESTEP-ADDITIVE-PERSISTENCE-IMPLEMENTATION.md`

This slice adds the **narrow runtime boundary by which a human-selected `ChoiceValue` completes the current terminal `ChoiceStep`**.

Do not add Flutter presentation.

Do not extend the live Onboarding Schedule.

Do not add sparse-history ChoiceStep usage.

Do not broaden this into generic Step input.

---

## Governing runtime rule

Presence already knows:

```text
current ScheduleRun
current Trip
current terminal ChoiceStep
```

The caller must report only:

```text
ChoiceValue
```

The caller must not supply:

```text
StepDefinitionId
TripDefinitionId
ScheduleTripOccurrenceId
destination
routing instruction
```

Presence itself resolves the selected opaque value against the current persisted `ChoiceStep`.

Conceptually:

```text
human selects:
    ChoiceValue("pink")

Presence:
    verify this selection still belongs to the current ChoiceStep
    currentChoiceStep.destinationFor("pink")
        -> TripDefinitionId(15)

Trip:
    completes with TripDefinitionId(15)

Scheduler:
    resolves Trip 15 in active Schedule
    checkpoints it
```

Onboarding does not participate.

Presentation does not know the destination.

---

# 1. First inspect the existing Scheduler/runtime seam

Before editing, trace the exact current path for:

```text
Step completion
    -> Trip completion
    -> TripDefinitionId?
    -> Scheduler destination resolution
    -> ScheduleRun checkpoint
    -> trace ordering
```

Document briefly in the implementation record which existing method(s) will be reused.

Do not invent a parallel routing path for ChoiceStep.

The selected Choice destination must enter the same ordinary Trip-boundary machinery already used by TestStep and FixedDestinationStep.

---

# 2. Add one choice-specific runtime entry point

Add the smallest application/runtime operation conceptually equivalent to:

```dart
selectCurrentChoice(ChoiceValue value)
```

The exact class/method name should follow existing Presence application conventions.

This API must be **choice-specific**.

Do not add:

```text
completeStepWithInput(...)
submitStepResult(...)
Map<String, dynamic>
Object? payload
generic interaction result
```

Nothing broader has been earned.

---

# 3. Presence owns current execution identity

The caller must not identify the Step.

Presence already owns the active execution state.

So this is wrong:

```dart
selectChoice(
    stepDefinitionId: ...,
    value: ...
)
```

Prefer the conceptual model:

```dart
selectCurrentChoice(value)
```

with any necessary current-Step evidence retained internally by Presence.

The runtime contract should remain:

> The outside world reports only what the human selected.

---

# 4. Stale interaction protection

A Choice selection rendered earlier must not accidentally complete a later ChoiceStep.

For example:

```text
ChoiceStep A displays:
    continue

execution advances somehow

ChoiceStep B also contains:
    continue

old callback from A fires
```

That stale selection must fail.

Preserve this without teaching presentation about Step IDs.

Use the smallest mechanism consistent with current architecture.

Possible shapes include:

```text
context-bound selection callback
```

or:

```text
opaque internal interaction/version evidence
```

but do not create a generic interaction-token framework.

The caller/presenter should not need to inspect or understand the evidence.

The invariant is simply:

> A selection may complete only the ChoiceStep for which that interaction boundary was issued.

---

# 5. ChoiceStep remains synchronous domain mapping

Do not change the pure domain contract into an object that waits for a human.

`ChoiceStep` should still conceptually do only:

```dart
destinationFor(ChoiceValue)
    -> TripDefinitionId
```

Do not add:

```text
Completer
Future waiting for UI
callback storage
presentation lifecycle
pendingChoice
```

Human interaction belongs at the Presence application/runtime boundary.

The domain implementation explicitly reserved runtime submission for this later slice.

---

# 6. Only terminal ChoiceStep may be completed this way

Persistence already enforces terminal placement.

At runtime, also fail closed if the current interaction does not resolve to the current terminal `ChoiceStep`.

Do not attempt to support a mid-Trip ChoiceStep.

The established rule remains:

> only the terminal Step result crosses the Trip boundary.

---

# 7. Unknown ChoiceValue

If the current ChoiceStep contains:

```text
blue
pink
purple
```

and runtime receives:

```text
orange
```

fail explicitly.

Do not:

- fall back;
- route default-next;
- return null;
- interpret strings;
- silently ignore.

Reuse the domain `destinationFor()` validation where practical.

---

# 8. Ordinary Trip result

The selected destination is not a special Choice routing object.

The result after acceptance is simply the already-established canonical:

```text
TripDefinitionId?
```

For ChoiceStep specifically, the persisted destination is required, so successful selection produces:

```text
TripDefinitionId
```

Then ordinary Trip/Scheduler logic proceeds.

Do not add:

```text
ChoiceRoute
ChoiceResult
HumanDecisionResult
```

unless the current runtime architecture absolutely requires a tiny temporary internal value and Codex can demonstrate why.

Prefer no new routing type.

---

# 9. Checkpoint semantics

Choice acceptance and routing must preserve the existing durable rule:

```text
Definitions prescribe.
ScheduleRun remembers where execution is.
Trace records where it went.
```

The database documentation currently states that `schedule_runs.currentTripOccurrenceId` is the durable restart checkpoint and that trace is not runtime authority.

After a valid selection:

```text
ChoiceValue
    -> configured TripDefinitionId
    -> active Schedule occurrence resolution
    -> checkpoint destination occurrence
```

Reuse existing checkpoint behavior.

Do not persist:

```text
selected ChoiceValue
current Step
pending choice
```

---

# 10. Restart semantics

Preserve Trip-granular restart.

If the process quits before the selection is durably accepted:

```text
restart
    -> current Trip
    -> Step 1
```

If destination checkpointing succeeds:

```text
restart
    -> selected destination Trip
```

No new current-Step persistence is allowed.

---

# 11. Trace behavior

Do not add a ChoiceValue trace field in this slice.

Use the existing event sequence as far as possible:

```text
step_completed
trip_completed
route_decision
next trip started
```

The selected destination already distinguishes the first real workflow choices.

Do not make trace authoritative.

If existing trace machinery requires a minimal adaptation simply because `ChoiceStep.complete()` cannot be called autonomously, make the smallest explicit change and document it.

---

# 12. Autonomous Step execution

Inspect the current Trip execution loop carefully.

Today it likely assumes each Step can be autonomously completed through something like:

```dart
await step.complete()
```

ChoiceStep deliberately cannot.

Refine the runtime only as much as necessary so it can distinguish:

```text
autonomous Step
    -> Presence executes it

ChoiceStep
    -> Presence exposes/awaits external human selection through the narrow choice boundary
```

Do not solve this by making every Step interactive-capable.

Do not create a generic state machine.

Do not add `Step.requiresInput`, arbitrary input bags, or generalized events unless existing architecture makes one tiny mechanical discriminator unavoidable.

Prefer a direct exhaustive type distinction.

---

# 13. Runtime status

Presence must be able to represent:

> the current Trip is active and currently waiting at its terminal ChoiceStep.

But do not persist a new durable “waiting” state unless absolutely required.

This may simply be reconstructable application state:

```text
current Trip
+
current Step shape = ChoiceStep
```

Remember:

```text
ScheduleRun stores Trip checkpoint only.
```

Do not change that unless a test proves the model impossible.

---

# 14. Concurrency / repeated selection

Prove that rapid repeated interaction cannot advance twice.

Example:

```text
user double-clicks "Continue"
```

Only one accepted transition should checkpoint.

The second invocation should fail as stale/already advanced rather than routing again.

Reuse existing Scheduler serialization/maintenance locks if applicable.

Do not create a Choice-specific mutex if existing execution serialization already solves this.

---

# 15. Development topology remains separate

Do not implement Choice visualization in this slice.

The development topology switch may continue fail-closed if it is purely visualization.

If compilation requires awareness of the now-executable ChoiceStep, add only the minimum explicit case needed to preserve the slice boundary.

Presentation and visualization are Slice 4/5 concerns.

---

# 16. Focused runtime tests

Add tests proving at least:

### Valid selection

Current terminal ChoiceStep:

```text
blue   -> Trip 12
pink   -> Trip 15
purple -> Trip 19
```

Submit:

```text
pink
```

Prove:

```text
Trip 15 becomes the durable current Trip occurrence.
```

### Unknown value

Submit:

```text
orange
```

Prove:

- explicit failure;
- no checkpoint change;
- no false route.

### Caller supplies no Step identity

The public choice-selection API should require only the selected `ChoiceValue` plus whatever opaque/context-bound callable Presence supplied.

### Stale interaction

Obtain interaction boundary for ChoiceStep A.

Advance away from A.

Invoke A's old interaction.

Prove rejection.

### Same value on later ChoiceStep

ChoiceStep A contains:

```text
continue -> Trip B
```

ChoiceStep C also contains:

```text
continue -> Trip D
```

Old callback from A must not select `continue` on C.

### Double selection

Invoke the same choice twice.

Prove exactly one transition.

### Shared destination

Two different ChoiceValues may still resolve to the same destination and both work correctly.

### Restart before selection

Current Trip remains checkpoint.

### Restart after accepted selection

Destination Trip is checkpoint.

### Existing Step types

All TestStep, TellStep, FixedDestinationStep, and current FDA behavior remain unchanged.

---

# 17. Architecture tripwires

Protect:

- Presence runtime does not import Onboarding to complete ChoiceStep;
- choice runtime API accepts no workflow semantic type;
- no Flutter dependency;
- no value-string interpretation;
- no destination supplied by caller;
- no generic arbitrary Step input abstraction.

The ideal dependency statement remains:

```text
caller:
    selected ChoiceValue

Presence:
    current ChoiceStep
    value -> destination geometry
```

---

# 18. Documentation

Create:

`15-CHOICESTEP-RUNTIME-COMPLETION-IMPLEMENTATION.md`

Document:

1. existing completion path discovered;
2. final choice-selection API;
3. stale-interaction mechanism;
4. how current ChoiceStep is identified internally;
5. how selected value reaches ordinary Trip completion;
6. checkpoint semantics;
7. restart semantics;
8. double-selection behavior;
9. trace behavior;
10. confirmation that no Step/Trip identity crosses into presentation-facing API;
11. tests;
12. deviations from Document 12.

Update:

- `00-START-HERE.md`
- package index
- `DOCUMENTATION_PASS_LOG.md`
- `15-PRESENCE-DATABASE-IN-PLAIN-ENGLISH.md` only if runtime explanation there genuinely needs a small update; do not rewrite unrelated sections.

---

# 19. Verification

Run:

- focused Choice runtime tests;
- Choice domain tests;
- Choice persistence tests;
- Presence infrastructure tests;
- complete Presence/development harness tests;
- Onboarding tests;
- architecture tripwires;
- migration tests if touched;
- `flutter analyze`;
- formatting;
- `git diff --check`.

Run code generation only if actual Drift/model changes require it.

No macOS build unless runtime integration causes compiled application code to require one.

---

# Hard constraints

Do not in Slice 3:

- add Flutter Choice UI;
- add generic Presence presenter;
- extend the Onboarding Schedule;
- add sparse-history choice usage;
- expose Step IDs to presentation;
- expose Trip IDs to presentation;
- accept destination from caller;
- add generic Step input/result bags;
- add pending-choice persistence;
- persist current Step;
- add ChoiceValue trace fields;
- add ActionStep;
- add presentation metadata;
- interpret ChoiceValue strings;
- involve Onboarding at runtime.

If any of these appears necessary, stop and explain why.

---

# Success criterion

At the end of Slice 3, Presence can be sitting at:

```text
current Trip
    terminal ChoiceStep

        ("Blue", "blue")       -> Trip 12
        ("Pink", "pink")       -> Trip 15
        ("Purple", "purple")   -> Trip 19
```

An external human-facing caller can report only:

```text
ChoiceValue("pink")
```

and Presence will:

```text
verify the interaction is still current
resolve "pink" against the current ChoiceStep
obtain TripDefinitionId(15)
use ordinary Scheduler routing
checkpoint Trip 15
```

while the caller remains completely ignorant of:

```text
Step ID
Trip ID
Schedule geometry
destination
routing semantics
```

Stop after Slice 3 and report before generic Presence presentation begins.
