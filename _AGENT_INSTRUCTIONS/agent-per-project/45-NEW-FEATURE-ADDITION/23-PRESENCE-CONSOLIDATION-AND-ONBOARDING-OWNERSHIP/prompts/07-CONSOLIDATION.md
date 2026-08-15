Good. I’d make this a **consolidation/audit pass only**: verify the permanent shape, remove transitional debris that is now clearly obsolete, and stop before ActionStep design.

Perform a **post-Slice-4 consolidation audit** of the Presence/TestAgent work.

Do not add new abstractions.

Do not implement `ActionStep`.

Do not change production onboarding.

The purpose is to verify that the four completed slices have actually produced the intended permanent architecture, identify and remove transitional debris that is now clearly obsolete, and leave the repository in a coherent state before we consider the next concept.

---

## Read first

Read the consolidation package in order:

- `00-START-HERE.md`
- `01-CURRENT-OWNERSHIP-INVENTORY.md`
- `02-TARGET-OWNERSHIP-PROPOSAL.md`
- `03-FIRST-MECHANICAL-MOVES.md`
- `04-GENERIC-TESTSTEP-AND-OPAQUE-AGENT-RESOLUTION-PROPOSAL.md`
- `05-GENERIC-TEST-AGENT-CONTRACTS-IMPLEMENTATION.md`
- `06-GENERIC-TESTSTEP-ADDITIVE-SCHEMA-IMPLEMENTATION.md`
- `07-GENERIC-TESTSTEP-RUNTIME-CUTOVER-IMPLEMENTATION.md`
- `08-ONBOARDING-TEST-AGENT-COMPOSITION-IMPLEMENTATION.md`

Also inspect the current code, especially:

```text
lib/essentials/presence/
lib/essentials/onboarding/
lib/features/presence_iteration_simple/
```

and the current relevant tests.

Do not treat the documentation as automatically correct if current code differs.

---

## Governing architecture to verify

The intended permanent model is now:

```text
Presence
    owns:
        Schedule
        Trip
        generic Step machinery
        TestStep
        TestAgentId
        TestAgent
        TestAgentResolver
        generic persistence/reconstruction
        routing
        checkpointing
        runs
        trace

Onboarding
    owns:
        onboarding Schedule meaning
        onboarding copy
        stable onboarding TestAgentIds
        concrete onboarding TestAgents/adapters
        onboarding TestAgent bindings
        remediation decisions

Specialists
    own:
        chat.db probing
        Address Book discovery/readability
        macOS/platform expertise

Application composition
    owns:
        combining TestAgentBinding contributions
        constructing ImmutableTestAgentResolver

Development harness
    owns:
        manual Step progression
        source substitution
        diagrams
        trace display
        live visualization
```

The blank-stare invariant remains:

> Presence may know that a TestStep invokes an opaque TestAgent and maps true/false to destinations. Presence must not know what the test means.

---

## 1. Repository-wide verification

Audit all active Presence code for remaining onboarding-specific knowledge.

Search for active references to concepts such as:

```text
FDA
Full Disk Access
Messages source readiness
Contacts source readiness
Address Book
chat.db
MacosFullDiskAccess
Onboarding
```

Classify each occurrence as:

```text
A. legitimate migration/history evidence
B. legitimate documentation/test fixture
C. current known transitional debt
D. accidental active dependency that should now be removed
```

Do not remove migration evidence merely because a string is domain-specific.

---

## 2. Verify generic Test path

Trace the complete current runtime path from persisted definition to execution:

```text
presence.db
    -> step_definitions.type = test
    -> test_step_definitions
    -> TestAgentId
    -> TestAgentResolver
    -> TestAgent
    -> TestStep
    -> TripDefinitionId?
    -> Trip
    -> Scheduler
```

Document the actual current file/method chain.

Verify explicitly that:

- no test-specific domain branch remains in active repository reconstruction;
- no workflow-specific test authority is required by generic Presence;
- TestStep contains no onboarding meaning;
- Scheduler remains unaware of TestStep semantics;
- Trip remains unaware of Agent semantics.

---

## 3. Verify persistence cleanup

Audit schema v8 and repository integrity handling.

Confirm:

```text
test_agent_definitions
test_step_definitions
```

are current active truth for Boolean tests.

Confirm old:

```text
fda_test_step_definitions
contacts_source_readiness_step_definitions
```

are genuinely frozen migration evidence and not consulted during active reconstruction.

Identify whether any code paths still write to those old tables.

If active writes remain accidentally possible, remove or mechanically prohibit them if this can be done without deleting historical data or changing migration semantics.

Do not drop the tables in this pass.

---

## 4. Verify Onboarding ownership

Audit `lib/essentials/onboarding/`.

Confirm it now clearly owns:

- the required-sources Schedule definition;
- onboarding TestAgent IDs;
- Messages TestAgent;
- Contacts TestAgent;
- TestAgent binding contribution;
- onboarding copy and route decisions;
- FDA remediation composition.

Identify any current onboarding-owned code still stranded in:

```text
features/presence_iteration_simple
essentials/presence
```

that can now be moved mechanically without conceptual redesign.

Move only files whose ownership is now unambiguous.

Do not move development harness code into Onboarding merely because it exercises Onboarding.

---

## 5. Verify specialist ownership

Confirm the concrete expertise remains with the correct specialist owner.

For example:

```text
SqliteChatDbSourceProbeReader
AddressBookFolderRepository
MacosFullDiskAccess
```

must not have migrated into Presence.

Check that onboarding TestAgents delegate rather than duplicate specialist logic.

If duplicate SQL/path/discovery logic has appeared during the refactor, remove that duplication and restore delegation.

---

## 6. Verify application composition

Trace where:

```text
TestAgentBinding contributions
    -> ImmutableTestAgentResolver
```

are currently assembled.

The current development composition root is expected to be:

```text
presenceExperimentTestAgentResolverProvider
```

Verify:

- it is clearly application/client composition, not a Presence service locator;
- Presence does not import its clients;
- future workflow owners could contribute additional bindings without changing Presence;
- duplicate binding failure remains mechanical;
- resolver remains immutable.

Document whether this current composition point is permanent enough for development or still obviously experimental.

Do not invent a new global composition framework unless the current structure genuinely fails.

---

## 7. Retire clearly obsolete transitional code

Now that generic TestStep composition is complete, search for obsolete transitional artifacts from Slices 1–4.

Candidates may include:

- dead specialized test Step code;
- retired readiness-authority files;
- unused provider exports;
- compatibility helpers no longer referenced;
- stale test fixtures that teach the pre-generic model;
- outdated comments/docstrings;
- obsolete feature-level provider exports.

Delete or move only things that are demonstrably dead.

Preserve:

- migration code;
- frozen schema evidence;
- historical documentation;
- tests that prove migration continuity.

Do not perform aesthetic cleanup unrelated to this architecture.

---

## 8. Reassess `step.dart`

Inspect the current Step domain model.

The desired conceptual shape should now be close to:

```text
Step
    TellStep
    FixedDestinationStep
    TestStep
    OpenFdaSettingsStep   <- known transitional debt
```

Verify whether the file organization still makes sense.

If `step.dart` has become too mixed, propose or perform a mechanical split into generic Step files only if it clearly improves ownership/readability without behavior change.

Do not generalize `OpenFdaSettingsStep`.

Do not invent `ActionStep`.

---

## 9. Reassess Presence public API

Audit:

```text
lib/essentials/presence/feature_level_providers.dart
```

and other public seams.

Confirm the public API exposes generic Presence concepts rather than onboarding-specific test concepts.

Remove stale exports/imports left by the old specialized test model.

Do not broaden the public API unnecessarily.

---

## 10. Architecture tests

Strengthen or simplify architecture tripwires so they protect the final intended boundary rather than historical transitional names.

At minimum prove:

```text
Presence does not import Onboarding.

Generic TestAgent/TestStep files do not import:
    Conversation Graph
    Address Book
    macOS onboarding infrastructure
    Flutter presentation

Onboarding may import generic Presence contracts.

Specialist source readers do not import Presence routing/Scheduler machinery.

Development harness may depend on Presence and Onboarding,
but neither depends on the harness.
```

Remove obsolete tripwires protecting code that no longer exists.

---

## 11. Documentation reconciliation

Review the current Presence database guides and consolidation docs for stale transitional language.

Update current-facing docs so a future reader sees the final generic Test architecture first.

Preserve historical implementation records as history.

The current mental model should be explainable as:

```text
presence.db stores:
    Test Agent identities
    Test Steps that reference them

runtime composition supplies:
    actual TestAgent objects

Presence joins the two by TestAgentId
without knowing what the Agent does
```

---

## 12. Known remaining debt

At the end of the audit, identify every remaining domain-specific concept inside generic Presence.

Expected known item:

```text
OpenFdaSettingsStep
FdaSettingsOpeningAuthority
```

Do not assume this is the only one; verify.

For each remaining item classify:

```text
earned generic concept pending
temporary tolerated debt
migration/history only
actual ownership violation
```

---

## 13. Do not solve ActionStep yet

Do not generalize `OpenFdaSettingsStep`.

Do not add:

```text
ActionStep
ActionAgent
Agent supertype
generic operation result
```

This pass should only leave a clean statement of the remaining problem.

If the audit concludes that `OpenFdaSettingsStep` is the sole active domain-specific debt, record that clearly.

---

## 14. Deliverable

Create:

`09-PRESENCE-TESTSTEP-CONSOLIDATION-AUDIT.md`

Structure:

1. **Executive result**
2. **Final generic Test runtime path**
3. **Presence ownership audit**
4. **Onboarding ownership audit**
5. **Specialist ownership audit**
6. **Application composition audit**
7. **Persistence and migration-evidence audit**
8. **Transitional code retired**
9. **Public API cleanup**
10. **Architecture-tripwire state**
11. **Documentation reconciliation**
12. **Remaining domain-specific debt**
13. **Files deliberately left unchanged**
14. **Verification**
15. **Recommended next architectural question**

Update:

- `00-START-HERE.md`
- package index
- `DOCUMENTATION_PASS_LOG.md`

---

## 15. Verification

Run:

- complete Presence tests;
- complete Onboarding tests;
- development harness tests;
- migration/schema tests;
- architecture tripwires;
- `flutter analyze`;
- formatting;
- code generation only if required by actual code changes;
- macOS Debug build if imports/providers moved;
- Mermaid regeneration;
- `git diff --check`.

---

## Hard constraints

Do not:

- change `presence.db` schema;
- alter TestStep semantics;
- alter resolver semantics;
- alter onboarding Schedule topology;
- alter onboarding copy;
- add new onboarding blockers;
- add ActionStep;
- add Agent supertype;
- integrate Presence into production OnboardingGate;
- delete historical migration evidence;
- rewrite run/trace history.

---

## Success criterion

At the end of this pass we should be able to say:

```text
The generic Boolean Test architecture is complete and coherent.

Presence knows:
    TestStep
    TestAgentId
    TestAgent
    resolver
    Boolean routing

Onboarding knows:
    what the tests mean
    which Agents to bind
    where results lead

Specialists know:
    how to establish the facts

The development harness knows:
    how to observe and perturb the workflow

No obsolete transitional test machinery remains active.
```

And the report should answer explicitly:

> If we now ask Presence what the Messages-readiness TestAgent actually does, can it answer?

The required answer is:

```text
No.
```

Stop after the consolidation audit and report back before ActionStep design or production onboarding integration.
