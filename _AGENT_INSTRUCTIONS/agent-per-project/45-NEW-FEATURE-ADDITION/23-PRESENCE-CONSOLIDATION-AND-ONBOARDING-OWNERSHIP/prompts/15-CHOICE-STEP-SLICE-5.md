Implement **ChoiceStep Slice 5 only** from:

`12-CHOICESTEP-AND-WORKFLOW-PRESENTATION-PROPOSAL.md`

using the completed implementation records:

- `11-MESSAGES-SOURCE-HISTORY-SUFFICIENCY-TESTAGENT-IMPLEMENTATION.md`
- `13-CHOICESTEP-PURE-DOMAIN-IMPLEMENTATION.md`
- `14-CHOICESTEP-ADDITIVE-PERSISTENCE-IMPLEMENTATION.md`
- `15-CHOICESTEP-RUNTIME-COMPLETION-IMPLEMENTATION.md`
- `16-GENERIC-PRESENCE-PRESENTATION-IMPLEMENTATION.md`

This slice adds the **real Messages-history sufficiency branch to the active Onboarding Schedule** and uses the now-complete generic Presence `ChoiceStep`.

Do not invent new Presence machinery.

Do not add an Onboarding-specific renderer.

Do not change ChoiceStep domain, persistence, runtime, or presentation contracts unless a real integration failure proves that one of them is insufficient.

The purpose of this slice is to answer:

> Can the real Onboarding workflow now use the generic TestStep + TellStep + ChoiceStep grammar exactly as designed?

---

# 1. Read the current active Onboarding Schedule first

Before changing anything, inspect the current active Onboarding workflow definition and document the exact existing Trip sequence around:

```text
Messages source readable
Contacts source readable
required sources confirmed
```

Identify the correct insertion point for the already-implemented Messages-history sufficiency test.

Do not infer old Trip numbers from design documents if the active persisted definition differs.

Use the current canonical definitions as source of truth.

---

# 2. Add the existing history-sufficiency TestAgent to the active workflow

The TestAgent already exists and is already bound:

```text
onboarding.messages-source-history-sufficient
```

Its approved factual semantics are:

```text
COUNT(*) FROM message

0–10
    -> false

11+
    -> true

count unavailable
    -> typed evaluation failure
```

Do not change that Agent.

Do not duplicate its SQL.

Do not substitute `readImportableMessageCount()` or any other similar-looking count.

The workflow should now actually invoke this already-proven Agent through generic `TestStep`.

---

# 3. Insert the history-sufficiency Test Trip

Add a real Onboarding Trip representing the question:

> Is the local Messages history sufficiently populated?

Use ordinary Onboarding naming conventions.

Conceptually:

```text
determine_messages_source_history_sufficiency

    TestStep
        Agent:
            onboarding.messages-source-history-sufficient
```

Routing:

```text
true
    -> confirm_messages_source_history_accepted

false
    -> guide_sparse_or_unsynced_messages_source
```

Use actual canonical `TripDefinitionId`s from the workflow writer.

Do not make Presence understand either branch semantically.

---

# 4. Add sparse-history guidance Trip

Add a new Onboarding Trip for the false branch.

Conceptually:

```text
guide_sparse_or_unsynced_messages_source
```

This Trip should contain enough persisted `TellStep` copy to explain, in calm user-facing language:

1. MessageLens found very little local Messages history;
2. this may mean Messages history has not fully synchronized to this Mac;
3. the user may either re-check after allowing synchronization to continue or knowingly continue with the currently available local history.

Keep the copy concise and reassuring.

Do not overstate certainty.

Do not claim that sparse history definitely means iCloud synchronization is incomplete.

The fact established by the Agent is only:

> the local Messages database currently contains 10 or fewer message rows.

The explanation may describe plausible implications, but it must remain truthful.

---

# 5. End that Trip with a real ChoiceStep

The terminal Step of the sparse-history guidance Trip must be a generic persisted `ChoiceStep`.

Use exactly two options.

Conceptually:

```text
value = "recheck"
label = "Re-check"
destination =
    determine_messages_source_history_sufficiency
```

and:

```text
value = "import_anyway"
label = "Import Anyway"
destination =
    confirm_messages_source_history_accepted
```

The actual value strings may follow existing authoring conventions, but preserve the approved durable-value / mutable-label distinction.

Do not use labels as routing keys.

Do not expose Trip IDs to presentation.

Do not add Onboarding-specific button logic.

---

# 6. Preserve the generic runtime boundary

When the user selects:

```text
Re-check
```

the runtime should see only:

```text
ChoiceValue("recheck")
```

and Presence should resolve the configured destination from the current persisted `ChoiceStep`.

When the user selects:

```text
Import Anyway
```

the runtime should see only:

```text
ChoiceValue("import_anyway")
```

and Presence should resolve the configured destination.

Onboarding must not be consulted at runtime to translate either value into a Trip.

There should be no code like:

```text
if choice == recheck
    goTo(historyTestTrip)
```

inside Onboarding presentation or runtime integration.

The rods already live in `presence.db`.

---

# 7. Confirm destination semantics

The successful history-sufficiency branch and the explicit Import Anyway branch must converge on the same semantic result:

```text
confirm_messages_source_history_accepted
```

That Trip means:

> either sufficient history was found, or the human explicitly accepted continuing despite sparse history.

Do not create two confirmation Trips unless current workflow semantics genuinely require different user-facing copy.

Prefer one canonical convergence point.

---

# 8. Re-check loop

The Re-check branch must loop back to the history test Trip:

```text
guide_sparse_or_unsynced_messages_source
    ChoiceStep
        recheck
            -> determine_messages_source_history_sufficiency
```

This is an ordinary configured route.

Do not add:

- retry state;
- loop count;
- retry object;
- special remediation mode;
- Boolean persistence.

Each re-entry performs a fresh Agent evaluation.

That is the point.

---

# 9. Trip-granular restart behavior

Preserve current restart semantics.

If the user quits while inside the sparse-history guidance Trip before making a choice:

```text
restart
    -> sparse-history guidance Trip
    -> Step 1
```

The explanatory TellSteps repeat before the ChoiceStep is shown again.

If the user selects Re-check and the destination checkpoint commits:

```text
restart
    -> history-sufficiency test Trip
```

If the user selects Import Anyway and the checkpoint commits:

```text
restart
    -> confirmation Trip
```

Do not persist current Step or pending Choice.

---

# 10. Generic Presence presentation only

The active workflow should now render the Choice through the permanent generic Presence presenter created in Slice 4.

Do not add any Onboarding widget for:

```text
Re-check
Import Anyway
```

Do not add workflow-specific button style.

Do not add semantic interpretation of:

```text
recheck
import_anyway
```

to Presence presentation.

The real workflow should prove that the generic presenter is sufficient.

---

# 11. Existing FDA-specific presentation remains unchanged

Do not use this slice to clean up:

```text
OpenFdaSettingsStep
FdaSettingsOpeningAuthority
```

That remains separate debt.

Do not create ActionStep.

Do not broaden generic presentation based on FDA behavior.

This slice is about the history-sufficiency branch only.

---

# 12. Development source substitution

The existing development-only Contacts substitution must remain unchanged.

If there is already a safe development seam for controlling the Messages-history count, use it only if it naturally exists.

Do not modify the real `chat.db`.

Do not introduce a production test hook.

If manual sparse-history testing requires a disposable source database, follow existing development/test-source patterns and keep that seam explicitly development-only.

---

# 13. Topology generation

The active Onboarding topology should now include the new branch and loop.

Regenerate or update the existing topology artifact/mechanism if the project does this automatically.

The resulting conceptual structure should be visibly equivalent to:

```text
messages source readable
        |
        v
contacts source readable
        |
        v
messages history sufficient?
      /   \
    yes    no
    |       |
    |       v
    |   sparse-history guidance
    |       |
    |   ChoiceStep
    |     /    \
    | recheck   import anyway
    |    |           |
    |    +-----------|----+
    |                |    |
    +----------------+    |
          |               |
          v               |
    history test <--------+
          |
          | true / accepted
          v
    required-sources/history confirmation
```

Adjust for the actual surrounding workflow order.

The important part is:

```text
Test false
    -> guidance
    -> Choice
        recheck -> Test
        import anyway -> confirmation
```

---

# 14. Persistence fixture / workflow writer

Update the canonical Onboarding workflow-definition writer so the new Trip and Steps are persisted in `presence.db`.

Use the generic Choice persistence already implemented.

Do not hand-write special SQL for Choice routing if the workflow writer already has generic definition support.

The workflow author should supply:

```text
label
value
destination
position
```

and let generic Presence persistence do the rest.

---

# 15. Migration / existing databases

Determine how the current project updates an existing development/production `presence.db` when canonical workflow definitions change.

Use the established workflow-definition migration/update mechanism.

Do not:

- delete existing schedule runs casually;
- destroy trace history;
- reset production state merely because the definition expanded.

If the current workflow-definition model requires a versioned canonical-definition update, implement the smallest consistent change.

If a live run can be structurally invalidated by inserting Trips into the Schedule, explicitly analyze that before writing.

Preserve the current production data folder and its run state.

If this cannot be done safely within the existing mechanism, stop and report before changing production workflow persistence.

---

# 16. Existing-run safety

This point matters.

Inspect what happens if an existing Onboarding `ScheduleRun` currently points to a Trip occurrence in the old definition.

Adding new Trip occurrences must not make the existing checkpoint ambiguous or point it at the wrong semantic Trip.

Prove that stable occurrence identity / canonical update behavior remains correct.

If the project currently recreates occurrences during definition replacement, do not assume old `currentTripOccurrenceId` remains valid.

Investigate and test.

The success criterion is:

> An existing valid Onboarding run remains resumable after the definition update, or there is an explicit safe migration for it.

Do not paper over this with a reset.

---

# 17. Focused workflow tests

Add tests proving at least:

### Sufficient history

Agent returns true:

```text
history test
    -> confirmation
```

No sparse guidance appears.

### Sparse history

Agent returns false:

```text
history test
    -> sparse guidance
    -> ChoiceStep
```

### Re-check

Select:

```text
recheck
```

Prove:

```text
-> history test Trip
-> Agent evaluates freshly again
```

### Import Anyway

Select:

```text
import_anyway
```

Prove:

```text
-> confirmation Trip
```

### Fresh fact after loop

First evaluation:

```text
false
```

second evaluation after Re-check:

```text
true
```

Prove the workflow escapes to confirmation.

No stale Boolean is reused.

### Repeated false

Prove:

```text
false
-> guidance
-> recheck
-> false
-> guidance
```

works as repeated ordinary routing.

### Restart in guidance

Quit before choice.

Restart at guidance Trip Step 1.

### Restart after Re-check checkpoint

Restart at history test Trip.

### Restart after Import Anyway checkpoint

Restart at confirmation Trip.

### Presentation boundary

Prove Onboarding has no runtime routing callback translating choice values.

### Generic presenter

Prove the real ChoiceStep projects/render through Presence presentation.

---

# 18. Existing workflow regressions

Re-run and preserve all existing real Onboarding behaviors:

- Messages source unreadable path;
- FDA remediation;
- restart after FDA settings;
- Messages source verification;
- Contacts source unreadable path;
- Contacts remediation;
- restart inside Contacts guidance;
- Contacts verification;
- final confirmation path.

The new history-sufficiency concern must be inserted without regressing any proven branch.

---

# 19. Manual development experiment

If practical, perform or prepare a deterministic manual experiment with a disposable Messages source.

Desired cases:

### Case A — sufficient history

```text
count > 10
```

Expected:

```text
history test passes
-> confirmation
```

### Case B — sparse history

```text
count <= 10
```

Expected:

```text
guidance
-> Re-check / Import Anyway
```

Then verify:

```text
Re-check
-> fresh test
```

and:

```text
Import Anyway
-> confirmation
```

Do not modify the user's real Messages database.

If manual execution is not appropriate in this slice, document the exact procedure for the human to run.

---

# 20. Trace expectations

Use the existing universal trace.

For Re-check, expect ordinary route history equivalent to:

```text
history-test
-> sparse-guidance
-> history-test
```

For Import Anyway:

```text
history-test
-> sparse-guidance
-> confirmation
```

Do not add Choice-specific trace fields.

Do not make trace authoritative.

---

# 21. Documentation

Create:

`17-ONBOARDING-MESSAGES-HISTORY-CHOICE-WORKFLOW-IMPLEMENTATION.md`

Document:

1. previous active topology;
2. new Trips and Steps;
3. canonical Agent ID used;
4. exact Choice values and labels;
5. routing topology;
6. how Re-check obtains a fresh fact;
7. restart behavior;
8. existing-run migration/update safety;
9. confirmation that generic Presence presentation renders the Choice;
10. confirmation that Onboarding performs no runtime value-to-Trip translation;
11. manual experiment procedure/result;
12. tests;
13. deviations from Document 12 or prior implementation records.

Update:

- `00-START-HERE.md`
- package index
- `DOCUMENTATION_PASS_LOG.md`
- relevant Onboarding workflow/topology documentation.

Do not rewrite unrelated historical documents.

---

# 22. Verification

Run:

- focused history-choice workflow tests;
- Choice domain tests;
- Choice persistence tests;
- Choice runtime tests;
- generic Presence presentation tests;
- complete Presence/development-harness tests;
- complete Onboarding tests;
- migration/update tests for existing Schedule definitions/runs;
- architecture tripwires;
- `flutter analyze`;
- formatting;
- `git diff --check`.

Run code generation only if canonical workflow-definition changes require generated artifacts.

Run the macOS app/build if this active workflow integration touches production application compilation.

---

# Hard constraints

Do not in Slice 5:

- alter the history sufficiency threshold;
- duplicate source-count SQL;
- introduce an Onboarding-specific Choice renderer;
- expose destinations to presentation;
- add runtime value-to-Trip translation in Onboarding;
- add retry/loop abstractions;
- persist selected ChoiceValue;
- persist current Step;
- change Trip-granular restart semantics;
- add Choice-specific trace;
- add ActionStep;
- redesign FDA settings;
- add presentation metadata;
- parse ChoiceValue semantics in Presence;
- modify the real Messages database;
- reset existing production Onboarding runs without explicit proof that it is necessary and safe.

If existing-run migration cannot be made safe within the current definition-update architecture, stop and report before proceeding.

---

# Success criterion

At the end of Slice 5, real Onboarding can truthfully do this:

```text
Test local Messages history

    sufficient
        -> continue

    sparse
        -> explain

        -> ChoiceStep

            "Re-check"
                value = recheck
                -> test local Messages history again

            "Import Anyway"
                value = import_anyway
                -> continue
```

and the runtime ownership remains:

```text
Onboarding
    authored the workflow meaning

TestAgent
    establishes the fresh count fact

Presence presentation
    shows the generic labels

human
    selects one option

Presence execution
    receives only ChoiceValue
    resolves stored geometry
    checkpoints destination
```

There should be no special “sparse history interaction” mechanism anywhere.

It should look, to Presence, like nothing more remarkable than another TestStep, two TellSteps, and a ChoiceStep.

Stop after Slice 5 and report before any further Onboarding expansion.
